library emoji_picker_2;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:emoji_picker_2/emoji_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'category.dart';
import 'emoji_lists.dart' as emojiList;

import 'package:shared_preferences/shared_preferences.dart';

/// Enum to alter the keyboard button style
enum ButtonMode {
  /// Android button style - gives the button a splash color with ripple effect
  MATERIAL,

  /// iOS button style - gives the button a fade out effect when pressed
  CUPERTINO
}

/// Callback function for when emoji is selected
///
/// The function returns the selected [Emoji] as well as the [Category] from which it originated
typedef void OnEmojiSelected(Emoji emoji, Category category);

/// The Emoji Keyboard widget
///
/// This widget displays a grid of [Emoji] sorted by [Category] which the user can horizontally scroll through.
///
/// There is also a bottombar which displays all the possible [Category] and allow the user to quickly switch to that [Category]
class EmojiPicker2 extends StatefulWidget {
  @override
  _EmojiPickerState createState() => new _EmojiPickerState();

  /// Number of columns in keyboard grid
  int columns;

  /// Number of rows in keyboard grid
  int rows;

  /// The currently selected [Category]
  ///
  /// This [Category] will have its button in the bottombar darkened
  Category selectedCategory;

  /// The function called when the emoji is selected
  OnEmojiSelected onEmojiSelected;

  /// The background color of the keyboard
  Color bgColor;

  /// The color of the keyboard page indicator
  Color indicatorColor;

  Color progressIndicatorColor;

  Color _defaultBgColor = Color.fromRGBO(242, 242, 242, 1);

  /// A list of keywords that are used to provide the user with recommended emojis in [Category.Recommended]
  List<String> recommendKeywords;

  /// The maximum number of emojis to be recommended
  int numRecommended;

  /// The string to be displayed if no recommendations found
  String noRecommendationsText;

  /// The text style for the [noRecommendationsText]
  TextStyle noRecommendationsStyle;

  /// The string to be displayed if no recent emojis to display
  String noRecentsText;

  /// The text style for the [noRecentsText]
  TextStyle noRecentsStyle;

  /// Determines the icon to display for each [Category]
  CategoryIcons categoryIcons;

  /// Determines the style given to the keyboard keys
  ButtonMode buttonMode;

  EmojiPicker2({
    Key key,
    @required this.onEmojiSelected,
    this.columns = 7,
    this.rows = 3,
    this.selectedCategory,
    this.bgColor,
    this.indicatorColor = Colors.blue,
    this.progressIndicatorColor = Colors.blue,
    this.recommendKeywords,
    this.numRecommended = 10,
    this.noRecommendationsText = "No Recommendations",
    this.noRecommendationsStyle,
    this.noRecentsText = "No Recents",
    this.noRecentsStyle,
    this.categoryIcons,
    this.buttonMode = ButtonMode.MATERIAL,
    //this.unavailableEmojiIcon,
  }) : super(key: key) {
    if (selectedCategory == null) {
      if (recommendKeywords == null) {
        selectedCategory = Category.Smileys;
      } else {
        selectedCategory = Category.Recommended;
      }
    } else if (recommendKeywords == null &&
        selectedCategory == Category.Recommended) {
      selectedCategory = Category.Smileys;
    }

    if (this.noRecommendationsStyle == null) {
      noRecommendationsStyle = TextStyle(fontSize: 20, color: Colors.black26);
    }

    if (this.noRecentsStyle == null) {
      noRecentsStyle = TextStyle(fontSize: 20, color: Colors.black26);
    }

    if (this.bgColor == null) {
      bgColor = _defaultBgColor;
    }

    if (categoryIcons == null) {
      categoryIcons = CategoryIcons();
    }
  }
}

class _Recommended {
  final String name;
  final String emoji;
  final int tier;
  final int numSplitEqualKeyword;
  final int numSplitPartialKeyword;

  _Recommended(
      {this.name,
      this.emoji,
      this.tier,
      this.numSplitEqualKeyword = 0,
      this.numSplitPartialKeyword = 0});
}

/// Class that defines the icon representing a [Category]
class CategoryIcon {
  /// The icon to represent the category
  IconData icon;

  /// The default color of the icon
  Color color;

  /// The color of the icon once the category is selected
  Color selectedColor;

  CategoryIcon({@required this.icon, this.color, this.selectedColor}) {
    if (this.color == null) {
      this.color = Color.fromRGBO(211, 211, 211, 1);
    }
    if (this.selectedColor == null) {
      this.selectedColor = Color.fromRGBO(178, 178, 178, 1);
    }
  }
}

/// Class used to define all the [CategoryIcon] shown for each [Category]
///
/// This allows the keyboard to be personalized by changing icons shown.
/// If a [CategoryIcon] is set as null or not defined during initialization, the default icons will be used instead
class CategoryIcons {
  /// Icon for [Category.Recommended]
  CategoryIcon recommendationIcon;

