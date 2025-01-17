
# Cloud Customer App Build Script Documentation

This documentation provides instructions for using the `build-customer-app.sh` script to build customized mobile applications.

## Overview

The script automates the process of building a custom mobile application with specified branding and configuration.


## Installation

Run this command in your terminal to install the build scripts.

`wget -O - https://raw.githubusercontent.com/weDevsOfficial/dokan-app-build-script/dokan_cloud_customer/setup.sh | bash`

Test your installation by running any of `config-customer-app` commands



## Required Parameters

All paths should be absolute paths.

| Parameter | Description | Example |
|-----------|-------------|---------|
| --app-name | The name of your application | `"My Custom App"` |
| --version | Version number of the app | `"1.0.0"` |
| --package-name | Application package identifier | `"com.company.appname"` |
| --site-url | URL for the application | `"https://example.com"` |
| --launcher-icon | Path to the app icon file | `"/Users/username/assets/icon.png"` |
| --splash-image | Path to the splash screen image | `"/Users/username/assets/splash.png"` |
| --splash-bg-color | Background color for splash screen | `"#FFFFFF"` |
| --google-services-json | Path to Google Services JSON file (Android) | `"/Users/username/google-services.json"` |
<!-- | --google-service-plist | Path to Google Service Plist file (iOS) | `"/Users/username/GoogleService-Info.plist"` | -->

## File Requirements

- Launcher Icon: Must be a PNG file
- Splash Image: Must be a PNG file

## Example Usage

## Permissions

Set the execute permission for the script:

```bash
chmod +x build-customer-app.sh
```

## Run

Run the script with the following options:

```bash
./config-customer-app.sh \
--app-name="<Your App Name>" \
--version="<App Version>" \
--package-name="<Package Name>" \
--site-url="<Site URL>" \
--launcher-icon="<Path to Launcher Icon>" \
--splash-image="<Path to Splash Image>" \
--splash-bg-color="<Splash Background Color>" \
--google-services-json="<Path to Google Services JSON>"
```