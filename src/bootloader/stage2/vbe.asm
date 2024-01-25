%include "procmodes.asm"
%include "lin2SegOffset.asm"

struc VesaInfoBlock
  .sig resb 4
  .version resw 1
  .OEMNamePtr resd 1
  .capabilities resd 1

  .videoModesOffset resw 1
  .videoModesSegment resw 1

  .countOf64KBlocks resw 1
  .OEMSoftwareRevision resw 1
  .OEMVendorNamePtr resd 1
  .OEMProductNamePtr resd 1
  .OEMProductRevisionPtr resd 1
  .reserved resb 222
  .OEMData resb 256
endstruc

global getVBEInfo
getVBEInfo:
  push ebp
  mov ebp, esp

  enterRealMode

  push edi
  push es
  push ebp ;bochs vbe changes ebp

  mov ax, 0x4f00 ; ah = 4f, al = 00
  lin2SegOffset [bp+8], es, edi, di
  int 0x10

  cmp al, 0x4f
  jne .getVBEInfoError

  mov al, ah
  and eax, 0xff
  jmp .getVBEInfoOK

.getVBEInfoError:
  mov eax, -1

.getVBEInfoOK:
  pop ebp
  pop es
  pop ebx

  push eax
  enterProtectedMode
  pop eax

  mov esp, ebp
  pop ebp
  ret


VesaInfoBlockBuf: istruc VesaInfoBlock
    at VesaInfoBlock.sig, db "VESA"
    times 508 db 0
  iend