  /// Icon for [Category.Recent]
  CategoryIcon recentIcon;

  /// Icon for [Category.Smileys]
  CategoryIcon smileyIcon;

  /// Icon for [Category.Animals]
  CategoryIcon animalIcon;

  /// Icon for [Category.Foods]
  CategoryIcon foodIcon;

  /// Icon for [Category.Travel]
  CategoryIcon travelIcon;

  /// Icon for [Category.Activities]
  CategoryIcon activityIcon;

  /// Icon for [Category.Objects]
  CategoryIcon objectIcon;

  /// Icon for [Category.Symbols]
  CategoryIcon symbolIcon;

  /// Icon for [Category.Flags]
  CategoryIcon flagIcon;

  CategoryIcons(
      {this.recommendationIcon,
      this.recentIcon,
      this.smileyIcon,
      this.animalIcon,
      this.foodIcon,
      this.travelIcon,
      this.activityIcon,
      this.objectIcon,
      this.symbolIcon,
      this.flagIcon}) {
    if (recommendationIcon == null) {
      recommendationIcon = CategoryIcon(icon: Icons.search);
    }
    if (recentIcon == null) {
      recentIcon = CategoryIcon(icon: Icons.access_time);
    }
    if (smileyIcon == null) {
      smileyIcon = CategoryIcon(icon: Icons.tag_faces);
    }
    if (animalIcon == null) {
      animalIcon = CategoryIcon(icon: Icons.pets);
    }
    if (foodIcon == null) {
      foodIcon = CategoryIcon(icon: Icons.fastfood);
    }
    if (travelIcon == null) {
      travelIcon = CategoryIcon(icon: Icons.location_city);
    }
    if (activityIcon == null) {
      activityIcon = CategoryIcon(icon: Icons.directions_run);
    }
    if (objectIcon == null) {
      objectIcon = CategoryIcon(icon: Icons.lightbulb_outline);
    }
    if (symbolIcon == null) {
      symbolIcon = CategoryIcon(icon: Icons.euro_symbol);
    }
    if (flagIcon == null) {
      flagIcon = CategoryIcon(icon: Icons.flag);
    }
  }
}

/// A class to store data for each individual emoji
class Emoji {
  /// The name or description for this emoji
  final String name;

  /// The unicode string for this emoji
  ///
  /// This is the string that should be displayed to view the emoji
  final String emoji;

  Emoji({@required this.name, @required this.emoji});

  @override
  String toString() {
    return "Name: " + name + ", Emoji: " + emoji;
  }
}

class _EmojiPickerState extends State<EmojiPicker2> {
  static const platform = const MethodChannel("emoji_picker_2");

  List<Widget> pages = [];
  int recommendedPagesNum;
  int recentPagesNum;
  int smileyPagesNum;
  int animalPagesNum;
  int foodPagesNum;
  int travelPagesNum;
  int activityPagesNum;
  int objectPagesNum;
  int symbolPagesNum;
  int flagPagesNum;
  List<String> allNames = [];
  List<String> allEmojis = [];
  List<String> recentEmojis = [];

