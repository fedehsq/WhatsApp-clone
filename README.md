# WhatsApp_clone

## Description

A functional replica of the [WhatsApp](https://www.whatsapp.com/) mobile application.

## Functionalities

The project is under development. \
Features implemented:

* **Registration request**: a client can request the WhatsApp registration to the server.

* **Registration**: a client can be registered to WhatsApp with a profile picture.

* **Registered users**: a client can see for the registered users to WhatsApp.

* **Status**: a client can see the online/offline status of the registered users to WhatsApp.

* **Chat**: a client can start a chat with another user.

* **OfflineMessages**: a client can receives messages while it is offline.

* **In app Notification**: a client can receive in app notification for incoming messages.

Features to implement:

* **Edit profile**: a client can edit its personal informations.

* **Send file**: a client can send files.

* **Chat groups**: Diffrent clients can chat together.

* **Other**

## Tools

To develeop this application, several software/framework have been used:

* [Flutter](https://flutter.dev/) transforms the app development process. Build, test, and deploy beautiful mobile, web, desktop, and embedded apps from a single codebase.\
The client mobile app is developed with Flutter.

* [Node.js](https://nodejs.org/en/) is designed to build scalable network applications, many connections can be handled concurrently. Upon each connection, the callback is fired, but if there is no work to be done, Node.js will sleep.\
The server is developed with NodeJs.

* [SQLite](https://www.sqlite.org/) is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.\
Both client and server store data using SQLite.

## Instructions

1. Download and install [Flutter](https://docs.flutter.dev/get-started/install).

2. Download and install [Node.js](https://nodejs.org/).

3. Clone the repo:

```
git clone https://github.com/fedehsq/whatsapp_clone
```

4. Change the server ip address in `whatsapp_clone/app/lib/api.dart`

5. Run the server:

```
cd whatsapp_clone/app
npm rebuild
node server.js
```

6. Run the client:

```
cd whatsapp_clone/app
flutter run
```

## Author

* [Federico Bernacca](https://fedehsq.github.io/)
