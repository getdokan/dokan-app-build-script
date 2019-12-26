#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
GRADLE_PROP='./android/gradle.properties'
FN=
LN=
L=
S=
C=
STORE_PASSWORD=
KEY_PASSWORD=
UPDATE=

function usage() {
  printf "\n"
  echo -e "Android app signing and building script.\n"

  echo -e "  [--first-name=<name>]${GREEN}(required)${NC}"
  echo -e "\tFirst name of a person, e.g., John\n"

  echo -e "  [--last-name=<name>]${GREEN}(required)${NC}"
  echo -e "\tLast name of a person, e.g., Doe\n"

  echo -e "  [--city=<name>]${GREEN}(required)${NC}"
  echo -e "\tCity name, e.g., Palo Alto\n"

  echo -e "  [--state=<name>]${GREEN}(optional)${NC}"
  echo -e "\tState or province name, e.g., California or Omit if there is no state\n"

  echo -e "  [--country=<key>]${GREEN}(required)${NC}"
  echo -e "\tTwo-letter country code, e.g., US\n"

  echo -e "  [--store-password=<key>]${GREEN}(required)${NC}"
  echo -e "\tStore password for your keys\n"

  echo -e "  [--key-password=<key>]${GREEN}(required)${NC}"
  echo -e "\tPassword for the upload key. Can be same as store-password\n"

  echo -e "  [--update]${GREEN}(optional)${NC}"
  echo -e "\tFor a sequential build\n"
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
  --first-name)
    FN=$VALUE
    ;;
  --last-name)
    LN=$VALUE
    ;;
  --city)
    L=$VALUE
    ;;
  --state)
    S="$VALUE"
    ;;
  --country)
    C="$VALUE"
    ;;
  --store-password)
    STORE_PASSWORD="$VALUE"
    ;;
  --key-password)
    KEY_PASSWORD="$VALUE"
    ;;
  --update)
    UPDATE="yes"
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
if [[ "$FN" == "" && "$UPDATE" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--first-name] is required\n"
  exit 1
elif [[ "$LN" == "" && "$UPDATE" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--last-name] is required\n"
  exit 1
elif [[ "$L" == "" && "$UPDATE" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--city] is required\n"
  exit 1
elif [[ "$C" == "" && "$UPDATE" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--country] is required\n"
  exit 1
elif [[ "$STORE_PASSWORD" == "" && "$UPDATE" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--store-password] is required\n"
  exit 1
elif [[ "$KEY_PASSWORD" == "" && "$UPDATE" == "" ]]; then
  echo -e "\n${RED}ERROR: ${NC}[--key-password] is required\n"
  exit 1
fi

CN="$FN $LN"

if [[ "$UPDATE" == "yes" ]]; then
  cd android
  ./gradlew clean
  ./gradlew bundleRelease
  exit 1
fi

# Generate sigining keypair
keytool -genkeypair -noprompt \
  -alias my-key-alias \
  -dname "CN=$CN, L=$L, S=$S, C=$C" \
  -keystore my-release-key.keystore \
  -storepass "$STORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Replace gradle.properties with new Store Password and Key Password
sed -i '' 's/\(MYAPP_RELEASE_STORE_PASSWORD=\)\(.*\)/\1'"$STORE_PASSWORD"'/' "$GRADLE_PROP"
sed -i '' 's/\(MYAPP_RELEASE_KEY_PASSWORD=\)\(.*\)/\1'"$KEY_PASSWORD"'/' "$GRADLE_PROP"


# Generate Release Hash key for facbook login and write it to file
README_FILE="readme.txt";
PATH_TO_README=`pwd`/$file;

if [[ ! -f $PATH_TO_README ]]; then
  touch $PATH_TO_README;

  HASH=$(keytool -exportcert -noprompt \
    -alias my-key-alias \
    -keystore my-release-key.keystore \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" | openssl sha1 -binary | openssl base64)

  echo "Place the following code in your facebook developer portal. For detail instruction follow Dokan App documentation \n\n${HASH}" >> $fullpath;
fi

# Move key store to android/app dir
mv my-release-key.keystore android/app

# Build the app
cd android
./gradlew clean
./gradlew bundleRelease

# Create a zip file including the newly built app and readme.txt
mkdir download
cp app/build/outputs/bundle/release/app.aab download/ || exit "$?"
mv readme.txt download/
zip -r download.zip download || exit "$?"
rm -rf download

echo -e "${GREEN}\nAndroid app is successfully built. Downloadable is available at android/download.zip${NC}"

