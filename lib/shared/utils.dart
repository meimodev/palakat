extension StringExtension on String {
  String cleanPhone(){
    trim();
    return contains('+62') ? replaceFirst('+62', '0') : this;
}
}