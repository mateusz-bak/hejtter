class PollToBeCreated {
  PollToBeCreated({
    required this.title,
    required this.options,
  });

  final String title;
  final List<OptionOfPollToBeCreated> options;

  Map<String, dynamic> toJson() => {
        'title': title,
        'options': options.map((option) => option.toJson()).toList(),
      };
}

class OptionOfPollToBeCreated {
  OptionOfPollToBeCreated({
    required this.title,
  });

  final String title;

  Map<String, dynamic> toJson() => {
        'title': title,
      };
}
