import 'dart:convert' as convert;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';
import 'package:youinroll.com/constant/api.dart';
import 'package:youinroll.com/constant/static_variables.dart';
import 'package:youinroll.com/helpers/print_response_error.dart';
import 'package:youinroll.com/pages_web/video_tape_page_for_cat_web.dart';
import 'package:youinroll.com/pages_web/web_widgets/video_tile.dart';
import 'package:youinroll.com/multilanguage/string_constants.dart';

import '../constant/helper.dart';
import '../multilanguage/languages.dart';
import '../project_data/project_data.dart';

class CategoryPageVideoWebForLoginUser extends StatefulWidget {
  final String catId;

  const CategoryPageVideoWebForLoginUser(
      this.catId, {
        Key? key,
      }) : super(key: key);

  @override
  State<CategoryPageVideoWebForLoginUser> createState() =>
      _CategoryPageVideoWebForLoginUserState();
}

class _CategoryPageVideoWebForLoginUserState
    extends State<CategoryPageVideoWebForLoginUser> {
  late bool isCatExist;
  late bool isUserSubbedToCat;
  int page = 1;

  String? token;

  List videos = [];

  bool isLoaded = false;
  bool isTokenLoaded = false;
  bool isCategoryInfoLoaded = false;

  String catName = '...';
  String catPictureLink = '...';
  String catAllFollowers = '...';
  String catAllViews = '...';

  String myUserAvatar = '';

  ScrollController? controller;
  ProjectData? pD;

  var showTrackedUsers = true;

  late final String catId;

  get http => null; //Its my change

  void loadMyUserData() async {
    Uri url = Uri.parse(
        'https://youinroll.com/profile/${StaticVariables.activeUserId}/info?api=v1.1');
    Response response = await get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var userData = jsonResponse['response'];
      myUserAvatar = userData["avatar"].toString();
    } else {
      printResponseError(
        what: 'current user data',
        file: 'category_page_video_web_for_login_user.dart',
        function: 'loadMyUserData()',
        api: 'profile/{userId}/info?api=v1.1',
        code: response.statusCode,
      );
    }
  }

  checkCatExist() async {
    await Future.delayed(
      const Duration(
        milliseconds: 1000,
      ),
    );
    // Uri url = Uri.https('https://youinroll.com/lib/ajax/getCategory.php'),
    //     body: {
    //  'cat_id': widget.catId,
    //  }
    //  Response response = await client.get(url);
    //  });
/////////
    Uri url = Uri.parse('https://youinroll.com/lib/ajax/getCategory.php?cat_id=${widget.catId}');
    Response response = await get(url);
//    var url = Uri.https('a~youinroll.com/lib/ajax/getCategory.php?cat_id=${widget.catId}');
//    var response = await http.get(url);

////////
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var check = jsonResponse['result'] as bool;
      isCatExist = check;
      if (!check) {
        context.go('/404');
      } else {
        var catInfo = jsonResponse['category'];
        catName = catInfo['cat_name'];
        catPictureLink = catInfo['picture'];
        catAllFollowers = catInfo['all_followers'];
        catAllViews = catInfo['all_views_cat'];
        setState(() {
          isCategoryInfoLoaded = true;
        });
      }
    } else {
      printResponseError(
        what: 'category subscription state',
        file: 'category_page_video_web_for_login_user.dart',
        function: 'checkCatExist()',
        api: 'getCategory.php',
        code: response.statusCode,
        info1: 'Category ID: ${widget.catId}',
      );
    }
  }

  void getUserToken() async {
    token = StaticVariables.token;
    final prefs = await SharedPreferences.getInstance();
    showTrackedUsers = prefs.getBool('showTrackedUsers') ?? true;
    checkCategorySubscription();
  }

  void saveShowTrackedUsersValueToPrefs(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showTrackedUsers', value);
  }

  void checkCategorySubscription() async {
    await Future.delayed(
      const Duration(
        milliseconds: 1000,
      ),
    );

    Uri url = Uri.parse('https://youinroll.com/lib/ajax/isSubscribeCat.php');
    Response response = await post(url, body: {
      'cat': widget.catId,
      'token': token,
    });

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonResponse = jsonDecode(response.body);
      var exists = jsonResponse['exists'] as bool;
      if (exists) {
        var check = jsonResponse['subscribe'] as bool;
        isUserSubbedToCat = check;
      }
    } else {
      printResponseError(
        what: 'subscribe status on current category',
        file: 'category_page_video_web_for_login_user.dart',
        function: 'checkCategorySubscription()',
        api: 'isSubscribeCat.php',
        code: response.statusCode,
        info1: 'Category ID: ${widget.catId}',
        info2: 'Token: $token',
      );
    }
    setState(() {
      isTokenLoaded = true;
    });
  }

  getVideos() async {
    try {
      if (page == 1) {
        await Future.delayed(
          const Duration(
            milliseconds: 1000,
          ),
        );
      }
      Uri url = Uri.parse(
          'https://youinroll.com/lib/ajax/getVideosByCat.php?cat=${widget.catId}&p=$page&lang=${languageList[StaticVariables.selectedLanguageIndex].langName}');
      Response response = await get(url);

      if (response.statusCode >= 200 && response.statusCode < 400) {
        var jsonResponse = jsonDecode(response.body);
        List curVideos = [];
        if (jsonResponse['videos'] != '') {
          curVideos = jsonResponse['videos'].toList();
        }
        if (jsonResponse['streams'] != null) {
          List streamList = jsonResponse['streams'];
          videos.addAll(streamList);
        }
        videos.addAll(curVideos);

        if (page < 2) {
          page++;
          getVideos();
        }
        setState(() {
          isLoaded = true;
        });

        if (page > 3) {

        }
      } else {
        printResponseError(
          what: 'category videos',
          file: 'category_page_video_web_for_login_user.dart',
          function: 'getVideos()',
          api: 'getVideosByCat',
          code: response.statusCode,
          info1: 'Category ID: ${widget.catId}',
          info2: 'Page: $page',
          info3:
          'Language: ${languageList[StaticVariables.selectedLanguageIndex].langName}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
        print('end videos');
      }
      return;
    }
  }

  void chooseCategorySubscribe() async {
    Uri url = Uri.parse('https://youinroll.com/lib/ajax/subscribeCat.php');
    Response response = await post(url, body: {
      'cat': widget.catId,
      'token': token,
    });
    if (kDebugMode) {
      print(response.body);
    }
  }

  Future<void> _scrollListener() async {
    if (controller!.position.extentAfter == 0) {
      Future.delayed(
        const Duration(
          seconds: 1,
        ),
      ).then((_) {
        page++;
        getVideos();
      });

    }
  }

  _generateAndShareDeepLink() {
    StaticVariables.shareDeepLink(context,
        '${charFromDeepLinkType(DeepLinkType.category)}_${widget.catId}');
  }

  @override
  void initState() {
    pD = Provider.of<ProjectData>(context, listen: false);
    checkCatExist();
    getUserToken();
    loadMyUserData();
    getVideos();
    controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void deactivate() {
    youInRollDebugPrint("CustomVideoPage, Deactivated");
    if (pD!.isFromDeepLinkOpened) {
      pD!.setIsFromDeepLinkOpened(value: false);
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    var querySize = MediaQuery.of(context).size;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/categories'),
        ),
        title: Text(categoryTr.trText),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              _generateAndShareDeepLink();
            },
            icon: SvgPicture.asset(
              "assets/Icons/message_icon.svg",
              width: 26,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.white54,
                        blurRadius: 15.0,
                        offset: Offset(0.0, 0.75),
                      ),
                    ],
                  ),
                  width: 150,
                  height: 150,
                  child: !isCategoryInfoLoaded
                      ? const Center(
                    child: CupertinoActivityIndicator(),
                  )
                      : Image.network('${Api.httpsDomain}$catPictureLink',
                      width: 100, fit: BoxFit.fitHeight),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: AutoSizeText(
                        catName,
                        minFontSize: 10,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: AutoSizeText(
                        '${viewersTr.trText}: $catAllViews',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: AutoSizeText(
                        '${followersTr.trText}: $catAllFollowers',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        //child: isCatExist
                        //    ? subscribeButtonWidget()
                        //    : const Text('Category is not exist'),
                        child: isTokenLoaded
                            ? subscribeButtonWidget()
                            : const CupertinoActivityIndicator(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            height: 44,
            thickness: 3,
            indent: 2,
            endIndent: 10,
          ),
          isLoaded
              ? Container(
              constraints:
              BoxConstraints(maxHeight: querySize.height - 340),
              child: gridVideosForWeb())
              : Container(
              constraints:
              BoxConstraints(maxHeight: querySize.height - 340),
              child: const Center(
                  child: CupertinoActivityIndicator(
                    radius: 30,
                  ))),
        ],
      ),
    );
  }

  Widget subscribeButtonWidget() {
    if (StaticVariables.activeUserId == 0) {
      return ElevatedButton(
        child: Text(followTr.trText),
        style: ElevatedButton.styleFrom(
          primary: const Color(0xFF772CE8),
        ),
        onPressed: () => context.go('/inbox'),
      );
    } else {
      if (isLoaded && isTokenLoaded) {
        if (isUserSubbedToCat) {
          return IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.black,
            ),
            onPressed: () {
              chooseCategorySubscribe();
              setState(() {
                isUserSubbedToCat = false;
              });
            },
          );
        } else {
          return ElevatedButton(
            child: Text(followTr.trText),
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFF772CE8),
            ),
            onPressed: () async {
              chooseCategorySubscribe();
              setState(() {
                isUserSubbedToCat = true;
              });
            },
          );
        }
      } else {
        return const CupertinoActivityIndicator();
      }
    }
  }

  Widget gridVideosForWeb() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1),
        controller: controller,
        itemCount: videos.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          Size frameSize = MediaQuery.of(context).size;

          if (videos[index]['type'] == 'video') {
            return SizedBox(
              height: frameSize.height / 5,
              child: VideoTile(
                index: index,
                videos: videos,
                page: page,
                catId: widget.catId,
                myUserAvatar: myUserAvatar,
                frameSize: frameSize,
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoTapePageForCatWeb(
                      index: index.toString(),
                      items: videos,
                      page: page,
                      catId: widget.catId,
                      myUserAvatar: myUserAvatar,
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Center(
                      child: FittedBox(
                        child: CachedNetworkImage(
                          imageUrl:
                          'https://youinroll.com/${videos[index]['userAvatar']}',
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(35.0),
                            child: SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                width: frameSize.width * 4.2,
                                height: frameSize.height * 3,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.network(
                              'https://youinroll.com//storage//media//photo_2021-11-16_17-39-06.jpg'),
                        ),
                        fit: BoxFit.fitWidth,
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 20,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFE2C55),
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            liveTr.trText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        });
  }
}
