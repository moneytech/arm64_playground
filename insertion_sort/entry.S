/*
Author: github.com/nilput
A program that takes integers from user input and sorts them
needs to be linked against libc for printf and scanf
entry symbol is to be called from C as void entry(void);
*/
        .data
enter_num_msg:
        .string "Enter numbers followed by an empty line:\n"
too_many_msg:
        .string "Too many numbers!\n"
input_nums_msg:
        .string "input:\n"
output_nums_msg:
        .string "output:\n"
scanf_fmt:
        .string " %d"
printf_int_fmt:
        .string "%d\n"

num_arr:
        .equ num_arr_size, 32
        .skip   (4 * num_arr_size), 0
        .text

        .global entry
        .type   entry, %function
entry:
        stp     x29, x30, [sp, #-16]!    // Pre addressing mode, subtract then store 
                                         // Push Frame Pointer and Link Register
        stp     x19, x20, [sp, #-16]!    // save callee saved registers, we're gonna use to count stuff
        sub     sp, sp, #16              // Grow stack for two dword variables

        ldr     X0, =enter_num_msg
        bl      printf
        /*
            Stack layout (8 byte lines)
            --Higher Address--
            x29
            x30
            num_word    num_arr_len
            unused_
            --Lower  Address--
        */
        mov     w1, #0
        str     w1, [sp, #4]            //Store num_len in ((int *)sp)[1]
        b       read_number

save_number:
        ldr     w0, [sp]                // Load scanf result
        ldr     x2, =num_arr            // x2 = (int*) num_arr
        // should zero extend?
        str     w0, [x2, x1, lsl 2]     // ((int *)x2)[num_arr] = w0
                                        // x2[w1 * 4] = w0
        add     w1, w1, 1
        str     w1, [sp, #4]            // Store num_len in ((int *)sp)[1]
read_number:
        mov     x1, sp                  // X1 = ((int *)sp) + 0 (scanf integer dest)
        ldr     x0, =scanf_fmt          
        bl      scanf
        cbz     w0, scanf_returned_zero // jmp if scanf() == 0
        ldr     w1, [sp, #4]            // load num_len from ((int *)sp)[1]
        cmp     w1, #num_arr_size
        blo     save_number             // jmp if unsigned < 
scanf_too_many:
        ldr     X0, =too_many_msg
        bl      printf
scanf_returned_zero:
        ldr     X0, =input_nums_msg
        bl      printf

        ldr     x0, =num_arr
        ldr     w1, [sp, #4]            // load num_len from ((int *)sp)[1]
        bl      print_nums

        ldr     X0, =output_nums_msg
        bl      printf

        ldr     x0, =num_arr
        ldr     w1, [sp, #4]            // load num_len from ((int *)sp)[1]
        bl      sort_nums

        ldr     x0, =num_arr
        ldr     w1, [sp, #4]            // load num_len from ((int *)sp)[1]
        bl      print_nums

        add     sp, sp, 16              // Shrink the stack by the 16 we added
        ldp     x19, x20, [sp], #16     // Callee saved registers, we're gonna use to count stuff
        ldp     x29, x30, [sp], #16     // Post addressing mode, load then add
        ret
        .size   entry, (. - entry)

/*
Procedure sort_nums(int *nums, int nums_len) (insertion sort)
*/
//clobbers: x0,x1,x2,x3,x4,x5,x6
sort_nums:
        stp     x29, x30, [sp, #-16]!       // Save LR and FP
                                        // x0 = nums
        add     x1, x0, x1, lsl 2           // x1 = nums_end
        mov     x2, x0                      // x2 = nums + i, (i = 0)
0:
        add     x2, x2, 4                   // i++
        cmp     x2, x1                      // nums+i >= nums_end ? break
        bhs     1f
        ldr     w3, [x2, #-4]               // w3: loaded nums[i - 1]
        ldr     w4, [x2]                    // w4: loaded nums[i]
        cmp     w4, w3
        bge     0b                          // nums[i] >= nums[i - 1] ? loop i
                                        // here nums[i] < nums[i - 1]
        mov     x5, x2                      // x5 = nums + i  (j = i)
2:
        ldr     w6, [x5, #-4]!              // w6 = nums[--j]
        cmp     w4, w6 
        bge     3f                          // nums[i] >= nums[j-1] ? break
        str     w6, [x5, #4]                // nums[j+1] = nums[j]
        cmp     x5, x0
        bhi     2b                          // j > 0 ? loop j
        sub     x5, x5, #4
3:                                      // end j loop
        str     w4, [x5, #4]                // nums[j] = v
        b       0b                          // loop
1:
        ldp     x29, x30, [sp], #16         // Restore LR and FP
        ret
.size   sort_nums, (. - sort_nums)
.type   sort_nums, %function
    
/*
Procedure print_nums(int *nums, int nums_len)
*/
print_nums:
        stp     x29, x30, [sp, #-16]!   // Save FP and LR
        stp     x19, x20, [sp, #-16]!   // Save x19 and x20
        mov     x19, x0                 // x19 = nums
        mov     w20, w1                 // w20 = nums_len

        cbz     w20, 1f                 // if len == 0 return
0:
        ldr     w1, [x19], #4
        ldr     x0, =printf_int_fmt
        bl      printf
        subs    w20, w20, 1
        bhi     0b                      // jmp if (--nums_len > 1)
1:
        ldp     x19, x20, [sp], #16      // Restore x19 and x20
        ldp     x29, x30, [sp], #16      // Restore FP and LR
        ret
.size   print_nums, (. - print_nums)
.type   print_nums, %function
