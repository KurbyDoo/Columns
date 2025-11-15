.data
# Display and Input Addresses
DISPLAY_ADDRESS: .word 0x10008000
KEYBOARD_FLAG:   .word 0xffff0000 # Address that signals a key has been pressed
KEYBOARD_DATA:   .word 0xffff0004 # Address that holds the pressed key's value

# Colors (32-bit color: 0x00RRGGBB)
COLOR_BLACK:   .word 0x00000000
COLOR_WHITE:   .word 0x00FFFFFF
COLOR_RED:     .word 0x00FF0000
COLOR_BLUE:    .word 0x000000FF

# Game board (9 words, initialized to 0)
game_board: .space 36 # 9 * 4 bytes

# Cursor position (row, col from 0-2)
cursor_col: .word 0
cursor_row: .word 0

# ASCII values for keys
KEY_X: .word 0x78 # 'x'
KEY_O: .word 0x6f # 'o'
# NOTE: Arrow key values are guesses. You may need to find the correct
# values by testing what appears in the KEYBOARD_DATA address.
KEY_UP:    .word 0x77 # 'w' (was 0x57 for 'W')
KEY_DOWN:  .word 0x73 # 's' (was 0x53 for 'S')
KEY_LEFT:  .word 0x61 # 'a' (was 0x41 for 'A')
KEY_RIGHT: .word 0x64 # 'd' (was 0x44 for 'D')
COLOR_GREEN:   .word 0x0000FF00

msg_loop: .asciiz "Looping...\n"
msg_key_flag_val: .asciiz "  Keyboard Flag Value: "
msg_key_detected: .asciiz "  Key Press Detected!\n"
msg_key_ascii_val: .asciiz "  Key ASCII Value: "
msg_loop_counter: .asciiz "Cursor loop counter i ($t0): "
newline: .asciiz "\n"

.text
.globl main
main:
    # Runs ONCE at the start
    jal clear_screen
    jal draw_grid

# debug_game_loop:
    # # --- DEBUG PRINT ---
    # # Print "Looping..." to the console
    # li $v0, 4
    # la $a0, msg_loop
    # syscall
    # # --- END DEBUG ---

    # # Call the input handler
    # jal handle_input

    # # Delay to make the console output readable
    # li $v0, 32
    # li $a0, 250 # sleep for 250ms
    # syscall

    # j debug_game_loop # Loop forever

game_loop:
    # Handle Input
    jal handle_input

    # Draw the game state
    jal clear_screen
    jal draw_board
    jal draw_cursor
    jal draw_grid

    # A small delay to prevent the loop from running too fast
    li $v0, 32
    li $a0, 100 # sleep for 100ms
    syscall

    # Loop forever
    j game_loop


# --- Drawing Functions ---

# -----------------------------------------------------------------------
# draw_pixel: Draws a single pixel on the screen. (Safe Version)
# Arguments:
#   $a0 - x coordinate (0-63)
#   $a1 - y coordinate (0-63)
#   $a2 - color
# -----------------------------------------------------------------------
draw_pixel:
    # --- SAVE REGISTERS ---
    # Save any temporary registers we are about to modify ($t0, $t1, $t2)
    # as well as the return address ($ra).
    addi $sp, $sp, -16
    sw   $ra, 0($sp)
    sw   $t0, 4($sp)
    sw   $t1, 8($sp)
    sw   $t2, 12($sp)

    # --- FUNCTION BODY ---
    lw   $t0, DISPLAY_ADDRESS  # $t0 = base display address
    sll  $t1, $a1, 6           # $t1 = y * 64
    add  $t1, $t1, $a0         # $t1 = y * 64 + x
    sll  $t1, $t1, 2           # $t1 = (y * 64 + x) * 4 (byte offset)
    add  $t2, $t0, $t1         # $t2 = base_address + offset
    sw   $a2, 0($t2)           # Draw the pixel

    # --- RESTORE REGISTERS ---
    # Restore the registers to the exact state they were in before this
    # function was called.
    lw   $ra, 0($sp)
    lw   $t0, 4($sp)
    lw   $t1, 8($sp)
    lw   $t2, 12($sp)
    addi $sp, $sp, 16

    jr   $ra

