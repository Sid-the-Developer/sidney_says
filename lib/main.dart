import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mode.dart';
import 'splashscreen.dart';
import 'win.dart';

void main() {
  runApp(MyApp());
}

//
class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
}

SharedPreferences prefs;
bool supportTextShown = false;

//app root
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

    return MaterialApp(
        title: 'SidneySays',
        theme: ThemeData(
            primarySwatch: Colors.blue, backgroundColor: Colors.black),
        home: SplashScreen());
  }
}

//Game logic and layout
class GamePage extends StatefulWidget {
  GamePage(
    this.mode, {
    Key key,
  }) : super(key: key);

  final Mode mode;
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List pattern = List<int>();
  List input = List<int>();
  int patternIndex = 0;

  /// blink duration is in seconds because its from [Slider]
  final Duration duration =
      Duration(milliseconds: (prefs.get('blink_duration') * 1000).round());

  /// tooltip key to set visibility
  final toolKey = GlobalKey();

  // bottom left = bl, top left = tl, etc
  Color colorBL = Colors.yellow;
  Color colorBR = Color.fromRGBO(0, 255, 0, enabled);
  Color colorTR = Color.fromRGBO(0, 38, 255, enabled);
  Color colorTL = Color.fromRGBO(255, 17, 0, enabled);
  static const enabled = 1.0;
  static const disabled = .3;
  var _buttonTL = false; //top left = TL ...
  var _buttonBL = false;
  var _buttonBR = false;
  var _buttonTR = false;
  Timer blueBlink;
  Timer redBlink;
  Timer greenBlink;
  Timer yellowBlink;
  Timer nextBlink;

  @override
  void dispose() {
    blueBlink?.cancel();
    redBlink?.cancel();
    greenBlink?.cancel();
    yellowBlink?.cancel();
    nextBlink?.cancel();
    super.dispose();
  }

