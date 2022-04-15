import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'json/user.dart';

class AuthenticationScreen extends StatefulWidget{
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends Superbase<AuthenticationScreen> {


  final _key = GlobalKey<FormState>();

  bool _loading = false;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> login() async {
    setState(() {
      _loading = true;
    });
    await ajax(url: '?action=login',method: "POST",data: FormData.fromMap({
      "phone":_phoneController.text,
      "password":_passwordController.text,
    }),error: (s,v)=>print(s),onValue: (map,v){
      if (map['error'] != null && map['error']) {
        showSnack(map['text'].toString());
      } else {
        User user = User.fromJson(map);
        save(userKey, map);
        User.user = user;
        push(const HomeScreen(),replaceAll: true);
      }
    });
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _key,
        child: Center(
          child: ListView(padding: const EdgeInsets.all(15),shrinkWrap: true,children: [
            Center(
              child: Column(
                children: [
                  Image.asset("assets/cowbe_logo.png"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Injira muri konti yawe"),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextFormField(
                controller: _phoneController,
                validator: (s)=>s?.trim().isNotEmpty == true ? null : "Field is required !",
                decoration: InputDecoration(
                    filled: true,
                    hintText: "Phone number",
                    fillColor: const Color(0xffECF1F1),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)
                    )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: TextFormField(
                obscureText: true,
                controller: _passwordController,
                validator: (s)=>s?.trim().isNotEmpty == true ? null : "Field is required !",
                decoration: InputDecoration(
                    filled: true,
                    hintText: "Password",
                    fillColor: const Color(0xffECF1F1),
                    prefixIcon: const Icon(Icons.key_outlined),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)
                    )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _loading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: (){
                var bool = _key.currentState?.validate() ?? false;

                if(bool){
                  login();
                }

              },style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                  ))
              ), child: const Text("Login")),
            ),
          ],),
        ),
      ),
    );
  }
}