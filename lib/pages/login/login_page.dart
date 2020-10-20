import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myfinance_app/api/authentication.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/network.dart';

enum _LoginStatus { select, signIn, signUp }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // All state attributes
  _LoginStatus _loginStatus = _LoginStatus.select;
  bool _viewPassword = false;
  bool _loading = false;
  String _errorMsg = '';
  bool _usernameAlreadyExists = false;
  bool _usernameDoesNotExists = false;
  bool wrongPassword = false;

  // All controller
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordValidationController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _passwordValidationFocus = FocusNode();

  Future<void> validate() async {
    // Check if all forms are correct
    if (_formKey.currentState.validate()) {
      // Remove focus
      _passwordFocus.unfocus();
      _passwordValidationFocus.unfocus();

      setState(() => _loading = true);
      final username = _usernameController.text;
      final password = _passwordController.text;

      final authHandler = AuthenticationHandler();

      // If it is a new user, sign up first
      if (_loginStatus == _LoginStatus.signUp) {
        final response = await authHandler.register(username, password);
        if (!handleStatusCode(response.statusCode, true)) {
          if (mounted) setState(() => _loading = false);
          _formKey.currentState?.validate();
          return;
        }
      }

      // Then always create a new session
      final response = await authHandler.login(username, password);
      if (!handleStatusCode(response.statusCode, false)) {
        if (mounted) setState(() => _loading = false);
        _formKey.currentState?.validate();
        return;
      }

      // If successful start the homepage
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  bool handleStatusCode(StatusCode statusCode, bool signUp) {
    // Reset previous errors
    _usernameAlreadyExists = false;
    _usernameDoesNotExists = false;
    wrongPassword = false;
    _errorMsg = '';

    switch (statusCode) {
      case StatusCode.offline:
        _errorMsg = MyFinanceLocalizations.of(context).offlineMsg;
        return false;
      case StatusCode.unauthorized:
        wrongPassword = true;
        return false;
      case StatusCode.conflict:
        if (signUp)
          _usernameAlreadyExists = true;
        else
          _usernameDoesNotExists = true;
        return false;
      case StatusCode.success:
        return true;
      default:
        _errorMsg = MyFinanceLocalizations.of(context).failed;
        return false;
    }
  }

  @override
  void dispose() {
    // Dispose all text controller
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordValidationController.dispose();

    // Dispose all focus controller
    _passwordValidationFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return Center(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                child: !_loading
                    ? SingleChildScrollView(
                        reverse: true,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Disable image for small screens
                            if (constraints.maxHeight > 400)
                              Image.asset(
                                'assets/icon.png',
                                height: 100,
                              ),
                            // Disable title for small screens
                            if (constraints.maxHeight > 300)
                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 30),
                                child: Text(
                                  MyFinanceLocalizations.of(context).title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            if (_loginStatus == _LoginStatus.select)
                              OutlineButton(
                                onPressed: () => setState(
                                    () => _loginStatus = _LoginStatus.signIn),
                                child: Text(
                                    MyFinanceLocalizations.of(context).login),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            if (_loginStatus == _LoginStatus.select)
                              Text(
                                MyFinanceLocalizations.of(context).or,
                                style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            if (_loginStatus == _LoginStatus.select)
                              OutlineButton(
                                onPressed: () => setState(
                                    () => _loginStatus = _LoginStatus.signUp),
                                child: Text(MyFinanceLocalizations.of(context)
                                    .register),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            if (_loginStatus != _LoginStatus.select)
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    if (_errorMsg.isNotEmpty)
                                      Text(
                                        _errorMsg,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                        labelText:
                                            MyFinanceLocalizations.of(context)
                                                .username,
                                      ),
                                      validator: (value) {
                                        value = value.trim();
                                        if (value.length < 4 ||
                                            value.length > 10) {
                                          return MyFinanceLocalizations.of(
                                                  context)
                                              .usernameLengthCondition;
                                        }
                                        if (value
                                            .replaceAll(
                                                RegExp(
                                                  '[A-Z]|[0-9]|ä|ü|ö|Ä|Ü|Ö',
                                                  caseSensitive: false,
                                                ),
                                                '')
                                            .isNotEmpty) {
                                          return MyFinanceLocalizations.of(
                                                  context)
                                              .usernameCharacterCondition;
                                        }
                                        if (_usernameAlreadyExists) {
                                          return MyFinanceLocalizations.of(
                                                  context)
                                              .usernameExists;
                                        }
                                        if (_usernameDoesNotExists) {
                                          return MyFinanceLocalizations.of(
                                                  context)
                                              .usernameDoesNotExist;
                                        }
                                        return null;
                                      },
                                      onEditingComplete: () =>
                                          _passwordFocus.nextFocus(),
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_viewPassword,
                                      decoration: InputDecoration(
                                        labelText:
                                            MyFinanceLocalizations.of(context)
                                                .password,
                                      ),
                                      validator: (value) {
                                        value = value.trim();
                                        if (value.length < 5) {
                                          return MyFinanceLocalizations.of(
                                                  context)
                                              .passwordLengthCondition;
                                        }
                                        if (wrongPassword) {
                                          return MyFinanceLocalizations.of(
                                                  context)
                                              .wrongPassword;
                                        }
                                        return null;
                                      },
                                      focusNode: _passwordFocus,
                                      onEditingComplete:
                                          _loginStatus == _LoginStatus.signUp
                                              ? () => _passwordValidationFocus
                                                  .nextFocus()
                                              : validate,
                                    ),
                                    if (_loginStatus == _LoginStatus.signUp)
                                      TextFormField(
                                        controller:
                                            _passwordValidationController,
                                        obscureText: !_viewPassword,
                                        decoration: InputDecoration(
                                          labelText:
                                              MyFinanceLocalizations.of(context)
                                                  .passwordValidation,
                                        ),
                                        validator: (value) {
                                          value = value.trim();
                                          if (value !=
                                              _passwordController.text) {
                                            return MyFinanceLocalizations.of(
                                                    context)
                                                .passwordValidationCondition;
                                          }
                                          return null;
                                        },
                                        focusNode: _passwordValidationFocus,
                                        onEditingComplete: validate,
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: IconButton(
                                                icon: Icon(
                                                  _viewPassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () => setState(() =>
                                                    _viewPassword =
                                                        !_viewPassword),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: OutlineButton(
                                              onPressed: () {
                                                // Reset all fields
                                                _usernameController.text = '';
                                                _passwordController.text = '';
                                                _passwordValidationController
                                                    .text = '';

                                                // Open the select page
                                                setState(() => _loginStatus =
                                                    _LoginStatus.select);
                                              },
                                              child: Text(
                                                  MyFinanceLocalizations.of(
                                                          context)
                                                      .back),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          OutlineButton(
                                            onPressed: validate,
                                            child: Text(_loginStatus ==
                                                    _LoginStatus.signIn
                                                ? MyFinanceLocalizations.of(
                                                        context)
                                                    .login
                                                : MyFinanceLocalizations.of(
                                                        context)
                                                    .register),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                          ],
                        ),
                      )
                    : SpinKitFadingCircle(
                        itemBuilder: (context, index) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            );
          }),
        ),
      );
}
