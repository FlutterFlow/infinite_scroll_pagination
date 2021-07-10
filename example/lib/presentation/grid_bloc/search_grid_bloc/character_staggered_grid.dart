import 'dart:async';

import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/grid_bloc/character_grid_item.dart';
import 'package:breaking_bapp/presentation/grid_bloc/character_sliver_grid_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterStaggeredGrid extends StatefulWidget {
  @override
  _CharacterStaggeredGridState createState() => _CharacterStaggeredGridState();
}

class _CharacterStaggeredGridState extends State<CharacterStaggeredGrid> {
  final CharacterSliverGridBloc _bloc = CharacterSliverGridBloc();
  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0);
  late StreamSubscription _blocListingStateSubscription;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _bloc.onPageRequestSink.add(pageKey);
    });

    // We could've used StreamBuilder, but that would unnecessarily recreate
    // the entire [PagedSliverGrid] every time the state changes.
    // Instead, handling the subscription ourselves and updating only the
    // _pagingController is more efficient.
    _blocListingStateSubscription =
        _bloc.onNewListingState.listen((listingState) {
      _pagingController.value = PagingState(
        nextPageKey: listingState.nextPageKey,
        error: listingState.error,
        itemList: listingState.itemList,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PagedStaggeredGridView.count(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
          itemBuilder: (context, item, index) => CharacterGridItem(
            character: item,
          ),
        ),
        crossAxisCount: 2,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    _blocListingStateSubscription.cancel();
    _bloc.dispose();
    super.dispose();
  }
}
