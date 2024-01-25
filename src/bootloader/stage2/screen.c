#include "screen.h"

const unsigned screenW = 80;
const unsigned screenH = 25;
const uint8_t defaultCol = 0x7;

uint8_t* screenBuf = (uint8_t*)0xb8000;

void printChar(int x, int y, char c) {
  screenBuf[2 * (y * screenW + x)] = c;

}

void clearScreen() {
  for(int y = 0; y < screenH; y++) {
    for(int x = 0; x < screenW; x++) {
      printChar(x, y, '\0');
    }
  }
  printChar(0, 0, 'b');
}
