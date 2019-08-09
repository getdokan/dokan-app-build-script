#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==> Installing Dokan Android app configuration script${NC}"
if [[ ! -f /usr/local/bin/config-android ]]; then
  wget -qO /usr/local/bin/config-android https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/configure-android.sh
  # Executable permission
  chmod a+x /usr/local/bin/config-android
  echo -e "${GREEN}Done!${NC}"
else
  echo -e "${GREEN}Android configuration script is already installed${NC}"
fi

echo -e "${BLUE}==> Installing Dokan Android app build script${NC}"
if [[ ! -f /usr/local/bin/build-android ]]; then
  wget -qO /usr/local/bin/build-android https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/build-android.sh
  # Executable permission
  chmod a+x /usr/local/bin/build-android
  echo -e "${GREEN}Done!${NC}"
else
  echo -e "${GREEN}Android build script is already installed${NC}"
fi

echo -e "${BLUE}==> Installing Dokan iOS app configuration script${NC}"
if [ ! -f /usr/local/bin/config-ios ]; then
  wget -qO /usr/local/bin/config-ios https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/configure-ios.sh
  # Executable permission
  chmod a+x /usr/local/bin/config-ios
  echo -e "${GREEN}Done!${NC}"
else
  echo -e "${GREEN}iOS configuration script is already installed${NC}\n"
fi

echo "**************************"
echo "* Finished Installation! *"
echo "**************************"
