/*!
   @file debug.h
   @brief Debugging utilities for serial output
   @author Mahmoud Yasser
*/

#ifndef DEBUG_H
#define DEBUG_H

// Debugging macros
#define DEBUG  // Enable debug output

/**
 * @brief Prints to Serial if DEBUG is defined, otherwise does nothing.
 * @param x The value to print.
 */
#ifdef DEBUG
#define debugPrint(x) Serial.print(x)
#else
#define debugPrint(x)
#endif

/**
 * @brief Prints to Serial with newline if DEBUG is defined, otherwise does nothing.
 * @param x The value to print.
 */
#ifdef DEBUG
#define debugPrintln(x) Serial.println(x)
#else
#define debugPrintln(x)
#endif

#endif // DEBUG_H