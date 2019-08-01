#!/bin/bash

# Colors
BLUE='\033[0;34m'
RED='\033[31m'
NC='\033[0m'

# Variables
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
cd "$APP_NAME/ios"
# react-native-rename "$APP_NAME" -b "$PACKAGE_NAME"
find . -name 'Dokan*' -print0 | xargs -0 rename --subst-all 'Dokan' "$APP_NAME"
find . -name 'Dokan*' -print0 | xargs -0 rename --subst-all 'Dokan' "$APP_NAME"
find . -name 'com.wedevs.dokan' -print0 | xargs -0 rename --subst-all 'com.wedevs.dokan' "$PACKAGE_NAME"
find . -name 'dokan*'
ack --literal --files-with-matches 'Dokan' --print0 | xargs -0 sed -i '' "s/Dokan/$APP_NAME/g"
ack --literal 'Dokan'

if [ ! -d "$APP_NAME" ]
then
    echo -e "${BLUE}Creating new project.....${NC}"
    git clone -b upgrade-rn59 git@bitbucket.org:wedevs/dokan-app.git "$APP_NAME"
    cd "$APP_NAME/ios"
    react-native-rename "$APP_NAME" -b "$PACKAGE_NAME"
    find . -name 'Dokan*' -print0 | xargs -0 rename --subst-all 'Dokan' "$APP_NAME"
    find . -name 'Dokan*' -print0 | xargs -0 rename --subst-all 'Dokan' "$APP_NAME"
    find . -name 'com.wedevs.dokan' -print0 | xargs -0 rename --subst-all 'com.wedevs.dokan' "$PACKAGE_NAME"
    find . -name 'dokan*'
    ack --literal --files-with-matches 'Dokan' --print0 | xargs -0 sed -i '' "s/Dokan/$APP_NAME/g"
    ack --literal 'Dokan'
else
    echo -e "${BLUE}Existing project found\n${NC}"
    echo -e "${BLUE}Renaming iOS projetc.....\n${NC}"
    cd "$APP_NAME/ios"
    find . -name 'Dokan*' -print0 | xargs -0 rename --subst-all 'Dokan' "$APP_NAME"
    find . -name 'Dokan*' -print0 | xargs -0 rename --subst-all 'Dokan' "$APP_NAME"
    find . -name 'com.wedevs.dokan' -print0 | xargs -0 rename --subst-all 'com.wedevs.dokan' "$PACKAGE_NAME"
    find . -name 'dokan*'
    ack --literal --files-with-matches 'Dokan' --print0 | xargs -0 sed -i '' "s/Dokan/$APP_NAME/g"
    ack --literal 'Dokan'
fi


# echo -e "${BLUE}Setting up configurations.....${NC}"
# Replace woocommerce values
# PREV_URL=$(awk -F "url:" '{print $2}' src/common/Config.js | tr -d '\n')
# sed -i '' "s|$PREV_URL|$SITE_URL|g" "$CONFIG_FILE"
# sed -i '' 's/\(consumerKey:\)\(.*\)/\1'"$WC_KEY,"'/' "$CONFIG_FILE"
# sed -i '' 's/\(consumerSecret:\)\(.*\)/\1'"$WC_SECRET,"'/' "$CONFIG_FILE"