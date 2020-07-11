# Freezers App

This small Flutter app showcases how Cumulocity APIs can be used by any kind of framework without relying on Cumulocity SDKs.

![Image1](https://user-images.githubusercontent.com/1639884/87221223-a62ae480-c36a-11ea-9164-e38ccf848a96.png)![Image2](https://user-images.githubusercontent.com/1639884/87221246-c490e000-c36a-11ea-86b0-f37ca55f8292.png)

## Instructions

### Prerequisites

This app is build using the Flutter SDK.
Please follow the [Flutter documentation](https://flutter.dev/docs) in order to install and setup the SDK.

### Preparing the app

The app is currently hard coded on a specific tenant. You can change that by going to the file ```lib/views/loginPage.dart``` and change the varibles ```baseUrl``` and ```tenant``` to your own tenant.

### Running and building the app

For details please follow the [Flutter documentation](https://flutter.dev/docs).

Example for building an Android app: ```flutter build apk```