#include <stdint.h>
#include "screen.h"

void __attribute((cdecl)) start(uint16_t bootDrive) {
  clearScreen();

  const int wantedW = 1920;
  const int wantedH = 1080;

}