draw_grid:
    lw   $t0, DISPLAY_ADDRESS  # Base display address
    lw   $t1, COLOR_WHITE      # Line color (e.g., white)

    # --- Draw two vertical lines ---
    li   $t2, 0                # Initialize y = 0
loop_vertical_lines:
    beq  $t2, 64, end_vertical_loop # Loop from y = 0 to 63

    # Calculate address for pixel at (x=21, y)
    # Address = base + (y * 64 + x) * 4
    # We use shifts: y * 64 is (y << 6), and the final * 4 is (<< 2)
    sll  $t3, $t2, 6        # t3 = y * 64
    addi $t3, $t3, 21      # t3 = y * 64 + 21
    sll  $t3, $t3, 2        # t3 = (y * 64 + 21) * 4 (byte offset)
    add  $t4, $t0, $t3      # t4 = base_address + offset
    sw   $t1, 0($t4)        # Set the pixel color for the first line

    # Calculate address for pixel at (x=42, y)
    sll  $t3, $t2, 6        # t3 = y * 64
    addi $t3, $t3, 42      # t3 = y * 64 + 42
    sll  $t3, $t3, 2        # t3 = (y * 64 + 42) * 4
    add  $t4, $t0, $t3      # t4 = base_address + offset
    sw   $t1, 0($t4)        # Set the pixel color for the second line

    addi $t2, $t2, 1        # y++
    j    loop_vertical_lines
end_vertical_loop:

    # --- Draw two horizontal lines ---
    li   $t2, 0                # Initialize x = 0
loop_horizontal_lines:
    beq  $t2, 64, end_horizontal_loop # Loop from x = 0 to 63

    # Calculate address for pixel at (x, y=21)
    # y_offset for y=21 is (21 * 64) = 1344
    li   $t5, 1344
    add  $t3, $t5, $t2      # t3 = 21 * 64 + x
    sll  $t3, $t3, 2        # t3 = (21 * 64 + x) * 4
    add  $t4, $t0, $t3      # t4 = base_address + offset
    sw   $t1, 0($t4)        # Set the pixel color for the first line

    # Calculate address for pixel at (x, y=42)
    # y_offset for y=42 is (42 * 64) = 2688
    li   $t5, 2688
    add  $t3, $t5, $t2      # t3 = 42 * 64 + x
    sll  $t3, $t3, 2        # t3 = (42 * 64 + x) * 4
    add  $t4, $t0, $t3      # t4 = base_address + offset
    sw   $t1, 0($t4)        # Set the pixel color for the second line

    addi $t2, $t2, 1        # x++
    j    loop_horizontal_lines
    
end_horizontal_loop:
    jr   $ra

# -----------------------------------------------------------------------
# draw_board: Iterates through the game_board array and draws
#             the corresponding X or O for each cell.
# -----------------------------------------------------------------------
draw_board:
    # Save registers
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)  # i (loop counter)
    sw   $s1, 8($sp)  # board value
    sw   $s2, 12($sp) # row
    sw   $s3, 16($sp) # col

    la   $t0, game_board # Load base address of the board
    li   $s0, 0          # i = 0

draw_board_loop:
    beq  $s0, 9, draw_board_done # Loop 9 times for 9 cells

    # Load the value from game_board[i]
    sll  $t1, $s0, 2      # offset = i * 4
    add  $t2, $t0, $t1    # address = &game_board[i]
    lw   $s1, 0($t2)      # $s1 = game_board[i]

    # Calculate row and column from index i
    li   $t3, 3
    divu $s0, $t3
    mflo $s2             # s2 (row) = i / 3 (quotient)
    mfhi $s3             # s3 (col) = i % 3 (remainder)

    # Check the board value
    beq  $s1, 1, draw_board_x # If 1, draw 'X'
    beq  $s1, 2, draw_board_o # If 2, draw 'O'
    j    continue_board_loop   # If 0 or other, do nothing

