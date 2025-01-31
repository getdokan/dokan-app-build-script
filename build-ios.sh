#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e  # Exit on error

# Function to validate required arguments
validate_args() {
    local MISSING_ARGS=()
    
    # Comment out the lines below to avoid required validation
    [[ -z "$VERSION" ]] && MISSING_ARGS+=("Version")
    [[ -z "$PACKAGE_NAME" ]] && MISSING_ARGS+=("Package Name")
    [[ -z "$APP_STORE_CONNECT_API_KEY_P8" ]] && MISSING_ARGS+=("App Store Connect API Key P8 File")
    [[ -z "$APP_STORE_CONNECT_API_KEY_KEY_ID" ]] && MISSING_ARGS+=("Appstore Connect API Key ID")
    [[ -z "$APP_STORE_CONNECT_API_KEY_ISSUER_ID" ]] && MISSING_ARGS+=("Appstore Connect API Key Issuer ID")

    if [[ ${#MISSING_ARGS[@]} -ne 0 ]]; then
        echo -e "${RED}Missing required arguments:${NC}"
        for ARG in "${MISSING_ARGS[@]}"; do
            echo "- $ARG"
        done
        exit 1
    fi
}

# Parse command-line arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --version=*) VERSION="${1#*=}" ;;
            --package-name=*) PACKAGE_NAME="${1#*=}" ;;
            --app-store-connect-api-key-p8=*) APP_STORE_CONNECT_API_KEY_P8="${1#*=}" ;;
            --app-store-connect-api-key-id=*) APP_STORE_CONNECT_API_KEY_KEY_ID="${1#*=}" ;;
            --app-store-connect-api-key-issuer-id=*) APP_STORE_CONNECT_API_KEY_ISSUER_ID="${1#*=}" ;;
            *) 
                echo "Unknown argument: $1"
                exit 1 
                ;;
        esac
        shift
    done
}

# Update environment properties
update_env_properties() {
    echo "Updating global env..."
    local ENV_FILE="configs/env.properties"
    
    # Ensure file exists
    [[ ! -f "$ENV_FILE" ]] && { echo "Error: $ENV_FILE not found."; exit 1; }
    
    # Update properties
    sed -i.bak "s/^iosBundleId=.*/iosBundleId=$PACKAGE_NAME/" "$ENV_FILE"
    sed -i.bak "s/^iosBundleIdOneSignal=.*/iosBundleIdOneSignal=${PACKAGE_NAME}.onesignal/" "$ENV_FILE"
    sed -i.bak "s/^iosAppGroups=.*/iosAppGroups=group.${PACKAGE_NAME}.onesignal/" "$ENV_FILE"
    sed -i.bak "s/^iosMerchantId=.*/iosMerchantId=merchant.${PACKAGE_NAME}/" "$ENV_FILE"
    
    rm -f "$ENV_FILE.bak"
}

# Update app configuration files
update_app_config() {
    echo "Updating app configuration..."
    local PUBSPEC_FILE="pubspec.yaml"
    SED_CMD="sed -i"
    [[ "$OSTYPE" == "darwin"* ]] && SED_CMD="sed -i ''"
    
    # Update version
    $SED_CMD "s/^version: .*/version: $VERSION/" $PUBSPEC_FILE
    
}

# Replace configuration files
replace_config_files() {
    echo -e "${BLUE}Updating configuration files...${NC}"
    local config_dir="configs"
    
    # Check if API key path is empty
    if [ -z "$APP_STORE_CONNECT_API_KEY_P8" ]; then
        echo -e "${RED}Error: API key path is empty${NC}"
        exit 1
    fi
    
    # Check if API key file exists
    if [ ! -f "$APP_STORE_CONNECT_API_KEY_P8" ]; then
        echo -e "${RED}Error: API key file not found: $APP_STORE_CONNECT_API_KEY_P8${NC}"
        exit 1
    fi
    
    # Ensure config directory exists
    mkdir -p "$config_dir"
    
    # Copy API key file
    cp "$APP_STORE_CONNECT_API_KEY_P8" "$config_dir/app-store-connect-api-key.p8"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Configuration files updated successfully${NC}"
    else
        echo -e "${RED}Error updating configuration files${NC}"
        exit 1
    fi
}


update_fastlane_env_file_ios() {
    echo "Updating fastlane for ios..."

    local ENV_FILE="ios/fastlane/.env"
    local ENV_PROPS_FILE="configs/env.properties"
    
    # Ensure files exist
    [[ ! -f "$ENV_FILE" ]] && { echo "Error: $ENV_FILE not found."; exit 1; }

    # Extract env properties
    PACKAGE_NAME=$(grep "^iosBundleId=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    IOS_MERCHANT_ID=$(grep "^iosMerchantId=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    IOS_APP_GROUP=$(grep "^iosAppGroups=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    
    
    # Update apples required items for .env
    sed -i.bak "s|^APP_IDENTIFIER=.*|APP_IDENTIFIER=\"$PACKAGE_NAME\"|" "$ENV_FILE"
    sed -i.bak "s|^APP_STORE_CONNECT_API_KEY_KEY_ID=.*|APP_STORE_CONNECT_API_KEY_KEY_ID=\"$APP_STORE_CONNECT_API_KEY_KEY_ID\"|" "$ENV_FILE"
    sed -i.bak "s|^APP_STORE_CONNECT_API_KEY_ISSUER_ID=.*|APP_STORE_CONNECT_API_KEY_ISSUER_ID=\"$APP_STORE_CONNECT_API_KEY_ISSUER_ID\"|" "$ENV_FILE"
    sed -i.bak "s|^IOS_MERCHANT_ID=.*|IOS_MERCHANT_ID=\"$IOS_MERCHANT_ID\"|" "$ENV_FILE"
    sed -i.bak "s|^IOS_APP_GROUP=.*|IOS_APP_GROUP=\"$IOS_APP_GROUP\"|" "$ENV_FILE"
    
    rm -f "$ENV_FILE.bak"
}

# Cleanup function
cleanup() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Deployment configuration completed successfully!${NC}"
    else
        echo -e "${RED}Deployment configuration failed${NC}"
    fi
}

# Main execution
main() {
    # Register cleanup trap
    trap cleanup EXIT 

    # Parse and validate arguments
    parse_args "$@"
    # validate_args
    
    echo "Updating app configuration..."
    cd DokanCustomerApp

    # update_env_properties
    update_app_config
    replace_config_files

    update_fastlane_env_file_ios
    cd ios && rm -rf Podfile.lock && pod deintegrate && pod install && fastlane ios check_certificates && cd ..
    flutter build ios --debug --no-codesign
    cd ios && fastlane ios beta
    
    echo -e "${GREEN}App configuration updated successfully!${NC}"
}

# Run the script
main "$@"