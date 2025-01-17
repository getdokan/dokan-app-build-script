#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'
NOT_INSTALL_STATUS=0

if [[ -f /usr/local/bin/config-customer-app ]]; then
  echo -e "${BLUE}==> Removing Dokan Android app configuration script${NC}"
  rm /usr/local/bin/config-customer-app
  echo -e "${GREEN}Done!${NC}"
else
  NOT_INSTALL_STATUS=$((NOT_INSTALL_STATUS+1))
  echo -e "${GREEN}Customer app configuration script is not installed${NC}"
fi



if [[ $NOT_INSTALL_STATUS == 0 ]]
then
  echo "**********************************************************"
  echo "* Successfully Removed Dokan Cloud Customer App Scripts! *"
  echo "**********************************************************"
fi

if [[ $NOT_INSTALL_STATUS == 3 ]]
then
  echo -e "${RED}Dokan App build scripts are not installed! To install these scripts run the follwoing command in your terminal\n${NC}"
  echo -e "wget -O - https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/setup.sh | bash\n"
fi