draw_board_x:
    move $a0, $s2
    move $a1, $s3
    jal  draw_x
    j    continue_board_loop

draw_board_o:
    move $a0, $s2
    move $a1, $s3
    jal  draw_o

continue_board_loop:
    addi $s0, $s0, 1
    j    draw_board_loop

draw_board_done:
    # Restore registers and return
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1, 8($sp)
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 20
    jr   $ra

# -----------------------------------------------------------------------
# draw_x: (SAFE VERSION) Draws an 'X' in a given grid cell.
# -----------------------------------------------------------------------
draw_x:
    # --- SAVE REGISTERS ---
    # We save all registers this function modifies: $ra, $s0, $s1, $t0, $t1
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $t0, 12($sp)
    sw   $t1, 16($sp)

    # Calculate top-left corner of the cell's drawing area
    li   $t0, 22
    mul  $s0, $a1, $t0  # x_start = col * 22
    mul  $s1, $a0, $t0  # y_start = row * 22
    addi $s0, $s0, 4   # Add margin
    addi $s1, $s1, 4   # Add margin

    lw   $a2, COLOR_RED # Use red for 'X'

    # Draw the two diagonal lines
    li   $t0, 0 # i = 0
draw_x_loop:
    beq  $t0, 14, draw_x_done

    # First diagonal (\)
    add  $a0, $s0, $t0
    add  $a1, $s1, $t0
    jal  draw_pixel

    # Second diagonal (/)
    add  $a0, $s0, $t0
    li   $t1, 13
    sub  $t1, $t1, $t0
    add  $a1, $s1, $t1
    jal  draw_pixel

    addi $t0, $t0, 1
    j    draw_x_loop

draw_x_done:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $t0, 12($sp)
    lw   $t1, 16($sp)
    addi $sp, $sp, 20
    jr   $ra

# -----------------------------------------------------------------------
# draw_o: (SAFE VERSION) Draws an 'O' in a given grid cell.
# -----------------------------------------------------------------------
draw_o:
    # --- SAVE REGISTERS ---
    # We save all registers this function modifies: $ra, $s0, $s1, $t0
    addi $sp, $sp, -16
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $t0, 12($sp)

    # Calculate top-left corner of the cell's drawing area
    li   $t0, 22
    mul  $s0, $a1, $t0  # x_start = col * 22
    mul  $s1, $a0, $t0  # y_start = row * 22
    addi $s0, $s0, 4   # Add margin
    addi $s1, $s1, 4   # Add margin

    lw   $a2, COLOR_WHITE # Use white for 'O'

    # Draw a 14x14 hollow square to represent a circle
    li   $t0, 0 # i = 0
draw_o_loop:
    beq  $t0, 14, draw_o_done

    # Top line
    add  $a0, $s0, $t0
    move $a1, $s1
    jal  draw_pixel
    # Bottom line
    add  $a0, $s0, $t0
    addi $a1, $s1, 13
    jal  draw_pixel
    # Left line
    move $a0, $s0
    add  $a1, $s1, $t0
    jal  draw_pixel
    # Right line
    addi $a0, $s0, 13
    add  $a1, $s1, $t0
    jal  draw_pixel

    addi $t0, $t0, 1
    j    draw_o_loop

draw_o_done:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $t0, 12($sp)
    addi $sp, $sp, 16
    jr   $ra

# -----------------------------------------------------------------------
# draw_cursor: Draws a cursor around the currently selected cell.
# -----------------------------------------------------------------------
draw_cursor:
    # Save registers
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp) # x_start
    sw   $s1, 8($sp) # y_start

    # Load cursor position
    lw   $t0, cursor_col
    lw   $t1, cursor_row

    # Calculate top-left corner of the cell
    li   $t2, 22
    mul  $s0, $t0, $t2  # x_start = cursor_col * 22
    mul  $s1, $t1, $t2  # y_start = cursor_row * 22

    lw   $a2, COLOR_BLUE # Use blue for the cursor

    # Draw a 21x21 hollow square for the cursor
    li   $t0, 0 # i = 0
