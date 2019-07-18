#!/bin/bash

# Colors
BLUE='\033[0;34m'
RED='\033[31m'
NC='\033[0m'

# Variables
FN=
LN=
L=
S=
C=
STORE_PASSWORD=
KEY_PASSWORD=

function usage() {
  echo -e "Android app signing and building script. All params are required\n"

  echo "  [--first-name=<name>]"
  echo -e "\tCommon name of a person, e.g., Susan\n"

  echo "  [--last-name=<name>]"
  echo -e "\tCommon name of a person, e.g., Jones\n"

  echo "  [--city=<name>]"
  echo -e "\tCity name, e.g., Palo Alto\n"

  echo "  [--state=<name>]"
  echo -e "\tState or province name, e.g., California\n"

  echo "  [--country=<key>]"
  echo -e "\t Two-letter country code, e.g., US\n"

  echo "  [--store-password=<key>]"
  echo -e "\t Store password for your keys\n"

  echo "  [--key-password=<key>]"
  echo -e "\t Password for the upload key. Can be same as store-password\n"
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    --first-name)
        FN=$VALUE
        ;;
    --last-name)
        LN=$VALUE
        ;;
    --city)
        C=$VALUE
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
    *)
    echo "ERROR: unknown parameter \"$PARAM\""
    usage
    exit 1
    ;;
  esac
  shift
done

# Execute with no args
if [ "$1" == "" ]; then
  usage
  exit 1
fi

# Validate supplied args number
if [ "$#" -ne 7 ]; then
  echo -e "${RED}All params were not supplied${NC}\n"
  usage
  exit 1
fi

CN="$FN $LN"

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

 # Move key store to android/app dir
 mv my-release-key.keystore android/app

 # Build the app
 cd android
 ./grdlew clean
 ./grdlew bundleRelease