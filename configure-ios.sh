#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Vars
CONFIG_FILE="./src/common/Config.js"
APP_NAME=
PACKAGE_NAME=
SITE_URL=
WC_KEY=
WC_SECRET=
FB_APP_ID=
IC_LAUNCHER=
SPLASH_IMAGE=
UPDATE_STRING=
tmp=$(mktemp) # to hold values of buildScript.json changed by jq temporarily, before writing to actual file

function usage() {
    printf "\n"
    echo -e "Dokan iOS app configuration script.\n"

    echo -e "  [--app-name=<name>]${GREEN}(required)${NC}"
    echo -e "\tName of the app\n"

    echo -e "  [--package-name=<name>]${GREEN}(required)${NC}"
    echo -e "\tUnique package name for your app e.g com.wedevs.dokan or com.dokan\n"

    echo -e "  [--site-url=<url>]${GREEN}(required)${NC}"
    echo -e "\tWebsite url e.g. https://wedevs.com\n"

    echo -e "  [--wc-key=<key>]${GREEN}(required)${NC}"
    echo -e "\tWoocommerce consumer key\n"

    echo -e "  [--wc-secret=<key>]${GREEN}(required)${NC}"
    echo -e "\tWoocommerce consumer secret\n"

    echo -e "  [--fb-app-id=<key>]${GREEN}(required)${NC}"
    echo -e "\tFacbook App ID\n"

    echo -e "  [--launcher-icon=<path>]${GREEN}(required)${NC}"
    echo -e "\tAbsolute Path to launcher icon image /path/to/laucnher.png\n"

    echo -e "  [--splash-image=<path>]${GREEN}(required)${NC}"
    echo -e "\tAbsolute Path to splash image /path/to/splash.png\n"

    echo -e "  [--update=<update-key>]${GREEN}(optional)${NC}"
    echo -e "\tSingle or comma separated update keys. Available keys are \"siteUrl\", \"wcKeys\", \"fbId\", \"iconSet\", \"splashSet\"\n"
}

# Execute with no args
if [[ "$1" == "" ]]; then
    usage
    exit 1
fi

while [ "$1" != "" ]; do
    PARAM=$(echo $1 | awk -F= '{print $1}')
    VALUE=$(echo $1 | awk -F= '{print $2}')
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
    --update)
        UPDATE_STRING=$VALUE
        ;;
    *)
        echo -e "\n${RED}ERROR: unknown parameter${NC} \"$PARAM\""
        usage
        exit 1
        ;;
    esac
    shift
done

