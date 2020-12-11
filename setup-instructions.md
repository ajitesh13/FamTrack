# Setup instructions

Setup instructions to set up both backend [`Node.js server`] and frontend [`Flutter app`].

## Flutter App | Front-End
---


## Prerequisites
- Android Studio or any `IDE` to open Flutter project
- `JDK`

## Installations

1) Install `Flutter` by following instructions from [flutter.dev](flutter.dev). To summarise:
    - Select the appropriate operating system
    - Download the flutter sdk to a preferred location on your local system.

2) Fork and clone the `FamTrack repository` to your local machine.

3) Make sure to install the `Flutter` and `Dart` plugins.
    - If FamTrack is the first flutter project that you will be viewing in Android Studio then:
        - Start Android Studio
        - Open Plugin Preferences
        - Browse repositories and search for flutter
        - Install and click yes to install Dart as well if prompted.
    - Flutter and dart can also be installed after opening a project.
        - Go to File menu -> Settings -> plugins
        - Search for the plugin. In this case it would be Flutter and Dart. Install them if not done yet and click Apply.

## Local Development Setup

 This section will help you set up the project locally on your system.

 1. Open the project on your IDE.
 2. Run `pub get` on project level terminal to install all the required dependencies.
 3. Ensure that the Flutter SDK is provided the correct path. Open File menu -> Settings -> Languages & Frameworks -> Flutter
 4. In order to run a flutter project, either a virtual device needs to be setup or a physical device can be used. Remember to `enable Debugging` in **Developer Options** in the physical device.
 5. Connect your physical device or setup the virtual device before you run the application. Ensure that the device is visible on top menu.
 6. Run the command `flutter run` to run the application on your phone.

Huge shoutout to [AnitaB's mentorship-flutter project](https://github.com/anitab-org/mentorship-flutter) for the detailed installation guide! 

## NodeJs | Express | MongoDB | Backend
---
## Prerequisites
* Node Package Manager [NPM]

## Installations
1) Install express using NPM ```npm install —save express```

## Local Development Setup
1) Just run the command ```node server```