// All code regarding Firebase Notifications will be managed here in this file

import 'dart:io';
import 'dart:math';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications/message_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';


class NotificationServices {

  // initializing FirebaseMessaging class/plugin whose package we have added to pubspec.yaml ie; creating its instance to access its properties
  FirebaseMessaging messaging = FirebaseMessaging.instance ;

  // initializing "'flutter_local_notifications' Plugin, which will be used to display the notification popup on the device
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();  // // Inorder to display the notification coming from firebase on screen we will use "flutter_local_notifications"


   //   // the "RemoteMessage" comes from Firebase and below in the 'initLocalNotifications' we are trying to send icon with the following message
  //function to initializes FlutterLocalNotificationsPlugin to show notifications for android when app is active
  void initLocalNotifications(BuildContext context, RemoteMessage message)async{
   // The 'androidInitializationSettings' and 'iosInitializationSettings' variables are declared and assigned an instance of 'AndroidInitializationSettings' and 'DarwinInitializationSettings' respectively. 'AndroidInitializationSettings' has Android app launcher icon specified as '@mipmap/ic_launcher'.
    // The const keyword is used to optimize performance by creating a compile-time constant.
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');  // here we can also provide our custom app icon from @drawable(contain customIcon) like: ('@drawable/custom_icon')or @mipmap(contain default Flutter icon) like: ('@mipmap/ic_launcher'), but the icon's size must be small in kbs ie; 10 or 12 kb
    var iosInitializationSettings = const DarwinInitializationSettings();  // for iphone no need to place the icon

    // The 'initializationSetting' variable is declared and assigned an instance of 'InitializationSettings'. It takes the 'androidInitializationSettings' and 'iosInitializationSettings' objects as parameters to configure the initialization settings for both Android and iOS platforms.
    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings,   // we have initialized the notification settings for both android and ios mentioned in the previous lines
        iOS: iosInitializationSettings
    );

    //The '_flutterLocalNotificationsPlugin.initialize' method is called to initialize the local notifications plugin. It takes the 'initializationSetting' as the first parameter.
    // Additionally, it registers an onDidReceiveNotificationResponse callback as a named parameter. This callback is triggered when a user interacts with a notification (e.g., taps on it).

