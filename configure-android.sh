#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Vars
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
STRIPE_PK=
ONE_SIGNAL_ID=
IC_LAUNCHER=
SPLASH_IMAGE=
UPDATE_STRING=
tmp=$(mktemp) # to hold values of buildScript.json changed by jq temporarily, before writing to actual file

function usage() {
  printf "\n"
  echo -e "Dokan Android app configuration script.\n"

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

  echo -e "  [--google-geo-key=<key>]${GREEN}(required)${NC}"
  echo -e "\tGoogle maps API key\n"

  echo -e "  [--stripe-pk=<key>]${GREEN}(required)${NC}"
  echo -e "\tStripe publishable key\n"

  echo -e "  [--onse-signal-id=<key>]${GREEN}(required)${NC}"
  echo -e "\tOneSignal App ID\n"

  echo -e "  [--launcher-icon=<path>]${GREEN}(required)${NC}"
  echo -e "\tPath to  launcher icon image /path/to/laucnher.png\n"

  echo -e "  [--splash-image=<path>]${GREEN}(required)${NC}"
  echo -e "\tPath to splash image /path/to/splash.png\n"

  echo -e "  [--update=<update-key>]${GREEN}(optional)${NC}"
  echo -e "\tSingle or comma separated update keys. Available keys are \"siteUrl\", \"wcKeys\", \"fbId\", \"geoKey\", \"stripePk\", \"oneSingalId\", \"iconSet\", \"splashSet\"\n"
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
  --google-geo-key)
    GOOGLE_GEO_KEY=$VALUE
    ;;
  --stripe-pk)
    STRIPE_PK=" '$VALUE',"
    ;;
  --one-signal-id)
    ONE_SIGNAL_ID=" '$VALUE',"
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
    echo "ERROR: unknown parameter \"$PARAM\""
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
elif [[ "$GOOGLE_GEO_KEY" == "" && "$UPDATE_STRING" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--google-geo-key] is required\n"
  exit 1
elif [[ "$STRIPE_PK" == "" && "$UPDATE_STRING" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--stripe-pk] is required\n"
  exit 1
elif [[ "$ONE_SIGNAL_ID" == "" && "$UPDATE_STRING" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--one-signal-id] is required\n"
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
fi

# Creat new project dir
if [[ ! -d "$APP_NAME" ]]; then
  echo -e "${BLUE}==> Creating new project...${NC}"
  git clone -b NewUpdate git@bitbucket.org:wedevs/dokan-app.git "$APP_NAME" || exit "$?"
  cd "$APP_NAME"
  react-native-rename "$APP_NAME" -b "$PACKAGE_NAME"
else
  echo -e "${GREEN}Existing project found\n${NC}"
  cd "$APP_NAME"
fi

# Replace site url
echo -e "${BLUE}==> Setting Site URL...${NC}"
siteUrl=$(jq -r '.siteUrl' buildScript.json)
if [[ "$siteUrl" == "false" ]]; then
  PREV_URL=$(awk -F "url:" '{print $2}' src/common/Config.js | tr -d '\n')
  sed -i '' "s|$PREV_URL|$SITE_URL|g" "$CONFIG_FILE"
  echo -e "${GREEN}Done!${NC}"
  jq '.siteUrl=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
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

# Replace facebook-app-id
echo -e "${BLUE}==> Setting Facebook App ID...${NC}"
androidFbId=$(jq -r '.androidFbId' buildScript.json)
if [[ "$androidFbId" == "false" ]]; then
  xmlstarlet ed --inplace -O -u "/resources/string[@name='facebook_app_id']" -v "$FB_APP_ID" "$ANDROID_STRINGS"
  xmlstarlet ed --inplace -O -u "/resources/string[@name='fb_login_protocol_scheme']" -v "fb$FB_APP_ID" "$ANDROID_STRINGS"
  xmlstarlet ed --inplace -O -u "/manifest/application/provider[@android:authorities]/@android:authorities" -v "com.facebook.app.FacebookContentProvider$FB_APP_ID" "$ANDROID_MANIFEST"
  jq '.androidFbId=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
  echo -e "${GREEN}Done!${NC}"
elif [[ "$androidFbId" == "true" && "$UPDATE_STRING" == "fbId" || "${updateStrArr[@]}" =~ "fbId" ]]; then
  xmlstarlet ed --inplace -O -u "/resources/string[@name='facebook_app_id']" -v "$FB_APP_ID" "$ANDROID_STRINGS"
  xmlstarlet ed --inplace -O -u "/resources/string[@name='fb_login_protocol_scheme']" -v "fb$FB_APP_ID" "$ANDROID_STRINGS"
  xmlstarlet ed --inplace -O -u "/manifest/application/provider[@android:authorities]/@android:authorities" -v "com.facebook.app.FacebookContentProvider$FB_APP_ID" "$ANDROID_MANIFEST"
  echo -e "${GREEN}Facebook App Id is updated${NC}"
else
  echo -e "${GREEN}Facebook App Id is already configured!${NC}"
fi

# Replace google-geo-key
echo -e "${BLUE}==> Setting Google Maps API key...${NC}"
androidGeoKey=$(jq -r '.androidGeoKey' buildScript.json)
if [[ "$androidGeoKey" == "false" ]]; then
  xmlstarlet ed --inplace -O -u "/resources/string[@name='google_api_key']" -v "$GOOGLE_GEO_KEY" "$ANDROID_STRINGS"
  jq '.androidGeoKey=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
  echo -e "${GREEN}Done!${NC}"
elif [[ "$androidGeoKey" == "true" && "$UPDATE_STRING" == "geoKey" || "${updateStrArr[@]}" =~ "geoKey" ]]; then
  xmlstarlet ed --inplace -O -u "/resources/string[@name='google_api_key']" -v "$GOOGLE_GEO_KEY" "$ANDROID_STRINGS"
  jq '.androidGeoKey=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
  echo -e "${GREEN}Google Map API key is updated!${NC}"
else
  echo -e "${GREEN}Google map API key is already configured!${NC}"
fi

# Replace Stripe Publishable_key
echo -e "${BLUE}==> Setting Stripe Publishable Key...${NC}"
stripePk=$(jq -r '.stripePk' buildScript.json)
if [[ "$stripePk" == "false" ]]; then
  sed -i '' 's/\(publishableKey:\)\(.*\)/\1'"$STRIPE_PK"'/' "$CONFIG_FILE"
  echo -e "${GREEN}Done!${NC}"
  jq '.stripePk=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
elif [[ "$stripePk" == "true" && "$UPDATE_STRING" == "stripePk" || "${updateStrArr[@]}" =~ "stripePk" ]]; then
  sed -i '' 's/\(publishableKey:\)\(.*\)/\1'"$STRIPE_PK"'/' "$CONFIG_FILE"
  echo -e "${GREEN}Stripe Publishable Key is updated!${NC}"
else
  echo -e "${GREEN}Stripe Publishable Key is already configured!${NC}"
fi

# Replace OneSignal App ID
echo -e "${BLUE}==> Setting OnseSignal App ID...${NC}"
oneSingalId=$(jq -r '.oneSingalId' buildScript.json)
if [[ "$oneSingalId" == "false" ]]; then
  sed -i '' 's/\(appID:\)\(.*\)/\1'"$ONE_SIGNAL_ID"'/' "$CONFIG_FILE"
  echo -e "${GREEN}Done!${NC}"
  jq '.oneSingalId=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
elif [[ "$oneSingalId" == "true" && "$UPDATE_STRING" == "oneSingalId" || "${updateStrArr[@]}" =~ "oneSingalId" ]]; then
  sed -i '' 's/\(appID:\)\(.*\)/\1'"$ONE_SIGNAL_ID"'/' "$CONFIG_FILE"
  echo -e "${GREEN}OnseSignal App ID is updated!${NC}"
else
  echo -e "${GREEN}OnseSignal App ID is already configured!${NC}"
fi

# Generate app icon and splash image set
echo -e "${BLUE}==> Generating icon set...${NC}"
if [[ -f $IC_LAUNCHER ]]; then
  androidIcon=$(jq -r '.androidIcon' buildScript.json)
  if [[ "$androidIcon" == "false" ]]; then
    find ./android/app/src -type f -name 'ic_launcher.*' | while read -r icon; do
      size=$(convert "$icon" -print '%wx%h^' /dev/null)
      cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" "$icon"
      echo -e "\t$icon"
    done
    find ./android/app/src -type f -name 'ic_launcher_round.*' | while read -r icon; do
      size=$(convert "$icon" -print '%wx%h^' /dev/null)
      cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" -vignette 0x0 "$icon"
      echo -e "\t$icon"
    done
    jq '.androidIcon=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
    echo -e "${GREEN}Done!${NC}"
  elif [[ "$androidIcon" == "true" && "$UPDATE_STRING" == "iconSet" || "${updateStrArr[@]}" =~ "iconSet" ]]; then
    find ./android/app/src -type f -name 'ic_launcher.*' | while read -r icon; do
      size=$(convert "$icon" -print '%wx%h^' /dev/null)
      cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" "$icon"
      echo -e "\t$icon"
    done
    find ./android/app/src -type f -name 'ic_launcher_round.*' | while read -r icon; do
      size=$(convert "$icon" -print '%wx%h^' /dev/null)
      cp "$IC_LAUNCHER" "$icon" && convert "$icon" -resize "$size" -background none -gravity center -extent "$size" -vignette 0x0 "$icon"
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
if [[ -f $SPLASH_IMAGE ]]; then
  androidSplash=$(jq -r '.androidSplash' buildScript.json)
  if [[ "$androidSplash" == "false" ]]; then
    find ./android/app/src -type f -name 'launch_screen.*' | while read -r splash; do
      size=$(convert "$splash" -print '%wx%h^' /dev/null)
      cp "$SPLASH_IMAGE" "$splash" && convert "$splash" -resize "$size" -background none -gravity center -extent "$size" "$splash"
      echo -e "\t$splash"
    done
    jq '.androidSplash=true' buildScript.json >"$tmp" && mv "$tmp" buildScript.json
    echo -e "${GREEN}Done!${NC}"
  elif [[ "$androidSplash" == "false" && "$UPDATE_STRING" == "splashSet" || "${updateStrArr[@]}" =~ "splashSet" ]]; then
    find ./android/app/src -type f -name 'launch_screen.*' | while read -r splash; do
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
  echo -e "${RED}Splash image not found! Set splash image path correctly and try again\n${NC}"
  exit 1
fi

echo -e "${BLUE}==> Installing dependencies...${NC}"
yarn install

echo -e "${GREEN}\n$APP_NAME Android is sucessfully configured and is ready to be built!!${NC}"
