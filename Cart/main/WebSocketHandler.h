/*!
   @file WebSocketHandler.h
   @brief WebSocket communication interface for smart cart
   @author Mahmoud Yasser
*/
#ifndef WEBSOCKET_HANDLER_H
#define WEBSOCKET_HANDLER_H

#include "debug.h"
#include "GM65_scanner.h"
#include <WebSocketsClient.h>

// Server details
extern const char* serverHost;
extern const int serverPort;
extern const char* serverPath;

// Global variables
extern WebSocketsClient webSocket;
extern bool isConnected;
extern bool userAdded;
extern unsigned long lastPingTime;

// Function declarations
/**
 * @brief Handles WebSocket events (connect, disconnect, text, etc.).
 * @param type Type of WebSocket event.
 * @param payload Data received from the event.
 * @param length Length of the payload.
 * @return void
 */
void webSocketEvent(WStype_t type, uint8_t* payload, size_t length);
/**
 * @brief Processes Socket.IO messages received via WebSocket.
 * @param message The message to process.
 * @return void
 */
void handleSocketIoMessage(char* message);
/**
 * @brief Handles the "User_Check" event from the server.
 * @param payload The event data as a String.
 * @return void
 */
void handleUserCheckEvent(String payload);
/**
 * @brief Performs actions when a user is added to the cart.
 * @return void
 */
void performUserAddedActions();
/**
 * @brief Performs actions when no user is connected to the cart.
 * @return void
 */
void performNoUserActions();
/**
 * @brief Sends a heartbeat message to maintain WebSocket connection.
 * @return void
 */
void Send_heartbeat();

#endif // WEBSOCKET_HANDLER_H