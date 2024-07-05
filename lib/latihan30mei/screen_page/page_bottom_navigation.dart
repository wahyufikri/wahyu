import 'package:flutter/material.dart';

import 'page_beranda.dart';
import 'page_favorite.dart';

class PageBottomNavigationBar extends StatefulWidget {
  const PageBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<PageBottomNavigationBar> createState() => _PageBottomNavigationBarState();
}

class _PageBottomNavigationBarState extends State<PageBottomNavigationBar> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  Set<String> favoriteIds = {'4', '2', '3', '5'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: [
          PageHome(),
          PageFavorite(favoriteIds: favoriteIds),
          PageHome(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[850], // Set background color to dark grey
        child: TabBar(
          controller: tabController,
          labelColor: Colors.green, // Set selected icon color to green
          unselectedLabelColor: Colors.grey, // Set unselected icon color to grey
          indicatorColor: Colors.transparent, // Remove indicator
          tabs: [
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.music_note),
                  ),
                  Text("Home"),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.favorite),
                  ),
                  Text("Favorite"),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.playlist_play),
                  ),
                  Text("My Playlist"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
