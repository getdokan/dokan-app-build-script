#!/bin/bash

if [ ! -f /usr/local/bin/config-android ]
then
  printf "\n"
  echo -e "Installing Dokan Android app configuration script\n"
  wget -qO /usr/local/bin/config-android https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/configure-android.sh

  # Executable permission
  chmod a+x /usr/local/bin/config-android

  echo -e "Done!\n"
else
  echo -e "Android configuration script is already installed\n"
fi

if [ ! -f /usr/local/bin/build-android ]
then
  echo -e "Installing Dokan Android app build script\n"

  wget -qO /usr/local/bin/build-android https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/build-android.sh

  # Executable permission
  chmod a+x /usr/local/bin/build-android

  echo -e "Done!\n"
else
  echo -e "Android build script is already installed\n"
fi

echo "**************************"
echo "* Finished Installation! *"
echo "**************************"