draw_cursor_loop:
    beq  $t0, 21, draw_cursor_done

    # Top line
    add  $a0, $s0, $t0
    move $a1, $s1
    jal  draw_pixel

    # Bottom line
    add  $a0, $s0, $t0
    addi $a1, $s1, 20
    jal  draw_pixel

    # Left line
    move $a0, $s0
    add  $a1, $s1, $t0
    jal  draw_pixel

    # Right line
    addi $a0, $s0, 20
    add  $a1, $s1, $t0
    jal  draw_pixel

    addi $t0, $t0, 1
    j    draw_cursor_loop

draw_cursor_done:
    # Restore registers and return
    lw   $s1, 8($sp)
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 12
    jr   $ra

clear_screen:
    li $t0, 0           # i = 0
    li $t1, 4096        # 64 * 64 pixels
    lw $t2, DISPLAY_ADDRESS
    lw $t3, COLOR_BLACK # Background color
clear_loop:
    beq $t0, $t1, end_clear
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    addi $t0, $t0, 1
    j clear_loop
end_clear:
    jr $ra

# --- Input Handling ---

handle_input:
    # Load address of the keyboard flag
    lw $t0, KEYBOARD_FLAG
    # Load the value of the flag (0 or 1)
    lw $t1, 0($t0)
    
    # --- DEBUG PRINT ---
    # Print the current value of the flag
    li $v0, 4
    la $a0, msg_key_flag_val
    syscall
    li $v0, 1
    move $a0, $t1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    # --- END DEBUG ---

    # If flag is 0, no key has been pressed, so just return
    beq $t1, $zero, input_done

    # A key was pressed. Load the address of the key data
    lw $t0, KEYBOARD_DATA
    # Load the key's ASCII value
    lw $t2, 0($t0)
    
    # --- DEBUG PRINT ---
    # Print the ASCII value of the key that was pressed
    li $v0, 4
    la $a0, msg_key_ascii_val
    syscall
    li $v0, 1
    move $a0, $t2
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    # --- END DEBUG ---

    # --- Check which key was pressed ---
    lw $t3, KEY_X
    beq $t2, $t3, place_x

    lw $t3, KEY_O
    beq $t2, $t3, place_o

    # Using WASD for movement as their ASCII codes are standard
    lw $t3, KEY_UP
    beq $t2, $t3, move_up

    lw $t3, KEY_DOWN
    beq $t2, $t3, move_down

    lw $t3, KEY_LEFT
    beq $t2, $t3, move_left

    lw $t3, KEY_RIGHT
    beq $t2, $t3, move_right

    # If we get here, it was a different key, so we do nothing
    j input_done
# -----------------------------------------------------------------------
# place_x: (SAFE VERSION) Places a 1 in the game_board array.
# -----------------------------------------------------------------------
place_x:
    # --- SAVE REGISTERS ---
    addi $sp, $sp, -24
    sw   $ra, 0($sp)
    sw   $t0, 4($sp)
    sw   $t1, 8($sp)
    sw   $t2, 12($sp)
    sw   $t3, 16($sp)
    sw   $t4, 20($sp)
    # Note: We don't need to save $t5 as it's used right before returning.

    lw   $t0, cursor_row
    lw   $t1, cursor_col
    li   $t2, 3
    mul  $t3, $t0, $t2
    add  $t3, $t3, $t1
    sll  $t3, $t3, 2
    la   $t4, game_board
    add  $t4, $t4, $t3

    lw   $t5, 0($t4)
    bne  $t5, $zero, place_x_done

    li   $t5, 1
    sw   $t5, 0($t4)

