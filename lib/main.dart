import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoginController(),
          child: LoginPage(),
        )
      ],
      child: MaterialApp(
        title: 'Facebook login',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(),
      ),
    );
  }
}

class LoginController with ChangeNotifier {
  UserDetails? userDetails;

  allowUserToSignInWithFB() async {
    var result = await FacebookAuth.i.login(
      permissions: ["public_profile", "email"],
    );

    if (result.status == LoginStatus.success) {
      final requestData = await FacebookAuth.i
          .getUserData(fields: "email, name, picture.type(large)");
      this.userDetails = new UserDetails(
        displayName: requestData["name"],
        email: requestData["email"],
        photoURL: requestData["picture"]["data"]["url"] ?? " ",
      );

      notifyListeners();
    }
  }

  allowUserToSignOut() async {
    await FacebookAuth.i.logOut();
    userDetails = null;
    notifyListeners();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  loginPageUI() {
    return Consumer<LoginController>(
      builder: (context, model, child) {
        if (model.userDetails != null) {
          return Center(
            child: alreadyLoggedInScreen(model),
          );
        } else {
          return notLoggedInScreen();
        }
      },
    );
  }

  alreadyLoggedInScreen(LoginController model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage:
              Image.network(model.userDetails!.photoURL ?? "").image,
          radius: 100.0,
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person),
            SizedBox(
              width: 20.0,
            ),
            Text(
              model.userDetails!.displayName ?? "",
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        ActionChip(
            backgroundColor: Colors.red,
            avatar: Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Icon(
                Icons.logout,
              ),
            ),
            label: Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Text(
                "Logout",
              ),
            ),
            onPressed: () {
              Provider.of<LoginController>(context, listen: false)
                  .allowUserToSignOut();
            })
      ],
    );
  }

  notLoggedInScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Text('FB'),
          ),
          GestureDetector(
            child: Text('fb'),
            onTap: () {
              Provider.of<LoginController>(context, listen: false)
                  .allowUserToSignInWithFB();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: loginPageUI(),
    );
  }
}

class UserDetails {
  String? displayName;
  String? email;
  String? photoURL;

  UserDetails({this.displayName, this.email, this.photoURL});

  UserDetails.fromJson(Map<String, dynamic> json) {
    displayName = json["displayName"];
    photoURL = json["photoUrl"];
    email = json["email"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['photoUrl'] = this.photoURL;

    return data;
  }
}
