String reFormatPhoneNumber(String phoneNumber) {
  if (phoneNumber.startsWith("0")) {
    phoneNumber = phoneNumber.replaceFirst("0", "+92");
  }
  if (phoneNumber.startsWith("92")) {
    phoneNumber = phoneNumber.replaceFirst("92", "+92");
  }
  if (phoneNumber.startsWith("3")) {
    phoneNumber = "+92$phoneNumber";
  }

  return phoneNumber;
}
