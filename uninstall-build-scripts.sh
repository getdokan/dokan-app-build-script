#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'
NOT_INSTALL_STATUS=0

if [[ -f /usr/local/bin/config-android ]]; then
  echo -e "${BLUE}==> Removing Dokan Android app configuration script${NC}"
  rm /usr/local/bin/config-android
  echo -e "${GREEN}Done!${NC}"
else
  NOT_INSTALL_STATUS=$((NOT_INSTALL_STATUS+1))
  echo -e "${GREEN}Android configuration script is not installed${NC}"
fi

if [[ -f /usr/local/bin/build-android ]]; then
  echo -e "${BLUE}==> Removing Dokan Android app build script${NC}"
  rm /usr/local/bin/build-android
  echo -e "${GREEN}Done!${NC}"
else
  NOT_INSTALL_STATUS=$((NOT_INSTALL_STATUS+1))
  echo -e "${GREEN}Android build script is not installed${NC}"
fi

if [[ -f /usr/local/bin/config-ios ]]; then
  echo -e "${BLUE}==> Removing Dokan iOS app configuration script${NC}"
  rm /usr/local/bin/config-ios
  echo -e "${GREEN}Done!${NC}"
else
  NOT_INSTALL_STATUS=$((NOT_INSTALL_STATUS+1))
  echo -e "${GREEN}iOS configuration script is not installed${NC}\n"
fi

if [[ $NOT_INSTALL_STATUS == 0 ]]
then
  echo "******************************************"
  echo "* Successfully Removed Dokan App Scripts! *"
  echo "*******************************************"
fi

if [[ $NOT_INSTALL_STATUS == 3 ]]
then
  echo -e "${RED}Dokan App build scripts are not installed! To install these scripts run the follwoing command in your terminal\n${NC}"
  echo -e "wget -O - https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/setup.sh | bash\n"
fi
