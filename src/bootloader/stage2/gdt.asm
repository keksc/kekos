global loadGDT
loadGDT:
  bits 16
  lgdt [gdtDesc]
  ret

gdt:
  dq 0 ; reserved

  ; 32bit code segment
  dw 0xffff ; limit
  dw 0 ; base
  db 0 ; base (bits 16-23)
  db 0b10011001 ; access (present, 2 ring 0, code/data, executable, dir0, not readable, accessed)
  db 0b11001111 ; granularity (4k pages, 32bit, not longmode, reserved, 4 limit)
  db 0
  
  ; 32bit data segment
  dw 0xffff ; limit
  dw 0 ; base
  db 0 ; base (bits 16-23)
  db 0b10010010 ; access (present, 2 ring 0, code/data, executable, dir0, writable, accessed)
  db 0b11001111 ; granularity (4k pages, 32bit, not longmode, reserved, 4 limit)
  db 0

  ; 16bit code segment
  dw 0xffff ; limit
  dw 0 ; base
  db 0 ; base (bits 16-23)
  db 0b10011001 ; access (present, 2 ring 0, code/data, executable, dir0, not readable, accessed)
  db 0b00001111 ; granularity (4k pages, 32bit, not longmode, reserved, 4 limit)
  db 0
  
  ; 16bit data segment
  dw 0xffff ; limit
  dw 0 ; base
  db 0 ; base (bits 16-23)
  db 0b10010010 ; access (present, 2 ring 0, code/data, executable, dir0, writable, accessed)
  db 0b00001111 ; granularity (4k pages, 32bit, not longmode, reserved, 4 limit)
  db 0
gdtEnd:
gdtDesc:
  dw gdtDesc - gdtEnd - 1
  dd gdt

