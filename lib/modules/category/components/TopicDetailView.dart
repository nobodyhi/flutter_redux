import 'dart:ui' as ui;
import 'package:cat_dog/modules/category/components/TopicItemView.dart';
import 'package:flutter/material.dart';
import 'package:cat_dog/modules/category/actions.dart';
import 'package:cat_dog/common/utils/navigation.dart';
import 'package:cat_dog/common/configs.dart';
import 'package:cat_dog/styles/colors.dart';

class TopicDetailView extends StatefulWidget {
  final dynamic topic;
  final BuildContext scaffoldContext;
  const TopicDetailView({
    Key key,
    this.topic,
    this.scaffoldContext
  }) : super(key: key);

  @override
  _TopicDetailViewState createState() => new _TopicDetailViewState();
}

class _TopicDetailViewState extends State<TopicDetailView> {
  List<Object> list = [];
  _TopicDetailViewState();

  @override
  void initState() {
    super.initState();
    getNews(true);
  }

  getNews (bool replace) async {
    try {
      List<dynamic> data = await getNewsFromUrl(GET_NEWS_API + widget.topic['url'], 1);
      setState(() {
        if (replace) {
          list = data;
        } else {
          list.addAll(data);
        }
      });
    } catch (err) {
      print(err);
    }
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAvatar(),
          _buildInfo(),
          _buildVideoScroller(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 110.0,
      height: 110.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30),
      ),
      margin: const EdgeInsets.only(top: 32.0, left: 16.0),
      padding: const EdgeInsets.all(3.0),
      child: ClipOval(
        child: Image.network(widget.topic['image']),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.topic['heading'],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          Text(
            '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.85),
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            width: 225.0,
            height: 1.0,
          ),
          Text(
            widget.topic['summary'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoScroller() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox.fromSize(
        size: Size.fromHeight(245.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: list.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            var news = list[index];
            return TopicItemView(news, (seleted) {
              pushByName('/reading', context, { 'news': seleted });
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: MediaQuery.of(context).size.height,
      decoration: new BoxDecoration(color: AppColors.commonBackgroundColor),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: _buildContent(),
        ),
      )
    );
  }
}