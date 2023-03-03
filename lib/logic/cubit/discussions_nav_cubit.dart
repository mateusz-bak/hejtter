import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/utils/enums.dart';

import 'package:rxdart/rxdart.dart';

final discussionsNavCubit = DiscussionsNavCubit();

class DiscussionsNavCubit extends Cubit {
  final BehaviorSubject<HejtoPage> _currentHejtoPageFetcher =
      BehaviorSubject<HejtoPage>();
  final BehaviorSubject<PostsCategory> _currentPostsCategoryFetcher =
      BehaviorSubject<PostsCategory>();

  Stream<HejtoPage> get currentHejtoPageFetcher =>
      _currentHejtoPageFetcher.stream;
  Stream<PostsCategory> get currentPostsCategoryFetcher =>
      _currentPostsCategoryFetcher.stream;

  DiscussionsNavCubit() : super(null) {
    _currentHejtoPageFetcher.sink.add(HejtoPage.all);
    _currentPostsCategoryFetcher.sink.add(PostsCategory.hotSixHours);
  }

  changeCurrentHejtoPage(HejtoPage hejtoPage) async {
    _currentHejtoPageFetcher.sink.add(hejtoPage);
  }

  changeCurrentPostsCategoryPage(PostsCategory postsCategory) async {
    _currentPostsCategoryFetcher.sink.add(postsCategory);
  }
}
