    .section .rodata
filename: .string "input.txt"
mode: .string "r"
msg_yes: .string "Yes\n"
msg_no: .string "No\n"

    .section .text
    .global main

main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp) #end ptr
    sd s2, 16(sp) #start ptr
    sd s3, 8(sp)

    lla a0, filename # first arg
    lla a1, mode #second arg
    call fopen

    mv s0, a0 #s0 -> file ptr

    #go to the  eof
    mv a0, s0
    li a1, 0
    li a2, 2 # SEEK_END = 2
    call fseek

    mv a0, s0
    call ftell
    mv s1, a0 # s1 = file_size
    addi s1, s1, -1

/*
    #IF THE FINAL CHAR IS \n
    mv a0, s0
    mv a1, s1
    li a2, 0
    call fseek #point to last char

    mv a0, s0
    call fgetc # last char
    li t0, 10 #10 ascii-> '\n"
    
    bne a0, t0, file_ready # if not a newline, skip to file_ready
    
    addi s1, s1, -1 */

file_ready:
    #back to begining of file
    mv a0, s0
    li a1, 0
    li a2, 0
    call fseek

    li s2, 0 #left ptr

start_loop:
    bge s2, s1, yes_palindrome
    mv a0, s0 #file ptr
    mv a1, s2 # pos of left ptr
    li a2, 0 # SEEK_SET
    call fseek

    mv a0, s0
    call fgetc
    mv s3, a0 # s3 = LEFTCHAR

    # --- RIGHT CHAR FETCH---
    mv a0, s0
    mv a1, s1
    li a2, 0
    call fseek

    mv a0, s0
    call fgetc

    mv t0, a0 # t0 = char from right ptr

    bne s3, t0, no_palindrome # if both chars not equal

    addi s2, s2, 1 #move left ptr
    addi s1, s1, -1 #move right ptr
    j start_loop


no_palindrome:
    lla a0, msg_no
    call printf
    j program_end

yes_palindrome:
    lla a0, msg_yes
    call printf

program_end:
    mv a0, s0
    call fclose #close the file

    li a0, 0
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    addi sp, sp, 48
    ret

    