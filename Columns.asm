# CSC258 Project: Columns
# Student 1: Cayden Wong 1010871139
# Student 2: 


# Structure / Style assumptions
# Assume argument registers $a[0-3] are only valid at the start of a function call
#   If a function needs the argument, save it as $s[0-7]
# Assume temporaries $t[0-9] can be modified after a function call, 
#   if you want to preserve values use $s[0-7] instead
# We enforce that saved registed $s[0-7] should NOT be modifed after a function call
#   functions that modify them MUST save and load their values from the stack
# If the function does jal, MAKE SURE TO SAVE THE ra in mem at the start 
#   of the function call and load from mem at the end

.data
# -----------------------------------------------------------------------
# Memory-Mapped I/O and Constants
# -----------------------------------------------------------------------
# Display and Input Addresses
DISPLAY_ADDRESS:    .word 0x10008000 # Address specified in the bitmap tab
KEYBOARD_FLAG:      .word 0xffff0000 # Address that signals a key has been pressed
KEYBOARD_DATA:      .word 0xffff0004 # Address that holds the pressed key's value

# Colors (32-bit color: 0x00RRGGBB)
COLOUR_BLACK:       .word 0x00000000
COLOUR_WHITE:       .word 0x00FFFFFF
COLOUR_BLUE:        .word 0x000080FF
COLOUR_GREEN:       .word 0x0000C000
COLOUR_RED:         .word 0x00FF0000
COLOUR_ORANGE:      .word 0x00FF8000
COLOUR_PURPLE:      .word 0x00C000C0
COLOUR_YELLOW:      .word 0x00FFFF00

# -----------------------------------------------------------------------
# Game State
# -----------------------------------------------------------------------
# Current cursor position on the game grid (column and row)
cursor_col:         .word 0
cursor_row:         .word 0
last_cursor_col:    .word 0
last_cursor_row:    .word 0

# -----------------------------------------------------------------------
# Keyboard ASCII Values
# -----------------------------------------------------------------------
KEY_UP:    .word 0x77 # 'w'
KEY_DOWN:  .word 0x73 # 's'
KEY_LEFT:  .word 0x61 # 'a'
KEY_RIGHT: .word 0x64 # 'd'

# -----------------------------------------------------------------------
# Game Board Representation
# -----------------------------------------------------------------------
# Game board stores the state of each cell on the 6x13 grid.
# Each cell is a word (4 bytes).
# The value in each word corresponds to a color:
# 0: BLACK (empty)
# 1: BLUE
# 2: GREEN
# 3: RED
# 4: ORANGE
# 5: PURPLE
# 6: YELLOW
game_board: .space 312 # 13 rows * 6 columns * 4 bytes/cell

# -----------------------------------------------------------------------
# Debugging Messages
# -----------------------------------------------------------------------
msg_loop_counter: .asciiz "Loop counter i ($t0): "
msg_print: .asciiz "Printed($t0): "
newline: .asciiz "\n"

.text
.globl main
# =======================================================================
# Main Program Entry Point
# =======================================================================
main:
    # Initialization: These functions run once at the start.
    jal clear_screen
    jal draw_board
    # TODO:
    # - Populate first column slot
    # -- TEMPORARY DEBUG --
    li $a0 2
    li $a1 2
    li $a2 2
    jal set_board_value

# =======================================================================
# Main Game Loop
# =======================================================================
game_loop:
    # TODO:
    # - Add cycling inputs
    jal handle_input

    # TODO:
    # - Gravity logic
    # - Draw columns as 1x3 instead of 1x1
    # - Add random select
    jal update_game_logic
    
    # TODO:
    # - Update game screen
    # - Add next column display
    # - Scale up display?
    jal draw_board
    
    # 4. Delay to control game speed (game tick)
    li $v0, 32
    li $a0, 16 # sleep for 16ms (approx 60 FPS)
    syscall
    
    # 5. Repeat
    j game_loop

# =======================================================================
# Game Logic
# =======================================================================

# -----------------------------------------------------------------------
# update_game_logic: Updates the state of the game for one frame.
# This is where the core game mechanics will be implemented.
# -----------------------------------------------------------------------
update_game_logic:
    # --- SAVE REGISTERS ---
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    
    # TODO: Implement game logic here.
    # This could include:
    # - Making pieces fall
    # - Checking for matches
    # - Spawning new pieces
    
    # For now, it just draws the cursor for demonstration.
    j update_cursor
    
end_update_game_logic:
    # --- RESTORE REGISTERS ---
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    
    jr     $ra
    
