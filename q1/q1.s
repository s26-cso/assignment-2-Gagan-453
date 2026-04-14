    .section .text
    .globl make_node
    .globl insert
    .globl get
    .globl getAtMost

make_node:
    # save return address and s0
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)

    mv s0, a0 # a0 = val
    li a0, 24 #size of Node struct
    call malloc # a0 -> pointer

    sw s0, 0(a0) # node->val = val
    sd zero, 8(a0) # node->left = null
    sd zero, 16(a0)


    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 16
    ret 

insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)

    #a0 -> root ptr, a1->val

    beqz a0, rootptrnull

    mv s0, a1 #key
    mv s1, a0 #root node ptr

    lw t1, 0(s1)
    beq s0, t1, insert_end
    blt s0, t1, updateleft # if key < root->val

    j updateright



rootptrnull:
    mv a0, a1
    call make_node # create new node and return
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    addi sp, sp, 32
    ret 

updateleft:
    ld a0, 8(s1)
    mv a1, s0
    call insert
    sd a0, 8(s1) # root->left = insert(root->left, key)
    j insert_end

updateright:
    ld a0, 16(s1)
    mv a1, s0
    call insert
    sd a0, 16(s1)

insert_end:
    mv a0, s1
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    addi sp, sp, 32
    ret

get:
get_loop:
    beqz a0, get_end # If root is NULL then return NULL
    
    lw t0, 0(a0) # t0 = root->val
    beq a1, t0, get_end # If val == root->val, return root (a0 is root)
    
    blt a1, t0, get_left
get_right:
    ld a0, 16(a0) # root = root->right
    j get_loop
get_left:
    ld a0, 8(a0) # root = root->left
    j get_loop
get_end:
    ret

getAtMost:
    # a0 -> val, a1-> root ptr
    li t0, -1 # t0 -> best value
    mv t1, a1 # t1 -> current node

start_loop:
    beqz t1, gat_end
    lw t2, 0(t1) # t2 = curr_node->val

    beq t2, a0, match # if val exactly matches with a node
    bgt t2, a0, go_left
    j go_right

go_left:
    ld t1, 8(t1) # curr_node = curr_node->left
    j start_loop

go_right:
    # curr_node->val < val
    mv t0, t2 # update best value
    ld t1, 16(t1)
    j start_loop

match:
    mv t0, t2
    j gat_end

gat_end:
    mv a0, t0 #return the best val
    ret
