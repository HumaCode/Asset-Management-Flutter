import 'dart:convert';

import 'package:course_asset_management/config/api_url.dart';
import 'package:course_asset_management/config/app_constant.dart';
import 'package:course_asset_management/page/asset/home_page.dart';
import 'package:d_info/d_info.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // controllerInputan
  final edtUsername = TextEditingController();
  final edtPassword = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // function login
  login(BuildContext context) {
    // pengecekan
    bool isValid = formKey.currentState!.validate();
    if (isValid) {
      // print('OKE');

      Uri url = Uri.parse(loginurl);

      http.post(url, body: {
        'username': edtUsername.text,
        'password': edtPassword.text,
      }).then((response) {
        DMethod.printResponse(response);

        Map resBody =
            jsonDecode(response.body); // ubah dari string ke bentuk json objek

        bool success = resBody['success'] ?? false;

        if (success) {
          DInfo.toastSuccess('Login Berhasil');

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          DInfo.toastError('Login Gagal');
        }
      }).catchError((onError) {
        DInfo.toastError('Someting Wrong');
        DMethod.printTitle('catchError', onError.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.purple[300],
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.purple[300],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            child: Icon(
              Icons.scatter_plot,
              size: 90,
              color: Colors.purple[400],
            ),
          ),

          // form
          Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstant.appName.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.purple[700],
                        ),
                  ),
                  const SizedBox(height: 30),

                  // username
                  TextFormField(
                    controller: edtUsername,
                    validator: (value) =>
                        value == '' ? 'Username harus diisi.!' : null,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      hintText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // password
                  TextFormField(
                    controller: edtPassword,
                    obscureText: true,
                    validator: (value) =>
                        value == '' ? 'Password harus diisi.!' : null,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      hintText: 'Password',
                    ),
                  ),

                  // tombol
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      login(context);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
