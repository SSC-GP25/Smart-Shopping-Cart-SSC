/*!
   @file GM65_scanner.h
   @brief GM65 barcode reader
   @author Mahmoud Yasser
*/
#ifndef GM65_SCANNER_H
#define GM65_SCANNER_H


#include "debug.h"
#include "APIHandler.h"
#include <Preferences.h>

// Constants
#define GM65_ON true
#define GM65_OFF false
#define BUFFER_SIZE 128  // Adjust based on expected barcode length
// UART2 pins for GM65 barcode scanner
#define RX2 16  // GPIO16 for RX
#define TX2 17  // GPIO17 for TX
#define Gm65_BAUD 115200
// Command arrays
extern const char set_default[9];          // Factory settings
extern const char set_serial_output[9];    // Set serial output
extern const char enable_settingcode[9];   // Enable setting code
extern const char disable_settingcode[9];  // Disable setting code
extern char read_reg[9];                   // Read register command

// Enums for scanner modes
enum class WorkingMode : uint8_t {
  MANUAL = 0,
  COMMAND_TRIGGER = 1,
  CONTINUOUS = 2,
  SENSING = 3
};
enum class SilentMode : uint8_t {
  DISABLED_SilentMode = 0,  // Silent mode disabled
  ENABLED_SilentMode = 1    // Silent mode enabled
};
enum class LEDMode : uint8_t {
  DISABLED_LEDMode = 0,  // LED mode disabled
  ENABLED_LEDMode = 1    // LED mode enabled
};
enum class LightMode : uint8_t {
  NO_LIGHT = 0,  // No light
  NORMAL = 1,    // Normal light
  ALWAYS_ON = 2  // Light always on (2 or 3)
};
enum class AimMode : uint8_t {
  NO_AIM = 0,    // No aim
  NORMAL = 1,    // Normal aim
  ALWAYS_ON = 2  // Aim always on (2 or 3)
};
enum class SleepMode : uint8_t {
  DISABLED_SleepMode = 0,  // Sleep mode disabled
  ENABLED_SleepMode = 1    // Sleep mode enabled
};

// Function declarations
/**
 * @brief Initializes the GM65 barcode scanner with default settings.
 * @return void
 */
void gm65_init();
/**
 * @brief Clears the serial buffer of the GM65 scanner.
 * @return void
 */
void gm65_clear_buffer();

/**
 * @brief Enables setting code for module configuration.
 * @return void
 */
void gm65_enable_setting_code();

/**
 * @brief Disables setting code for module configuration.
 * @return void
 */
void gm65_disable_setting_code();
/**
 * @brief Retrieves the response from the GM65 scanner.
 * @param response Pointer to array to store response data.
 * @param response_size Pointer to store the number of bytes received.
 * @param max_size Maximum size of the response array.
 * @return void
 */
void gm65_get_response(int* response, int* response_size, int max_size);
/**
 * @brief Gets the current mode from the specified register.
 * @param addr1 First address byte.
 * @param addr2 Second address byte.
 * @return The mode byte or -1 if no valid response.
 */
int gm65_get_mode(byte addr1, byte addr2);

/**
 * @brief Sets specific bits in a mode register of the GM65 scanner.
 * @param start_bit Starting bit position (0-based).
 * @param num_bits Number of bits to set.
 * @param value Value to write to the bits.
 * @param addr1 First address byte.
 * @param addr2 Second address byte.
 * @return void
 */
void gm65_set_mode_bits(uint8_t start_bit, uint8_t num_bits, uint8_t value, byte addr1, byte addr2);
// Mode setting functions
/**
 * @brief Sets the silent mode (bit 6).
 * @param silent_mode SilentMode enum value (0 = disabled, 1 = enabled).
 * @return void
 */
void gm65_set_silent_mode(SilentMode silent_mode);
/**
 * @brief Sets the LED mode (bit 7).
 * @param LED_mode LEDMode enum value (0 = disabled, 1 = enabled).
 * @return void
 */
void gm65_set_LED_mode(LEDMode LED_mode);
/**
 * @brief Sets the working mode (bits 0-1).
 * @param working_mode WorkingMode enum value (0 = manual, 1 = command trigger, 2 = continuous, 3 = sensing).
 * @return void
 */
void gm65_set_working_mode(WorkingMode working_mode);
/**
 * @brief Sets the light mode (bits 2-3).
 * @param light_mode LightMode enum value (0 = no light, 1 = normal, 2 = always on).
 * @return void
 */
void gm65_set_light_mode(LightMode light_mode);
/**
 * @brief Sets the aim mode (bits 4-5).
 * @param aim_mode AimMode enum value (0 = no aim, 1 = normal, 2 = always on).
 * @return void
 */
void gm65_set_aim_mode(AimMode aim_mode);
/**
 * @brief Sets the sleep mode (bit 7 at address 0x00, 0x07).
 * @param sleep_mode SleepMode enum value (0 = disabled, 1 = enabled).
 * @return void
 */
void gm65_set_sleep_mode(SleepMode sleep_mode);
/**
  * @brief Processes incoming UART data from the GM65 scanner.
  * @return void
  */
void gm65_processUART();
/**
  * @brief Waits for a response from the GM65 scanner within a specified timeout.
  * @param timeout The maximum time to wait for a response (in milliseconds).
  * @return bool True if data is received within the timeout, false otherwise.
  */
bool gm65_waitForResponse(unsigned long timeout);
/**
  * @brief Turns on the GM65 scanner by setting it to continuous scanning mode.
  * @return void
  */
void gm65_Turn_ON_Scanner();
/**
  * @brief Saves the current status of the GM65 scanner to persistent storage.
  * @param status The status to save (true = on, false = off).
  * @return void
  */
void gm65_Turn_OFF_Scanner();
/**
  * @brief Saves the current status of the GM65 scanner to persistent storage.
  * @param status The status to save (true = on, false = off).
  * @return void
  */
void gm65_saveGM65Status(bool status);
/**
  * @brief Loads the saved status of the GM65 scanner from persistent storage.
  * @return bool The saved status (true = on, false = off).
  */
bool gm65_loadGM65Status();
/**
 * @brief Checks the current status of the GM65 scanner and turns it on/off accordingly.
 * @param status The desired status of the scanner (true = on, false = off).
 * @return void
 */
void gm65_checkGM65Status(bool status);

#endif  // GM65_SCANNER_H
