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
    [[ -z "$APP_NAME" ]] && MISSING_ARGS+=("App Name")
    [[ -z "$VERSION" ]] && MISSING_ARGS+=("Version")
    [[ -z "$PACKAGE_NAME" ]] && MISSING_ARGS+=("Package Name")
    [[ -z "$SITE_URL" ]] && MISSING_ARGS+=("Site URL")
    [[ -z "$LAUNCHER_ICON" ]] && MISSING_ARGS+=("Launcher Icon")
    [[ -z "$SPLASH_IMAGE" ]] && MISSING_ARGS+=("Splash Image")
    [[ -z "$SPLASH_BG_COLOR" ]] && MISSING_ARGS+=("Splash Background Color")
    [[ -z "$GOOGLE_SERVICES_JSON" ]] && MISSING_ARGS+=("Google Services JSON")
    [[ -z "$GOOGLE_CLOUD_SERVICE_KEY_JSON" ]] && MISSING_ARGS+=("Google Cloud Service Key JSON")
    # [[ -z "$APPLE_APPLICATION_SPECIFIC_PASSWORD" ]] && MISSING_ARGS+=("Apple Application Specific Password")

    if [[ ${#MISSING_ARGS[@]} -ne 0 ]]; then
        echo -e "${RED}Missing required arguments:${NC}"
        for ARG in "${MISSING_ARGS[@]}"; do
            echo "- $ARG"
        done
        exit 1
    fi
}

# Clone repository
clone_repository() {
    # Variables
    REPO_URL="git@github.com:getdokan/mobile-app-customer.git"  # Replace with your repository URL 
    OUTPUT_DIR="$(pwd)/output_file" # Absolute path for output directory
    TEMP_DIR="$APP_NAME"
    BRANCH_NAME="fast_lane_integration"

    # Clean up previous clones
    rm -rf "$TEMP_DIR"

    # Clone repository
    echo "${BLUE}Cloning repository from $REPO_URL (branch: $BRANCH_NAME)...${NC}"
    git clone --branch "$BRANCH_NAME" "$REPO_URL" "$TEMP_DIR"
    cd "$TEMP_DIR"
}

# Clean up function
cleanup() {
    # Remove temporary directory
    rm -rf "$TEMP_DIR"
}

# Parse command-line arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --app-name=*) APP_NAME="${1#*=}" ;;
            --version=*) VERSION="${1#*=}" ;;
            --package-name=*) PACKAGE_NAME="${1#*=}" ;;
            --site-url=*) SITE_URL="${1#*=}" ;;
            --launcher-icon=*) LAUNCHER_ICON="${1#*=}" ;;
            --splash-image=*) SPLASH_IMAGE="${1#*=}" ;;
            --splash-bg-color=*) SPLASH_BG_COLOR="${1#*=}" ;;
            --google-services-json=*) GOOGLE_SERVICES_JSON="${1#*=}" ;;
            --google-cloud-service-key-json=*) GOOGLE_CLOUD_SERVICE_KEY_JSON="${1#*=}" ;;
            --apple-application-specific-password=*) APPLE_APPLICATION_SPECIFIC_PASSWORD="${1#*=}" ;;
            --apple-id=*) APPLE_ID="${1#*=}" ;;
            --apple-team-name=*) APPLE_TEAM_NAME="${1#*=}" ;;
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
    sed -i.bak "s/^appName=.*/appName=$APP_NAME/" "$ENV_FILE"
    sed -i.bak "s/^androidPackageName=.*/androidPackageName=$PACKAGE_NAME/" "$ENV_FILE"
    sed -i.bak "s/^iosBundleId=.*/iosBundleId=$PACKAGE_NAME/" "$ENV_FILE"
    sed -i.bak "s/^iosBundleIdOneSignal=.*/iosBundleIdOneSignal=${PACKAGE_NAME}.onesignal/" "$ENV_FILE"
    sed -i.bak "s/^iosAppGroups=.*/iosAppGroups=group.${PACKAGE_NAME}.onesignal/" "$ENV_FILE"
    sed -i.bak "s/^iosMerchantId=.*/iosMerchantId=merchant.${PACKAGE_NAME}/" "$ENV_FILE"
    
    rm -f "$ENV_FILE.bak"
}

# Update Flutter environment dart file
update_flutter_env() {
    echo "Updating app env..."
    local ENV_DART_FILE="lib/env.dart"
    
    [[ ! -f "$ENV_DART_FILE" ]] && { echo "Error: $ENV_DART_FILE not found."; exit 1; }
    
    # Remove trailing slash from SITE_URL
    SITE_URL="${SITE_URL%/}"
    
    sed -i.bak "s|\"url\": \".*\"|\"url\": \"$SITE_URL\"|" "$ENV_DART_FILE"
    sed -i.bak "s|\"backgroundColor\": \".*\"|\"backgroundColor\": \"$SPLASH_BG_COLOR\"|" "$ENV_DART_FILE"
    
    rm -f "$ENV_DART_FILE.bak"
}

