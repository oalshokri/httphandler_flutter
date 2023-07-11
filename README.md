# Handle Http request in Flutter (smart way)
## Some Prerequisites
As we are going to implement this app using BLOC pattern you should know the basics of Streams and StreamControllers or bloc or Provider or any State Management way. Some basic knowledge of HTTP response codes and repository pattern will also be going to help you understand this more easily.
The basic architecture of our Application is going to be like this:

![Basic Architecture of our Application](https://miro.medium.com/v2/resize:fit:620/format:webp/1*ItecwYVQ68gTHY6h6S7mjA.png)
## Steps we are going to follow in this article :
- Creating an API base helper class.
- Custom app exceptions.
- LinkResponse model classes.
- A generic API response class.
- A repository class to fetch data from APIs.
- A Provider class for consuming Provider data and state.
- A UI to display all the data.

## 1- Creating an API base helper class
For making communication between our Remote server and Application we use various APIs which needs some type of HTTP methods to get executed. So we are first going to create a base API helper class, which will be going to help us communicate with our server.
[api_base_helper.dart](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/core/util/api_base_helper.dart ':include')
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'app_exception.dart';

class ApiBaseHelper {
  final String _baseUrl = "http://osamapro.online/api";

  Future<dynamic> get(String url, Map<String, String> header) async {
    var responseJson;
    try {
      final response =
          await http.get(Uri.parse(_baseUrl + url), headers: header);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(
      String url, Map<String, String> body, Map<String, String> header) async {
    var responseJson;
    try {
      final response = await http.post(
        Uri.parse(_baseUrl + url),
        headers: header,
        body: body,
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    var responseJson;
    try {
      final response = await http.put(
        Uri.parse(_baseUrl + url),
        body: body,
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
```

The helper class is self-explanatory. It just contains an HTTP Get method which then can be used by our repository class. You can add other HTTP methods too such as (“POST”, “DELETE”, “PUT”) in this class.
You must be wondering what are all those exceptions? I never heard anything about them. Don’t worry all those are just our custom app exceptions which we are going to create in our next step.
## 2- Creating custom app exceptions
An HTTP request on execution can return various types of status codes based on its status. We don’t want our app to misbehave if the request fails so we are going to handle most of them in our app. For doing so are going to create our custom app exceptions which we can throw based on the response status code.
[app_exception.dart](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/core/util/app_exception.dart ':include')

```dart
class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}
```

## 3- Creating LinkResponse model classes
As we are working with Betweener Api to get our Links. we have to create a basic dart model class which will be going to hold our Link data.
[link_model.dart](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/features/profile/links/models/link_model.dart ':include')
```dart
class LinkResponse {
  int? totalResults;
  List<Link> results = [];

  LinkResponse.fromJson(Map<String, dynamic> json) {
    //you can use your custom json field depend on api response
    // totalResults = json['total_results'];
    if (json['links'] != null) {
      json['links'].forEach((v) {
        results.add(Link.fromJson(v));
      });
    }
  }
}

class Link {
  int? id;
  String? title;
  String? link;
  String? username;
  int? isActive;
  int? userId;
  String? createdAt;
  String? updatedAt;

  Link(
      {this.id,
      this.title,
      this.link,
      this.username,
      this.isActive,
      this.userId,
      this.createdAt,
      this.updatedAt});

  Link.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    link = json['link'];
    username = json['username'];
    isActive = json['isActive'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['link'] = this.link;
    data['username'] = this.username;
    data['isActive'] = this.isActive;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
```

## 4- Creating a generic ApiResponse class
In order to expose all those HTTP errors and exceptions to our UI, we are going to create a generic class which encapsulates both the network status and the data coming from the API.
[api_response.dart](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/core/util/api_response.dart ':include')
```dart
class ApiResponse<T> {
  Status status;
  T? data;
  String? message;

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR }
```

## 5- Creating a repository class to fetch data from APIs
As I stated at the start that we are creating this app with a thought of implementing a good architecture. We are going to use a Repository class which going to act as the intermediator and a layer of abstraction between the APIs and the StateManagment layer. The task of the repository is to deliver links data to the Provider after fetching it from the API.
[LinkRepository.dart](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/features/profile/links/repo/LinkRepository.dart ':include')
```dart
import '../../../../core/util/api_base_helper.dart';
import '../models/link_model.dart';

class LinkRepository {
  final ApiBaseHelper _helper = ApiBaseHelper();

  //example - you can use cashed user token
  String userToken = '1|LajBiiQSs1r9FOVowIXKpdFJYQAzCvrhCOjND7iM';

  Future<List<Link>> fetchLinkList() async {
    final response = await _helper.get("/links", {
      'Authorization': 'Bearer $userToken',
    });
    return LinkResponse.fromJson(response).results;
  }

  Future<dynamic> addLink() async {
    final response = await _helper.post("", {}, {});
    return LinkResponse.fromJson(response).results;
  }
}
```

## 6- Creating the Link Bloc/Provider
For consuming the various UI events and act accordingly, we are going to create a Link Provider. Its task is just to handle the “fetch link list” event and adding the returned data to the Sink which then can be easily listened by our UI.
The main part of blog comes here as we are going to handle all those exceptions that we created. The basic thing that we are doing here is to track the different states of our Data and pass it to our UI using ChangeNotifier.
State: Loading -> Notifies the UI that our data is currently loading.
State: Completed -> Notifies the UI that our data is now successfully fetched and we can show it.
State: Error -> Notifies the UI that we got an error or exception while fetching our data.
[links_provider.dart](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/features/profile/links/providers/links_provider.dart ':include')
```dart
import 'package:flutter/cupertino.dart';
import '../../../../core/util/api_response.dart';
import '../models/link_model.dart';
import '../repo/LinkRepository.dart';

class LinkProvider extends ChangeNotifier {
  late LinkRepository _linkRepository;

  late ApiResponse<List<Link>> _linkList;

  ApiResponse<List<Link>> get linkList => _linkList;

  LinkProvider() {
    _linkRepository = LinkRepository();
    fetchLinkList();
  }

  fetchLinkList() async {
    _linkList = ApiResponse.loading('Fetching Links');
    notifyListeners();
    try {
      List<Link> links = await _linkRepository.fetchLinkList();
      _linkList = ApiResponse.completed(links);
      notifyListeners();
    } catch (e) {
      _linkList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }
}
```
## Last Step - Creating a Profile view to display popular Links
In order to react to the states of our data, we going to create a Stateful widget called ProfileView and listen to all that state changes using the Consumer widget which comes from Provider package.

Things we should do ->

Register the LinkProvider in the main.dart file by wrapping all the app with provider or MultiProvider, use Provider or Consumer to listen to data changes in any Screen to get the provided data.
[main.dart ](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/main.dart ':include')

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/profile/links/providers/links_provider.dart';
import 'features/profile/profile_view.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LinkProvider>(
          create: (_) => LinkProvider(),
        ),
      ],
      child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Betweener',
          home: ProfileView()),
    );
  }
}
```

Handled all the three states of our data using a Switch Case and returning a widget as per the data state.
[profile_view.dart](https://github.com/oalshokri/httphandler_flutter/blob/master/lib/features/profile/profile_view.dart ':include')

```dart
import 'package:flutter/material.dart';
import 'package:httphandler/features/profile/links/providers/links_provider.dart';
import 'package:provider/provider.dart';

import '../../core/util/api_response.dart';
import 'links/models/link_model.dart';

class ProfileView extends StatefulWidget {
  static const id = '/profileView';

  final bool Function(UserScrollNotification)? onNotification;

  const ProfileView({super.key, this.onNotification});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LinkProvider>(
        builder: (_, linkProvider, __) {
          if (linkProvider.linkList.status == Status.LOADING) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (linkProvider.linkList.status == Status.ERROR) {
            return Center(
              child: Text('${linkProvider.linkList.message}'),
            );
          }
          print(linkProvider.linkList.data?.length);
          return Center(
            child: ListView.builder(
              itemCount: linkProvider.linkList.data?.length,
              itemBuilder: (context, index) {
                Link? link = linkProvider.linkList.data?[index];
                return Text('${link?.title}');
              },
            ),
          );
        },
      ),
    );
  }
}
```

We did it, our app is now working perfectly and we also handled our network call like a pro. Our users will never be going to suffer now.
