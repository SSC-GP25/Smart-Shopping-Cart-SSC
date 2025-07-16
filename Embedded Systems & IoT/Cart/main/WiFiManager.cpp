/*!
   @file WiFiManager.cpp
   @brief WiFi connection management implementation
   @author Mahmoud Yasser
*/

#include "WiFiManager.h"

void connectToWiFi(const char* ssid, const char* password) {
  if (WiFi.status() == WL_CONNECTED) {
    return;  // Already connected
  }

  debugPrint("Connecting to WiFi...");
  WiFi.begin(ssid, password);

  unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startTime < 10000) {
    delay(500);
    debugPrint(".");
  }

  if (WiFi.status() == WL_CONNECTED) {
    debugPrintln("\nConnected to WiFi");
    debugPrintln("IP Address: " + WiFi.localIP().toString());
  } else {
    debugPrintln("\nFailed to connect to WiFi");
  }
}
void checkWiFiReconnect(const char* ssid, const char* password) {
  // Check WiFi connection periodically
  static unsigned long lastWiFiCheck = 0;
  if (millis() - lastWiFiCheck >= 10000) {  // Check every 10 seconds
    lastWiFiCheck = millis();
    if (WiFi.status() != WL_CONNECTED) {
      debugPrintln("WiFi disconnected. Reconnecting...");
      connectToWiFi(ssid, password);
    }
  }
}