import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 Importar el timer 

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

  //3.1 
  Timer? _typingDebounce;

   //2.1 Crear variables para focusNode
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  //4.1 Controllers para maniputal el texto escrito por el usuario
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  //4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

 // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 Acción al botón
  void _onLogin(){
    //De lo que escribió el usuario, quita espacios en blanco
    final email = emailCtrl.text.trim();
    //john.doe@tecdesoftware.edu.mx
    final pass = passCtrl.text;

    final emailTypedError = isValidEmail(email) ? null : "Email Inválido";
    final passwordTypedError = isValidPassword(pass) ? null : "Contraseña inválida";

    //.4.5 Avisar que hubo un cambio
    setState(() {
      emailError = emailTypedError;
      passError = passwordTypedError;
    });

    //4.6 Cerrar el teclado y bajar manos 
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //4.7 Activar triggers
    if(emailTypedError == null && passwordTypedError == null){
      _trigSuccess?.fire();
    } else{
      _trigFail?.fire();
    }
  }
  

  //2.2 Agregar listeners 
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener((){
      if (_emailFocusNode.hasFocus) {
        //Veriicar que no sea null
        if (_isHandsUp != null) {
          //Ojos sin cerrar en email
          _isHandsUp!.change(false);
          _numLook?.value = 50; //Mirada neutral
        }
      } else {
        //Deja de mirar al salir del email
        _typingDebounce?.cancel();
        _isChecking?.change(false);
      }
    });
    _passwordFocusNode.addListener((){
      //Manos arriba en password
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });

    
  }
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
                  //4.8 Vincular Controller
                  controller: emailCtrl,
                  //2.3 Asignar el foco al campo de texto
                  focusNode: _emailFocusNode,
                  onChanged: (value){
                    //Si isChecking es null
                    if (_isChecking == null) return;
                    //Activar el modo chismoso
                    _isChecking!.change(true);
                    //3.4 Implementar numLook
                    //Ajustes del 0 al 100
                    //80 es medida de calibración. Clamp es el rango
                    final look = (value.length / 80 * 100).clamp(0.0, 100.0);
                    _numLook?.value = look;

                    //3.5 Debounce: si vuelve a teclear, reinicia el contador
                    _typingDebounce?.cancel(); //Cancelamos cualquier timer existente
                    //Crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), (){
                      if (!mounted) return;
                      _isChecking?.change(false);
                    });

                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    //4.9 Mostrar el texto de error
                    errorText: emailError,
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
                  //4.8 Vincular Controller
                  controller: passCtrl,
                  //2.3 Asignar el foco al campo de texto
                  focusNode: _passwordFocusNode,
                  onChanged: (value){
                    //Si isHandsUp es null
                    if (_isHandsUp == null) return;
                    //Taparse los ojos
                    _isHandsUp!.change(true);
                  },
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    errorText: passError,
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
                SizedBox(height: 10),
                SizedBox(
                  width: size.width,
                  child: const Text(
                    "Fortgot password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 10),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _onLogin,
                  child: Text("Login", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(
                    height: 20
                  ),
                  SizedBox(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  //2.4 Liberar los recursos de los focusNode
  void dispose() {
    //4.10 Liberar controllers
    emailCtrl.dispose();
    passCtrl.dispose();
    //2.4 Liberar recursos de los focusNode
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //3.5 Liberar Timer 
    _typingDebounce?.cancel();
    super.dispose();
  }
}