place_x_done:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    lw   $t0, 4($sp)
    lw   $t1, 8($sp)
    lw   $t2, 12($sp)
    lw   $t3, 16($sp)
    lw   $t4, 20($sp)
    addi $sp, $sp, 24
    j    input_done

# -----------------------------------------------------------------------
# place_o: (SAFE VERSION) Places a 2 in the game_board array.
# -----------------------------------------------------------------------
place_o:
    # --- SAVE REGISTERS ---
    addi $sp, $sp, -24
    sw   $ra, 0($sp)
    sw   $t0, 4($sp)
    sw   $t1, 8($sp)
    sw   $t2, 12($sp)
    sw   $t3, 16($sp)
    sw   $t4, 20($sp)

    lw   $t0, cursor_row
    lw   $t1, cursor_col
    li   $t2, 3
    mul  $t3, $t0, $t2
    add  $t3, $t3, $t1
    sll  $t3, $t3, 2
    la   $t4, game_board
    add  $t4, $t4, $t3

    lw   $t5, 0($t4)
    bne  $t5, $zero, place_o_done

    li   $t5, 2
    sw   $t5, 0($t4)

place_o_done:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    lw   $t0, 4($sp)
    lw   $t1, 8($sp)
    lw   $t2, 12($sp)
    lw   $t3, 16($sp)
    lw   $t4, 20($sp)
    addi $sp, $sp, 24
    j    input_done

# -----------------------------------------------------------------------
# move_up: (SAFE VERSION) Decrements cursor_row.
# -----------------------------------------------------------------------
move_up:
    addi $sp, $sp, -8
    sw   $t0, 0($sp)
    sw   $t1, 4($sp)

    la   $t0, cursor_row
    lw   $t1, 0($t0)
    beq  $t1, $zero, move_up_done
    addi $t1, $t1, -1
    sw   $t1, 0($t0)

move_up_done:
    lw   $t0, 0($sp)
    lw   $t1, 4($sp)
    addi $sp, $sp, 8
    j    input_done

# -----------------------------------------------------------------------
# move_down: (SAFE VERSION) Increments cursor_row.
# -----------------------------------------------------------------------
move_down:
    addi $sp, $sp, -12
    sw   $t0, 0($sp)
    sw   $t1, 4($sp)
    sw   $t2, 8($sp)

    la   $t0, cursor_row
    lw   $t1, 0($t0)
    li   $t2, 2
    beq  $t1, $t2, move_down_done
    addi $t1, $t1, 1
    sw   $t1, 0($t0)

move_down_done:
    lw   $t0, 0($sp)
    lw   $t1, 4($sp)
    lw   $t2, 8($sp)
    addi $sp, $sp, 12
    j    input_done

# -----------------------------------------------------------------------
# move_left: (SAFE VERSION) Decrements cursor_col.
# -----------------------------------------------------------------------
move_left:
    addi $sp, $sp, -8
    sw   $t0, 0($sp)
    sw   $t1, 4($sp)

    la   $t0, cursor_col
    lw   $t1, 0($t0)
    beq  $t1, $zero, move_left_done
    addi $t1, $t1, -1
    sw   $t1, 0($t0)

move_left_done:
    lw   $t0, 0($sp)
    lw   $t1, 4($sp)
    addi $sp, $sp, 8
    j    input_done

# -----------------------------------------------------------------------
# move_right: (SAFE VERSION) Increments cursor_col.
# -----------------------------------------------------------------------
move_right:
    addi $sp, $sp, -12
    sw   $t0, 0($sp)
    sw   $t1, 4($sp)
    sw   $t2, 8($sp)

    la   $t0, cursor_col
    lw   $t1, 0($t0)
    li   $t2, 2
    beq  $t1, $t2, move_right_done
    addi $t1, $t1, 1
    sw   $t1, 0($t0)

move_right_done:
    lw   $t0, 0($sp)
    lw   $t1, 4($sp)
    lw   $t2, 8($sp)
    addi $sp, $sp, 12
    j    input_done

input_done:
    jr $ra