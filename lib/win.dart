import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'main.dart';
import 'mode.dart';

class WinPage extends StatefulWidget {
  WinPage(this.mode, {Key key, this.won = false, this.score = 0})
      : super(key: key);
  final Mode mode;
  final bool won;
  final int score;
  _WinPageState createState() => _WinPageState();
}

class _WinPageState extends State<WinPage> {
  bool newHigh = false;
  final Duration duration = const Duration(milliseconds: 150);
  static const double enabled = 1.0;
  static const double disabled = .3;
  // bottom left = bl, top left = tl, etc
  Color colorBL = Colors.yellow;
  Color colorBR = Color.fromRGBO(0, 255, 0, enabled);
  Color colorTR = Color.fromRGBO(0, 38, 255, enabled);
  Color colorTL = Color.fromRGBO(255, 17, 0, enabled);
  bool _buttonTL = false;
  bool _buttonBL = false;
  bool _buttonBR = false;
  bool _buttonTR = false;
  double topPadding;
  BannerAd _bannerAd;

  //waits for build to complete before execution
  void initState() {
    super.initState();

    if (widget.score > (prefs.get('highscore_${widget.mode.name}') ?? 0)) {
      prefs.setInt('highscore_${widget.mode.name}', widget.score);
      newHigh = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//      _bannerAd = BannerAd(
//          adUnitId: AdManager.bannerAdUnitId, size: AdSize.smartBanner);
//      _bannerAd
//        ..load()
//        ..show(anchorType: AnchorType.top, anchorOffset: topPadding);
      if (widget.won || newHigh) cycle();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void blinkButton({int color = -1}) {
    switch (color) {
      case 0:
        setState(() {
          _buttonTL = !_buttonTL;
        });
        Timer(duration, () => setState(() => _buttonTL = !_buttonTL));
        break;
      case 1:
        setState(() {
          _buttonTR = !_buttonTR;
        });
        Timer(duration, () => setState(() => _buttonTR = !_buttonTR));
        break;
      case 2:
        setState(() {
          _buttonBL = !_buttonBL;
        });
        Timer(duration, () => setState(() => _buttonBL = !_buttonBL));
        break;
      case 3:
        setState(() {
          _buttonBR = !_buttonBR;
        });
        Timer(duration, () => setState(() => _buttonBR = !_buttonBR));
        break;
    }
  }

  void cycle() {
    Timer(duration, () {
      blinkButton(color: 0);
      Timer(duration, () {
        blinkButton(color: 1);
        Timer(duration, () {
          blinkButton(color: 3);
          Timer(duration, () {
            blinkButton(color: 2);
            cycle();
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(children: <Widget>[
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

                /// OPTIONAL ADS
//                supportTextShown
//                    ? Container()
//                    : Column(children: [
//                        Text(
//                          'Feeling generous? Support the developer through ads',
//                          textAlign: TextAlign.center,
//                          style: TextStyle(
//                              fontSize: 18,
//                              color: Colors.white,
//                              fontWeight: FontWeight.bold),
//                        ),
//                        Padding(
//                          padding: const EdgeInsets.all(8.0),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                            children: [
//                              RaisedButton(
//                                child: Text(
//                                  'Sure',
//                                  style: TextStyle(color: Colors.white),
//                                ),
//                                color: Colors.blue[600],
//                                shape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(5)),
//                                onPressed: () {
//                                  prefs.setBool('ads', true);
//                                  _interstitialAd = InterstitialAd(
//                                    adUnitId: AdManager.interstitialAdUnitId,
//                                  );
//                                  _interstitialAd
//                                    ..load()
//                                    ..show(anchorType: AnchorType.top);
//                                  setState(() {
//                                    supportTextShown = true;
//                                  });
//                                },
//                              ),
//                              RaisedButton(
//                                  child: Text('No Thanks'),
//                                  shape: RoundedRectangleBorder(
//                                      borderRadius: BorderRadius.circular(5)),
//                                  onPressed: () => setState(
//                                        () => supportTextShown = true,
//                                      ))
//                            ],
//                          ),
//                        ),
//                      ]),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.mode.name,
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'bungee_inline',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: widget.won
                      ? Text(
                          widget.mode.difficulty == 1
                              ? 'Mediocre performance but...\n\nYou Win!'
                              : widget.mode.difficulty == 2
                                  ? 'Pretty Good, could be MUCH better but...\n\nYou Win!!'
                                  : "You're INSANE!!!\n\nYou OWN the game!!!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              fontFamily: 'bungee_inline'),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text('Game Over',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'audiowide',
                                        fontSize: 36)),
                              ),
                            ),
                            Flexible(
                              child: Hero(
                                tag: 'logo',
                                child: GestureDetector(
                                  onTap: () => prefs
                                      .setBool('squares', !prefs.get('squares'))
                                      .then((value) => setState(() {})),
                                  child: Image.asset(
                                    'assets/images/logoHD.png',
                                    filterQuality: FilterQuality.high,
                                    height: 250,
                                    width: 250,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text('Score:  ${widget.score}',
                                    style: TextStyle(
                                        fontFamily: 'audiowide', fontSize: 25)),
                              ),
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                    newHigh
                                        ? 'NEW HIGH SCORE!'
                                        : 'High Score:  ${prefs.get('highscore_${widget.mode.name}')}',
                                    style: TextStyle(
                                        fontWeight: newHigh
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontFamily: 'audiowide',
                                        fontSize: 25)),
                              ),
                            ),
                          ],
                        ),
                )
              ])),
        ),
      ),
      floatingActionButton: Row(
        children: <Widget>[
          Flexible(
            child: Listener(
              onPointerDown: (details) {
                _bannerAd?.dispose();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ModePage(details: details)));
              },
              child: OutlineButton(
                  onPressed: () {},
                  borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  shape: StadiumBorder(),
                  child: Text('  Modes  ',
                      style: TextStyle(
                          fontFamily: 'bungee_inline',
                          fontSize: 25,
                          color: Colors.deepPurpleAccent))),
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 10,
          ),
          Flexible(
            child: OutlineButton(
                borderSide: BorderSide(color: Colors.deepPurpleAccent),
                shape: StadiumBorder(),
                child: Text('Restart',
                    style: TextStyle(
                        fontFamily: 'bungee_inline',
                        fontSize: 25,
                        color: Colors.deepPurpleAccent)),
                onPressed: () {
                  _bannerAd?.dispose();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          GamePage(widget.mode)));
                }),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