    //Inside the 'onDidReceiveNotificationResponse' callback, the 'handleMessage' function is called, passing the 'context' and 'message' objects as arguments.
    // This function can be customized to handle the received notification based on your requirements.
    //
    // The 'await' keyword is used before calling '_flutterLocalNotificationsPlugin.initialize' to ensure that the initialization process completes before proceeding further.
    await _flutterLocalNotificationsPlugin.initialize(  // initializing the instance of FlutterLocalNotification class ie; "_flutterLocalNotificationsPlugin" for android and ios.
        initializationSetting,  // we provided all the settings that we initialized above to this 'initialize' function

        // the RemoteMessage 'message' form 'initLocalNotifications()' is received here as argument on 'payload' variable and then passed to 'handleMessage()' function's 'message' variable as argument.
        onDidReceiveNotificationResponse: (payload){  // every notification that comes from firebase has its payload(ie; data to display)
          // handle interaction when app is active for android
          handleMessage(context, message);
      }
    );
  }

  // ... ... ... ... ... ... Function no 3   (firebaseInit() function)  ..............................................

  void firebaseInit(BuildContext context){ // this function is to be used to manage notification when app is alive and in the foreground

    // The stream contains a RemoteMessage, detailing various information about the payload, such as where it was from, the unique ID, sent time, whether it contained a notification and more.
    // To handle messages while your application is in the foreground, we use the "onMessage" stream.
    FirebaseMessaging.onMessage.listen((message) {   // this 'message' object will will store the message sent by firebase

      RemoteNotification? notification = message.notification ;
      AndroidNotification? android = message.notification!.android ;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      if(Platform.isIOS){
        forgroundMessage();
      }

      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }


  // ... ... ... ... ... ... Function no 1   (requestNotificationPermission() function)  ..............................................
  void requestNotificationPermission() async {  // this is a future function
    // 'NotificationSettings' is coming from firebase_messaging package
    // once the user enable/disable a permission so you cannot automatically undo it unless he himself manually undo it
    NotificationSettings settings = await messaging.requestPermission(  // 'NotificationSettings' is coming from 'FirebaseMessaging' Package
        alert: true,           // if 'alert' is true so notification will show on the device otherwise not
        announcement: true,    // The 'announcement' feature refers to a setting that can be enabled or disabled on an Apple device that supports Siri and AirPods.
                              // If the feature is enabled, when you connect your AirPods to your device, Siri will read out the content of any notifications that you receive.
                             // For example, if you receive a text message or an email, Siri will announce the sender's name and read out the content of the message or email.

        badge: true,             // Sets whether a notification dot will appear next to the app icon on the device when there are unread notifications.
        carPlay: true,          // Sets whether notifications will appear on the car's display when the iPhone is connected to CarPlay(a software by apple to connect iphone to cars).
        criticalAlert: true,    // Allows developers to send push notifications with sound and vibration even when the user's device is in Do Not Disturb mode. Examples of use cases for critical alerts include severe weather alerts, public safety alerts, or healthcare-related alerts.
        provisional: true,     // With Provisional Notification Permissions, users will receive a notification that says, "This app has sent you X notifications in the last Y days. Would you like to continue receiving notifications?" Users can choose to turn off notifications from the app or continue to receive them.
                               //This feature is useful for apps that want to provide a seamless onboarding experience for users without interrupting them with a permission request for push notifications.
        sound: true ,          // Sets whether a sound will be played when a notification is displayed on the device.
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {   //The 'authorizationStatus' property can return a value which can be used to determine the user's overall decision:
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) { // Provisional permission/authorization is for iPhone
      // When a notification is displayed on the device, the user will be presented with several actions prompting to keep receiving notifications quietly, enable full notification permission or turn them off:
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    }
    // else if(settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    //   print('authorizations are still not determined');
    // }
    else {
      /// if user has not given the permissions to app so open a DialogBox for him to ask for permissions as soon as he opens the app and reaches home screen.
      /// Or he can be directly directed to settings portion where he shall be asked to give permission to app

      //appsetting.AppSettings.openNotificationSettings();
                    // or //
      //AppSettings.openNotificationSettings();     // we used it through "import 'package:app_settings/app_settings.dart';"
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  // ... ... ... ... ... ... Function no 4   (showNotification() function)..............................................

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message)async{  // this function will display the notification on the screen

    // ... ... ... ... ... ... Function no 7   (AndroidNotificationChannel() function)  ..............................................

    //settling Android Notifications
    //An 'AndroidNotificationChannel' object is created. This represents the notification channel for Android devices.
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),   // 'id' ... This channel ID is sent by Firebase server so as to show a notification popUp. The channel 'id' will be sent from " Firebase -> Messaging -> Additional options (optional) -> Android Notification Channel "
        message.notification!.android!.channelId.toString() ,
      importance: Importance.max,  // if you make the 'importance' == 'Importance.high' then notifications will not show on frontEnd although they wil show on the console of Android Studio
      showBadge: true ,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('jetsons_doorbell')  // The 'RawResourceAndroidNotificationSound' class is used to set a specific default sound for the notification.
    );

    // ... ... ... ... ... ... Function no 6   (AndroidNotificationDetails() function)  ..............................................

    // 'notification' details for Android support
    // An 'AndroidNotificationDetails' object is created. This represents the notification details specific to Android devices.
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(   // this instance receives data from the above channel instance.
      //  The 'channel ID and name' are extracted from the 'message' object, and the sound is set to the sound specified in the previously created 'AndroidNotificationChannel'.
      channel.id.toString(),      //channelId, /// Imported from Math Library
      channel.name.toString() ,  //channelName
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high ,
      playSound: true,
      ticker: 'ticker' ,
         sound: channel.sound
    //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
    //  icon: largeIconPath
    );

    // ... ... ... ... ... ... Function no 7   (DarwinNotificationDetails() function)  ..............................................

    // 'notification' details for IOS support
    //A 'DarwinNotificationDetails' object is created. This represents the notification details specific to iOS devices.
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(  //  [ Firebase doesn't use the follwoing function for managing IOS notifications because 'IOS' handles it by itself ]
      presentAlert: true ,
      presentBadge: true ,
      presentSound: true
    ) ;

    // ... ... ... ... ... ... Function no 8   (DarwinNotificationDetails() function)  ..............................................

    // A 'NotificationDetails' object is created. This represents the combined notification details for both 'Android' and 'iOS' devices.
    // The constructor of 'NotificationDetails' takes the 'android' and 'iOS' parameters, which are set to the previously created 'androidNotificationDetails' and 'darwinNotificationDetails' objects, respectively.
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails        // IOS support
    );

    // ... ... ... ... ... ... Function no 5   (Future.delayed() function)  ..............................................

    /// the notification here will be shown using the "_flutterLocalNotificationsPlugin"

    //By using 'Future.delayed(Duration.zero)' function, we are essentially requesting that the code inside the Future callback be executed in the next cycle of the event loop, allowing any pending UI updates or other tasks to be completed before our code is executed.
    // This approach can be useful in scenarios where we want to ensure that the code runs after the current frame is rendered or after certain UI updates have been applied, hence, providing a smoother user experience.
    Future.delayed(Duration.zero , (){
      _flutterLocalNotificationsPlugin.show(      // This function displays the 'local notification popup' on the screen which shows the Notification's message ie; its 'ID','Title','Body' and 'NotificationDetails'
          0,   // 'id'  [ ' This is the unique identifier for the notification. It helps in distinguishing multiple notifications displayed at different times.']
          message.notification!.title.toString(), // title,
          message.notification!.body.toString(),  // body,
          notificationDetails ,  // 'notificationDetails' is an object that contains additional settings and configurations for the local notification, such as sound, vibration, patterns and priority, to specify how the local notification should behave and appear to the user.
      );
    });

  }

  // ... ... ... ... ... ... Function no 2   (getDeviceToken() function)   ..............................................

  //function to get device token on which we will send the notifications
  // 'Token/device ID' is used for testing purpose only.
  Future<String> getDeviceToken() async {
    // Firebase sends Notifications on a specific device ID(token) and every device has a unique ID(token)
    String? token = await messaging.getToken();  // through the following line of code we will find the device ID(token)
    return token!;   // we have placed null check operator so that the token cannot return null value
  }

  void isTokenRefresh()async{  // this functions keep listening to token and if it expires so this function generates a new token for you.
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  //handle tap on notification when app is in background or terminated. The 'payload' and settings for background notifications is handled by flutter SDK itself
  Future<void> setupInteractMessage(BuildContext context)async{

    /// when app is terminated / killed then the 'initial' message is received...
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }


    /// when app is in background ...

    // 'onMessageOpenedApp' is used to handle the interactions with the notifications ie; when notification is clicked so the "onMessageOpenedApp" method is triggered
    // With 'onMessageOpenedApp', if the notification is clicked and the application is terminated so it will be re-started; also if it is in the background it will be brought to the foreground.
    // Depending on the content of a notification, you may wish to handle the user's interaction when the application opens. For example, if a new chat message is sent via a notification and the user presses it, you may want to open the specific conversation when the application opens.
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });

  }

  void handleMessage(BuildContext context, RemoteMessage message) {

    if(message.data['type'] =='msj'){
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MessageScreen(
            id: message.data['id'] ,
          )));
    }
  }


  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }


}