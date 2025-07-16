/*!
   @file gps.cpp
   @brief GPS module implementation for location data
   @author Mahmoud Yasser
*/

#include "debug.h"
#include "WebSocketHandler.h"
#include "gps.h"

// Declare the TinyGPS and Serial object
TinyGPSPlus gps;
HardwareSerial gpsSerial(1);

// State variables
const unsigned long gpsSendInterval = 3000;
unsigned long lastGPSSendTime = 0;
int Numdatasending = 0;
float latitude = 0;
float longitude = 0;
float hdop = 0;
int satellites = 0;



void sendGPSDataToServer() {
  unsigned long currentMillis = millis();
  if (currentMillis - lastGPSSendTime >= gpsSendInterval) {
    lastGPSSendTime = currentMillis;

    while (gpsSerial.available() > 0) {
      gps.encode(gpsSerial.read());
    }

    String gpsData;

    if (gps.location.isUpdated() && gps.location.isValid()) {
      Numdatasending = 0;
      latitude = gps.location.lat();
      longitude = gps.location.lng();
      hdop = gps.hdop.value() / 100.0;
      satellites = gps.satellites.value();

      gpsData = "42[\"cart-location\", {"
                "\"id\":1,"
                "\"name\":\"Smart-Cart1\","
                "\"cartID\":\"SMCart-001\","
                "\"lat\":" + String(latitude, 6) + ","
                "\"lng\":" + String(longitude, 6) + ","
                "\"hdop\":" + String(hdop, 2) + ","
                "\"satellites\":" + String(satellites) + ","
                "\"gps_status\":true"
                "}]";
    } else if (Numdatasending < 2) {
      Numdatasending++;
      hdop = gps.hdop.value() / 100.0;
      satellites = gps.satellites.value();
      gpsData = "42[\"cart-location\", {"
                "\"id\":1,"
                "\"name\":\"Smart-Cart1\","
                "\"cartID\":\"SMCart-001\","
                "\"lat\":" + String(latitude, 6) + ","
                "\"lng\":" + String(longitude, 6) + ","
                "\"hdop\":" + String(hdop, 2) + ","
                "\"satellites\":" + String(satellites) + ","
                "\"gps_status\":false"
                "}]";
    } else {
      return;
    }

    webSocket.sendTXT(gpsData);
    debugPrintln("Sent GPS data: " + gpsData);
  }
}
