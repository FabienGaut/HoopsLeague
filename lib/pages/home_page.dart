import 'package:flutter/material.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:HoopsBets/pages/sign_up_page.dart';

import '../l10n/app_localizations.dart';


class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [

          Image.asset("assets/images/logo.jpeg"),
          const Text(
              "Welcome to HoopsBets !",
              style: TextStyle(fontSize: 32, fontFamily: 'Helvetica-Bold')),
          Padding(padding: EdgeInsets.all(10)),
          ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.grey)
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_,__,___) => SignInPage()
                  )
              );
            },
            label: Text(AppLocalizations.of(context)!.signIn,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            icon: Icon(Icons.account_box) ,
          ),
          Padding(padding: EdgeInsets.all(5)),
          ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.grey)
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_,__,___) => SignUpPage()
                  )
              );
            },
            label: Text(AppLocalizations.of(context)!.signUP,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            icon: Icon(Icons.account_box),
          )
        ],
      ),
    );
  }
}