# Update app configuration files
update_app_config() {
    echo "Updating app configuration..."
    local PUBSPEC_FILE="pubspec.yaml"
    local APP_CONFIG_FILE="app_config_options.yaml"
    SED_CMD="sed -i"
    [[ "$OSTYPE" == "darwin"* ]] && SED_CMD="sed -i ''"
    
    # Update version
    $SED_CMD "s/^version: .*/version: $VERSION/" $PUBSPEC_FILE
    
    # Update splash config
    $SED_CMD "s/color: \".*\"/color: \"$SPLASH_BG_COLOR\"/" "$APP_CONFIG_FILE"
    $SED_CMD "s/color_ios: \".*\"/color_ios: \"$SPLASH_BG_COLOR\"/" "$APP_CONFIG_FILE"
    $SED_CMD "s/android_12:\n    color: \".*\"/android_12:\n    color: \"$SPLASH_BG_COLOR\"/" "$APP_CONFIG_FILE"
}

# Replace configuration files
replace_config_files() {
    echo "Updating files..."
    cp "$GOOGLE_SERVICES_JSON" configs/google-services.json
    cp "$LAUNCHER_ICON" configs/app_icon/app_icon.png
    cp "$SPLASH_IMAGE" configs/app_icon/app_splash.png
    cp "$GOOGLE_CLOUD_SERVICE_KEY_JSON" configs/google-cloud-service-key.json
}

update_fastlane_env_file_android() {
    echo "Updating fastlane for android..."
    # local ENV_FILE="configs/env.properties"
    local ENV_FILE="android/fastlane/.env"
    local ENV_PROPS_FILE="configs/env.properties"
    
    # Ensure files exist
    [[ ! -f "$ENV_FILE" ]] && { echo "Error: $ENV_FILE not found."; exit 1; }
    [[ ! -f "$ENV_PROPS_FILE" ]] && { echo "Error: $ENV_PROPS_FILE not found."; exit 1; }
    
    # # Extract package name from env.properties
    # PACKAGE_NAME=$(grep "^androidPackageName=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    
    # Get the filename of the Google Cloud Service Key JSON
    GOOGLE_CLOUD_JSON_FILENAME=$(basename "$GOOGLE_CLOUD_SERVICE_KEY_JSON")
    
    # Update package name and Google Cloud JSON path
    sed -i.bak "s|^ANDROID_PACKAGE_NAME=.*|ANDROID_PACKAGE_NAME=\"$PACKAGE_NAME\"|" "$ENV_FILE"
    sed -i.bak "s|^ANDROID_PLAY_JSON_KEY_PATH=.*|ANDROID_PLAY_JSON_KEY_PATH=\"../configs/$GOOGLE_CLOUD_JSON_FILENAME\"|" "$ENV_FILE"
    
    rm -f "$ENV_FILE.bak"
}

update_fastlane_env_file_ios() {
    echo "Updating fastlane for ios..."
    # local ENV_FILE="configs/env.properties"
    local ENV_FILE="ios/fastlane/.env"
    local ENV_PROPS_FILE="configs/env.properties"
    
    # Ensure files exist
    [[ ! -f "$ENV_FILE" ]] && { echo "Error: $ENV_FILE not found."; exit 1; }
    [[ ! -f "$ENV_PROPS_FILE" ]] && { echo "Error: $ENV_PROPS_FILE not found."; exit 1; }
    
    # Extract package name from env.properties
    PACKAGE_NAME=$(grep "^androidPackageName=" "$ENV_PROPS_FILE" | cut -d'=' -f2)
    
    # Update apples required items for .env
    sed -i.bak "s|^FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=.*|FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=\"$APPLE_APPLICATION_SPECIFIC_PASSWORD\"|" "$ENV_FILE"
    sed -i.bak "s|^APPLE_ID=.*|APPLE_ID=\"$APPLE_ID\"|" "$ENV_FILE"
    sed -i.bak "s|^APPLE_TEAM_NAME=.*|APPLE_TEAM_NAME=\"$APPLE_TEAM_NAME\"|" "$ENV_FILE"
    sed -i.bak "s|^APP_IDENTIFIER=.*|APP_IDENTIFIER=\"$PACKAGE_NAME\"|" "$ENV_FILE"
    
    rm -f "$ENV_FILE.bak"
}


# Main execution
main() {
    # Register cleanup trap
    trap cleanup EXIT

    # Parse and validate arguments
    parse_args "$@"
    validate_args

    # Clone repository
    clone_repository
    
    echo "Updating app configuration..."
    update_env_properties
    update_flutter_env
    update_app_config
    replace_config_files
    update_fastlane_env_file_android
    update_fastlane_env_file_ios
    
    # Prepare and clean app
    flutter clean
    flutter pub get
    cd ios && pod install && cd ..
    dart run flutter_launcher_icons -f app_config_options.yaml
    dart run flutter_native_splash:create --path=app_config_options.yaml
    
    echo -e "${GREEN}App configuration updated successfully!${NC}"
}

# Run the script
main "$@"