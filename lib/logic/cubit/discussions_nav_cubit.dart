import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/utils/enums.dart';

import 'package:rxdart/rxdart.dart';

final discussionsNavCubit = DiscussionsNavCubit();

class DiscussionsNavCubit extends Cubit {
  final BehaviorSubject<DiscussionsTab> _discussionsTabFetcher =
      BehaviorSubject<DiscussionsTab>();
  final BehaviorSubject<PostsPeriod> _hotTabPeriodFetcher =
      BehaviorSubject<PostsPeriod>();
  final BehaviorSubject<PostsPeriod> _topTabPeriodFetcher =
      BehaviorSubject<PostsPeriod>();

  Stream<DiscussionsTab> get discussionsTab => _discussionsTabFetcher.stream;
  Stream<PostsPeriod> get hotTabPeriod => _hotTabPeriodFetcher.stream;
  Stream<PostsPeriod> get topTabPeriod => _topTabPeriodFetcher.stream;

  DiscussionsNavCubit() : super(null) {
    _topTabPeriodFetcher.sink.add(PostsPeriod.sevenDays);
  }

  changeDiscussionsTab(DiscussionsTab discussionsTab) async {
    _discussionsTabFetcher.sink.add(discussionsTab);
  }

  changeHotTabPeriod(PostsPeriod postsPeriod) async {
    _hotTabPeriodFetcher.sink.add(postsPeriod);
  }

  changeTopTabPeriod(PostsPeriod postsPeriod) async {
    _topTabPeriodFetcher.sink.add(postsPeriod);
  }
}
