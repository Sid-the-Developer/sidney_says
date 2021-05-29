import 'package:flutter/material.dart';

import 'main.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text('Settings', style: TextStyle(fontFamily: 'audiowide')),
            backgroundColor: Colors.blue),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: ListTile.divideTiles(context: context, tiles: [
//            OPTIONAL ADS
//            SwitchListTile(
//              title: Text(
//                'Ads',
//              ),
//              subtitle: Text('Show ads to support the developer'),
//              value: prefs.getBool('ads'),
//              onChanged: (value) {
//                prefs.setBool('ads', value).then((value) => setState(() {}));
//              },
//            ),
            SwitchListTile(
                title: Text('Square color buttons'),
                subtitle: Text('Show square buttons for easier visibility'),
                value: prefs.getBool('squares'),
                onChanged: (value) => prefs
                    .setBool('squares', value)
                    .then((value) => setState(() {}))),
            Column(
              children: [
                ListTile(
                  title: Text('Button blink duration'),
                  subtitle: Text('How long a button stays highlighted'),
                ),
                Slider(
                    value: prefs.get('blink_duration'),
                    min: .3,
                    max: 1,
                    divisions: 7,
                    label: prefs.get('blink_duration').toStringAsFixed(2) +
                        " seconds",
                    onChanged: (double value) {
                      setState(() {
                        prefs.setDouble('blink_duration', value);
                      });
                    }),
              ],
            ),
            SwitchListTile(
                title: Text('Coming Soon'),
                subtitle: Text('Buttons play sounds in game'),
                value: prefs.getBool('sound'),
                onChanged: (value) => prefs
                    .setBool('sound', value)
                    .then((value) => setState(() {}))),
            SwitchListTile(
              title: Text(
                'Coming Soon',
              ),
              subtitle:
                  Text('Compare your scores in local and global leaderboards'),
              value: prefs.getBool('leaderboard'),
              onChanged: (value) => prefs
                  .setBool('leaderboard', value)
                  .then((value) => setState(() {})),
            ),
            ListTile(
              title: Text('Stats'),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      children: ListTile.divideTiles(context: context, tiles: [
                        ListTile(
                          title: Text("## games played"),
                          subtitle: Text('Favorite mode: \nFavorite scheme: '),
                        ),
                        ListTile(
                          title: Text('Colors'),
                          subtitle: Text(
                              'You pressed yellow times:\nYou pressed green times:'
                              '\nYou pressed blue times:\nYou pressed red times:'),
                          isThreeLine: true,
                        ),
                        ListTile(
                          title: Text('Normal'),
//                          trailing: Text('Complete!'),
                          subtitle: Text(
                              'Best:  ${prefs.get('highscore_normal') ?? 0}\n'
                              "## games with ## rounds played"),
                        ),
                        ListTile(
                          title: Text('Medium'),
//                          trailing: Text('Complete!'),
                          subtitle: Text(
                              'Best:  ${prefs.get('highscore_medium') ?? 0}\n'
                              "## games with ## rounds played"),
                        ),
                        ListTile(
                          title: Text('Insane'),
//                          trailing: Text('Complete!'),
                          subtitle: Text(
                              'Best:  ${prefs.get('highscore_insane') ?? 0}\n'
                              "## games with ## rounds played"),
                        ),
                      ]).toList(),
                    );
                  }),
            )
          ]).toList(),
        ));
  }
}
