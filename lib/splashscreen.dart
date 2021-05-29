import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'ad_manager.dart';
import 'mode.dart';

//Splashscreen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController _glowcontroller;
  AnimationController _fadecontroller;
  AnimationController _textcontroller;

  //waits for build to complete before execution
  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: AdManager.appId);

    _fadecontroller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _glowcontroller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _textcontroller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _fadecontroller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _glowcontroller.forward();
          _textcontroller
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed)
                _textcontroller.reverse();
              else if (status == AnimationStatus.dismissed)
                _textcontroller.forward();
            })
            ..forward();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    super.dispose();
    _textcontroller.dispose();
    _fadecontroller.dispose();
    _glowcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(children: <Widget>[
              Center(
                child: FadeTransition(
                    opacity: CurvedAnimation(
                        parent: _glowcontroller, curve: Curves.linear),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: RadialGradient(colors: [
                        Color(0xffFCF809),
                        Colors.black
                      ], stops: [
                        .35,
                        .55,
                      ], radius: 1)),
                    )),
              ),
              Center(
                  child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _fadecontroller, curve: Curves.easeInToLinear),
                child: Image.asset(
                  'assets/images/logoHD.png',
                  filterQuality: FilterQuality.high,
                ),
              )),
              FadeTransition(
                opacity: CurvedAnimation(
                    parent: _textcontroller, curve: Curves.linear),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Tap to Start',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'audiowide',
                        fontSize: 30),
                  ),
                ),
              )
            ])),
        onPointerDown: (details) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ModePage(details: details)));
        });
  }

  /// zoom in animation for logo
  /* Listener(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: ScaleTransition(
                child: Image.asset('assets/images/logoHD.png'),
                scale: animation,),
            )), onPointerDown: (details) {
      if (animation.isCompleted) Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ModePage(title: 'Modes', details: details)));
    }); */
}
