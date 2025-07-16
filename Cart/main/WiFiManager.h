/*!
   @file WiFiManager.h
   @brief WiFi connection management interface
   @author Mahmoud Yasser
*/
#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H
#include <WiFi.h>
#include "debug.h"

// Function declarations
/**
 * @brief Connects to a WiFi network using the provided credentials.
 * @param ssid The WiFi network SSID.
 * @param password The WiFi network password.
 * @return void
 */
void connectToWiFi(const char* ssid, const char* password);
/**
 * @brief Periodically checks and reconnects to WiFi if disconnected.
 * @param ssid The WiFi network SSID.
 * @param password The WiFi network password.
 * @return void
 */
void checkWiFiReconnect(const char* ssid, const char* password);

#endif
