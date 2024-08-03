.intel_syntax noprefix

.data
    flags_ptr: .long 0
.section .rodata
    flag_format_print: .asciz "The Flag %s is : %x\n"
    ID_FLAG: .asciz "ID Flag"
    CARRY_FLAG: .asciz "Carry Flag"
    PARITY_FLAG: .asciz "Parity Flag"
    AUXILIARY_CARRY_FLAG: .asciz "AF Flag"
    ZERO_FLAG: .asciz "Zero Flag"
    SIGN_FLAG: .asciz "Sign Flag"
    TRAP_FLAG: .asciz "Trap Flag"
    INTERRUPT_FLAG: .asciz "Interrupt Enable Flag"
    DIRECTION_FLAG: .asciz "Direction Flag"
    OVERFLOW_FLAG: .asciz "Overflow Flag"
    IO_PRIV_FLAG: .asciz "IOPL"
    NESTED_TASK_FLAG: .asciz "Nested Flag"
    RESUME_FLAG: .asciz "Resume Flag"
    VM_MODE_FLAG: .asciz "VM Flag"
    AC_FLAG: .asciz "AC FLAG"
    VIRTUAL_INT_FLAG: .asciz "VIF Flag"
    VIRTUAL_INT_PENDING_FLAG: .asciz "VIP Flag"


    flags_array:
        .quad CARRY_FLAG
        .quad PARITY_FLAG
        .quad AUXILIARY_CARRY_FLAG
        .quad ZERO_FLAG
        .quad SIGN_FLAG
        .quad TRAP_FLAG
        .quad INTERRUPT_FLAG
        .quad DIRECTION_FLAG
        .quad OVERFLOW_FLAG
        .quad IO_PRIV_FLAG
        .quad NESTED_TASK_FLAG
        .quad RESUME_FLAG
        .quad VM_MODE_FLAG
        .quad AC_FLAG
        .quad VIRTUAL_INT_FLAG
        .quad VIRTUAL_INT_PENDING_FLAG
        .quad ID_FLAG

    flags_offset:
        CARRY_FLAG_OFFSET:  .quad 0
        PARITY_FLAG_OFFSET:  .quad 2
        AUXILIARY_CARRY_FLAG_OFFSET:  .quad 4
        ZERO_FLAG_OFFSET:  .quad 6
        SIGN_FLAG_OFFSET:  .quad 7
        TRAP_FLAG_OFFSET:  .quad 8
        INTERRUPT_FLAG_OFFSET:  .quad 9
        DIRECTION_FLAG_OFFSET:  .quad 10
        OVERFLOW_FLAG_OFFSET:  .quad 11
        IO_PRIV_FLAG_OFFSET:  .quad 12
        NESTED_TASK_FLAG_OFFSET:  .quad 14
        RESUME_FLAG_OFFSET:  .quad 16
        VM_MODE_FLAG_OFFSET:  .quad 17
        AC_FLAG_OFFSET:  .quad 18
        VIRTUAL_INT_FLAG_OFFSET:  .quad 19
        VIRTUAL_INT_PENDING_FLAG_OFFSET:  .quad 20
        ID_FLAG_OFFSET:  .quad 21



.text
.global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10

    xor rdi, rdi
    mov [rbp - 0x8], rdi

print_flags_loop:
    // this is mandatory to keep stack 16 bytes aligned;
    //The alignment requirement allows the use of SSE instructions when operating on the array
    mov rdi, [rbp - 0x8]

    call print_flag

    // increment index
    mov rdi, [rbp - 0x8]
    add rdi, 0x1
    mov [rbp - 0x8], rdi

    cmp rdi, 0x11
    jnz print_flags_loop

    leave
    ret


.func print_flag
print_flag:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10
    push rbx
    push rcx

    // put the flag index in a variable
    mov [rbp -  0x8], rdi
    mov rdi, [flags_array + rdi * 8]
    // store the specific flag we going to print
    mov [rbp - 0x10], rdi

    lea rdi, flag_format_print
    mov rsi, [rbp - 0x10]

    pushfq
    pop rbx
    mov [flags_ptr], rbx
    mov rcx, [rbp - 0x8]

    # get the correct index
    mov rcx, [flags_offset + rcx * 8]

    // handle special cases
    // if IOPL its 2 bits
    cmp rcx, 0xC
    jnz one_bit
    mov rdx, 0x3
    jmp get_bits

one_bit:
    mov rdx, 0x1
get_bits:
    shl rdx, rcx
    and rdx, rbx

    // shift back the result
    shr rdx, rcx

    call printf
    
    pop rcx
    pop rbx
    leave
    ret