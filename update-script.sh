#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'
NOT_INSTALL_STATUS=0

if [[ -f /usr/local/bin/config-customer-app ]]; then
  echo -e "${BLUE}==> Updating Customer app configuration script${NC}"
  rm /usr/local/bin/config-customer-app
  wget -qO /usr/local/bin/config-customer-app https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/dokan_cloud_customer/config-customer-app.sh
  # Executable permission
  chmod a+x /usr/local/bin/config-customer-app
  echo -e "${GREEN}Done!${NC}"
else
  NOT_INSTALL_STATUS=$((NOT_INSTALL_STATUS+1))
  echo -e "${GREEN}Customer app configuration script is not installed${NC}"
fi


if [[ $NOT_INSTALL_STATUS == 0 ]]; then
  echo "**********************************************************"
  echo "* Successfully updated Dokan Cloud Customer App Scripts! *"
  echo "**********************************************************"
fi