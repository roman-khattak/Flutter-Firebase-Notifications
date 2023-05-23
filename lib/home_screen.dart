

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications/notification_services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  NotificationServices notificationServices = NotificationServices();  // creating the instance of NotificationServices class to access the functions


  @override
  void initState() {
    super.initState();

    notificationServices.requestNotificationPermission();  // we request permissions from user as soon as he opens the app and reaches home screen if he hasn't given the permissions
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);  //
    notificationServices.setupInteractMessage(context);


    notificationServices.isTokenRefresh();   // To call/regenerate for a refreshed token if the previous one has expired.

    // this token is your device ID that you will place in "Add an FCM registration token" section in Firebase Notification Messages to send notification
    // This must be remembered that the following token can expire after sometime and then you can refresh and regenerate a new token using 'isTokenRefresh()' function.
    notificationServices.getDeviceToken().then((value){
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Notifications'),
      ),
      body: Center(
        child: TextButton(onPressed: (){

          // send notification from one device to another.
          notificationServices.getDeviceToken().then((value)async{   // This line will get us the device token

            var data = {   // defining payload here so that we can be redirected to another screen on click of the notification being sent from one device to another
              'to' : value.toString(),          // we will send the payload to the device whose token is mentioned here
              'notification' : {
                'title' : 'Asif' ,
                'body' : 'Subscribe to my channel' ,
                "sound": "jetsons_doorbell.mp3"
            },
              'android': {
                'notification': {
                  'notification_count': 23,
                },
              },
              'data' : {
                'type' : 'msj' ,
                'id' : 'Asif Taj'
              }
            };

            // 'Server key' from 'Cloud Messaging API(Legacy)' is to be passed in 'headers' in 'Authorization' section as { 'Authorization' : 'key=|server key|' }
            await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'), // this is the url of 'google' API
            body: jsonEncode(data) ,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization' : 'key=AAAAp9pXDFM:APA91bGhBeMCUABE2PXjl9UqodAZ2WdV_UI6PoiwdCzYaT8KeZmBKZszc01CD1GgN0OAJ1w3sNw9IVISyKhrrxQLASHizenGJUr2hjzoPjbjFu0HAx1CTk0l8Ut95ZENAQyRKm6hrltV'
              }
            ).then((value){
              if (kDebugMode) {
                print(value.body.toString());
              }
            }).onError((error, stackTrace){
              if (kDebugMode) {
                print(error);
              }
            });
          });
        },
            child: Text('Send Notifications')),
      ),
    );
  }
}
