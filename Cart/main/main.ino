/*!
   @file main.ino
   @brief Main application logic for smart cart system
   @author Mahmoud Yasser
*/
#include "debug.h"
#include "WebSocketHandler.h"
#include "APIHandler.h"
#include "GM65_scanner.h"
#include "gps.h"
#include "weight_sensor.h"


const char* ssid = "Mahmoudd";
const char* password = "123456789";
// Global variables
extern Stream* scanner;  // Declared in GM65_scanner.cpp
bool userAdded = false;

void setup() {
  // Initialize serial for debugging if enabled
#ifdef DEBUG
  Serial.begin(115200);
#endif

  // Initialize Serial2 for GM65 scanner
  Serial2.begin(Gm65_BAUD, SERIAL_8N1, RX2, TX2);
  scanner = &Serial2;  // Set GM65 serial
  debugPrintln("Serial2 started at 115200 baud rate");

  // Load GM65 status
  userAdded = gm65_loadGM65Status();
  gm65_checkGM65Status(userAdded);

  // Initialize Serial1 for GPS
  gpsSerial.begin(GPS_BAUD, SERIAL_8N1, RX1, TX1);

  // Initialize weight sensor
  weightSensorBegin();

  // Connect to WiFi and secure connection
  connectToWiFi(ssid, password);
  beginSecureConnection();

  // Initialize WebSocket
  webSocket.beginSSL(serverHost, serverPort, serverPath);
  webSocket.onEvent(webSocketEvent);
  webSocket.setReconnectInterval(2000);
  webSocket.setExtraHeaders("Origin: https://ssc-grad.up.railway.app");
}

void loop() {
  // Handle WebSocket events
  webSocket.loop();

  if (userAdded) {
    // Process UART data from GM65 scanner
    gm65_processUART();

    // Check weight every 4 seconds
    static unsigned long lastWeightCheck = 0;
    unsigned long currentTime = millis();
    if (currentTime - lastWeightCheck >= 1000) {
      float weight = getStableWeight();
      SendWeightToServerIfChanged(weight);
      lastWeightCheck = currentTime;
    }
  } else {
    // Send GPS data to server
    sendGPSDataToServer();
  }

  // Check WiFi connection every 10 seconds
  checkWiFiReconnect(ssid, password);

  // Send heartbeat every 20 seconds
  Send_heartbeat();
}