  LinkedHashMap<String, String> smileyMap = new LinkedHashMap();
  LinkedHashMap<String, String> animalMap = new LinkedHashMap();
  LinkedHashMap<String, String> foodMap = new LinkedHashMap();
  LinkedHashMap<String, String> travelMap = new LinkedHashMap();
  LinkedHashMap<String, String> activityMap = new LinkedHashMap();
  LinkedHashMap<String, String> objectMap = new LinkedHashMap();
  LinkedHashMap<String, String> symbolMap = new LinkedHashMap();
  LinkedHashMap<String, String> flagMap = new LinkedHashMap();

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    updateEmojis().then((_) {
      loaded = true;
    });
  }

  List<int> units(codepoint) {
    final int tmp = codepoint - 0x10000;
    final padded = tmp.toRadixString(2).padLeft(20, '0');
    final unit1 = int.parse(padded.substring(0, 10), radix: 2) + 0xD800;
    final unit2 = int.parse(padded.substring(10), radix: 2) + 0xDC00;

    return [unit1, unit2];
  }

  bool canApplySkinColor(String emoji) {
    // Simulate text and measure width
    var textStyle = TextStyle();
    final TextPainter emojiTextPainter = TextPainter(
      text: TextSpan(text: emoji + "🏻", style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final TextPainter singleCharTextPainter = TextPainter(
      text: TextSpan(text: emoji, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return emojiTextPainter.width == singleCharTextPainter.width;

    // Previous implementation

    return EmojiCharacter.emojiList
        .firstWhere((e) => e.emoji == emoji)
        .applySkinTone;
  }

  Future<String> skinColorDialog(BuildContext context, String emoji) async {
    var returnEmoji;

    final Function onTap = (BuildContext context, {int skinCode}) {
      returnEmoji = skinCode == null
          ? emoji
          : String.fromCharCodes([...emoji.codeUnits, ...units(skinCode)]);
    };

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick emoji skin color',
              style: Theme.of(context).textTheme.subtitle1),
          content: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                  child: Text(emoji),
                  onTap: () {
                    onTap(context, skinCode: null);
                    Navigator.pop(context);
                  }),
              for (var skinCode in [
                0x1F3FB,
                0x1F3FC,
                0x1F3FD,
                0x1F3FE,
                0x1F3FF
              ])
                GestureDetector(
                  child: Text(String.fromCharCodes(
                      [...emoji.codeUnits, ...units(skinCode)])),
                  onTap: () {
                    onTap(context, skinCode: skinCode);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );

    return returnEmoji;
  }

  Future<bool> _isEmojiAvailable(String emoji) async {
    if (Platform.isAndroid) {
      bool isAvailable;
      try {
        isAvailable =
            await platform.invokeMethod("isAvailable", {"emoji": emoji});
      } on PlatformException catch (_) {
        isAvailable = false;
      }
      return isAvailable;
    } else {
      return true;
    }
  }

  /// Mutating function removing unsupported emojis from the input list
  void _filterUnsupportedEmojis(LinkedHashMap<String, String> emoji) async {
    if (Platform.isAndroid) {
      LinkedHashMap<String, String> filtered;
      try {
        var temp =
            await platform.invokeMethod("checkAvailability", {'emoji': emoji});
        filtered = LinkedHashMap<String, String>.from(temp);
      } on PlatformException catch (_) {
        filtered = null;
      }

      // Filter the emojis that have been filtered.
      emoji.removeWhere((key, value) => !filtered.containsValue(value));
    }
  }

  SharedPreferences _sharedPreferences;

  Future<List<String>> getRecentEmojis() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    final key = "recents";
    recentEmojis = _sharedPreferences.getStringList(key) ?? [];
    return recentEmojis;
  }

  void addRecentEmoji(Emoji emoji) async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    final key = "recents";
    getRecentEmojis().then((_) {
      print("adding emoji");
      setState(() {
        recentEmojis.insert(0, emoji.name);
        _sharedPreferences.setStringList(key, recentEmojis);
      });
    });
  }

  Future<LinkedHashMap<String, String>> getAvailableEmojis(
      LinkedHashMap<String, String> map,
      {@required String title}) async {
    LinkedHashMap<String, String> newMap = restoreFilteredEmojis(title);

    if (newMap != null) {
      return newMap;
    } else {
      await _filterUnsupportedEmojis(map);

      cacheFilteredEmojis(title, map);

      return map;
    }
  }

  void cacheFilteredEmojis(String title, LinkedHashMap<String, String> emojis) {
    String emojiJson = jsonEncode(emojis);
    _sharedPreferences.setString(title, emojiJson);
    return;
  }

  LinkedHashMap<String, String> restoreFilteredEmojis(String title) {
    String emojiJson = _sharedPreferences.getString(title);
    if (emojiJson == null) {
      return null;
    }
    LinkedHashMap<String, String> emojis =
        LinkedHashMap<String, String>.from(jsonDecode(emojiJson));
    return emojis;
  }

  Future updateEmojis() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    smileyMap = await getAvailableEmojis(emojiList.smileys, title: 'smileys');
    animalMap = await getAvailableEmojis(emojiList.animals, title: 'animals');
    foodMap = await getAvailableEmojis(emojiList.foods, title: 'foods');
    travelMap = await getAvailableEmojis(emojiList.travel, title: 'travel');
    activityMap =
        await getAvailableEmojis(emojiList.activities, title: 'activities');
    objectMap = await getAvailableEmojis(emojiList.objects, title: 'objects');
    symbolMap = await getAvailableEmojis(emojiList.symbols, title: 'symbols');
    flagMap = await getAvailableEmojis(emojiList.flags, title: 'flags');

    allNames.addAll(smileyMap.keys);
    allNames.addAll(animalMap.keys);
    allNames.addAll(foodMap.keys);
    allNames.addAll(travelMap.keys);
    allNames.addAll(activityMap.keys);
    allNames.addAll(objectMap.keys);
    allNames.addAll(symbolMap.keys);
    allNames.addAll(flagMap.keys);

    allEmojis.addAll(smileyMap.values);
    allEmojis.addAll(animalMap.values);
    allEmojis.addAll(foodMap.values);
    allEmojis.addAll(travelMap.values);
    allEmojis.addAll(activityMap.values);
    allEmojis.addAll(objectMap.values);
    allEmojis.addAll(symbolMap.values);
    allEmojis.addAll(flagMap.values);

    recommendedPagesNum = 0;
    List<_Recommended> recommendedEmojis = [];
    List<Widget> recommendedPages = [];

    final onPressed =
        (int index, int i, LinkedHashMap<String, String> emojiMap) async {
      var emoji =
          emojiMap.values.toList()[index + (widget.columns * widget.rows * i)];

      if (canApplySkinColor(emoji)) {
        // Present / await skin tone dialog and callback on select
        await skinColorDialog(context, emoji).then((returnEmoji) =>
            widget.onEmojiSelected(
                Emoji(
                    name: emojiMap.keys
                        .toList()[index + (widget.columns * widget.rows * i)],
                    emoji: returnEmoji),
                widget.selectedCategory));
      } else {
        // Callback with selected emoji
        widget.onEmojiSelected(
            Emoji(
                name: emojiMap.keys
                    .toList()[index + (widget.columns * widget.rows * i)],
                emoji: emoji),
            widget.selectedCategory);
      }
    };

    if (widget.recommendKeywords != null) {
      allNames.forEach((name) {
        int numSplitEqualKeyword = 0;
        int numSplitPartialKeyword = 0;

        widget.recommendKeywords.forEach((keyword) {
          if (name.toLowerCase() == keyword.toLowerCase()) {
            recommendedEmojis.add(_Recommended(
                name: name, emoji: allEmojis[allNames.indexOf(name)], tier: 1));
          } else {
            List<String> splitName = name.split(" ");

            splitName.forEach((splitName) {
              if (splitName.replaceAll(":", "").toLowerCase() ==
                  keyword.toLowerCase()) {
                numSplitEqualKeyword += 1;
              } else if (splitName
                  .replaceAll(":", "")
                  .toLowerCase()
                  .contains(keyword.toLowerCase())) {
                numSplitPartialKeyword += 1;
              }
            });
          }
        });

        if (numSplitEqualKeyword > 0) {
          if (numSplitEqualKeyword == name.split(" ").length) {
            recommendedEmojis.add(_Recommended(
                name: name, emoji: allEmojis[allNames.indexOf(name)], tier: 1));
          } else {
            recommendedEmojis.add(_Recommended(
                name: name,
                emoji: allEmojis[allNames.indexOf(name)],
                tier: 2,
                numSplitEqualKeyword: numSplitEqualKeyword,
                numSplitPartialKeyword: numSplitPartialKeyword));
          }
        } else if (numSplitPartialKeyword > 0) {
          recommendedEmojis.add(_Recommended(
              name: name,
              emoji: allEmojis[allNames.indexOf(name)],
              tier: 3,
              numSplitPartialKeyword: numSplitPartialKeyword));
        }
      });

      recommendedEmojis.sort((a, b) {
        if (a.tier < b.tier) {
          return -1;
        } else if (a.tier > b.tier) {
          return 1;
        } else {
          if (a.tier == 1) {
            if (a.name.split(" ").length > b.name.split(" ").length) {
              return -1;
            } else if (a.name.split(" ").length < b.name.split(" ").length) {
              return 1;
            } else {
              return 0;
            }
          } else if (a.tier == 2) {
            if (a.numSplitEqualKeyword > b.numSplitEqualKeyword) {
              return -1;
            } else if (a.numSplitEqualKeyword < b.numSplitEqualKeyword) {
              return 1;
            } else {
              if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
                return -1;
              } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
                return 1;
              } else {
                if (a.name.split(" ").length < b.name.split(" ").length) {
                  return -1;
                } else if (a.name.split(" ").length >
                    b.name.split(" ").length) {
                  return 1;
                } else {
                  return 0;
                }
              }
            }
          } else if (a.tier == 3) {
            if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
              return -1;
            } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
              return 1;
            } else {
              return 0;
            }
          }
        }

        return 0;
      });

      if (recommendedEmojis.length > widget.numRecommended) {
        recommendedEmojis =
            recommendedEmojis.getRange(0, widget.numRecommended).toList();
      }

      if (recommendedEmojis.length != 0) {
        recommendedPagesNum =
            (recommendedEmojis.length / (widget.rows * widget.columns)).ceil();

        for (var i = 0; i < recommendedPagesNum; i++) {
          recommendedPages.add(Container(
            color: widget.bgColor,
            child: GridView.count(
              shrinkWrap: true,
              primary: true,
              crossAxisCount: widget.columns,
              children: List.generate(widget.rows * widget.columns, (index) {
                if (index + (widget.columns * widget.rows * i) <
                    recommendedEmojis.length) {
                  switch (widget.buttonMode) {
                    case ButtonMode.MATERIAL:
                      return Center(
                          child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(0),
                        ),
                        child: Center(
                          child: Text(
                            recommendedEmojis[
                                    index + (widget.columns * widget.rows * i)]
                                .emoji,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        onPressed: () {
                          _Recommended recommended = recommendedEmojis[
                              index + (widget.columns * widget.rows * i)];
                          widget.onEmojiSelected(
                              Emoji(
                                  name: recommended.name,
                                  emoji: recommended.emoji),
                              widget.selectedCategory);
                          addRecentEmoji(Emoji(
                              name: recommended.name,
                              emoji: recommended.emoji));
                        },
                      ));
                      break;
                    case ButtonMode.CUPERTINO:
                      return Center(
                          child: CupertinoButton(
                        pressedOpacity: 0.4,
                        padding: EdgeInsets.all(0),
                        child: Center(
                          child: Text(
                            recommendedEmojis[
                                    index + (widget.columns * widget.rows * i)]
                                .emoji,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        onPressed: () {
                          _Recommended recommended = recommendedEmojis[
                              index + (widget.columns * widget.rows * i)];
                          widget.onEmojiSelected(
                              Emoji(
                                  name: recommended.name,
                                  emoji: recommended.emoji),
                              widget.selectedCategory);
                          addRecentEmoji(Emoji(
                              name: recommended.name,
                              emoji: recommended.emoji));
                        },
                      ));

                      break;
                    default:
                      return Container();
                      break;
                  }
                } else {
                  return Container();
                }
              }),
            ),
          ));
        }
      } else {
        recommendedPagesNum = 1;

        recommendedPages.add(Container(
            color: widget.bgColor,
            child: Center(
                child: Text(
              widget.noRecommendationsText,
              style: widget.noRecommendationsStyle,
            ))));
      }
    }

    List<Widget> recentPages = [];
    recentPagesNum = 1;
    recentPages.add(recentPage());

    smileyPagesNum =
        (smileyMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();
    animalPagesNum =
        (animalMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();
    foodPagesNum =
        (foodMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();
    travelPagesNum =
        (travelMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();
    activityPagesNum =
        (activityMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();
    objectPagesNum =
        (objectMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();
    symbolPagesNum =
        (symbolMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();
    flagPagesNum =
        (flagMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();

    List<Widget> smileyPages = getPages(smileyMap, smileyPagesNum, onPressed);
    List<Widget> animalPages = getPages(animalMap, animalPagesNum, onPressed);
    List<Widget> foodPages = getPages(foodMap, foodPagesNum, onPressed);
    List<Widget> travelPages = getPages(travelMap, travelPagesNum, onPressed);
    List<Widget> activityPages =
        getPages(activityMap, activityPagesNum, onPressed);
    List<Widget> objectPages = getPages(objectMap, objectPagesNum, onPressed);
    List<Widget> symbolPages = getPages(symbolMap, symbolPagesNum, onPressed);
    List<Widget> flagPages = getPages(flagMap, flagPagesNum, onPressed);

    pages.addAll(recommendedPages);
    pages.addAll(recentPages);
    pages.addAll(smileyPages);
    pages.addAll(animalPages);
    pages.addAll(foodPages);
    pages.addAll(travelPages);
    pages.addAll(activityPages);
    pages.addAll(objectPages);
    pages.addAll(symbolPages);
    pages.addAll(flagPages);

    getRecentEmojis().then((_) {
      pages.removeAt(recommendedPagesNum);
      pages.insert(recommendedPagesNum, recentPage());
      if (mounted) setState(() {});
    });
  }

  Widget recentPage() {
    if (recentEmojis.length != 0) {
      return Container(
          color: widget.bgColor,
          child: GridView.count(
            shrinkWrap: true,
            primary: true,
            crossAxisCount: widget.columns,
            children: List.generate(widget.rows * widget.columns, (index) {
              if (index < recentEmojis.length) {
                switch (widget.buttonMode) {
                  case ButtonMode.MATERIAL:
                    return Center(
                        child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),
                      ),
                      child: Center(
                        child: Text(
                          allEmojis[allNames.indexOf(recentEmojis[index])],
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        String emojiName = recentEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: emojiName,
                                emoji: allEmojis[allNames.indexOf(emojiName)]),
                            widget.selectedCategory);
                      },
                    ));
                    break;
                  case ButtonMode.CUPERTINO:
                    return Center(
                        child: CupertinoButton(
                      pressedOpacity: 0.4,
                      padding: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          allEmojis[allNames.indexOf(recentEmojis[index])],
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        String emojiName = recentEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: emojiName,
                                emoji: allEmojis[allNames.indexOf(emojiName)]),
                            widget.selectedCategory);
                      },
                    ));

                    break;
                  default:
                    return Container();
                    break;
                }
              } else {
                return Container();
              }
            }),
          ));
    } else {
      return Container(
          color: widget.bgColor,
          child: Center(
              child: Text(
            widget.noRecentsText,
            style: widget.noRecentsStyle,
          )));
    }
  }

  List<Widget> getPages(
      LinkedHashMap<String, String> map,
      int numPages,
      Future<Null> Function(int, int, LinkedHashMap<String, String>)
          onPressed) {
    List<Widget> pages = [];

    for (var i = 0; i < numPages; i++) {
      pages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(widget.rows * widget.columns, (index) {
            if (index + (widget.columns * widget.rows * i) <
                map.values.toList().length) {
              String emojiTxt = map.values
                  .toList()[index + (widget.columns * widget.rows * i)];

              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(0),
                          ),
                          child: Center(
                            child: Text(
                              emojiTxt,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          onPressed: () => onPressed(index, i, map)));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                          pressedOpacity: 0.4,
                          padding: EdgeInsets.all(0),
                          child: Center(
                            child: Text(
                              emojiTxt,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          onPressed: () => onPressed(index, i, map)));
                  break;
                default:
                  return Container();
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    return pages;
  }

  Widget defaultButton(CategoryIcon categoryIcon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width /
          (widget.recommendKeywords == null ? 9 : 10),
      height: MediaQuery.of(context).size.width /
          (widget.recommendKeywords == null ? 9 : 10),
      child: Container(
        color: widget.bgColor,
        child: Center(
          child: Icon(
            categoryIcon.icon,
            size: 22,
            color: categoryIcon.color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      pages.removeAt(recommendedPagesNum);
      pages.insert(recommendedPagesNum, recentPage());

      PageController pageController;
      if (widget.selectedCategory == Category.Recommended) {
        pageController = PageController(initialPage: 0);
      } else if (widget.selectedCategory == Category.Recent) {
        pageController = PageController(initialPage: recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Smileys) {
        pageController =
            PageController(initialPage: recentPagesNum + recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Animals) {
        pageController = PageController(
            initialPage: smileyPagesNum + recentPagesNum + recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Foods) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Travel) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Activities) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Objects) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                activityPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Symbols) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                activityPagesNum +
                objectPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (widget.selectedCategory == Category.Flags) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                activityPagesNum +
                objectPagesNum +
                symbolPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      }

      pageController.addListener(() {
        setState(() {});
      });

      return Column(
        children: <Widget>[
          SizedBox(
            height: (MediaQuery.of(context).size.width / widget.columns) *
                widget.rows,
            width: MediaQuery.of(context).size.width,
            child: PageView(
                children: pages,
                controller: pageController,
                onPageChanged: (index) {
                  if (widget.recommendKeywords != null &&
                      index < recommendedPagesNum) {
                    widget.selectedCategory = Category.Recommended;
                  } else if (index < recentPagesNum + recommendedPagesNum) {
                    widget.selectedCategory = Category.Recent;
                  } else if (index <
                      recentPagesNum + smileyPagesNum + recommendedPagesNum) {
                    widget.selectedCategory = Category.Smileys;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.Animals;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.Foods;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.Travel;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          activityPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.Activities;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          activityPagesNum +
                          objectPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.Objects;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          activityPagesNum +
                          objectPagesNum +
                          symbolPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.Symbols;
                  } else {
                    widget.selectedCategory = Category.Flags;
                  }
                }),
          ),
          Container(
              color: widget.bgColor,
              height: 6,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 4, bottom: 0, right: 2, left: 2),
              child: CustomPaint(
                painter: _ProgressPainter(
                    context,
                    pageController,
                    new Map.fromIterables([
                      Category.Recommended,
                      Category.Recent,
                      Category.Smileys,
                      Category.Animals,
                      Category.Foods,
                      Category.Travel,
                      Category.Activities,
                      Category.Objects,
                      Category.Symbols,
                      Category.Flags
                    ], [
                      recommendedPagesNum,
                      recentPagesNum,
                      smileyPagesNum,
                      animalPagesNum,
                      foodPagesNum,
                      travelPagesNum,
                      activityPagesNum,
                      objectPagesNum,
                      symbolPagesNum,
                      flagPagesNum
                    ]),
                    widget.selectedCategory,
                    widget.indicatorColor),
              )),
          Container(
              height: 50,
              color: widget.bgColor,
              child: Row(
                children: <Widget>[
                  widget.recommendKeywords != null
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width / 10,
                          height: MediaQuery.of(context).size.width / 10,
                          child: widget.buttonMode == ButtonMode.MATERIAL
                              ? TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.all(0),
                                      backgroundColor:
                                          widget.selectedCategory ==
                                                  Category.Recommended
                                              ? Colors.black12
                                              : Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0)))),
                                  child: Center(
                                    child: Icon(
                                      widget.categoryIcons.recommendationIcon
                                          .icon,
                                      size: 22,
                                      color: widget.selectedCategory ==
                                              Category.Recommended
                                          ? widget.categoryIcons
                                              .recommendationIcon.selectedColor
                                          : widget.categoryIcons
                                              .recommendationIcon.color,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (widget.selectedCategory ==
                                        Category.Recommended) {
                                      return;
                                    }

                                    pageController.jumpToPage(0);
                                  },
                                )
                              : CupertinoButton(
                                  pressedOpacity: 0.4,
                                  padding: EdgeInsets.all(0),
                                  color: widget.selectedCategory ==
                                          Category.Recommended
                                      ? Colors.black12
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0)),
                                  child: Center(
                                    child: Icon(
                                      widget.categoryIcons.recommendationIcon
                                          .icon,
                                      size: 22,
                                      color: widget.selectedCategory ==
                                              Category.Recommended
                                          ? widget.categoryIcons
                                              .recommendationIcon.selectedColor
                                          : widget.categoryIcons
                                              .recommendationIcon.color,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (widget.selectedCategory ==
                                        Category.Recommended) {
                                      return;
                                    }

                                    pageController.jumpToPage(0);
                                  },
                                ),
                        )
                      : Container(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Recent
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.recentIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Recent
                                        ? widget.categoryIcons.recentIcon
                                            .selectedColor
                                        : widget.categoryIcons.recentIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Recent) {
                                return;
                              }

                              pageController
                                  .jumpToPage(0 + recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Recent
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.recentIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Recent
                                        ? widget.categoryIcons.recentIcon
                                            .selectedColor
                                        : widget.categoryIcons.recentIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Recent) {
                                return;
                              }

                              pageController
                                  .jumpToPage(0 + recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Smileys
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.smileyIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Smileys
                                        ? widget.categoryIcons.smileyIcon
                                            .selectedColor
                                        : widget.categoryIcons.smileyIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Smileys) {
                                return;
                              }

                              pageController.jumpToPage(
                                  0 + recentPagesNum + recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Smileys
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.smileyIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Smileys
                                        ? widget.categoryIcons.smileyIcon
                                            .selectedColor
                                        : widget.categoryIcons.smileyIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Smileys) {
                                return;
                              }

                              pageController.jumpToPage(
                                  0 + recentPagesNum + recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Animals
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.animalIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Animals
                                        ? widget.categoryIcons.animalIcon
                                            .selectedColor
                                        : widget.categoryIcons.animalIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Animals) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Animals
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.animalIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Animals
                                        ? widget.categoryIcons.animalIcon
                                            .selectedColor
                                        : widget.categoryIcons.animalIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Animals) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Foods
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.foodIcon.icon,
                                size: 22,
                                color: widget.selectedCategory == Category.Foods
                                    ? widget
                                        .categoryIcons.foodIcon.selectedColor
                                    : widget.categoryIcons.foodIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Foods) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Foods
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.foodIcon.icon,
                                size: 22,
                                color: widget.selectedCategory == Category.Foods
                                    ? widget
                                        .categoryIcons.foodIcon.selectedColor
                                    : widget.categoryIcons.foodIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Foods) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Travel
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.travelIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Travel
                                        ? widget.categoryIcons.travelIcon
                                            .selectedColor
                                        : widget.categoryIcons.travelIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Travel) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Travel
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.travelIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Travel
                                        ? widget.categoryIcons.travelIcon
                                            .selectedColor
                                        : widget.categoryIcons.travelIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Travel) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Activities
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.activityIcon.icon,
                                size: 22,
                                color: widget.selectedCategory ==
                                        Category.Activities
                                    ? widget.categoryIcons.activityIcon
                                        .selectedColor
                                    : widget.categoryIcons.activityIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory ==
                                  Category.Activities) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color:
                                widget.selectedCategory == Category.Activities
                                    ? Colors.black12
                                    : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.activityIcon.icon,
                                size: 22,
                                color: widget.selectedCategory ==
                                        Category.Activities
                                    ? widget.categoryIcons.activityIcon
                                        .selectedColor
                                    : widget.categoryIcons.activityIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory ==
                                  Category.Activities) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Objects
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.objectIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Objects
                                        ? widget.categoryIcons.objectIcon
                                            .selectedColor
                                        : widget.categoryIcons.objectIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Objects) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Objects
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.objectIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Objects
                                        ? widget.categoryIcons.objectIcon
                                            .selectedColor
                                        : widget.categoryIcons.objectIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Objects) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Symbols
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.symbolIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Symbols
                                        ? widget.categoryIcons.symbolIcon
                                            .selectedColor
                                        : widget.categoryIcons.symbolIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Symbols) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Symbols
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.symbolIcon.icon,
                                size: 22,
                                color:
                                    widget.selectedCategory == Category.Symbols
                                        ? widget.categoryIcons.symbolIcon
                                            .selectedColor
                                        : widget.categoryIcons.symbolIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Symbols) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 9 : 10),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              backgroundColor:
                                  widget.selectedCategory == Category.Flags
                                      ? Colors.black12
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                            ),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.flagIcon.icon,
                                size: 22,
                                color: widget.selectedCategory == Category.Flags
                                    ? widget
                                        .categoryIcons.flagIcon.selectedColor
                                    : widget.categoryIcons.flagIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Flags) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  symbolPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: widget.selectedCategory == Category.Flags
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.flagIcon.icon,
                                size: 22,
                                color: widget.selectedCategory == Category.Flags
                                    ? widget
                                        .categoryIcons.flagIcon.selectedColor
                                    : widget.categoryIcons.flagIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (widget.selectedCategory == Category.Flags) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  symbolPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                ],
              ))
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          SizedBox(
            height: (MediaQuery.of(context).size.width / widget.columns) *
                widget.rows,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: widget.bgColor,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      widget.progressIndicatorColor),
                ),
              ),
            ),
          ),
          Container(
            height: 6,
            width: MediaQuery.of(context).size.width,
            color: widget.bgColor,
            padding: EdgeInsets.only(top: 4, left: 2, right: 2),
            child: Container(
              color: widget.indicatorColor,
            ),
          ),
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                widget.recommendKeywords != null
                    ? defaultButton(widget.categoryIcons.recommendationIcon)
                    : Container(),
                defaultButton(widget.categoryIcons.recentIcon),
                defaultButton(widget.categoryIcons.smileyIcon),
                defaultButton(widget.categoryIcons.animalIcon),
                defaultButton(widget.categoryIcons.foodIcon),
                defaultButton(widget.categoryIcons.travelIcon),
                defaultButton(widget.categoryIcons.activityIcon),
                defaultButton(widget.categoryIcons.objectIcon),
                defaultButton(widget.categoryIcons.symbolIcon),
                defaultButton(widget.categoryIcons.flagIcon),
              ],
            ),
          )
        ],
      );
    }
  }
}

