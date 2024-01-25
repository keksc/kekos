#include "screen.h"

const unsigned screenW = 80;
const unsigned screenH = 25;
const uint8_t defaultCol = 0x7;

uint8_t* screenBuf = (uint8_t*)0xb8000;

int cursor[2] = {0, 0};

char getC(int x, int y) {
  return screenBuf[2 * (y * screenW + x)];
}

void putC(int x, int y, char c) {
  screenBuf[2 * (y * screenW + x)] = c;
}

void scroll(int lines) {
  for(int y = lines; y < screenH; y++) {
    for(int x = 0; y < screenW; x++) {
      putC(x, y - lines, getC(x, y));
    }
  }
  for(int y = screenH - lines; y < screenH; y++) {
    for(int x = 0; x < screenW; x++) {
      putC(x, y, '\0');
    }
  }
}

void printC(char c) {
  if(c == '\n') {
    cursor[0] = 0;
    cursor[1]++;
  } else {
    putC(cursor[0], cursor[1], c);
    cursor[0]++;
  }
  if(cursor[0] >= screenW) {
    cursor[0] = 0;
    cursor[1]++;
  }
  if(cursor[1] >= screenH) {
    scroll(1);
  }
}

void clearScreen() {
  for(int y = 0; y < screenH; y++) {
    for(int x = 0; x < screenW; x++) {
      putC(x, y, '\0');
    }
  }
}
