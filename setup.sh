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
  printf "\n"
  echo -e "Android configuration script is already installed\n"
fi

if [ ! -f /usr/local/bin/build-android ]
then
  printf "\n"
  echo -e "Installing Dokan Android app build script\n"

  wget -qO /usr/local/bin/build-android https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/build-android.sh

  # Executable permission
  chmod a+x /usr/local/bin/build-android

  echo -e "Done!\n"
else
  printf "\n"
  echo -e "Android build script is already installed\n"
fi

if [ ! -f /usr/local/bin/config-ios ]
then
  printf "\n"
  echo -e "Installing Dokan iOS app configuration script\n"
  wget -qO /usr/local/bin/config-ios https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/configure-ios.sh

  # Executable permission
  chmod a+x /usr/local/bin/config-android

  echo -e "Done!\n"
else
  printf "\n"
  echo -e "iOS configuration script is already installed\n"
fi

echo "**************************"
echo "* Finished Installation! *"
echo "**************************"