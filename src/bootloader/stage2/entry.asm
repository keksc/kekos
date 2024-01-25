bits 16

section .entry

extern __bss_start
extern __end

extern loadGDT
extern start

%include "procmodes.asm"

global entry
entry:
  mov [bootDrive], dl

  mov ax, ds
  mov ss, ax
  mov sp, 0xfff0
  mov bp, sp

  enterProtectedMode

  mov edi, __bss_start
  mov ecx, __end
  sub ecx, edi
  mov al, 0
  cld
  rep stosb

  xor edx, edx
  mov dl, [bootDrive]
  push edx

  call start
  cli
  hlt

bootDrive: db 0
