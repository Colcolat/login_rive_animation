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

  //1.1 Crear el cerebro de la animación
  StateMachineController? _controller;

  //1.2 Variables de la animación
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    "assets/login-bear-animation.riv",
                    stateMachines: const ['Login Machine'],
                    //1.3 Vincular la animación
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );

                      //1.4 Verificar que inició bien
                      if (_controller == null) return;

                      //Agregar el controlador al tablero
                      artboard.addController(_controller!);
                      //Vinculamos las variables
                      _isChecking = _controller!.findSMI('isChecking') as SMIBool?;
                      _isHandsUp = _controller!.findSMI('isHandsUp') as SMIBool?;
                      _trigSuccess = _controller!.findSMI('trigSuccess') as SMITrigger?;
                      _trigFail = _controller!.findSMI('trigFail') as SMITrigger?;
                      _numLook = _controller!.findSMI('numLook') as SMINumber?;
                    },
                  ),
                ), //SizedBox
                const SizedBox(height: 10),
                //Email
                TextField(
                  onChanged: (value){
                    if (_isHandsUp != null) {
                      //No tapes los ojos
                      _isHandsUp!.change(false);
                    }
                    //Si isChecking es null
                    if (_isChecking == null) return;
                    //Activar el modo chismoso
                    _isChecking!.change(true);
                  },
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
                //Password
                TextField(
                  onChanged: (value){
                    if (_isChecking != null) {
                      //Deja de mirar el texto
                      _isChecking!.change(false);
                    }
                    //Si isHandsUp es null
                    if (_isHandsUp == null) return;
                    //Taparse los ojos
                    _isHandsUp!.change(true);
                  },
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
      ),
    );
  }
}