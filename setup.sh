#!/bin/bash

if [ ! -f /usr/local/bin/config-android ]; then
    printf "\n"
    echo "Installing Dokan Android app configuration script"
    printf "\n"
    wget -qO /usr/local/bin/config-android https://bitbucket.org/wedevs/dokan-app-build-script/raw/daa7080a854e6740ff2bf2becd09570b4b604c57/build-android.sh

    # Executable permission
    chmod a+x /usr/local/bin/config-android

    echo "Done!"
fi

if [ ! -f /usr/local/bin/build-android ]; then
    printf "\n"
    echo "Installing Dokan Android app build script"
    printf "\n"
    wget -qO /usr/local/bin/build-android https://bitbucket.org/wedevs/dokan-app-build-script/raw/daa7080a854e6740ff2bf2becd09570b4b604c57/configure-android.sh

    # Executable permission
    chmod a+x /usr/local/bin/build-android

    echo "Done!"
fi

echo "******************************"
echo "* Finished Installation! *"
echo "******************************"