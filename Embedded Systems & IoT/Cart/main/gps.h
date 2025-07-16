/*!
   @file gps.h
   @brief GPS module interface for location data
   @author Mahmoud Yasser
*/
#ifndef GPSMODULE_H
#define GPSMODULE_H

#include <TinyGPS++.h>
#include <HardwareSerial.h>

// Constants
#define GPS_BAUD 9600
#define RX1 19
#define TX1 21

extern TinyGPSPlus gps;
extern HardwareSerial gpsSerial;
extern unsigned long lastGPSSendTime;
extern int Numdatasending;
extern float latitude;
extern float longitude;
extern float hdop;
extern int satellites;

//extern unsigned long gpsSendInterval;
/**
 * @brief Sends GPS data to the server via WebSocket.
 * @return void
 */
void sendGPSDataToServer();

#endif
