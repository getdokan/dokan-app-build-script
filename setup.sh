#!/bin/bash

if [ ! -f /usr/local/bin/config-android ]; then
    printf "\n"
    echo "Installing Dokan Android app configuration script"
    printf "\n"
    wget -qO /usr/local/bin/config-android https://github.com/weDevsOfficial/dokan-app-build-script/blob/master/configure-android.sh

    # Executable permission
    chmod a+x /usr/local/bin/config-android

    echo "Done!"
fi

if [ ! -f /usr/local/bin/build-android ]; then
    printf "\n"
    echo "Installing Dokan Android app build script"
    printf "\n"
    wget -qO /usr/local/bin/build-android https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/build-android.sh

    # Executable permission
    chmod a+x /usr/local/bin/build-android

    echo "Done!"
fi

echo "**************************"
echo "* Finished Installation! *"
echo "**************************"