  //waits for build to complete before execution
  @override
  void initState() {
    super.initState();

    /// prevents error where button is not built before adding button
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Timer(Duration(milliseconds: 300), () {
              if (prefs.get('tooltip_shown')) {
                final dynamic tooltip = toolKey.currentState;
                tooltip.ensureTooltipVisible();
                prefs.setBool('tooltip_shown', true);
              }
              _addButton();
            }));
  }

  /// add button to pattern
  void _addButton() {
    for (int buttonsPerAdd = widget.mode.difficulty;
        buttonsPerAdd > 0;
        buttonsPerAdd--) {
      pattern.add(Random().nextInt(4));
    }

    patternIndex = 0;
    input.clear();
    blinkButton(index: 0);
  }

  /// blinks button when user presses given color
  /// if index is given then recursively blinks the button pattern
  void blinkButton({int color = -1, int index = -1}) {
    if (index > -1 && index < pattern.length) {
      nextBlink = Timer(Duration(milliseconds: 1000),
          () => blinkButton(color: pattern[index], index: index + 1));
    }

    switch (color) {
      case 0:
        setState(() {
          _buttonTL = !_buttonTL;
        });
        blueBlink =
            Timer(duration, () => setState(() => _buttonTL = !_buttonTL));
        break;
      case 1:
        setState(() {
          _buttonTR = !_buttonTR;
        });
        redBlink =
            Timer(duration, () => setState(() => _buttonTR = !_buttonTR));
        break;
      case 2:
        setState(() {
          _buttonBL = !_buttonBL;
        });
        greenBlink =
            Timer(duration, () => setState(() => _buttonBL = !_buttonBL));
        break;
      case 3:
        setState(() {
          _buttonBR = !_buttonBR;
        });
        yellowBlink =
            Timer(duration, () => setState(() => _buttonBR = !_buttonBR));
        break;
    }
  }

  /// checks that the pressed button is correct
  /// fails if too many buttons are pressed
  void check() {
    if (input.last != pattern[patternIndex++] ||
        input.length > pattern.length) {
      // show add after lose
//      InterstitialAd(adUnitId: AdManager.interstitialAdUnitId)
//        ..load()
//        ..show();

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => WinPage(
                widget.mode,
                score: input.length - 1 ?? 0,
              )));
    } else if (input.length == pattern.length) {
      if (pattern.length == widget.mode.difficulty * 5 &&
          !widget.mode.isInfinite) {
//        InterstitialAd(adUnitId: AdManager.interstitialAdUnitId)
//          ..load()
//          ..show();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => WinPage(
                  widget.mode,
                  won: true,
                  score: input.length - 1 ?? 0,
                )));
      } else {
        Timer(Duration(seconds: 1), () => _addButton());
      }
    }
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Container(
        child: Padding(
            padding: const EdgeInsets.all(8.0),

            /// ensures buttons arent in status bar
            child: SafeArea(
              /// stack of logo and buttons
              child: Stack(children: <Widget>[
                /// grid of buttons
                Table(
                  children: [
                    TableRow(children: [
                      Container(
                        height: SizeConfig.blockSizeVertical * 45,
                        child: FlatButton(
                          color: prefs.get('squares')
                              ? _buttonTL
                                  ? colorTR.withOpacity(enabled)
                                  : colorTR.withOpacity(disabled)
                              : Colors.transparent,
                          onPressed: () {
                            blinkButton(color: 0);
                            input.add(0);
                            check();
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            //side: BorderSide(color: Colors.blue[900])
                          ),
                          child: null,
                        ),
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 45,
                        child: FlatButton(
                          color: prefs.get('squares')
                              ? _buttonTR
                                  ? colorTL.withOpacity(enabled)
                                  : colorTL.withOpacity(disabled)
                              : Colors.transparent,
                          onPressed: () {
                            blinkButton(color: 1);
                            input.add(1);
                            check();
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            //side: BorderSide(color: Colors.red[700])
                          ),
                          child: null,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: SizeConfig.blockSizeVertical * 5,
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 5,
                      )
                    ]),
                    TableRow(children: [
                      Container(
                        height: SizeConfig.blockSizeVertical * 45,
                        child: FlatButton(
                          color: prefs.get('squares')
                              ? _buttonBL
                                  ? colorBR.withOpacity(enabled)
                                  : colorBR.withOpacity(disabled)
                              : Colors.transparent,
                          onPressed: () {
                            blinkButton(color: 2);
                            input.add(2);
                            check();
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            // side: BorderSide(color: Colors.green[700])
                          ),
                          child: null,
                        ),
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 45,
                        child: FlatButton(
                          color: prefs.get('squares')
                              ? _buttonBR
                                  ? colorBL.withOpacity(enabled)
                                  : colorBL.withOpacity(disabled)
                              : Colors.transparent,
                          onPressed: () {
                            blinkButton(color: 3);
                            input.add(3);
                            check();
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            //side: BorderSide(color: Colors.yellow[700])
                          ),
                          child: null,
                        ),
                      ),
                    ])
                  ],
                ),
                Center(
                    child: Hero(
                  tag: 'logo',
                  child: Tooltip(
                    key: toolKey,
                    message: 'Tap logo to change button style',
                    textStyle: TextStyle(fontSize: 15, color: Colors.white),
                    child: GestureDetector(
                      onTap: () => prefs
                          .setBool('squares', !prefs.get('squares'))
                          .then((value) => setState(() {})),
                      child: Image.asset(
                        'assets/images/logoHD.png',
                        filterQuality: FilterQuality.high,
                        height: 150,
                        width: 150,
                      ),
                    ),
                  ),
                ))
              ]),
            )),

        /// radial background decoration
        decoration: prefs.get('squares')
            ? null
            : BoxDecoration(
                gradient: SweepGradient(
                colors: [
                  _buttonBR
                      ? colorBL.withOpacity(enabled)
                      : colorBL.withOpacity(disabled),
                  _buttonBL
                      ? colorBR.withOpacity(enabled)
                      : colorBR.withOpacity(disabled),
                  _buttonTL
                      ? colorTR.withOpacity(enabled)
                      : colorTR.withOpacity(disabled),
                  _buttonTR
                      ? colorTL.withOpacity(enabled)
                      : colorTL.withOpacity(disabled),
                  _buttonBR
                      ? colorBL.withOpacity(enabled)
                      : colorBL.withOpacity(disabled),
                ],
                stops: const <double>[.22, .3, .65, .9, 1],
              )),
      ),
    );
  }
}
