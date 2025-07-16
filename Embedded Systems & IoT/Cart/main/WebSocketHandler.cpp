/*!
   @file WebSocketHandler.cpp
   @brief WebSocket communication implementation for smart cart
   @author Mahmoud Yasser
*/
#include "GM65_scanner.h"
#include "WebSocketHandler.h"
#include <WebSocketsClient.h>

// Server details
const char* serverHost = "ssc-grad.up.railway.app";
const int serverPort = 443;
const char* serverPath = "/socket.io/?transport=websocket";

// Global variables
WebSocketsClient webSocket;
bool isConnected = false;
//bool userAdded = false;
unsigned long lastPingTime = 0;
unsigned long lastDataSendTime = 0;

void webSocketEvent(WStype_t type, uint8_t* payload, size_t length) {
  switch (type) {
    case WStype_DISCONNECTED:
      debugPrintln("WebSocket disconnected! Reconnecting...");
      isConnected = false;
      break;

    case WStype_CONNECTED:
      debugPrintln("WebSocket connected");
      webSocket.sendTXT("2probe");
      isConnected = true;
      break;

    case WStype_TEXT:
      debugPrintln((char*)payload);
      handleSocketIoMessage((char*)payload);
      break;

    case WStype_ERROR:
      debugPrintln("WebSocket error");
      break;

    case WStype_PING:
      debugPrintln("Received PING from server");
      webSocket.sendTXT("42[\"pong_ack\"]");
      break;

    case WStype_PONG:
      debugPrintln("Received PONG from server");
      break;
  }
}

void handleSocketIoMessage(char* message) {
  if (strcmp(message, "3") == 0) {
    debugPrintln("send 42");
    webSocket.sendTXT("42[\"pong_ack\"]");
    return;
  }

  if (strcmp(message, "40") == 0) {
    debugPrintln("Handshake completed! Waiting before sending '5'...");
    webSocket.sendTXT("5");
    return;
  }

  if (message[0] == '4' && message[1] == '2') {
    char* eventStart = strchr(message, '[');
    if (eventStart != NULL) {
      String eventData = String(eventStart);
      debugPrintln("Received event: " + eventData);
      if (eventData.indexOf("\"User_Check\"") != -1) {
        handleUserCheckEvent(eventData);
      }
    }
  }
}

void handleUserCheckEvent(String payload) {
  debugPrintln("user_check event received:");
  if (payload.indexOf("\"addedUser\":true") != -1) {
    debugPrintln("A user has been added to the cart!");
    performUserAddedActions();
  } else {
    debugPrintln("No user connected to the cart.");
    performNoUserActions();
  }
}

void performUserAddedActions() {
  gm65_Turn_ON_Scanner();
  gm65_saveGM65Status(GM65_ON);
  debugPrintln("Performing actions for addedUser = true...");
  userAdded = true;
}

void performNoUserActions() {
  gm65_Turn_OFF_Scanner();
  gm65_saveGM65Status(GM65_OFF);
  debugPrintln("Performing actions for addedUser = false...");
  userAdded = false;
}

void Send_heartbeat() {
  if (millis() - lastPingTime > 20000 && isConnected) {
    debugPrintln("Sending heartbeat (2)...");
    webSocket.sendTXT("2");
    lastPingTime = millis();
  }
}