# -----------------------------------------------------------------------
# set_board_value: Sets the value at a specified location on the board
# Arguments:
#   $a0 - x coordinate (0-5)
#   $a1 - y coordinate (0-12)
#   $a2 - type (0-6)
# -----------------------------------------------------------------------
set_board_value:
    # -- SAVE REGISTERS ---
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    
    # Calculate the 1D array index from the 2D grid position:
    # index = row * 6 + col
    li   $t0, 6
    mul  $t1, $t0, $a1
    add  $t1, $t1, $a0
    
    # Convert index to a byte offset: offset = index * 4
    sll  $t1, $t1, 2
    
    # Get the base address of the game board and add the offset
    la   $t2, game_board
    add  $t2, $t2, $t1
    
    # Overwrite the block at $a1 * 6 + $a0 with $a2
    sw   $a2, 0($t2)
    
end_set_board_value:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    addi $sp, $sp, 20
    
    jr $ra
    
# -----------------------------------------------------------------------
# read_board_value: Check the value at a specified location on the board
# Arguments:
#   $a0 - x coordinate (0-5)
#   $a1 - y coordinate (0-12)
# Return:
#   $v0 - type (0-6)
# -----------------------------------------------------------------------
read_board_value:
    # -- SAVE REGISTERS ---
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    # Calculate the 1D array index from the 2D grid position:
    # index = row * 6 + col
    li   $t0, 6
    mul  $t1, $t0, $a1
    add  $t1, $t1, $a0
    
    # Convert index to a byte offset: offset = index * 4
    sll  $t1, $t1, 2
    
    # Get the base address of the game board and add the offset
    la   $t2, game_board
    add  $t2, $t2, $t1
    
    # Load the block at $a1 * 6 + $a0
    lw   $v0, 0($t2)

end_read_board_value:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
# -----------------------------------------------------------------------
# update_cursor: Places a block of the current color at the cursor's
#              position on the game board. This is a placeholder for
#              spawning new pieces.
# -----------------------------------------------------------------------
update_cursor:
    # --- SAVE REGISTERS ---
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    lw   $s0, cursor_col
    lw   $s1, cursor_row
    # -- TEMPORARY CURSOR LOGIC --
    # Place a blue block (value 1) at the cursor position.
    # TODO: This should be replaced with the color of the falling piece.
    #       The bottom square of a piece should be the location of the cursor,
    #       Then, we only have to check collision at that one location
    #       This way, we only need to draw at and above the cursor for the cur piece
    lw   $a0, cursor_col
    lw   $a1, cursor_row
    li   $a2, 1
    jal set_board_value
    
    # If the cursor position just changed, 
    # then fill the prev location with void
    lw   $a0, last_cursor_col
    lw   $a1, last_cursor_row
    li   $a2, 0
    bne $s0, $a0, backfill_cursor
    bne $s1, $a1, backfill_cursor
    
    j end_update_cursor
    
backfill_cursor:
    jal set_board_value
    sw $s0, last_cursor_col
    sw $s1, last_cursor_row
    
    j end_update_cursor

end_update_cursor:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr   $ra

# =======================================================================
# Input Handling
# =======================================================================

# -----------------------------------------------------------------------
# handle_input: Checks for keyboard input and calls the appropriate
#               handler function.
# -----------------------------------------------------------------------
handle_input:
    # --- SAVE REGISTERS ---
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    # Load address of the keyboard flag
    lw $t0, KEYBOARD_FLAG
    # Load the value of the flag (1 if key pressed, 0 otherwise)
    lw $t1, 0($t0)

    # If flag is 0, no key has been pressed, so exit.
    beq $t1, $zero, input_done

    # A key was pressed. Load the key's ASCII value from the data register.
    lw $t0, KEYBOARD_DATA
    lw $s0, 0($t0)

    # --- Check which key was pressed ---
    # Compare the read ASCII value with our predefined key constants.
    # lw $t3, KEY_X
    # beq $t2, $t3, placeholder_func_for_x

    # lw $t3, KEY_O
    # beq $t2, $t3, placeholder_func_for_o

    # Check for movement keys (WASD)
    lw $t3, KEY_UP
    beq $s0, $t3, move_up

    lw $t3, KEY_DOWN
    beq $s0, $t3, move_down

    lw $t3, KEY_LEFT
    beq $s0, $t3, move_left

    lw $t3, KEY_RIGHT
    beq $s0, $t3, move_right

    # If the pressed key doesn't match any of our handlers, do nothing.
    j input_done

