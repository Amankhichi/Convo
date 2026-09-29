class Country {
  final String name;
  final String code;
  final String flag;
  final String dialCode;

  const Country({
    required this.name,
    required this.code,
    required this.flag,
    required this.dialCode,
  });

  static const Country defaultCountry = Country(
    name: "India",
    code: "IN",
    flag: "🇮🇳",
    dialCode: "+91",
  );

  static const List<Country> countries = [
    Country(name: "India", code: "IN", flag: "🇮🇳", dialCode: "+91"),
    Country(name: "United States", code: "US", flag: "🇺🇸", dialCode: "+1"),
    Country(name: "United Kingdom", code: "GB", flag: "🇬🇧", dialCode: "+44"),
    Country(name: "United Arab Emirates", code: "AE", flag: "🇦🇪", dialCode: "+971"),
    Country(name: "Canada", code: "CA", flag: "🇨🇦", dialCode: "+1"),
    Country(name: "Australia", code: "AU", flag: "🇦🇺", dialCode: "+61"),
    Country(name: "Germany", code: "DE", flag: "🇩🇪", dialCode: "+49"),
    Country(name: "France", code: "FR", flag: "🇫🇷", dialCode: "+33"),
    Country(name: "Saudi Arabia", code: "SA", flag: "🇸🇦", dialCode: "+966"),
    Country(name: "Singapore", code: "SG", flag: "🇸🇬", dialCode: "+65"),
    Country(name: "Pakistan", code: "PK", flag: "🇵🇰", dialCode: "+92"),
    Country(name: "Bangladesh", code: "BD", flag: "🇧🇩", dialCode: "+880"),
    Country(name: "Nepal", code: "NP", flag: "🇳🇵", dialCode: "+977"),
  ];
}
