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
    [[ -z "$GOOGLE_SERVICES_JSON" ]] && MISSING_ARGS+=("Google Services JSON")
    [[ -z "$GOOGLE_CLOUD_SERVICE_KEY_JSON" ]] && MISSING_ARGS+=("Google Cloud Service Key JSON")

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
            --google-services-json=*) GOOGLE_SERVICES_JSON="${1#*=}" ;;
            --google-cloud-service-key-json=*) GOOGLE_CLOUD_SERVICE_KEY_JSON="${1#*=}" ;;
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
    echo "Updating global env for keystore..."

    local ENV_FILE="configs/env.properties"
    
    # Ensure file exists
    [[ ! -f "$ENV_FILE" ]] && { echo "Error: $ENV_FILE not found."; exit 1; }
    
    # Update properties
    sed -i.bak "s/^storePassword=.*/storePassword=wedevs_dokan/" "$ENV_FILE"
    sed -i.bak "s/^keyPassword=.*/keyPassword=wedevs_dokan/" "$ENV_FILE"
    sed -i.bak "s/^keyAlias=.*/keyAlias=upload/" "$ENV_FILE"
    
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
    echo "Updating files..."

    cp "$GOOGLE_SERVICES_JSON" configs/google-services.json
    cp "$GOOGLE_CLOUD_SERVICE_KEY_JSON" configs/google-cloud-service-key.json
}

# Generate keystore file
generate_keystore() {
    echo "Checking existing keystore..."

    local KEYSTORE_FILE="configs/upload-keystore.jks"
    local ENV_PROPS_FILE="configs/env.properties"

    # Ensure env files exist
    [[ ! -f "$ENV_PROPS_FILE" ]] && { echo "Error: $ENV_PROPS_FILE not found."; exit 1; }
    
    # Extract keystore properties
    KEYSTORE_ALIAS=$(grep "^keyAlias=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    KEYSTORE_PASSWORD=$(grep "^storePassword=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    KEY_PASSWORD=$(grep "^keyPassword=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    
    # Ensure keystore files exist
    if [[ ! -f "$KEYSTORE_FILE" ]]; then
        echo "Warning: $KEYSTORE_FILE not found. generating new keystore..."
        # Generate keystore
        keytool -genkey -v -keystore "$KEYSTORE_FILE" -alias "$KEYSTORE_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 -storepass "$KEYSTORE_PASSWORD" -keypass "$KEY_PASSWORD" -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=Unknown"
    fi
}

update_fastlane_env_file_android() {
    echo "Updating fastlane for android..."

    local ENV_FILE="android/fastlane/.env"
    local ENV_PROPS_FILE="configs/env.properties"
    
    # Ensure files exist
    [[ ! -f "$ENV_FILE" ]] && { echo "Error: $ENV_FILE not found."; exit 1; }

    # Extract env properties
    PACKAGE_NAME=$(grep "^androidPackageName=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    
    # Update package name and Google Cloud JSON path
    sed -i.bak "s|^ANDROID_PACKAGE_NAME=.*|ANDROID_PACKAGE_NAME=\"$PACKAGE_NAME\"|" "$ENV_FILE"
    
    rm -f "$ENV_FILE.bak"
}

# upload_first_app() {
#     fastlane supply \
#     --aab /Users/wedevs/dokan/dokan-app-build-script/DokanCustomerApp/build/app/outputs/bundle/release/app-release.aab \
#     --track internal \
#     --package_name "co.dokan.customer.test" \
#     --json-key /Users/wedevs/dokan/dokan-app-build-script/DokanCustomerApp/configs/google-cloud-service-key.json \
#     --release_status draft
# }

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
    
    update_env_properties
    update_app_config
    replace_config_files

    generate_keystore

    update_fastlane_env_file_android
    cd android && fastlane android beta
    
    echo -e "${GREEN}App configuration updated successfully!${NC}"
}

# Run the script
main "$@"