import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cat_dog/modules/dashboard/actions.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cat_dog/styles/colors.dart';
import 'package:cat_dog/pages/OverlayLoadingPage.dart';
import 'package:cat_dog/common/components/MiniNewsfeed.dart';
import 'package:cat_dog/common/utils/navigation.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:cat_dog/common/configs.dart';
import 'package:flutter_parallax/flutter_parallax.dart';

class ReadingView extends StatefulWidget {
  final dynamic news;
  final int readingCount;
  final BuildContext scaffoldContext;
  final Function clearReadingCount;
  final Function addReadingCount;
  const ReadingView({
    Key key,
    this.news,
    this.scaffoldContext,
    this.readingCount,
    this.addReadingCount,
    this.clearReadingCount
  }) : super(key: key);

  @override
  _ReadingViewState createState() => new _ReadingViewState();
}
class _ReadingViewState extends State<ReadingView> {

  String html = '';
  bool loading = true;
  CarouselSlider carouselInstance;
  List<Widget> relatedInstance = [];

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    childDirected: true,
    nonPersonalizedAds: false,
  );
  ScrollController scrollController = new ScrollController();
  InterstitialAd interstitialAd;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      this.getDetail();
    });

    FirebaseAdMob.instance.initialize(appId: APP_ID);
    widget.addReadingCount();
    if (widget.readingCount > SHOW_ADS_COUNT) {
      interstitialAd = InterstitialAd(
        adUnitId: READING_ADS_ID,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            interstitialAd?.show();
          }
          if (event == MobileAdEvent.clicked || event == MobileAdEvent.closed) {
            widget.clearReadingCount();
          }
        }
      )..load();
    }
  }
  
  getDetail () async {
    try {
      if (widget.news['data'] != null) {
        return setState(() {
          html = widget.news['data'];
          loading = false;
        });
      }
      var result = await getDetailNews(widget.news['url']);
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          html = result['text'];
          if (result['video'] != null && result['video'].length > 0) {
            carouselInstance = buildCarousel(result['video'] ?? []);
          }
          if (result['related'] != null && result['related'].length > 0) {
            relatedInstance = result['related'].map<Widget>((item) => 
              Container(
                child: MiniNewsfeed(
                  item: item,
                  metaData: true,
                  onTap: (seleted) {
                    pushAndReplaceByName('/reading', context, { 'news': seleted });
                  }
                )
              )
            ).toList();
          }
          loading = false;
        });
      });
    } catch (err) {
    }
  }

  Widget _buildPlayButton() {
    return Center(
      child: Material(
        color: Colors.black87,
        type: MaterialType.circle,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.play_arrow,
              size: 56,
              color: AppColors.white,
            )
          )
        )
      )
    );
  }

  CarouselSlider buildCarousel (List<dynamic> data) {
    return CarouselSlider(
      items: data.map((item) {
        return new Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: FlatButton(
            onPressed: () async {
              String url = item['url'];
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                print('Could not launch $url');
              }
            },
            child: Stack(
              children: <Widget>[
                new Center(
                  child: item['image'] != null ? new Image(
                    image: NetworkImage(item['image']),
                  ) : Container(
                    color: Colors.black54,
                    height: 180
                  )
                ),
                _buildPlayButton()
              ]
            )
          )
        );
      }).toList(),
      autoPlay: data.length > 1,
      autoPlayCurve: Curves.fastOutSlowIn
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columns = [
      carouselInstance != null
      ? carouselInstance
      : Container(
        margin: EdgeInsets.only(bottom: 0),
        padding: EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.readingNewsBackgroundColor),
        ),
        child: Stack(
          children: <Widget>[
            loading
            ? Hero(
              tag: "news-feed-${widget.news['url']}",
              child: Image.network(
                widget.news['image'],
                fit: BoxFit.cover,
                height: 180,
                width: MediaQuery.of(widget.scaffoldContext).size.width
              )
            )
            : Hero(
              tag: "news-feed-${widget.news['url']}",
              child: Parallax.inside(
                child: Image.network(
                  widget.news['image'],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(widget.scaffoldContext).size.width
                ),
                mainAxisExtent: 180,
              )
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  // border: new Border.all(color: AppColors.readingNewsBackgroundColor),
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.readingNewsBackgroundColor.withOpacity(0),
                      AppColors.readingNewsBackgroundColor.withOpacity(1)
                    ],
                    stops: [0.0, 100.0],
                    tileMode: TileMode.clamp
                  )
                ),
              )
            )
          ]
        )
      ),
      AnimatedOpacity(
        opacity: loading ? 0 : 1,
        duration: Duration(milliseconds: 800),
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: MarkdownBody(
            data: html
          )
        )
      )
    ];
    columns.addAll(relatedInstance);
    return OverlayLoadingPage(
      loading: loading,
      component: ListView(
        controller: scrollController,
        children: columns
      )
    );
  }

}