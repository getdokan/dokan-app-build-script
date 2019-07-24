#!/bin/bash

# Colors
BLUE='\033[0;34m'
RED='\033[31m'
NC='\033[0m'

# Variables
ANDROID_STRINGS="./android/app/src/main/res/values/strings.xml"
ANDROID_MANIFEST="./android/app/src/main/AndroidManifest.xml"
CONFIG_FILE="./src/common/Config.js"
APP_NAME=
PACKAGE_NAME=
SITE_URL=
WC_KEY=
WC_SECRET=
FB_APP_ID=
GOOGLE_GEO_KEY=
IC_LAUNCHER=
SPLASH_IMAGE=

function usage() {
  printf "\n"
  echo -e "Dokan android app configuration script. All params are required\n"

  echo "  [--app-name=<name>]"
  echo -e "\tName of the app\n"

  echo "  [--package-name=<name>]"
  echo -e "\tUnique package name for your app e.g com.wedevs.dokan or com.dokan\n"

  echo "  [--site-url=<url>]"
  echo -e "\tWebsite url e.g. https://wedevs.com\n"

  echo "  [--wc-key=<key>]"
  echo -e "\tWoocommerce consumer key\n"

  echo "  [--wc-secret=<key>]"
  echo -e "\tWoocommerce consumer secret\n"

  echo "  [--fb-app-id=<key>]"
  echo -e "\tFacbook App ID\n"

  echo "  [--google-geo-key=<key>]"
  echo -e "\tGoogle maps API key\n"

  echo "  [--launcher-icon=<path>]"
  echo -e "\tPath to  launcher icon image /path/to/laucnher.png\n"

  echo "  [--splash-image=<path>]"
  echo -e "\tPath to splash image /path/to/splash.png\n"
}

# Execute with no args
if [ "$1" == "" ]; then
  usage
  exit 1
fi

# Validate supplied args number
if [ "$#" -ne 9 ]; then
  echo -e "${RED}All params were not supplied${NC}\n"
  usage
  exit 1
fi

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    --app-name)
        APP_NAME=$VALUE
        ;;
    --package-name)
        PACKAGE_NAME=$VALUE
        ;;
    --site-url)
        SITE_URL=" '$VALUE',"
        ;;
    --wc-key)
        WC_KEY=" '$VALUE'"
        ;;
    --wc-secret)
        WC_SECRET=" '$VALUE'"
        ;;
    --fb-app-id)
        FB_APP_ID=$VALUE
        ;;
    --google-geo-key)
        GOOGLE_GEO_KEY=$VALUE
        ;;
    --launcher-icon)
        IC_LAUNCHER=$VALUE
        ;;
    --splash-image)
        SPLASH_IMAGE=$VALUE
        ;;
    *)
    echo "ERROR: unknown parameter \"$PARAM\""
    usage
    exit 1
    ;;
  esac
  shift
done

# Creat new project dir
echo -e "${BLUE}Creating new project.....${NC}"
git clone -b upgrade-rn59 git@bitbucket.org:wedevs/dokan-app.git "$APP_NAME"
cd "$APP_NAME"
react-native-rename "$APP_NAME" -b "$PACKAGE_NAME"

echo -e "${BLUE}Setting up configurations.....${NC}"
#Replace woocommerce values
PREV_URL=$(awk -F "url:" '{print $2}' src/common/Config.js | tr -d '\n')
sed -i '' "s|$PREV_URL|$SITE_URL|g" "$CONFIG_FILE"
sed -i '' 's/\(consumerKey:\)\(.*\)/\1'"$WC_KEY,"'/' "$CONFIG_FILE"
sed -i '' 's/\(consumerSecret:\)\(.*\)/\1'"$WC_SECRET,"'/' "$CONFIG_FILE"

# Replace facebook-app-id
xmlstarlet ed --inplace -O -u "/resources/string[@name='facebook_app_id']" -v "$FB_APP_ID" "$ANDROID_STRINGS"
xmlstarlet ed --inplace -O -u "/resources/string[@name='fb_login_protocol_scheme']" -v "fb$FB_APP_ID" "$ANDROID_STRINGS"
xmlstarlet ed --inplace -O -u "/manifest/application/provider[@android:authorities]/@android:authorities" -v "com.facebook.app.FacebookContentProvider$FB_APP_ID" "$ANDROID_MANIFEST"

# Replace google-geo-key
xmlstarlet ed --inplace -O -u "/resources/string[@name='google_api_key']" -v "$GOOGLE_GEO_KEY" "$ANDROID_STRINGS"

echo -e "${BLUE}Generating assets.....${NC}"
# Generate rectangular launcher icon set and move them to mipmaps
find ./android/app/src -type f -name 'ic_launcher.*' | while read -r icon; do
    size=`convert "$icon" -print '%wx%h^' /dev/null`
    cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" "$icon"
done

# Generate round launcher icon set and move them to mipmaps
find ./android/app/src -type f -name 'ic_launcher_round.*' | while read -r icon; do
    size=`convert "$icon" -print '%wx%h^' /dev/null`
    cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" -vignette 0x0 "$icon"
done

# Generate splash image set and move them to drawables
find ./android/app/src -type f -name 'launch_screen.*' | while read -r splash; do
    size=`convert "$splash" -print '%wx%h^' /dev/null`
    cp "$SPLASH_IMAGE" "$splash" && convert "$splash" -resize "$size" -background none -gravity center -extent "$size" "$splash"
done


echo -e "${BLUE}Installing dependencies.....${NC}"
yarn install

echo "$APP_NAME is sucessfully configured and is ready to be built!!"