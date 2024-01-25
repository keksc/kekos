vbeInfoBlock:
  db "VESA" ; vbe signature
  dw 0x300 ; vbe version
  dw 0, 0 ; oemStringPtr
  db 0, 0, 0, 0 ; capabilities
  dd 0 ; videoModePtr
  dw 0 ; totalMemory
  resb 492 ; reserved

