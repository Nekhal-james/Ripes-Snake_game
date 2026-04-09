.data
# Game State - 100 slots each to prevent the "scattered dots" memory leak
snake_x:  .word 10, 9, 8, 7, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
snake_y:  .word 10, 10, 10, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
length:   .word 5
curr_dir: .word 3         # 0:U, 1:D, 2:L, 3:R
food_x:   .word 15
food_y:   .word 15

# Colors
C_SNAKE:  .word 0xFF00FF00
C_FOOD:   .word 0xFFFF0000
C_BG:     .word 0xFF000000
C_SCORE:  .word 0xFFFFFF00

.text
main:
    li s0, 0xf0000010       # LED Matrix Base
    li s1, 0xf0000000       # D-Pad Base
    la s2, snake_x          # Pointer to X array
    la s3, snake_y          # Pointer to Y array

game_loop:
    # --- 1. Body Shifting ---
    la t0, length
    lw t0, 0(t0)
    addi t3, t0, -1         # Start shifting from the tail

shift_loop:
    blez t3, move_head
    slli t4, t3, 2          # current segment offset
    addi t5, t4, -4         # leading segment offset
    add a0, s2, t4
    add a1, s2, t5
    lw a2, 0(a1)
    sw a2, 0(a0)            # Shift X
    add a0, s3, t4
    add a1, s3, t5
    lw a2, 0(a1)
    sw a2, 0(a0)            # Shift Y
    addi t3, t3, -1
    j shift_loop

move_head:
    la t4, curr_dir
    lw t4, 0(t4)
    lw t5, 0(s2)            # Head X
    lw t6, 0(s3)            # Head Y
    
    li t3, 0
    beq t4, t3, m_up
    li t3, 1
    beq t4, t3, m_down
    li t3, 2
    beq t4, t3, m_left
    li t3, 3
    beq t4, t3, m_right

m_up:
    addi t6, t6, -1
    j wrap
m_down:
    addi t6, t6, 1
    j wrap
m_left:
    addi t5, t5, -1
    j wrap
m_right:
    addi t5, t5, 1
    j wrap

wrap:
    # X/Y Screen Wrap (0-19)
    li t3, 19
    bltz t5, w_x_neg
    bgt t5, t3, w_x_pos
    j w_y_chk
w_x_neg:
    li t5, 19
    j w_y_chk
w_x_pos:
    li t5, 0
w_y_chk:
    bltz t6, w_y_neg
    bgt t6, t3, w_y_pos
    j post_wrap
w_y_neg:
    li t6, 19
    j post_wrap
w_y_pos:
    li t6, 0
post_wrap:
    sw t5, 0(s2)
    sw t6, 0(s3)

    # --- 2. Food & Collision ---
    la a4, food_x
    lw a5, 0(a4)
    la a6, food_y
    lw a7, 0(a6)
    bne t5, a5, render      # If head X != food X, skip eating
    bne t6, a7, render      # If head Y != food Y, skip eating
    
    # EAT: grow length and move food
    la t0, length
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    
    addi a5, a5, 7
    li t3, 20
    rem a5, a5, t3          # Move food X
    sw a5, 0(a4)
    
    addi a7, a7, 3
    li t3, 19
    rem a7, a7, t3
    addi a7, a7, 1          # Move food Y (stays off row 0)
    sw a7, 0(a6)

render:
    # Clear Matrix
    li t3, 400
    la t4, C_BG
    lw t4, 0(t4)
    li t5, 0
clr_lp:
    slli t6, t5, 2
    add t6, t6, s0
    sw t4, 0(t6)
    addi t5, t5, 1
    blt t5, t3, clr_lp

    # Draw Score Bar
    la t0, length
    lw t0, 0(t0)
    addi t0, t0, -5
    blez t0, d_food
    la t4, C_SCORE
    lw t4, 0(t4)
    li t5, 0
score_lp:
    slli t6, t5, 2
    add t6, t6, s0
    sw t4, 0(t6)
    addi t5, t5, 1
    blt t5, t0, score_lp

d_food:
    la t0, food_x
    lw t0, 0(t0)
    la t1, food_y
    lw t1, 0(t1)
    li t2, 20
    mul t1, t1, t2
    add t1, t1, t0
    slli t1, t1, 2
    add t1, t1, s0
    la t4, C_FOOD
    lw t4, 0(t4)
    sw t4, 0(t1)

    # Draw Snake
    la a0, length
    lw a0, 0(a0)
    li a1, 0
snk_draw:
    slli t2, a1, 2
    add t0, s2, t2
    lw t0, 0(t0)            # Current segment X
    add t1, s3, t2
    lw t1, 0(t1)            # Current segment Y
    li t2, 20
    mul t1, t1, t2
    add t1, t1, t0
    slli t1, t1, 2
    add t1, t1, s0
    la t4, C_SNAKE
    lw t4, 0(t4)
    sw t4, 0(t1)
    addi a1, a1, 1
    blt a1, a0, snk_draw

    # --- 3. Responsive Input Delay ---
    li t0, 3000             # Increase this to slow the snake down
poll_wait:
    lw t1, 0(s1)            # Check UP
    beqz t1, p_d
    li t2, 0
    la t3, curr_dir
    sw t2, 0(t3)
p_d:
    lw t1, 4(s1)            # Check DOWN
    beqz t1, p_l
    li t2, 1
    la t3, curr_dir
    sw t2, 0(t3)
p_l:
    lw t1, 8(s1)            # Check LEFT
    beqz t1, p_r
    li t2, 2
    la t3, curr_dir
    sw t2, 0(t3)
p_r:
    lw t1, 12(s1)           # Check RIGHT
    beqz t1, p_done
    li t2, 3
    la t3, curr_dir
    sw t2, 0(t3)
p_done:
    addi t0, t0, -1
    bnez t0, poll_wait
    j game_loop