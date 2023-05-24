import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications/home_screen.dart';

///Note: firebase_core package works on minSdkVersion 19 and is used to access the core functionality of flutter
///Note: flutter_local_notification package is used to display notification from firebase
///Note: we will also change the name of 'applicationId' from example to our app name in build.gradle file otherwise IOS will fail the bundle ID.
///Note: 'app_settings' is Flutter plugin for opening iOS and Android phone settings from an app. Thus, when you pubget it then kill the project and reLaunch it otherwise will get an error
///Note: There are three states of app in which we shall handle notifications ie; (1) When app is alive (2) When app is open in the background (3) When app is killed or dead


///Note: The following 'metadata' shall be added to 'AndroidManifest.xml' for assigning a notification channel to the notifications automatically.
//  <meta-data
//            android:name="com.google.firebase.messaging.default_notification_channel_id"
//            android:value="high_importance_channel" />

// ....................................................................................................................................................................................................
/// Note:

// In Flutter, a top-level function is a function that is defined outside of any class or method. It is declared at the top level of a Dart file and can be accessed globally within that file.
//
// In the context of Flutter development, top-level functions are commonly used for utility functions or helper functions that don't belong to a specific class. They provide reusable functionality and can be called from multiple parts of the application.
//
// Here's an example of a top-level function in Flutter:
//
// void showToast(String message) {
//   // Implementation for displaying a toast notification
//   // This function can be called from anywhere in the file
//   print('Toast: $message');
// }
// In this example, 'showToast' is a top-level function that takes a message parameter and prints a toast notification. It can be called from any other function, class, or widget within the same Dart file.
// ....................................................................................................................................................................................................

// '_firebaseMessagingBackgroundHandler' will be a 'static' and 'Top-lEVEL' function which will handle background notifications for us.
// It must be a 'Top-LEVEL' function otherwise there will be many issues with the notifications. ForExample; redirection on notification click may not work.
@pragma('vm:entry-point')   // This is the entry point for notification to reach our Mobile device from Firebase and 'vm' means virtual machine and this piece of code is necessary for background notification service. It starts the 'FirebaseBackgroundServices'
//This is a function that serves as the background message handler for Firebase Cloud Messaging (FCM). It takes a RemoteMessage object as a parameter, which represents the incoming message from Firebase.
// '_firebaseMessagingBackgroundHandler' is a user-defined function that serves as the actual callback function for handling background messages. It is responsible for processing the received background message and performing any desired actions. This function is passed as the parameter to FirebaseMessaging.onBackgroundMessage
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {  // '_firebaseMessagingBackgroundHandler' is a callback function, also known as a callback. This is a function that is passed as an argument to another function. The primary purpose of a callback function is to allow for flexible and customizable behavior by providing a way to specify additional code that should be executed at a particular point in the program.
  await Firebase.initializeApp(); // //This line initializes the Firebase services in the background message handler. It ensures that Firebase services are set up and ready to handle background notifications.

}


void main()async {
  // 'WidgetsFlutterBinding.ensureInitialized();' ensures that the necessary Flutter widgets are initialized before running the application. It is required to properly initialize the Flutter framework.
  WidgetsFlutterBinding.ensureInitialized();   // binding all widgets to ensure the Firebase initialization
  // This initializes the Firebase services within the main function, ensuring that Firebase is ready for use throughout the application.
  await Firebase.initializeApp();  // initializing firebase   and it comes from "FirebaseCore package"
  // 'FirebaseMessaging.onBackgroundMessage' sets the provided '_firebaseMessagingBackgroundHandler' function as the callback for handling background messages. It is called when the app is running in the background and receives a background notification.
 //  'FirebaseMessaging.onBackgroundMessage' is used to set the callback function that will be called when the app is running in the background and receives a background message/notification. It takes a single parameter, which is the callback function to be executed.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);  // // This function is used to handle background messages, i.e, when app is in the background and It is coming from 'firebase_messaging package'

  runApp(const MyApp()); // This runs the Flutter application, starting with the MyApp widget as the root of the widget tree.
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Firebase Notification application',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}


