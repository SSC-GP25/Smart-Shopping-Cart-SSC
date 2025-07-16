/*!
   @file GM65_scanner.cpp
   @brief GM65 barcode reader
   @author Mahmoud Yasser
*/

#include "GM65_scanner.h"
// Global variables
Stream* scanner;  // Serial stream for GM65 scanner
Preferences preferences;  // Preferences object for storing scanner status

// Command arrays
const char set_default[9] = {0x7E, 0x00, 0x08, 0x01, 0x00, 0xD9, 0x55, 0xAB, 0xCD};
const char set_serial_output[9] = {0x7E, 0x00, 0x08, 0x01, 0x00, 0x0D, 0x00, 0xAB, 0xCD};
const char enable_settingcode[9] = {0x7E, 0x00, 0x08, 0x01, 0x00, 0x03, 0x01, 0xAB, 0xCD};
const char disable_settingcode[9] = {0x7E, 0x00, 0x08, 0x01, 0x00, 0x03, 0x03, 0xAB, 0xCD};
char read_reg[9] = {0x7E, 0x00, 0x07, 0x01, 0x00, 0x00, 0x01, 0xAB, 0xCD};


// Clear serial buffer
void gm65_clear_buffer() {
  while (scanner->available()) {
    scanner->read();  // Discard data
  }
}

// Initialize GM65 scanner with default settings
void gm65_init() {
  scanner->write(set_default, 9);
  gm65_waitForResponse(3000);  // Wait for scanner to reset
  scanner->write(set_serial_output, 9);
  gm65_waitForResponse(500);  // Wait for command to process
  gm65_clear_buffer();
}


// Get response from scanner
void gm65_get_response(int* response, int* response_size, int max_size) {
  *response_size = 0;
  while (scanner->available() > 0 && *response_size < max_size) {
    response[*response_size] = scanner->read();
    (*response_size)++;
  }
}





// Enable setting code
void gm65_enable_setting_code() {
  scanner->write(enable_settingcode, 9);
  delay(1000);
  gm65_waitForResponse(500);
  gm65_clear_buffer();
}

// Disable setting code
void gm65_disable_setting_code() {
  scanner->write(disable_settingcode, 9);
  gm65_waitForResponse(500);
  gm65_clear_buffer();
}

// Get current mode from specified register
int gm65_get_mode(byte addr1, byte addr2) {
  read_reg[4] = addr1;
  read_reg[5] = addr2;
  gm65_clear_buffer();
  scanner->write(read_reg, 9);
  gm65_waitForResponse(500);

  int response[32];
  int response_size = 0;
  gm65_get_response(response, &response_size, 32);
  if (response_size > 4) {
    return response[4];  // Return the mode byte
  }
  return -1;  // Error: No valid response
}
// Set specific bits in the mode register
void gm65_set_mode_bits(uint8_t start_bit, uint8_t num_bits, uint8_t value, byte addr1, byte addr2) {
  int current_mode = gm65_get_mode(addr1, addr2);
  if (current_mode == -1) {
    return;  // Error handling
  }

  uint8_t mask = (1 << num_bits) - 1;              // e.g., for 2 bits: 0b11
  int temp = ~(mask << start_bit) & current_mode;  // Clear the target bits
  byte mode_data = temp + (value << start_bit);    // Set the new value

  char mode_command[9] = {0x7E, 0x00, 0x08, 0x01, 0x00, addr1, mode_data, 0xAB, 0xCD};
  scanner->write(mode_command, 9);
  gm65_waitForResponse(500);
  gm65_clear_buffer();
}

// Set silent mode (bit 6)
void gm65_set_silent_mode(SilentMode silent_mode) {
  gm65_set_mode_bits(6, 1, static_cast<uint8_t>(silent_mode), 0x00, 0x00);
}

// Set LED mode (bit 7)
void gm65_set_LED_mode(LEDMode LED_mode) {
  gm65_set_mode_bits(7, 1, static_cast<uint8_t>(LED_mode), 0x00, 0x00);
}

// Set working mode (bits 0-1)
void gm65_set_working_mode(WorkingMode working_mode) {
  gm65_set_mode_bits(0, 2, static_cast<uint8_t>(working_mode), 0x00, 0x00);
}

// Set light mode (bits 2-3)
void gm65_set_light_mode(LightMode light_mode) {
  gm65_set_mode_bits(2, 2, static_cast<uint8_t>(light_mode), 0x00, 0x00);
}

// Set aim mode (bits 4-5)
void gm65_set_aim_mode(AimMode aim_mode) {
  gm65_set_mode_bits(4, 2, static_cast<uint8_t>(aim_mode), 0x00, 0x00);
}

// Set sleep mode (bit 7 at address 0x00, 0x07)
void gm65_set_sleep_mode(SleepMode sleep_mode) {
  gm65_set_mode_bits(7, 1, static_cast<uint8_t>(sleep_mode), 0x00, 0x07);
}


// Process UART data from scanner
void gm65_processUART() {
  static char buffer[BUFFER_SIZE];
  static uint8_t index = 0;

  while (scanner->available()) {
    char data = scanner->read();

    if (data == '\n' || data == '\r') {
      if (index > 0) {
        buffer[index] = '\0';
        debugPrint("Scanned Barcode: ");
        debugPrintln(buffer);
        sendToAPI(buffer);
        index = 0;
      }
    } else {
      buffer[index++] = data;
      if (index >= BUFFER_SIZE - 1) {
        debugPrintln("Buffer overflow! Resetting buffer.");
        index = 0;
      }
    }
  }
}

// Wait for scanner response with timeout
bool gm65_waitForResponse(unsigned long timeout) {
  unsigned long startTime = millis();
  while (millis() - startTime < timeout) {
    if (scanner->available()) {
      return true;
    }
  }
  return false;
}

// Turn on scanner (set to continuous mode)
void gm65_Turn_ON_Scanner() {
  gm65_set_working_mode(WorkingMode::CONTINUOUS);
}

// Turn off scanner (set to manual mode)
void gm65_Turn_OFF_Scanner() {
  gm65_set_working_mode(WorkingMode::MANUAL);
}

// Save GM65 scanner status to preferences
void gm65_saveGM65Status(bool status) {
  preferences.begin("GM65", false);
  preferences.putBool("Status", status);
  preferences.end();
}

// Load GM65 scanner status from preferences
bool gm65_loadGM65Status() {
  preferences.begin("GM65", true);
  bool status = preferences.getBool("Status", GM65_OFF);
  preferences.end();
  return status;
}
// Check and apply GM65 scanner status
void gm65_checkGM65Status(bool status) {
  if (status) {
    gm65_Turn_ON_Scanner();
  } else {
    gm65_Turn_OFF_Scanner();
  }
}