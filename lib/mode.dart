import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'settings.dart';

/// data class for mode
class Mode {
  Mode({this.name, this.isInfinite});

  String name;
  final bool isInfinite;

  int get difficulty {
    if (name == 'normal')
      return 1;
    else if (name == 'medium')
      return 2;
    else if (name == 'intense') return 3;
    return 0;
  }

  set difficulty(int difficulty) {
    switch (difficulty) {
      case 1:
        this.name = 'normal';
        break;
      case 2:
        this.name = 'medium';
        break;
      case 3:
        this.name = 'intense';
        break;
      default:
        this.name = '';
    }
  }
}

/// Mode selection page
class ModePage extends StatefulWidget {
  ModePage({Key key, this.details}) : super(key: key);
  final PointerDownEvent details;

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> with TickerProviderStateMixin {
  AnimationController controller;
  static bool infinite = false;

  void _play(Mode mode) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => GamePage(mode)));
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    controller.forward();

    SharedPreferences.getInstance().then((value) {
      prefs = value;
      prefs.get('first_time') ?? prefs.setBool('first_time', true);
      prefs.get('tooltip_shown') ?? prefs.setBool('tooltip_shown', false);
      prefs.get('highscore_normal') ?? prefs.setInt('highscore_normal', 0);
      prefs.get('highscore_medium') ?? prefs.setInt('highscore_medium', 0);
      prefs.get('highscore_intense') ?? prefs.setInt('highscore_intense', 0);
      //settings
      prefs.get('squares') ?? prefs.setBool('squares', false);
      prefs.get('leaderboard') ?? prefs.setBool('leaderboard', false);
      prefs.getBool('sound') ?? prefs.setBool('sound', false);
      prefs.getDouble('blink_duration') ??
          prefs.setDouble('blink_duration', .5);
//      OPTIONAL ADS
//      prefs.get('ads') ?? prefs.setBool('ads', false);
      if (prefs.get('first_time')) {
        _showAbout();
        prefs.setBool('first_time', false);
      }
//      setState(() {
//        supportTextShown = prefs.getBool('ads');
//      });

//      FirebaseAdMob.instance.initialize(appId: AdManager.appId);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Row(
            children: [
              FloatingActionButton(
                tooltip: 'About the developer',
                backgroundColor: Colors.white.withOpacity(.3),
                mini: true,
                heroTag: 'about',
                onPressed: () => _showAbout(),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              FloatingActionButton(
                tooltip: 'Game settings',
                heroTag: 'settings',
                backgroundColor: Colors.white.withOpacity(.3),
                mini: true,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                )),
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        body: CircularRevealAnimation(
          animation:
              CurvedAnimation(parent: controller, curve: Curves.easeInOutExpo),
          centerOffset: widget.details.position, //animate at the point touched
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [
                    0,
                    .4,
                    .6,
                    .9
                  ],
                      colors: [
                    Colors.white,
                    Colors.yellow,
                    Colors.orange[500],
                    Colors.red[900]
                  ])),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        flex: 5,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: '',
                                children: [
                                  TextSpan(
                                      text: "Modes\n",
                                      style: TextStyle(
                                          fontFamily: 'audiowide',
                                          fontSize: 32,
                                          color: Colors.black)),
                                  TextSpan(
                                    text: "1. Choose a mode\n"
                                        "2. Watch the light up pattern\n"
                                        "3. Tap the buttons in the correct order\n"
                                        "4. Win!",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          //spacer
                          height: SizeConfig.blockSizeVertical * 15,
                        ),
                      ),
                      Flexible(
                        child: SizedBox(
                          child: SwitchListTile(
                            value: infinite,
                            activeColor: Color.fromRGBO(230, 0, 0, 0.87),
                            activeTrackColor: Color.fromRGBO(230, 0, 0, 0.5),
                            onChanged: (value) {
                              setState(() => infinite = value);
                            },
                            title: Text(
                              'infinite',
                              style: TextStyle(
                                  fontFamily: 'bungee_inline',
                                  fontSize: SizeConfig.blockSizeHorizontal * 5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          width: SizeConfig.blockSizeHorizontal * 60,
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: SizedBox(
                          //spacer
                          height: SizeConfig.blockSizeVertical * 9,
                        ),
                      ),
                      _buildButton('normal'),
                      _buildBest('normal'),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 11,
                        ),
                      ),
                      _buildButton('medium'),
                      _buildBest('medium'),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 11,
                        ),
                      ),
                      _buildButton('intense'),
                      _buildBest('intense')

                      /// OPTIONAL ADS
                      //Spacer(
                      // flex: 2,
                      // ),
//                    supportTextShown
//                        ? Container()
//                        : Column(mainAxisSize: MainAxisSize.min, children: [
//                            Text(
//                              'Feeling generous? Support the developer through ads!',
//                              textAlign: TextAlign.center,
//                              style: TextStyle(
//                                  fontSize: 18,
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                            Flexible(
//                              child: Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Row(
//                                  mainAxisAlignment:
//                                      MainAxisAlignment.spaceEvenly,
//                                  children: [
//                                    RaisedButton(
//                                      color: Colors.blue[600],
//                                      shape: RoundedRectangleBorder(
//                                          borderRadius:
//                                              BorderRadius.circular(5)),
//                                      onPressed: () => _adsOn(),
//                                      child: Text(
//                                        'Sure',
//                                        style: TextStyle(color: Colors.white),
//                                      ),
//                                    ),
//                                    RaisedButton(
//                                      shape: RoundedRectangleBorder(
//                                          borderRadius:
//                                              BorderRadius.circular(5)),
//                                      onPressed: () => setState(
//                                        () => supportTextShown = true,
//                                      ),
//                                      child: Text('No Thanks'),
//                                    )
//                                  ],
//                                ),
//                              ),
//                            )
//                          ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  /// OPTIONAL ADS
//  _adsOn() {
//    prefs.setBool('ads', true);
//    setState(() => supportTextShown = true);
//    _bannerAd =
//        BannerAd(adUnitId: AdManager.bannerAdUnitId, size: AdSize.banner);
//    _bannerAd
//      ..load()
//      ..show(anchorType: AnchorType.top);
//  }

  _showAbout() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Center(
                child: Text(
              'About the developer',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'bungee_inline'),
            )),
            children: [
              RichText(
                text: TextSpan(
                    text:
                        "Hey! I'm Sidney Wright, the creator of SidneySays. First, thank you for downloading the game! "
                        "I am in no way a professional developer, and I'm currently in high school. "
                        "This game began as a class project, then became hobby, and is now a published app. "
                        "Developing is not easy; I put a lot of time and effort into learning code as well as "
                        "tailoring the experience of SidneySays.\n\nI will support the game through updates,"
                        " but I need feedback! Even if you hate SidneySays, ",
                    children: [
                      TextSpan(
                          text:
                              "please leave a review in the Play Store to help me "
                              "to continue to improve as a developer.",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              "\n\nFor any questions, concerns, or ideas not fit for a review, you can email "),
                      TextSpan(
                        text: "swright3743@gmail.com\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                    style: TextStyle(color: Colors.black, fontSize: 17)),
                textAlign: TextAlign.center,
              ),
              RaisedButton(
                child: Text(
                  'Thanks for your support!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                color: Colors.blue,
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Widget _buildButton(String mode) {
    return Flexible(
      child: OutlineButton(
        child: Text(mode,
            style: TextStyle(
                fontFamily: 'bungee_inline',
                fontSize: SizeConfig.blockSizeHorizontal * 6)),
        shape: StadiumBorder(),
        onPressed: () =>
            _play(Mode(name: mode.toLowerCase(), isInfinite: infinite)),
        color: Colors.transparent, //Colors.yellow[700],
        borderSide: BorderSide(width: 1),
      ),
    );
  }
}

Widget _buildBest(String mode) {
  return Flexible(
      child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Best:  ${prefs?.get('highscore_$mode') ?? 0}',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  ));
}