# -----------------------------------------------------------------------
# move_up: Decrements the cursor's row, with bounds checking.
# -----------------------------------------------------------------------
move_up:
    # --- SAVE REGISTERS ---
    addi  $sp, $sp, -4
    sw    $s0, 0($sp)

    # Load the current row and check if it's already at the top (0).
    lw    $s0, cursor_row
    beq   $s0, $zero, move_up_done # If row is 0, skip
    addi  $s0, $s0, -1              # Decrement otherwise
    
    # Check collision
    lw    $a0, cursor_col
    add   $a1, $zero, $s0
    jal   read_board_value
    bne   $v0, $zero, move_up_done
    
    sw    $s0, cursor_row

move_up_done:
    # --- RESTORE REGISTERS ---
    lw   $s0, 0($sp)
    addi $sp, $sp, 4
    j    input_done

# -----------------------------------------------------------------------
# move_down: Increments the cursor's row, with bounds checking.
# -----------------------------------------------------------------------
move_down:
    # --- SAVE REGISTERS ---
    addi  $sp, $sp, -4
    sw    $s0, 0($sp)

    # Load the current row and check if it's at the bottom (12).
    lw    $s0, cursor_row
    li    $t0, 12
    beq   $s0, $t0, move_down_done  # If row is 12 (max), skip
    addi  $s0, $s0, 1               # Increment otherwise
    
    # Check collision
    lw    $a0, cursor_col
    add   $a1, $zero, $s0
    jal   read_board_value
    bne   $v0, $zero, move_down_done
    
    # Store value
    sw    $s0, cursor_row

move_down_done:
    # --- RESTORE REGISTERS ---
    lw    $s0, 0($sp)
    addi  $sp, $sp, 4
    j     input_done

# -----------------------------------------------------------------------
# move_left: Decrements the cursor's column, with bounds checking.
# -----------------------------------------------------------------------
move_left:
    # --- SAVE REGISTERS ---
    addi  $sp, $sp, -4
    sw    $s0, 0($sp)

    # Load the current column and check if it's at the left edge (0).
    lw    $s0, cursor_col
    beq   $s0, $zero, move_left_done # If col is 0, skip
    addi  $s0, $s0, -1               # Decrement otherwise
    
    # Check if new space is occupied
    add   $a0, $zero, $s0
    lw    $a1, cursor_row
    jal   read_board_value
    bne   $v0, $zero, move_left_done
    
    sw    $s0, cursor_col

move_left_done:
    # --- RESTORE REGISTERS ---
    lw    $s0, 0($sp)
    addi  $sp, $sp, 4
    j     input_done

# -----------------------------------------------------------------------
# move_right: Increments the cursor's column, with bounds checking.
# -----------------------------------------------------------------------
move_right:
    # --- SAVE REGISTERS ---
    addi  $sp, $sp, -4
    sw    $s0, 0($sp)

    # Load the current column and check if it's at the right edge (5).
    lw    $s0, cursor_col
    li    $t0, 5
    beq   $s0, $t0, move_right_done   # If col is 5, skip
    addi  $s0, $s0, 1                 # Increment otherwise
    
    # Check if new space is occupied
    add   $a0, $zero, $s0
    lw    $a1, cursor_row
    jal   read_board_value
    bne   $v0, $zero, move_right_done
    
    # Update cursor col
    sw    $s0, cursor_col

move_right_done:
    # --- RESTORE REGISTERS ---
    lw    $s0, 0($sp)
    addi  $sp, $sp, 4
    j     input_done

# -----------------------------------------------------------------------
# input_done: Common return point for all input handlers.
# -----------------------------------------------------------------------
input_done:
    # --- RESTORE REGISTERS ---
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8

    jr $ra


# =======================================================================
# Drawing Functions
# =======================================================================

# -----------------------------------------------------------------------
# clear_screen: Fills the entire 64x64 display with black pixels.
# -----------------------------------------------------------------------
clear_screen:
    li    $t0, 0                # i = 0 (pixel counter)
    li    $t1, 4096             # Total number of pixels (64 * 64)
    lw    $t2, DISPLAY_ADDRESS  # Base address of the display memory
    lw    $t3, COLOUR_BLACK     # Color to fill the screen with
clear_loop:
    beq   $t0, $t1, end_clear   # Loop 4096 times
    sw    $t3, 0($t2)           # Write the color to the current pixel address
    addi  $t2, $t2, 4           # Move to the next pixel's address
    addi  $t0, $t0, 1           # Increment counter
    j clear_loop
end_clear:
    jr $ra
    
