enum CurrentScreen { home, communities }

enum DiscussionsTab { hot, top, newTab, followed }

enum HejtoPage { all, articles, discussions }

enum PostsCategory {
  hotThreeHours,
  hotSixHours,
  hotTwelveHours,
  hotTwentyFourHours,
  topSevenDays,
  topThirtyDays,
  all,
  followed,
}

enum PostsPeriod {
  threeHours,
  sixHours,
  twelveHours,
  twentyFourHours,
  sevenDays,
  thirtyDays,
  all,
}

// post does not work
enum SearchType {
  // post,
  tag,
  user,
  community,
}