class _ProgressPainter extends CustomPainter {
  final BuildContext context;
  final PageController pageController;
  final Map<Category, int> pages;
  final Category selectedCategory;
  final Color indicatorColor;

  _ProgressPainter(this.context, this.pageController, this.pages,
      this.selectedCategory, this.indicatorColor);

  @override
  void paint(Canvas canvas, Size size) {
    double actualPageWidth = MediaQuery.of(context).size.width;
    double offsetInPages = 0;
    if (selectedCategory == Category.Recommended) {
      offsetInPages = pageController.offset / actualPageWidth;
    } else if (selectedCategory == Category.Recent) {
      offsetInPages = (pageController.offset -
              (pages[Category.Recommended] * actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Smileys) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] + pages[Category.Recent]) *
                  actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Animals) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] +
                      pages[Category.Recent] +
                      pages[Category.Smileys]) *
                  actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Foods) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] +
                      pages[Category.Recent] +
                      pages[Category.Smileys] +
                      pages[Category.Animals]) *
                  actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Travel) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] +
                      pages[Category.Recent] +
                      pages[Category.Smileys] +
                      pages[Category.Animals] +
                      pages[Category.Foods]) *
                  actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Activities) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] +
                      pages[Category.Recent] +
                      pages[Category.Smileys] +
                      pages[Category.Animals] +
                      pages[Category.Foods] +
                      pages[Category.Travel]) *
                  actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Objects) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] +
                      pages[Category.Recent] +
                      pages[Category.Smileys] +
                      pages[Category.Animals] +
                      pages[Category.Foods] +
                      pages[Category.Travel] +
                      pages[Category.Activities]) *
                  actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Symbols) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] +
                      pages[Category.Recent] +
                      pages[Category.Smileys] +
                      pages[Category.Animals] +
                      pages[Category.Foods] +
                      pages[Category.Travel] +
                      pages[Category.Activities] +
                      pages[Category.Objects]) *
                  actualPageWidth)) /
          actualPageWidth;
    } else if (selectedCategory == Category.Flags) {
      offsetInPages = (pageController.offset -
              ((pages[Category.Recommended] +
                      pages[Category.Recent] +
                      pages[Category.Smileys] +
                      pages[Category.Animals] +
                      pages[Category.Foods] +
                      pages[Category.Travel] +
                      pages[Category.Activities] +
                      pages[Category.Objects] +
                      pages[Category.Symbols]) *
                  actualPageWidth)) /
          actualPageWidth;
    }
    double indicatorPageWidth = size.width / pages[selectedCategory];

    Rect bgRect = Offset(0, 0) & size;

    Rect indicator = Offset(max(0, offsetInPages * indicatorPageWidth), 0) &
        Size(
            indicatorPageWidth -
                max(
                    0,
                    (indicatorPageWidth +
                            (offsetInPages * indicatorPageWidth)) -
                        size.width) +
                min(0, offsetInPages * indicatorPageWidth),
            size.height);

    canvas.drawRect(bgRect, Paint()..color = Colors.black12);
    canvas.drawRect(indicator, Paint()..color = indicatorColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
