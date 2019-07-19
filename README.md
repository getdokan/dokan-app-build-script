# Dokan App Build Scripts

A commandline tool for building customized Dokan App for a marketplace.

Quick Links: [Dependencies](#dependencies) | [Installation](#installation) | [Usage](#usage)

## Dependencies

Before using these scripts, a development environment needs to be configured for building a React Native app in your Machine/Server. See "React Native CLI Quickstart" section in [React Native's Official Doc](https://facebook.github.io/react-native/docs/getting-started)

Additionally, the following tools need to be installed in your system

- [XMLStarlet](http://xmlstar.sourceforge.net/)
- [imagemagick](https://imagemagick.org/index.php)
- [react-native-rename](https://github.com/junedomingo/react-native-rename)

## Installation

Run this command in your terminal to install the build scripts.

`wget -O - https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/master/setup.sh | bash`

Test your installation by running any of `config-android` or `build-android` commands

## Usage

In your termial create a new directory like `mkdir "My Projects"` and `cd` into it or `cd` the directory where you want to save your projects. For convenience create an `assets` directory there and put the app icon and splash image inside the `assets` directory. It will be useful later on.

**Android:**

In two steps you can generate an [Android App Bundle](https://developer.android.com/guide/app-bundle). This is the new way of uploading android apps to Google Play Store. At first run `config-android`

It will list the parameters that are needed to be supplied with the command. The list is self explanatory and all the parameters are required.

```bash
Dokan android app configuration script. All params are required

  [--app-name=<name>]
    Name of the app

  [--package-name=<name>]
    Unique package name your app e.g com.wedevs.dokan or com.dokan

  [--site-url=<url>]
    Website url e.g. https://wedevs.com

  [--wc-key=<key>]
    Woocommerce consumer key

  [--wc-secret=<key>]
    Woocommerce consumer secret

  [--fb-app-id=<key>]
    Facbook App ID

  [--google-geo-key=<key>]
    Google maps API key

  [--laucher-icon=<path>]
    Path to  launcher icon image /path/to/laucnher.png

  [--splash-image=<path>]
    Path to splash image /path/to/splash.png
```

Now run the command as follows, replacing the placeholder values with the actual ones

```bash
  config-android --app-name=MyApp --package-name=com.exmaple.app --site-url=https://example.com --wc-key=somekey --wc-secret=somesecret --fb-app-id=facebookappid --google-geo-key=googlemapapikey --launcher-icon=path/to/laucnher.png --splash-image=path/to/splash.png
```

If there is spacing in the app name, surround the app name with double qoutes `--app-name="My App"` like this. If you have created an `assets` folder before and placed your launcher icon as `launcher.png` and splash image as `splash.png`, you can specify the launcher icon path and splash image path like this `--launcher-icon=assets/launcher.png` and `--splash-image=assets/splash.png`

This will create and prepare a new project.

Now run `build-android` to see the list of parameters. All the parameters are required here also.

```bash
  Android app signing and building script. All params are required

  [--first-name=<name>]
    Common name of a person, e.g., Susan

  [--last-name=<name>]
    Common name of a person, e.g., Jones

  [--city=<name>]
    City name, e.g., Palo Alto

  [--state=<name>]
    State or province name, e.g., California

  [--country=<key>]
    Two-letter country code, e.g., US

  [--store-password=<key>]
    Store password 'for' your keys

  [--key-password=<key>]
    Password for the upload key. Can be same as store-password
```

Now `cd MyApp` and run the following command

```bash
  build-android --first-name=John --last-name=Doe --city=LosAngeles --state=California --country=US --store-password=somepassword --key-password=somepassword
```

This will perform the [code signing](https://developer.android.com/studio/publish/app-signing) of the app and generate an `app.aab` inside `MyApp/android/app/build/outputs/bundle/release/` directory. Your new app has been built and is ready to be uploaded to Google Play Store.
