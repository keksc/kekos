%macro lin2SegOffset 4
  mov %3, %1      ; linear address to eax
  shr %3, 4
  mov %2, %4
  mov %3, %1      ; linear address to eax
  and %3, 0xf
%endmacro
