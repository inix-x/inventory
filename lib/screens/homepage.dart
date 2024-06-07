import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/loginwidget/auth_service.dart';
import 'package:flutter_application_1/loginwidget/customersignout.dart';
import 'package:flutter_application_1/loginwidget/loginpage.dart';
import 'package:flutter_application_1/providers/categoryprovider.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_application_1/loginwidget/customersignout.dart';
import '../screens/menupage.dart';
import '../screens/accountpage.dart';
// import 'package:flutter_application_1/loginwidget/auth_service.dart';
// import 'package:flutter_application_1/loginwidget/loginpage.dart';

class HomeApp extends StatefulWidget {
  const HomeApp({super.key, required bool isFinished});
  // static final GlobalKey<NavigatorState> navigatorKey =
  //     GlobalKey<NavigatorState>();
  @override
  State<HomeApp> createState() => _HomeAppState();
}

bool _isClicked = false;
bool _isFinished = false;

class _HomeAppState extends State<HomeApp> {
  void navigateToAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountScreen()),
    );
    setState(() {
      _isClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    // Extract the storeName from the list
    final businessName = categories.isNotEmpty ? categories.first.storeName : '';

    // ignore: no_leading_underscores_for_local_identifiers
    final _auth = AuthService();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          centerTitle: true,
          title:   Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 30,
              ),
              const Spacer(),
              // Text(businessName.isEmpty ? 'Nothing\'s here ' : 'Yep', style: const TextStyle(color: accentColor)),
               Text('$businessName ', style: const TextStyle(color: accentColor)),
               const Spacer(),
                  Customsignout(
                onPressed: () async {
                  await _auth.signout();
                  // ignore: use_build_context_synchronously
                  goToLogin(context);
                },
                icon: const Icon(Icons.logout_sharp,
                    color: Colors.white), // Add icon and color
              ),
               const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        body: MenuScreen(
          isFinished: _isFinished,
        ),
        bottomNavigationBar: Container(
          height: 70,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: !_isClicked ? accentColor : primaryColor,
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          _isClicked = !_isClicked;
                        });
                      },
                      child: Icon(
                        Icons.menu_book,
                        color: _isClicked ? accentColor : primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(
                //   width: 15,
                // ),
                const DottedLine(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  dashLength: 5,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                      color: _isClicked ? accentColor : primaryColor,
                      child: MaterialButton(
                          onPressed: () => navigateToAccount(
                              context), // Pass context explicitly
                          child: Icon(
                            Icons.account_circle,
                            color: !_isClicked ? accentColor : primaryColor,
                            size: 25,
                          ))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

    bool shouldPop(Route<dynamic> route) {
    return false; // Always return false to prevent back navigation
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
}
  