# -----------------------------------------------------------------------
# draw_pixel: Draws a single pixel on the screen.
# Arguments:
#   $a0 - x coordinate (0-63)
#   $a1 - y coordinate (0-63)
#   $a2 - color (32-bit value)
# -----------------------------------------------------------------------
draw_pixel:
    # --- SAVE REGISTERS ---
    # Save any temporary registers we are about to modify ($t0, $t1, $t2)
    # as well as the return address ($ra).
    addi  $sp, $sp, -16
    sw    $ra, 0($sp)

    # --- FUNCTION BODY ---
    lw    $t0, DISPLAY_ADDRESS  # $t0 = base display address
    # Calculate pixel offset in display memory:
    # address = base + (y * 64 + x) * 4
    sll   $t1, $a1, 6           # $t1 = y * 64
    add   $t1, $t1, $a0         # $t1 = y * 64 + x
    sll   $t1, $t1, 2           # $t1 = (y * 64 + x) * 4 (byte offset)
    add   $t2, $t0, $t1         # $t2 = final address
    sw    $a2, 0($t2)           # Draw the pixel by writing the color

    # --- RESTORE REGISTERS ---
    lw    $ra, 0($sp)
    addi  $sp, $sp, 16

    jr    $ra

# -----------------------------------------------------------------------
# Color Setter Functions
# Description: These are helper functions to load a specific color into
#              the drawing color register ($a2). This simplifies changing
#              colors before calling a drawing function.
# Postcondition: Only $a2 is modified
# -----------------------------------------------------------------------
set_draw_colour_black:
    lw  $a2, COLOUR_BLACK
    jr  $ra
set_draw_colour_blue:
    lw  $a2, COLOUR_BLUE
    jr  $ra
set_draw_colour_green:
    lw  $a2, COLOUR_GREEN
    jr  $ra
set_draw_colour_red:
    lw  $a2, COLOUR_RED
    jr  $ra
set_draw_colour_orange:
    lw  $a2, COLOUR_ORANGE
    jr  $ra
set_draw_colour_purple:
    lw  $a2, COLOUR_PURPLE
    jr  $ra
set_draw_colour_yellow:
    lw  $a2, COLOUR_YELLOW
    jr  $ra

# -----------------------------------------------------------------------
# draw_board: Iterates through the game_board array and draws a pixel
#             for each cell with the corresponding color.
# -----------------------------------------------------------------------
draw_board:
    # --- SAVE REGISTERS ---
    addi  $sp, $sp, -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)           # i (loop counter)

    # TODO: Add the rest of the board interface
    # Offset board from edge and add section for next piece

    li    $s0, 0                # i = 0 (cell index)

draw_board_loop:
    # Loop 78 times (13 rows * 6 cols)
    beq   $s0, 78, draw_board_done

    # Load the value from game_board[i]
    la    $t0, game_board       # Load base address of the board
    sll   $t1, $s0, 2           # offset = i * 4
    add   $t1, $t0, $t1         # address = &game_board[i]
    lw    $t0, 0($t1)           # $a2 = game_board[i] (the color value)

    # Calculate 2D grid coordinates (row, col) from 1D index (i)
    li    $t1, 6
    divu  $s0, $t1
    mflo  $a1                   # $s2 (row) = i / 6 (quotient)
    mfhi  $a0                   # $s3 (col) = i % 6 (remainder)
    
    # At this point the arguments $a0 and $a1 for draw pixel are set
    # Set the correct draw color based on $t0 = game_board[i]
    jal   set_draw_colour_black
    beq   $t0, 0, draw_board_pixel
    jal   set_draw_colour_blue
    beq   $t0, 1, draw_board_pixel
    jal   set_draw_colour_green
    beq   $t0, 2, draw_board_pixel
    jal   set_draw_colour_red
    beq   $t0, 3, draw_board_pixel
    jal   set_draw_colour_orange
    beq   $t0, 4, draw_board_pixel
    jal   set_draw_colour_purple
    beq   $t0, 5, draw_board_pixel
    jal   set_draw_colour_yellow
    beq   $t0, 6, draw_board_pixel
    
    # this should be unreachable
    # maybe use for special logic for
    # different pixel types?
    
draw_board_pixel:
    # TODO:
    # - here would be the logic to scale pixels,
    #       for now we draw 1x1 -> 1x1 mapping
    jal   draw_pixel
    
    j    continue_board_loop
    
continue_board_loop:
    addi  $s0, $s0, 1           # Increment draw iteration
    j    draw_board_loop

draw_board_done:
    # --- RESTORE REGISTERS ---
    lw    $ra, 0($sp)
    lw    $s0, 4($sp)
    addi  $sp, $sp, 8
    jr    $ra