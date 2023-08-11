import 'dart:convert';

import 'package:eos_clock/view/home_screen.dart';
import 'package:eos_clock/view/signup_screen.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;


final String URL = "http://13.209.96.204:8000/";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // firebase authentication instance 생성
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget _userIdWidget() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'email'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return '이메일을 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _passwordWidget() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'password'),
      validator: (String? value) {
        if (value!.isEmpty) {
          // null or isEmpty
          return '비밀번호를 입력해주세요.';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFffffff),
      appBar: AppBar(
        title: const Text("로그인"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Form(
              key: _formKey,
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _userIdWidget(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      _passwordWidget(),
                      Container(
                        height: 50,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _login(),
                          child: const Text("로그인"),
                        ),
                      ),
                      GestureDetector(
                          child: Container(
                              width: double.infinity,
                              alignment: AlignmentDirectional.center,
                              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                              child: Text("회원 가입")),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return SignUpScreen();
                                }));
                          })
                    ],
                  )))),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _login() async {
    // 키보드 숨기기
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());

      String message = '';

      final request = Uri.parse(URL + "user/login/" + _emailController.text);

      Future<Map<String, String>> fetch() async {
        print("here");
        Map<String, String> header = {"password": _passwordController.text};
        print("here1");
        final response = await http.get(request, headers: header);
        var decodedResult = jsonDecode(response.body) as Map<String, dynamic>;

        var result =
        decodedResult.map((key, value) => MapEntry(key, value.toString()));

        return result;
      }

      var response = fetch();

      message = await response.then((value) => value['result'].toString());

      message =
      await response.then((value) => value["error_message"].toString());

      if (message == 'login success') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.deepOrange,
        ));
      }
    }
  }
}