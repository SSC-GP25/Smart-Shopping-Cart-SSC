/*!
   @file APIHandler.h
   @brief API communication interface for smart cart
   @author Mahmoud Yasser
*/
#ifndef API_HANDLER_H
#define API_HANDLER_H

// Include necessary libraries
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "WiFiManager.h"
#include "debug.h"

// External declarations for API endpoints and client
extern const char* root_ca;
extern const String serverUrl;
extern WiFiClientSecure client;

// Function declarations
/**
 * @brief Initializes a secure connection with the root CA certificate.
 * @return void
 */
void beginSecureConnection();
/**
 * @brief Initializes a secure connection with the root CA certificate.
 * @return void
 */
void sendToAPI(const char* barcode);
/**
 * @brief Sends weight data to the server via a POST request.
 * @param weight The weight to send (in kg).
 * @return void
 */
void sendWeightToAPI(float weight);

#endif // API_HANDLER_H