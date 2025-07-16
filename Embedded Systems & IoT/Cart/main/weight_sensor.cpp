/*!
   @file weight_sensor.cpp
   @brief HX711 weight sensor implementation
   @author Mahmoud Yasser
*/
#include "APIHandler.h"
#include "weight_sensor.h"

// Internal static variables
static HX711 scale;
static float previousWeights[STABILITY_READINGS] = {0.0};
static int readingCount = 0;
static float lastPrintedWeight = 0.0;

void weightSensorBegin() {
    scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
    
    // Wait for HX711 to be ready
    unsigned long startTime = millis();
    while (!scale.is_ready() && millis() - startTime < 1000) {
        delay(10);
    }
    if (!scale.is_ready()) {
        Serial.println("Error: HX711 not ready after 1 second");
    }
    
    scale.set_scale(CALIBRATION_FACTOR);
    scale.tare();
    
    // Brief stabilization period
    for (int i = 0; i < 10; i++) {
        scale.get_units(1); // Read to stabilize
        delay(10);
    }
    
    Serial.println("Setup complete. Reading weight...");
}

void weightSensorTare() {
    scale.tare();
}

float getStableWeight() {
    
    if (!scale.is_ready()) {
        Serial.println("Error: HX711 not ready");
        return -1.0;
    }

    float weight = scale.get_units(10); // Average 10 readings
    if (abs(weight) < WEIGHT_THRESHOLD) {
        weight = 0.0;
    }
    
    // Store the current reading
    previousWeights[readingCount % STABILITY_READINGS] = weight;
    readingCount++;
    
    // Check if we have enough readings to verify stability
    if (readingCount >= STABILITY_READINGS) {
        bool isStable = true;
        for (int i = 1; i < STABILITY_READINGS; i++) {
            if (abs(previousWeights[i] - previousWeights[i-1]) > STABILITY_THRESHOLD) {
                isStable = false;
                break;
            }
        }
        
        // Return weight if stable, otherwise return -1.0
        if (isStable) {
            return weight;
        }
    }
    
    return -1.0;
}

void SendWeightToServerIfChanged(float weight) {
    if (weight >= 0.0 && (abs(weight - lastPrintedWeight) >= WEIGHT_CHANGE_THRESHOLD || readingCount == STABILITY_READINGS)) {
        Serial.print("Weight: ");
        Serial.print(weight, 2);
        Serial.println(" kg");
        sendWeightToAPI(weight);
        lastPrintedWeight = weight;
    }
}