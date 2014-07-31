library foo;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'package:csv_sheet/csv_sheet.dart';
import 'countiesLatLon.dart';
import 'yrsapptestlevel.dart';

/*
 * Declare GeoLoaction variables.
 */
List<double> backUp = [53.479251000000000000, -2.248926000000009700];

double smallest = 999999999999999999.0, //A big value to start
       diff = 0.0;

String key;

/*
 * Declare CSV parsser variables.
 */
int RateOfFire = 0;
int numEnim = 0;

/*
 * Geolocation start.
 */
void getLocation() {
  setMap();
  
  Geoposition currentPos;
  
  window.navigator.geolocation.getCurrentPosition().then((Geoposition position) {
      currentPos = position;
      calculateClosest(currentPos.coords.latitude, currentPos.coords.longitude);
   }, onError: (error) => calculateClosest(backUp[0], backUp[1]));
}

void calculateClosest(double lat1, double lon1) {
   countyCo.forEach((k, v){
     print('claled for each');
     diff = sqrt((pow((v[0] - lat1), 2) + pow((v[1] - lon1), 2)));
     
     if (diff < smallest) {
       smallest = diff;
       key = k;
     };
   });
   print(key);
   print(smallest);
   setUpCrime();
}
/* ******************
 * Geolocation End.
 * ******************
 */

void setUpCrime() {
  getCrimes().then((Map crimes) {
    enimNum(crimes);
  });
}

void enimNum(crime) {
  int enim = 0;
  
  crime.forEach((k, v) => enim += v);
  
  numEnim   = ((enim / crime.length) / 600).round();
  RateOfFire = ((enim / crime.length) / 300).round();
  if (numEnim == 0) 
    numEnim = 1;
  
  stuff();
}

Future<Map> getCrimes() {
  print(key);
  return HttpRequest.getString('dataSets/${key}.csv').then((String data) {
    CsvSheet sheet = new CsvSheet(data);
    
    Map crimes = new Map();
    
    crimes['violence'] = int.parse(sheet[6][3]);
    crimes['robbery']  = int.parse(sheet[6][5]);
    crimes['theft']    = int.parse(sheet[6][6]);
    crimes['burglary'] = int.parse(sheet[6][8]);
    crimes['drugs']    = int.parse(sheet[6][9]);
    
    return crimes;
  });
}