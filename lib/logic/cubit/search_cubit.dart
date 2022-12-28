import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rxdart/rxdart.dart';

final searchCubit = SearchCubit();

class SearchCubit extends Cubit {
  final BehaviorSubject<String> _searchStringFetcher =
      BehaviorSubject<String>();

  Stream<String> get searchString => _searchStringFetcher.stream;

  SearchCubit() : super(null) {
    _searchStringFetcher.sink.add('');
  }

  changeString(String searchString) async {
    _searchStringFetcher.sink.add(searchString);
  }
}
