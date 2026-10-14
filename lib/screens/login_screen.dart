import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //Control para mostrar/ocultar contraseña
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: const RiveAnimation.asset(
                  "assets/login-bear-animation.riv",
                ),
              ), //SizedBox
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email@ejemplo.com",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton( icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off
                  ), 
                  onPressed: () {
                    setState((){
                      _isObscure = !_isObscure;
                    });
                  },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}