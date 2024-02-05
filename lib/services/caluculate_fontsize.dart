// Function to calculate font size based on the length of the amount
int calculateFontSize(int amountLength) {
  const int baseFontSize = 40;
  const int maxFontSize = 30;

  // You can adjust these values based on your needs
  double scaleFactor = (maxFontSize - baseFontSize) / 10;

  // Calculate the dynamic font size based on the length of the amount
  int fontSize = (baseFontSize - scaleFactor * (amountLength - 5)).toInt();

  // Ensure the font size does not go below the minimum
  return fontSize > maxFontSize ? maxFontSize : fontSize;
}
