String generateTag(String firstName) {
  // Convert the first name to lowercase
  String firstNameLower = firstName.toLowerCase();

  // Extract the first two characters of the first name
  String firstInitials = firstNameLower.substring(0, 2);

  // Generate a unique number or string (you can replace this logic with your unique identifier generation)
  String uniqueIdentifier =
      DateTime.now().millisecondsSinceEpoch.toString().substring(6);

  // Combine the first initials with the unique identifier
  String tag = '$firstInitials$uniqueIdentifier';

  return tag;
}
