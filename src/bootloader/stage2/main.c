#include <stdint.h>
#include "screen.h"
#include "vbe.h"
#include "memdefss.h"

void __attribute((cdecl)) start(uint16_t bootDrive) {
  clearScreen();
  
  for(int i = 0; i < 35; i++) {
    printC('s');
    printC('\n');
  }

  const int wantedW = 1920;
  const int wantedH = 1080;
  VbeInfoBlock* info = (VbeInfoBlock*)MEMORY_VESA_INFO;
  VBE_GetControllerInfo(info);

}
