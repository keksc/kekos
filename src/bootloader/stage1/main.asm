org 0x7c00
bits 16

%define endl 0xd, 0xa

jmp short start
nop

bpb_oem: db "MSWIN4.1"
bpb_bytesPerSector: dw 512
bpb_sectorsperCluster: db 1
bpb_reservedSectors: dw 1
bpb_FATCount: db 2
bpb_dirEntriesCount: dw 0xe0
bpb_totalSectors: dw 2880
bpb_mediaDescriptorType: db 0xf0
bpb_sectorsPerFAT: dw 9
bpb_sectorsPerTrack: dw 18
bpb_heads: dw 2
bpb_hiddenSectors: dd 0
bpb_largeSectorCount: dd 0

ebr_driveNumber: db 0
db 0 ; reserved
ebr_signature: db 0x29
ebr_volumeID: db 0x26, 0x34, 0x56, 0x77
ebr_volumeLabel: db "KEKOS      "
ebr_systemID: db "FAT12   "

start:
  mov ax, 0
  mov ds, ax
  mov es, ax

  mov ss, ax
  mov sp, 0x7c00

  push es
  push word .realplace
  retf
.realplace:
  mov [ebr_driveNumber], dl
  mov si, msgLoading
  call puts

  push es
  mov ah, 0x8
  int 0x13
  jc readDriveParameters_error
  pop es

  and cl, 0x3f
  xor ch, ch
  mov [bpb_sectorsPerTrack], cx
  
  inc dh
  mov [bpb_heads], dh

; LBA or root dir: reserved + bpb_FATCount * bpb_sectorsPerFAT
  mov ax, [bpb_sectorsPerFAT]
  mov bl, [bpb_FATCount]
  xor bh, bh
  mul bx ; bx * al = bpb_sectorsPerFAT * bpb_FATCount
  add ax, [bpb_reservedSectors] ; ax = LBA of root dir
  push ax

  ; size of root dir = 32 * bpb_dirEntriesCount / bpb_bytesPerSector
  mov ax, [bpb_dirEntriesCount]
  shl ax, 5 ; ax*=32
  xor dx, dx
  div word [bpb_bytesPerSector]

  test dx, dx ; if dw != 0, add 1
  jz .rootDirAfter
  inc ax
  ; division remainder != 0, add 1
                                        ; this means we have a sector only partially filled with entries

.rootDirAfter:
  mov cl, al ; cl = nb of sectors to read = size of root dir
  pop ax ; ax = LBA of root dir
  mov dl, [ebr_driveNumber]

  mov bx, buffer ; es:bx = buffer
  call diskRead
 
  xor bx, bx
  mov di, buffer

.searchStage2:
  mov si, file_stage2
  mov cx, 11
  push di
  repe cmpsb
  pop di
  je .foundStage2

  add di, 32
  inc bx
  cmp bx, [bpb_dirEntriesCount]
  jl .searchStage2

  jmp stage2NotFoundError

.foundStage2:
  ;di should have the addr to the entry
  mov ax, [di+26] ; 1st logical cluster field (offset 26)
  mov [stage2Cluster], ax

  mov ax, [bpb_reservedSectors]
  mov bx, buffer
  mov cl, [bpb_sectorsPerFAT]
  mov dl, [ebr_driveNumber]
  call diskRead

  mov bx, STAGE2_LOAD_SEGMENT
  mov es, bx
  mov bx, STAGE2_LOAD_OFFSET

.loadStage2Loop:
  mov ax, [stage2Cluster]
  add ax, 31
  ; first cluster = (stage2_cluster - 2) * sectors_per_cluster + start_sector
  ; start sector = reserved + fats + root directory size = 1 + 18 + 134 = 33
  
  mov cl, 1
  mov dl, [ebr_driveNumber]
  call diskRead

  add bx, [bpb_bytesPerSector]

  mov ax, [stage2Cluster]
  mov cx, 3
  mul cx
  mov cx, 2
  div cx

  mov si, buffer
  add si, ax
  mov ax, [ds:si]

  or dx, dx
  jz .even

.odd:
  shr ax, 4
  jmp .nextClusterAfter

.even:
  and ax, 0xfff

.nextClusterAfter:
  cmp ax, 0xff8 ; end of chain
  jae .readFinish

  mov [stage2Cluster], ax
  jmp .loadStage2Loop

.readFinish:
  mov dl, [ebr_driveNumber]
  mov ax, STAGE2_LOAD_SEGMENT
  mov ds, ax
  mov es, ax

  jmp STAGE2_LOAD_SEGMENT:STAGE2_LOAD_OFFSET

  jmp waitKeyAndReboot

  cli
  hlt

stage2NotFoundError:
  mov si, msgStage2NotFound
  call puts
  jmp waitKeyAndReboot

readDriveParameters_error:
  mov si, msgReadFailed
  call puts
  jmp waitKeyAndReboot

waitKeyAndReboot:
  mov ah, 0
  int 0x16
  jmp 0xffff:0

; Teletype outputs a string
; Params:
; ds:si: pointer to the string
puts:
  push si
  push ax
  push bx

.putsloop:
  lodsb
  or al, al
  jz .done
  
  mov ah, 0xe
  mov bh, 0
  int 0x10

  jmp .putsloop
.done:
  pop bx
  pop ax
  pop si
  ret

; LBA addr to CHS addr
; Params:
; ax: LBA addr
; Returns:
; cx[0-5]: sector number
; cx[6-15]: cylinder
; dh: head
LBA2CHS:
  push ax
  push dx

  xor dx, dx
  div word [bpb_sectorsPerTrack] ; ax = LBA / bpb_sectorsPerTrack
  ; dx = LBA % bpb_sectorsPerTrack

  inc dx ; dx = LBA / bpb_sectorsPerTrack + 1 = sector
  mov cx, dx ; cx = sector

  xor dx, dx
  div word [bpb_heads] ; ax = LBA / bpb_sectorsPerTrack / bpb_heads = cylinder
  ; dx = LBA  / bpb_sectorsPerTrack % Heads = head

  mov dh, dl ; dh = head
  mov ch, al ; ch = cylinder (lower 8 bits)
  shl ah, 6
  or cl, ah ; put upper 2 bits of cylinder in cl

  pop ax
  mov dl, al ; restore dl
  pop ax
  ret

; read sectors from a disk
; Params:
; ax: LBA addr
; cl: number of sectors to read
; dl: drive number
; es:bx: memory addr where to store read data
diskRead:
  push ax
  push bx
  push cx
  push dx

  push cx ; temp save cl
  call LBA2CHS
  pop ax

  mov ah, 0x2
  int 0x13

  pop dx
  pop cx
  pop bx
  pop ax
  ret

stage2Cluster: dw 0
msgStage2NotFound: db "Couldnt find stage 2", endl, 0
file_stage2: db "STAGE2  BIN"
msgLoading: db "Loading kekos, stage 1", endl, 0
msgReadFailed: db "Reading disk failed", endl, 0
STAGE2_LOAD_SEGMENT     equ 0x0
STAGE2_LOAD_OFFSET      equ 0x500
times 510-($-$$) db 0
dw 0AA55h
buffer:
