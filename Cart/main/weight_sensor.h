/*!
   @file weight_sensor.h
   @brief HX711 weight sensor interface
   @author Mahmoud Yasser
*/
#ifndef WEIGHT_SENSOR_H
#define WEIGHT_SENSOR_H

#include "HX711.h"

// Define pins for HX711
#define LOADCELL_DOUT_PIN 14  // Data pin (connect to DT on HX711)
#define LOADCELL_SCK_PIN 12   // Clock pin (connect to SCK on HX711)

// Calibration factor
#define CALIBRATION_FACTOR 96649.05

// Threshold for small fluctuations
#define WEIGHT_THRESHOLD 0.03  // Ignore small fluctuations (in kg)

// Stability check parameters
#define STABILITY_THRESHOLD 0.01  // Max difference between consecutive readings (in kg)
#define STABILITY_READINGS 2      // Number of consistent readings for stability

// Weight change threshold for printing
#define WEIGHT_CHANGE_THRESHOLD 0.05  // Minimum change to print new weight (in kg)
// Minimum interval between HX711 readings (ms)
#define HX711_READ_INTERVAL 50  // Ensures HX711 has time to prepare data

/**
 * @brief Initializes the HX711 weight sensor.
 * @return void
 */
void weightSensorBegin();
/**
 * @brief Tares (zeros) the weight sensor.
 * @return void
 */
void weightSensorTare();
/**
 * @brief Gets a stable weight reading from the sensor.
 * @return The stable weight in kg, or -1.0 if unstable or error.
 */
float getStableWeight();
/**
 * @brief Sends weight to the server if it has changed significantly.
 * @param weight The weight to send (in kg).
 * @return void
 */
void SendWeightToServerIfChanged(float weight);

#endif