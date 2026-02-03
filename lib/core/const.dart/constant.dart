import 'package:flutter/material.dart';

bool isDeviceThemeDark(BuildContext context) {
  Brightness brightness = MediaQuery.of(context).platformBrightness;
  return brightness == Brightness.dark;
}

class Constant{
  static bool isDark(BuildContext context) => isDeviceThemeDark(context);
}


String getapikey(){
return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVobXFnaXFyZnB2dnpudnN2Znl1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NTg5MTcsImV4cCI6MjA3ODMzNDkxN30.G7H75FoSN3q-le2CgJzJJgMrQBq_TDSFzCWonJqq4ws";
}
final apikey=getapikey();