extern loadGDT

%macro enterRealMode 0
  [bits 32]
  jmp 0x18:.pmode16

.pmode16:
  [bits 16]
  mov eax, cr0
  and al, ~1
  mov cr0, eax

  jmp word 0:.rmode

.rmode:
  mov ax, 0
  mov ds, ax
  mov ss, ax

  sti
%endmacro

%macro enterProtectedMode 0
  [bits 16]
  cli

  call loadGDT

  mov eax, cr0
  or al, 1
  mov cr0, eax

  jmp dword 0x8:.pmode

.pmode:
  [bits 32]

  mov ax, 0x10
  mov ds, ax
  mov ss, ax
%endmacro