# Validate supplied args
if [[ "$APP_NAME" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--app-name] is required\n"
    exit 1
elif [[ "$PACKAGE_NAME" == "" && "$UPDATE_STRING" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--package-name] is required\n"
    exit 1
elif [[ "$SITE_URL" == "" && "$UPDATE_STRING" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--site-url] is required\n"
    exit 1
elif [[ "$WC_KEY" == "" && "$UPDATE_STRING" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--wc-key] is required\n"
    exit 1
elif [[ "$WC_SECRET" == "" && "$UPDATE_STRING" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--wc-secret] is required\n"
    exit 1
elif [[ "$FB_APP_ID" == "" && "$UPDATE_STRING" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--fb-app-id] is required\n"
    exit 1
elif [[ "$IC_LAUNCHER" == "" && "$UPDATE_STRING" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--launcher-icon] is required\n"
    exit 1
elif [[ "$SPLASH_IMAGE" == "" && "$UPDATE_STRING" == "" ]]; then
    echo -e "\n${RED}ERROR: ${NC}[--splash-image] is required\n"
    exit 1
fi

# UPDATE_STRING array for updating multiple values all at once
if [[ $UPDATE_STRING == *[,]* ]]; then
    IFS=','
    read -a updateStrArr <<<"$UPDATE_STRING"
    unset IFS
fi

# Creat new project if not exists
if [[ ! -d "$APP_NAME" ]]; then
    echo -e "${BLUE}==> Creating new project...${NC}"
    git clone -b upgrade-rn59 git@bitbucket.org:wedevs/dokan-app.git "$APP_NAME"
    cd "$APP_NAME"
    react-native-rename "$APP_NAME" -b "$PACKAGE_NAME"
    grep -rl 'com.wedevs.dokan' ./ios | xargs sed -i '' "s/com.wedevs.dokan/$PACKAGE_NAME/g"
    jq '.iosRename=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
else
    echo -e "${GREEN}Existing project found${NC}\n"
    echo -e "${BLUE}==> Renaming iOS bundle...${NC}"
    cd "$APP_NAME"
    iosRename=$(jq -r '.iosRename' buildScript.json)
    if [[ "$iosRename" == "false" ]]; then
        grep -rl 'com.wedevs.dokan' ./ios | xargs sed -i '' "s/com.wedevs.dokan/$PACKAGE_NAME/g"
        echo -e "${GREEN}Done!${NC}"
        jq '.iosRename=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
    else
        echo -e "${GREEN}iOS project is already renamed!${NC}"
    fi
fi

# install PODS
echo -e "${BLUE}==> Installing Pods...${NC}"
iosPods=$(jq -r '.iosPods' buildScript.json)
if [[ "$iosPods" == "false" ]]; then
    cd ios
    pod install
    cd ..
    jq '.iosPods=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
else
    echo -e "${GREEN}Pods are already installed!${NC}"
fi

# Replace site url
echo -e "${BLUE}==> Setting Site URL...${NC}"
siteUrl=$(jq -r '.siteUrl' buildScript.json)
if [[ "$siteUrl" == "false" ]]; then
    PREV_URL=$(awk -F "url:" '{print $2}' src/common/Config.js | tr -d '\n')
    sed -i '' "s|$PREV_URL|$SITE_URL|g" "$CONFIG_FILE"
    echo -e "${GREEN}Done!${NC}"
elif [[ "$siteUrl" == "true" && "$UPDATE_STRING" == "siteUrl" || "${updateStrArr[@]}" =~ "siteUrl" ]]; then
    PREV_URL=$(awk -F "url:" '{print $2}' src/common/Config.js | tr -d '\n')
    sed -i '' "s|$PREV_URL|$SITE_URL|g" "$CONFIG_FILE"
    echo -e "${GREEN}Site URL is updated!${NC}"
else
    echo -e "${GREEN}Site URL is already configured!${NC}"
fi

# Replace woocommerce values
echo -e "${BLUE}==> Setting WooCommerce API keys...${NC}"
wcKeys=$(jq -r '.wcKeys' buildScript.json)
if [[ "$wcKeys" == "false" ]]; then
    sed -i '' 's/\(consumerKey:\)\(.*\)/\1'"$WC_KEY,"'/' "$CONFIG_FILE"
    sed -i '' 's/\(consumerSecret:\)\(.*\)/\1'"$WC_SECRET,"'/' "$CONFIG_FILE"
    echo -e "${GREEN}Done!${NC}"
    jq '.wcKeys=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
elif [[ "$wcKeys" == "true" && "$UPDATE_STRING" == "wcKeys" || "${updateStrArr[@]}" =~ "wcKeys" ]]; then
    sed -i '' 's/\(consumerKey:\)\(.*\)/\1'"$WC_KEY,"'/' "$CONFIG_FILE"
    sed -i '' 's/\(consumerSecret:\)\(.*\)/\1'"$WC_SECRET,"'/' "$CONFIG_FILE"
    echo -e "${GREEN}WooCommerce API keys are updated!${NC}"
else
    echo -e "${GREEN}WooCommerce API keys are already configured!${NC}"
fi

# Replace Facebook App id and url schemes
echo -e "${BLUE}==> Setting Facebook App ID...${NC}"
iosFbId=$(jq -r '.iosFbId' buildScript.json)
FB_URL_SCHEME="fb$FB_APP_ID"
if [ "$iosFbId" == "false" ]; then
    plutil -replace FacebookAppID -string $FB_APP_ID "ios/$APP_NAME/Info.plist"
    sed -i '' 's/\(fb[0-9]*\)/'"$FB_URL_SCHEME"'/' "ios/$APP_NAME/Info.plist"
    echo -e "${GREEN}Done!${NC}"
    jq '.iosFbId=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
elif [[ "$iosFbId" == "true" && "$UPDATE_STRING" == "fbId" || "${updateStrArr[@]}" =~ "fbId" ]]; then
    plutil -replace FacebookAppID -string $FB_APP_ID "ios/$APP_NAME/Info.plist"
    sed -i '' 's/\(fb[0-9]*\)/'"$FB_URL_SCHEME"'/' "ios/$APP_NAME/Info.plist"
    echo -e "${GREEN}Facebook App Id is updated${NC}"
else
    echo -e "${GREEN}Facebook App Id is already configured!${NC}"
fi

# Generate app icon and splash image set
echo -e "${BLUE}==> Generating icon set...${NC}"
if [[ -f "$IC_LAUNCHER" ]]; then
    iosIcon=$(jq -r '.iosIcon' buildScript.json)
    if [[ "$iosIcon" == "false" ]]; then
        find "./ios/$APP_NAME/Images.xcassets" -type f -name 'launch-icon-*' | while read -r icon; do
            size=$(convert "$icon" -print '%wx%h^' /dev/null)
            cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" "$icon"
            echo -e "\t$icon"
        done
        jq '.iosIcon=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
        echo -e "${GREEN}Done!${NC}"
    elif [[ "$iosIcon" == "true" && "$UPDATE_STRING" == "iconSet" || "${updateStrArr[@]}" =~ "iconSet" ]]; then
        find "./ios/$APP_NAME/Images.xcassets" -type f -name 'launch-icon-*' | while read -r icon; do
            size=$(convert "$icon" -print '%wx%h^' /dev/null)
            cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" "$icon"
            echo -e "\t$icon"
        done
        echo -e "${GREEN}Icon set is updated!${NC}"
    else
        echo -e "${GREEN}Icon set is already generated!${NC}"
    fi
elif [[ ! -f $IC_LAUNCHER && "$UPDATE_STRING" != "" ]]; then
    echo -e "${GREEN}Icon set is already generated!${NC}"
else
    echo -e "${RED}Icon image not found! Set icon image path correctly and try again${NC}"
    exit 1
fi

echo -e "${BLUE}==> Generating splash image set...${NC}"
if [[ -f "$SPLASH_IMAGE" ]]; then
    iosSplash=$(jq -r '.iosSplash' buildScript.json)
    if [[ "$iosSplash" == "false" ]]; then
        find "./ios/$APP_NAME/Images.xcassets" -type f -name 'Default-*' | while read -r splash; do
            size=$(convert "$splash" -print '%wx%h^' /dev/null)
            cp "$SPLASH_IMAGE" "$splash" && convert "$splash" -resize "$size" -background none -gravity center -extent "$size" "$splash"
            echo -e "\t$splash"
        done
        jq '.iosSplash=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
        echo -e "${GREEN}Done!${NC}"
    elif [[ "$iosSplash" == "true" && "$UPDATE_STRING" == "splashSet" || "${updateStrArr[@]}" =~ "splashSet" ]]; then
        find "./ios/$APP_NAME/Images.xcassets" -type f -name 'Default-*' | while read -r splash; do
            size=$(convert "$splash" -print '%wx%h^' /dev/null)
            cp "$SPLASH_IMAGE" "$splash" && convert "$splash" -resize "$size" -background none -gravity center -extent "$size" "$splash"
            echo -e "\t$splash"
        done
        echo -e "${GREEN}Splash image set is updated!${NC}"
    else
        echo -e "${GREEN}Splash image set is already generated!${NC}"
    fi
elif [[ ! -f $SPLASH_IMAGE && "$UPDATE_STRING" != "" ]]; then
    echo -e "${GREEN}Splash image set is already generated!${NC}"
else
    echo -e "${RED}Splash image not found! Check splash image path correctly and try again${NC}"
fi

echo -e "${BLUE}==> Installing dependencies...${NC}"
yarn install

echo -e "${GREEN}\n$APP_NAME iOS is sucessfully configured and is ready to be built!!${NC}"
