    .section .rodata
fmt_num: .string "%d"
fmt_space: .string " "
fmt_nl: .string "\n"

    .section .text
    .globl main

main:
    addi sp, sp, -80

    sd ra, 72(sp)
    sd s0, 64(sp)
    sd s1, 56(sp)
    sd s2, 48(sp) # i
    sd s3, 40(sp) # arr ptr
    sd s4, 32(sp) # no of elts
    sd s5, 24(sp) # res array ptr
    sd s6, 16(sp) #stack arr ptr
    sd s7, 8(sp) #stack top index

    # s2 = loop counter
    # s3 = ptr to array
    mv s0, a0 # argc
    mv s1, a1 #argv

    addi s4, s0, -1 # no of args
    blez s4, exit_prog

    slli a0, s4, 2 # a0 = a0*4
    call malloc
    mv s3, a0

    li s2, 1

start_loop:
    bge s2, s0, logic # if i>=argc jump

    # skip the first argument, it is the filename
    slli t0, s2, 3 # t0 = i*8
    add t1, s1, t0 
    ld a0, 0(t1) # a0 = argv[i]

    call atoi #string -> int

    addi t0, s2, -1 # arr index (i-1)
    slli t0, t0, 2
    add t1, s3, t0
    sw a0, 0(t1)

    addi s2, s2, 1 #i++
    j start_loop


logic:
    # INITIALISING RESULT ARRAY
    addi a0, s0, -1
    slli a0, s4, 2
    call malloc
    mv s5, a0 # result array
    li t0, -1 # default value
    li t1, 0 #loop counter

res_loop:
    bge t1, s4, init_res_done
    slli t2, t1, 2
    add t3, s5, t2
    sw t0, 0(t3) # result[i] = -1
    addi t1, t1, 1
    j res_loop

init_res_done:
    slli a0, s4, 2
    call malloc
    mv s6, a0 # s6 = stack 
    li s7, 0 # s7 = stack top

    addi s2, s4, -1 # i = n-1

arr_loop:
    bltz s2, print_result

    slli t0, s2, 2
    add t0, s3, t0
    lw a5, 0(t0) #a5 = arr[i]

while_loop:
    beqz s7, while_end # condition1: !stack.empty()

    # get stack[top-1]
    addi t0, s7, -1
    slli t0, t0, 2
    add t0, s6, t0
    lw t1, 0(t0) #t1 = index at stack top

    # get arr[stack.top()]
    slli t2, t1, 2
    add t2, s3, t2
    lw t2, 0(t2) # t2 = arr[stack.top()]

    # Condition 2: arr[stack.top()] <= arr[i]
    bgt t2, a5, while_end # If stack element > current element, break!

    # stack.pop()
    addi s7, s7, -1 # top--
    j while_loop

while_end:
    # iff (!stack.empty()) result[i] = stack.top()
    beqz s7, skip_if
    
    addi t0, s7, -1
    slli t0, t0, 2
    add t0, s6, t0
    lw t1, 0(t0) # t1 = stack.top()

    slli t0, s2, 2
    add t0, s5, t0
    sw t1, 0(t0)

skip_if:
    # stack.push(i)
    slli t0, s7, 2
    add t0, s6, t0
    sw s2, 0(t0) # stack[top] = i
    addi s7, s7, 1 # top++

    # i--
    addi s2, s2, -1
    j arr_loop


print_result:
    li s2, 0
print_loop:
    bge s2, s4, print_nl
    slli t0, s2, 2
    add t0, s5, t0
    lw a1, 0(t0)# a1 = result[i]

    lla a0, fmt_num # "%d"
    call printf

    addi s2, s2, 1
    bge s2, s4, print_nl
    lla a0, fmt_space
    call printf
    j print_loop

print_nl:
    lla a0, fmt_nl # "\n"
    call printf
    mv a0, s3
    call free
    mv a0, s5
    call free
    mv a0, s6
    call free

exit_prog:
    li a0, 0
    ld ra, 72(sp)
    ld s0, 64(sp)
    ld s1, 56(sp)
    ld s2, 48(sp)
    ld s3, 40(sp)
    ld s4, 32(sp)
    ld s5, 24(sp)
    ld s6, 16(sp)
    ld s7, 8(sp)
    addi sp, sp, 80
    ret
