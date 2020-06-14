.data
msg:
.string     "hello world!\n"
.text
.global entry
.type   entry, %function
entry:
        stp     x29, x30, [sp, #-16]!    // Pre addressing mode, subtract then store 
                                         // Push Frame Pointer and Link Register
        ldr     X0, =msg
        bl      printf
        ldp     x29, x30, [sp], #16      // Post addressing mode, load then add
        ret
.size   entry, (. - entry)
