global outb
outb:
  [bits 32]
  mov dx, [esp+4]
  mov al, [esp+8]
  out dx, al
  ret
