#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'


set -e  # Exit immediately if a command exits with a non-zero status.

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --app-name=*)
      APP_NAME="${1#*=}"
      shift
      ;;
    --version=*)
      VERSION="${1#*=}"
      shift
      ;;
    --package-name=*)
      PACKAGE_NAME="${1#*=}"
      shift
      ;;
    --site-url=*)
      SITE_URL="${1#*=}"
      shift
      ;;
    --launcher-icon=*)
      LAUNCHER_ICON="${1#*=}"
      shift
      ;;
    --splash-image=*)
      SPLASH_IMAGE="${1#*=}"
      shift
      ;;
    --splash-bg-color=*)
      SPLASH_BG_COLOR="${1#*=}"
      shift
      ;;
    --google-services-json=*)
      GOOGLE_SERVICES_JSON="${1#*=}"
      shift
      ;;
    # --google-service-plist=*)
    #   GOOGLE_SERVICE_PLIST="${1#*=}"
    #   shift
    #   ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Validate arguments
MISSING_ARGS=()

[[ -z "$APP_NAME" ]] && MISSING_ARGS+=("App Name")
[[ -z "$VERSION" ]] && MISSING_ARGS+=("Version")
[[ -z "$PACKAGE_NAME" ]] && MISSING_ARGS+=("Package Name")
[[ -z "$SITE_URL" ]] && MISSING_ARGS+=("Site URL")
[[ -z "$LAUNCHER_ICON" ]] && MISSING_ARGS+=("Launcher Icon")
[[ -z "$SPLASH_IMAGE" ]] && MISSING_ARGS+=("Splash Image")
[[ -z "$SPLASH_BG_COLOR" ]] && MISSING_ARGS+=("Splash Background Color")
[[ -z "$GOOGLE_SERVICES_JSON" ]] && MISSING_ARGS+=("Google Services JSON")

if [[ ${#MISSING_ARGS[@]} -ne 0 ]]; then
  echo -e "${RED}The following required arguments are missing:${NC}"
  for ARG in "${MISSING_ARGS[@]}"; do
    echo -e "- $ARG${NC}"
  done
  echo -e "${BLUE}Please provide them and try again.${NC}"
  exit 1
fi

# Variables
REPO_URL="https://github.com/getdokan/mobile-app-customer"  # Replace with your repository URL
OUTPUT_DIR="$(pwd)/output_file"  # Absolute path for output directory
TEMP_DIR="$APP_NAME"
BRANCH_NAME="diff_splash"

# Clean up temporary files on exit
trap "rm -rf '$TEMP_DIR'" EXIT

# Clone the repository
echo "Cloning repository..."
rm -rf "$TEMP_DIR"
git clone --branch "$BRANCH_NAME" "$REPO_URL" "$TEMP_DIR"
cd "$TEMP_DIR"



echo "${GREEN}Updating app name, package name, and iOS bundle ID in configs/env.properties..."
ENV_FILE="configs/env.properties"
if [[ -f "$ENV_FILE" ]]; then
  sed -i.bak "s/^appName=.*/appName=$APP_NAME/" "$ENV_FILE" || echo "appName=$APP_NAME" >> "$ENV_FILE"
  sed -i.bak "s/^androidPackageName=.*/androidPackageName=$PACKAGE_NAME/" "$ENV_FILE" || echo "androidPackageName=$PACKAGE_NAME" >> "$ENV_FILE"
  sed -i.bak "s/^iosBundleId=.*/iosBundleId=$PACKAGE_NAME/" "$ENV_FILE" || echo "iosBundleId=$PACKAGE_NAME" >> "$ENV_FILE"
  sed -i.bak "s/^iosBundleIdOneSignal=.*/iosBundleIdOneSignal=${PACKAGE_NAME}.onesignal/" "$ENV_FILE" || echo "iosBundleIdOneSignal=${PACKAGE_NAME}.onesignal" >> "$ENV_FILE"
  sed -i.bak "s/^iosAppGroups=.*/iosAppGroups=group.${PACKAGE_NAME}.onesignal/" "$ENV_FILE" || echo "iosAppGroups=group.${PACKAGE_NAME}.onesignal" >> "$ENV_FILE"
  sed -i.bak "s/^iosMerchantId=.*/iosMerchantId=merchant.${PACKAGE_NAME}/" "$ENV_FILE" || echo "iosMerchantId=merchant.${PACKAGE_NAME}" >> "$ENV_FILE"
  rm -f "$ENV_FILE.bak"  # Remove backup file created by sed
else
  echo "Error: $ENV_FILE not found."
  exit 1
fi


echo "Updating server config data in lib/env.dart..."
ENV_DART_FILE="lib/env.dart"
if [[ -f "$ENV_DART_FILE" ]]; then
  # Remove trailing slash from SITE_URL if present
  SITE_URL="${SITE_URL%/}"
  sed -i.bak "s|\"url\": \".*\"|\"url\": \"$SITE_URL\"|" "$ENV_DART_FILE"
  rm -f "$ENV_DART_FILE.bak"  # Remove backup file created by sed
else
  echo "Error: $ENV_DART_FILE not found."
  exit 1
fi

# Update app configuration
echo "Updating app configuration..."
SED_CMD="sed -i"
[[ "$OSTYPE" == "darwin"* ]] && SED_CMD="sed -i ''"

$SED_CMD "s/^version: .*/version: $VERSION/" pubspec.yaml

# Update app_config_options.yaml with splash background color
echo "Updating app_config_options.yaml with splash background color..."
APP_CONFIG_FILE="app_config_options.yaml"
if [[ -f "$APP_CONFIG_FILE" ]]; then
  $SED_CMD "s/color: \".*\"/color: \"$SPLASH_BG_COLOR\"/" "$APP_CONFIG_FILE"
  $SED_CMD "s/color_ios: \".*\"/color_ios: \"$SPLASH_BG_COLOR\"/" "$APP_CONFIG_FILE"
  $SED_CMD "s/android_12:\n    color: \".*\"/android_12:\n    color: \"$SPLASH_BG_COLOR\"/" "$APP_CONFIG_FILE"
else
  echo "Error: $APP_CONFIG_FILE not found."
  exit 1
fi


# Replaceing google services json and plist
echo "Replacing google services json..."
cp "$GOOGLE_SERVICES_JSON" configs/google-services.json
# cp "$GOOGLE_SERVICE_PLIST" configs/GoogleService-Info.plist


# Replace launcher icon and splash image
echo "Replacing assets $LAUNCHER_ICON and $SPLASH_IMAGE..."
cp "$LAUNCHER_ICON" configs/app_icon/app_icon.png
cp "$SPLASH_IMAGE" configs/app_icon/app_splash.png

# # Build the app bundle
# echo "Building the app bundle...$(pwd)"
flutter clean
flutter pub get && cd ios && pod install && cd ..
dart run flutter_launcher_icons -f app_config_options.yaml
dart run flutter_native_splash:create --path=app_config_options.yaml

# Clean up any files ending with ''
echo "Cleaning up temporary files..."
find . -type f -name "*''" -exec rm -f {} +