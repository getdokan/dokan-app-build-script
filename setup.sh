#!/bin/bash

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==> Installing Dokan Cloud Customer app configuration script${NC}"
if [[ ! -f /usr/local/bin/config-customer-app ]]; then
  wget -qO /usr/local/bin/config-customer-app https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/dokan_cloud_customer/config-customer-app.sh
  # Executable permission
  chmod a+x /usr/local/bin/config-customer-app
  echo -e "${GREEN}Done!${NC}"
else
  echo -e "${GREEN}Configuration script is already installed${NC}"
fi


# Install "update-dokan-customer-app-scripts"
if [[ ! -f /usr/local/bin/update-dokan-customer-app-scripts ]]; then
  wget -qO /usr/local/bin/update-dokan-customer-app-scripts https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/dokan_cloud_customer/update-script.sh
  # Executable permission
  chmod a+x /usr/local/bin/update-dokan-customer-app-scripts
fi

# Install "uninstall-dokan-customer-app-scripts"
if [[ ! -f /usr/local/bin/uninstall-dokan-customer-app-scripts ]]; then
  wget -qO /usr/local/bin/uninstall-dokan-customer-app-scripts https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/dokan_cloud_customer/uninstall-build-scripts.sh
  # Executable permission
  chmod a+x /usr/local/bin/uninstall-dokan-customer-app-scripts
fi

echo "**************************"
echo "* Finished Installation! *"
echo "**************************"
