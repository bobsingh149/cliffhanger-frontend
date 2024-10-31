enum PostCategory {
  currentlyReading,
  barter,
  favourite,
}

// Extension to get the display name for each category
extension CategoryExtension on PostCategory {
  String get displayName {
    switch (this) {
      case PostCategory.currentlyReading:
        return 'Currently Reading';
      case PostCategory.barter:
        return 'Barter';
      case PostCategory.favourite:
        return 'Favourite Book';
      default:
        return '';
    }
  }
}

PostCategory? stringToPostCategory(String category) {
  try {
    return PostCategory.values
        .firstWhere((e) => e.toString().split('.').last == category);
  } catch (e) {
    return null; // Handle the case where no match is found
  }
}

final List<PostCategory> postCategoryList = [
  PostCategory.currentlyReading,
  PostCategory.barter,
  PostCategory.favourite,
];

