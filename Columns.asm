# CSC258 Project: Columns
# Student 1: Cayden Wong 1010871139
# Student 2: William Wu 1008956685


# Structure / Style assumptions
# Assume argument registers $a[0-3] are only valid at the start of a function call
#   If a function needs the argument, save it as $s[0-7]
# Assume temporaries $t[0-9] can be modified after a function call, 
#   if you want to preserve values use $s[0-7] instead
# We enforce that saved registers $s[0-7] should NOT be modifed after a function call
#   functions that modify them MUST save and load their values from the stack
# If the function does jal, MAKE SURE TO SAVE THE ra in mem at the start 
#   of the function call and load from mem at the end



.data
# -----------------------------------------------------------------------
# Memory-Mapped I/O and Constants
# -----------------------------------------------------------------------
# Debug string
# Display and Input Addresses
DISPLAY_ADDRESS:    .word 0x10008000 # Address specified in the bitmap tab
KEYBOARD_FLAG:      .word 0xffff0000 # Address that signals a key has been pressed
KEYBOARD_DATA:      .word 0xffff0004 # Address that holds the pressed key's value

# ==============================================================================
# COLOR PALETTE (32-bit color: 0x00RRGGBB)
# ==============================================================================

# --- Original Colors (Do Not Modify) ---
COLOUR_PALETTE:
    COLOUR_BLACK:       .word 0x00000000
    COLOUR_BLUE:        .word 0x000080FF
    COLOUR_GREEN:       .word 0x0000C000
    COLOUR_RED:         .word 0x00FF0000
    COLOUR_ORANGE:      .word 0x00FF8000
    COLOUR_PURPLE:      .word 0x00C000C0
    COLOUR_YELLOW:      .word 0x00FFFF00
    COLOUR_WHITE:       .word 0x00FFFFFF
    
    # --- Greyscale & Off-Whites ---
    COLOUR_GREY_10:     .word 0x001A1A1A  # Very Dark
    COLOUR_GREY_25:     .word 0x00404040
    COLOUR_GREY_50:     .word 0x00808080  # Mid Grey
    COLOUR_GREY_75:     .word 0x00C0C0C0  # Silver
    COLOUR_SNOW:        .word 0x00FFFAFA
    COLOUR_IVORY:       .word 0x00FFFFF0
    COLOUR_BEIGE:       .word 0x00F5F5DC
    
    # --- Reds & Pinks ---
    COLOUR_MAROON:      .word 0x00800000
    COLOUR_DARK_RED:    .word 0x008B0000
    COLOUR_CRIMSON:     .word 0x00DC143C
    COLOUR_TOMATO:      .word 0x00FF6347
    COLOUR_SALMON:      .word 0x00FA8072
    COLOUR_HOT_PINK:    .word 0x00FF69B4
    COLOUR_DEEP_PINK:   .word 0x00FF1493
    COLOUR_LIGHT_PINK:  .word 0x00FFB6C1
    
    # --- Oranges & Browns ---
    COLOUR_CORAL:       .word 0x00FF7F50
    COLOUR_DARK_ORANGE: .word 0x00FF8C00
    COLOUR_GOLD:        .word 0x00FFD700
    COLOUR_CHOCOLATE:   .word 0x00D2691E
    COLOUR_SADDLE_BROWN:.word 0x008B4513
    COLOUR_SIENNA:      .word 0x00A0522D
    COLOUR_SANDY_BROWN: .word 0x00F4A460
    COLOUR_TAN:         .word 0x00D2B48C
    
    # --- Yellows ---
    COLOUR_KHAKI:       .word 0x00F0E68C
    COLOUR_PALE_GOLD:   .word 0x00EEE8AA
    COLOUR_MOCCASIN:    .word 0x00FFE4B5
    
    # --- Greens ---
    COLOUR_LIME:        .word 0x0000FF00  # Pure Green
    COLOUR_LIME_GREEN:  .word 0x0032CD32
    COLOUR_PALE_GREEN:  .word 0x0098FB98
    COLOUR_SEA_GREEN:   .word 0x002E8B57
    COLOUR_FOREST_GREEN:.word 0x00228B22
    COLOUR_DARK_GREEN:  .word 0x00006400
    COLOUR_OLIVE:       .word 0x00808000
    COLOUR_OLIVE_DRAB:  .word 0x006B8E23
    
    # --- Cyans & Teals ---
    COLOUR_CYAN:        .word 0x0000FFFF
    COLOUR_AQUAMARINE:  .word 0x007FFFD4
    COLOUR_TURQUOISE:   .word 0x0040E0D0
    COLOUR_TEAL:        .word 0x00008080
    COLOUR_LIGHT_CYAN:  .word 0x00E0FFFF
    
    # --- Blues ---
    COLOUR_POWDER_BLUE: .word 0x00B0E0E6
    COLOUR_SKY_BLUE:    .word 0x0087CEEB
    COLOUR_STEEL_BLUE:  .word 0x004682B4
    COLOUR_ROYAL_BLUE:  .word 0x004169E1
    COLOUR_PURE_BLUE:   .word 0x000000FF
    COLOUR_NAVY:        .word 0x00000080
    COLOUR_MIDNIGHT:    .word 0x00191970
    
    # --- Purples & Violets ---
    COLOUR_LAVENDER:    .word 0x00E6E6FA
    COLOUR_PLUM:        .word 0x00DDA0DD
    COLOUR_VIOLET:      .word 0x00EE82EE
    COLOUR_MAGENTA:     .word 0x00FF00FF
    COLOUR_DARK_ORCHID: .word 0x009932CC
    COLOUR_INDIGO:      .word 0x004B0082
    COLOUR_SLATE_BLUE:  .word 0x006A5ACD

# -----------------------------------------------------------------------
# Gravity Variables
# -----------------------------------------------------------------------
gravity_timer:      .word 0     # Increments every frame
gravity_threshold:  .word 60    # Drop every x frames (Adjust this to change speed, 60 is approx 1 sec, 30 is 2x speed...)

# -----------------------------------------------------------------------
# Game State
# -----------------------------------------------------------------------
# Current cursor position on the game grid (column and row)
cursor_col:         .word 0
cursor_row:         .word 0
last_cursor_col:    .word 0
last_cursor_row:    .word 0

piece_placed_flag:  .word 0 
found_match_flag:   .word 0

# -----------------------------------------------------------------------
# Keyboard ASCII Values
# -----------------------------------------------------------------------
KEY_UP:    .word 0x77 # 'w'
KEY_DOWN:  .word 0x73 # 's'
KEY_LEFT:  .word 0x61 # 'a'
KEY_RIGHT: .word 0x64 # 'd'

KEY_Z: .word 0x7A # 'z' change order
KEY_Q: .word 0x71 # 'q' quit(game over) now you need to press q twice to exit execution. 1st time to game over screen (can restart), 2nd time exit execution
KEY_R: .word 0x72 # 'r' restart

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
game_board:         .space 312 # 13 rows * 6 columns * 4 bytes/cell
removal_game_board: .space 312 # 13 rows * 6 columns * 4 bytes/cell

curr_column_colours: .space 12 # 3 columns * 4 bytes/cell
next_column_colours: .space 12 # 3 columns * 4 bytes/cell
# -----------------------------------------------------------------------
# Debugging Messages
# -----------------------------------------------------------------------
msg_loop_counter: .asciiz "Loop counter i ($t0): "
msg_print: .asciiz "Printed($t0): "
newline: .asciiz "\n"

.text
.globl main

# li $v0, 1           # syscall 1 = print integer
# li $a0, 42          # value to print
# syscall

# =======================================================================
# Main Program Entry Point
# =======================================================================
main:

# 1. Initialize Screen
    jal clear_screen
    
    # --- FEATURE 3: DIFFICULTY SELECTION START ---
    
    # 2. Draw Start Menu Text (Manual pixel drawing or helper text)
    # We will just draw colorful "E M H" letters for Easy/Med/Hard
    
    # Draw 'E' (Easy) in Green at (10, 25)
    li $a0, 10
    li $a1, 25
    li $a2, 4      # 'E'
    li $a3, 2      # Green Color ID
    jal draw_char
    
    # Draw 'M' (Medium) in Yellow at (20, 25)
    li $a0, 20
    li $a1, 25
    li $a2, 9      # 'M'
    li $a3, 6      # Yellow Color ID
    jal draw_char
    
    # Draw 'H' (Hard) in Red at (30, 25)
    li $a0, 30
    li $a1, 25
    li $a2, 11     # 'X' (used as H/Hard symbol or just generic) 
    li $a3, 3      # Red Color ID
    jal draw_char

menu_input_loop:
    # Check Keyboard
    lw $t0, KEYBOARD_FLAG
    lw $t1, 0($t0)
    beq $t1, $zero, menu_wait
    
    lw $t0, KEYBOARD_DATA
    lw $s0, 0($t0)
    
    # Check Inputs (Use Numbers 1, 2, 3)
    beq $s0, 0x31, set_easy   # '1'
    beq $s0, 0x32, set_med    # '2'
    beq $s0, 0x33, set_hard   # '3'
    
    j menu_wait

set_easy:
    li $t0, 60                 # Slow (1.0s)
    sw $t0, gravity_threshold
    j start_game_sequence

set_med:
    li $t0, 30                 # Med (0.5s)
    sw $t0, gravity_threshold
    j start_game_sequence

set_hard:
    li $t0, 10                 # Fast (0.16s)
    sw $t0, gravity_threshold
    j start_game_sequence

menu_wait:
    li $v0, 32
    li $a0, 50
    syscall
    j menu_input_loop
    
    # --- FEATURE 3 END ---

start_game_sequence:
    # Initialization: These functions run once at the start.
    jal clear_screen
    jal draw_background
    jal draw_board
    # TODO:
    # - Populate first column slot
        
    # li $a0, 5
    # li $a1, 12
    # li $a2, 1
    # jal set_board_value
    
    # li $a0, 5
    # li $a1, 11
    # li $a2, 2
    # jal set_board_value
    
    # li $a0, 4
    # li $a1, 12
    # li $a2, 1
    # jal set_board_value
    
    # li $a0, 4
    # li $a1, 11
    # li $a2, 2
    # jal set_board_value
    
    # li $a0, 5
    # li $a1, 10
    # li $a2, 1
    # jal set_board_value
    
    # li $a0, 5
    # li $a1, 9
    # li $a2, 1
    # jal set_board_value
    
    li $a0, 4
    li $a1, 12
    li $a2, 1
    jal set_board_value
    
    li $a0, 5
    li $a1, 12
    li $a2, 1
    jal set_board_value

    sw $zero, piece_placed_flag
    
    jal generate_next_column
    jal generate_next_column

# =======================================================================
# Main Game Loop
# =======================================================================
game_loop:
    # TODO:
    # - Add cycling inputs
    jal handle_input

    # TODO:
    # - Gravity logic
    jal apply_gravity
    
    jal update_game_logic
    
    # TODO:
    # - Update game screen
    # - Add next column display
    # - Scale up display?
    jal draw_board
    jal draw_score
    
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
    jal check_for_matching
    jal remove_marked_squares
    jal remove_empty_gaps
    
game_logic_skip_clear:
    # If we are still placing piece, skip cursor drawing
    lw $t0, piece_placed_flag
    bne $t0, $zero, end_update_game_logic
    jal update_cursor

    
end_update_game_logic:
    # --- RESTORE REGISTERS ---
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    
    jr     $ra

# -----------------------------------------------------------------------
# apply_gravity: Checks timer and forces piece down if needed
# -----------------------------------------------------------------------
apply_gravity:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)

    # 1. Update Timer
    lw   $t0, gravity_timer
    addi $t0, $t0, 1        # Increment timer
    sw   $t0, gravity_timer # Save it back

    # 2. Check if we reached the threshold
    lw   $t1, gravity_threshold
    blt  $t0, $t1, apply_gravity_done # If timer < threshold, exit

    # 3. Trigger Gravity! Reset timer first.
    sw   $zero, gravity_timer

    # 4. Attempt to Move Down
    # (Logic mirrors move_down but safely uses stack and returns via jr $ra)
    
    # Load current row
    lw    $s0, cursor_row
    
    # Check if we are at the bottom (Row 12)
    li    $t0, 12
    beq   $s0, $t0, gravity_collision  # Collision with floor
    
    # Calculate potential new row (current + 1)
    addi  $s0, $s0, 1
    
    # Check collision with existing blocks at (cursor_col, new_row)
    lw    $a0, cursor_col
    move  $a1, $s0      # The new row
    jal   read_board_value
    
    # If read_board_value returns non-zero ($v0 != 0), we hit a block
    bne   $v0, $zero, gravity_collision
    
    # 5. Move is valid: Update cursor position
    sw    $s0, cursor_row
    j     apply_gravity_done

gravity_collision:
    # We hit somethingm Lock the piece.
    
    # 1. Generate the next column immediately
    jal generate_next_column
    
    # 2. Reset cursor to top (hidden position)
    li $t0, -1
    sw $t0, cursor_row
    sw $t0, last_cursor_row
    li $t0, 3
    sw $t0, cursor_col
    sw $t0, last_cursor_col
    
    # 3. Set the flag so update_game_logic will check for matches
    li $t0, 1
    sw $t0, piece_placed_flag
    

apply_gravity_done:
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra
    
# -----------------------------------------------------------------------
# set_removal_board_value: Sets the value at a specified location on the board
# Arguments:
#   $a0 - x coordinate (0-5)
#   $a1 - y coordinate (0-12)
#   $a2 - T/F (1/0)
# -----------------------------------------------------------------------
set_removal_board_value:
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
    la   $t2, removal_game_board
    add  $t2, $t2, $t1
    
    # Overwrite the block at $a1 * 6 + $a0 with $a2
    sw   $a2, 0($t2)
    
    
end_set_removal_board_value:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
# -----------------------------------------------------------------------
# set_board_value: Sets the value at a specified location on the board
# Arguments:
#   $a0 - x coordinate (0-5)
#   $a1 - y coordinate (0-12)
#   $a2 - type (0-6)
# -----------------------------------------------------------------------
set_board_value:
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
    
    # Overwrite the block at $a1 * 6 + $a0 with $a2
    sw   $a2, 0($t2)
    
    
end_set_board_value:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    
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
#              position on the game board. 
# -----------------------------------------------------------------------
update_cursor:
    # --- SAVE REGISTERS ---
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    lw   $s0, cursor_col
    lw   $s1, cursor_row

backfill_cursor: 
    lw   $a0, last_cursor_col
    lw   $a1, last_cursor_row
    li   $a2, 0
    jal set_board_value
    
    lw   $a0, last_cursor_col
    lw   $a1, last_cursor_row
    li   $a2, 0
    # check if a1 is 0: a1 cannot go to negative
    beq  $a1, 0, draw_new_cursor 
    addi $a1, $a1, -1
    jal set_board_value
    
    lw   $a0, last_cursor_col
    lw   $a1, last_cursor_row
    li   $a2, 0
    # check if a1 is 0: a1 cannot go to negative
    beq  $a1, 1, draw_new_cursor 
    addi $a1, $a1, -2
    jal set_board_value
    
    
draw_new_cursor:
    la $t0, curr_column_colours
    
    lw   $a0, cursor_col
    lw   $a1, cursor_row
    lw   $a2, 0($t0)
    jal set_board_value
    
    la $t0, curr_column_colours

    lw   $a0, cursor_col
    lw   $a1, cursor_row
    lw   $a2, 4($t0)
    # check if a1 is 0: a1 cannot go to negative
    beq  $a1, 0, done_drawing_cursor 
    addi $a1, $a1, -1
    jal set_board_value
    
    la $t0, curr_column_colours
    
    lw   $a0, cursor_col
    lw   $a1, cursor_row
    lw   $a2, 8($t0)
    # check if a1 is 0: a1 cannot go to negative
    beq  $a1, 1, done_drawing_cursor 
    addi $a1, $a1, -2
    jal set_board_value
    
done_drawing_cursor:
    # Save new position of last_cursor row and col
    sw $s0, last_cursor_col
    sw $s1, last_cursor_row
    
    j end_update_cursor

end_update_cursor:
    # --- RESTORE REGISTERS ---
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr   $ra

generate_next_column:
    #TODO: Move random function to its own function
    addi  $sp, $sp, -4
    sw    $ra, 0($sp)
    
    la    $t0, curr_column_colours       # Load current column 
    la    $t1, next_column_colours       # Load next column
    
    #shift next column into current column
    lw   $t2, 0($t1)
    sw   $t2, 0($t0)
    
    lw   $t2, 4($t1)
    sw   $t2, 4($t0)
    
    lw   $t2, 8($t1)
    sw   $t2, 8($t0)
    
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    #return val in a0
    addi $a0, $a0, 1
    
    sw $a0, 0($t1)
    
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    #return val in a0
    addi $a0, $a0, 1
    
    sw $a0, 4($t1)
    
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    #return val in a0
    addi $a0, $a0, 1
    
    sw $a0, 8($t1)

    lw $ra 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
shift_current_column:
    addi  $sp, $sp, -4
    sw    $ra, 0($sp)
    
    la $t0, curr_column_colours
    lw $t1, 0($t0)
    lw $t2, 4($t0)
    lw $t3, 8($t0)
    
    sw $t1, 8($t0)
    sw $t2, 0($t0)
    sw $t3, 4($t0)
    
    lw $ra 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
# -----------------------------------------------------------------------
# check_for_matching: Mark board matches for removal
# -----------------------------------------------------------------------
check_for_matching:
    addi  $sp, $sp, -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # loop var
    
    # If the flag is zero, then we didnt place a piece
    lw $t0, piece_placed_flag
    beq $zero, $t0, end_check_for_matching
    
# ==========================================================
# FEATURE 2: GRADUAL SPEED INCREASE
# ==========================================================
    # Logic: If we just placed a piece, make the game slightly faster
    # by decreasing the gravity_threshold.
    
    la   $t5, gravity_threshold    # Get address of threshold
    lw   $t6, 0($t5)               # Load current speed value
    
    # Safety Check: Don't let it go below 10 frames 
    # If we go too low, the game becomes unplayable or glitches.
    li   $t7, 10
    ble  $t6, $t7, skip_speed_increase
    
    # Decrease threshold by 5 ^^^CHANGE SPEED HERE
    subi $t6, $t6, 5
    
    # Save the new speed back to memory
    sw   $t6, 0($t5)

skip_speed_increase:
    
    # We check all columns and all rows
    jal check_rows_for_matching
    jal check_cols_for_matching
    jal check_diag_left_ups_for_matching
    jal check_diag_left_downs_for_matching
    jal check_diag_right_bots_for_matching
    jal check_diag_right_tops_for_matching
    
    j end_check_for_matching

end_check_for_matching:
    # --- RESTORE REGISTERS ---
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# -----------------------------------------------------------------------
# check_rows_for_matching: Check rows
# -----------------------------------------------------------------------
check_rows_for_matching:
    addi  $sp, $sp, -20
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # cur row
    sw    $s1, 8($sp) # cur pos
    sw    $s2, 12($sp) # seq count
    sw    $s3, 16($sp) # cur color
    
    li $s0, 0
check_row_for_matching:
    li $s2, 0
    li $s1, 0 # pos in row
check_row_square_for_match:
    # Arguments:
    #   $a0 - x coordinate (0-5)
    #   $a1 - y coordinate (0-12)
    # Return:
    #   $v0 - type (0-6)
    add     $a0, $zero, $s1
    add   $a1, $zero, $s0
    jal   read_board_value
    
    # Skip if colours are the same, otherwise reset
    beq $v0, $s3, check_row_square_for_match_skip_color
    li $s2, 0
    add $s3, $zero, $v0
    
check_row_square_for_match_skip_color:
    # cap incremeent at 3
    li $t0, 3
    beq $s2, $t0, check_row_square_for_match_skip_increment
    addi $s2, $s2, 1
    
check_row_square_for_match_skip_increment:
    # if not 3 stored skip backfill
    li $t0, 3
    bne $s2, $t0, check_row_square_for_match_skip_fill
    # skip if colour is black
    beq $s3, $zero, check_row_square_for_match_skip_fill
    
    # Fill the past 3 squares with 0
    addi $a0, $s1, 0
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -1
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -2
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    
check_row_square_for_match_skip_fill:
    # incremenet x, != 6 go back
    addi $s1, $s1, 1
    li $t8, 6
    bne $s1, $t8, check_row_square_for_match

    # increment row
    addi $s0, $s0, 1
    li $t9, 13
    bne $s0, $t9, check_row_for_matching
    
    j end_check_rows_for_matching
    
end_check_rows_for_matching:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra
    

# -----------------------------------------------------------------------
# check_rows_for_matching: Check rows
# -----------------------------------------------------------------------
check_cols_for_matching:
    addi  $sp, $sp, -20
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # cur row
    sw    $s1, 8($sp) # cur col
    sw    $s2, 12($sp) # seq count
    sw    $s3, 16($sp) # cur color
    
    li $s1, 0
check_col_for_matching:
    li $s2, 0
    li $s0, 0 # pos in col
check_col_square_for_match:
    # Arguments:
    #   $a0 - x coordinate (0-5)
    #   $a1 - y coordinate (0-12)
    # Return:
    #   $v0 - type (0-6)
    add   $a0, $zero, $s1
    add   $a1, $zero, $s0
    jal   read_board_value
    
    # Skip if colours are the same, otherwise reset
    beq $v0, $s3, check_col_square_for_match_skip_color
    li $s2, 0
    add $s3, $zero, $v0
    
check_col_square_for_match_skip_color:
    # cap incremeent at 3
    li $t0, 3
    beq $s2, $t0, check_col_square_for_match_skip_increment
    addi $s2, $s2, 1
    
check_col_square_for_match_skip_increment:
    # if not 3 stored skip backfill
    li $t0, 3
    bne $s2, $t0, check_col_square_for_match_skip_fill
    # skip if colour is black
    beq $s3, $zero, check_col_square_for_match_skip_fill
    
    # Fill the past 3 squares with 0
    addi $a0, $s1, 0
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, 0
    addi $a1, $s0, -1
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, 0
    addi $a1, $s0, -2
    li $a2, 1
    jal set_removal_board_value
    
check_col_square_for_match_skip_fill:
    # incremenet x, != 6 go back
    addi $s0, $s0, 1
    li $t8, 13
    bne $s0, $t8, check_col_square_for_match

    # increment col
    addi $s1, $s1, 1
    li $t9, 6
    bne $s1, $t9, check_col_for_matching
    
    j end_check_cols_for_matching
    
end_check_cols_for_matching:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# -----------------------------------------------------------------------
# check_diag_left_ups_for_matching: Check diag in / on left wall
# -----------------------------------------------------------------------
check_diag_left_ups_for_matching:
    addi  $sp, $sp, -24
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # cur row
    sw    $s1, 8($sp) # cur pos
    sw    $s2, 12($sp) # seq count
    sw    $s3, 16($sp) # cur color
    sw    $s4, 20($sp) # start row
    
    li $s4, 0
check_diag_left_up_for_matching:
    li $s2, 0
    li $s1, 0 # pos in row
    add $s0, $zero, $s4
check_diag_left_up_square_for_match:
    # Arguments:
    #   $a0 - x coordinate (0-5)
    #   $a1 - y coordinate (0-12)
    # Return:
    #   $v0 - type (0-6)
    add   $a0, $zero, $s1
    add   $a1, $zero, $s0
    jal   read_board_value
    
    # Skip if colours are the same, otherwise reset
    beq $v0, $s3, check_diag_left_up_square_for_match_skip_color
    li $s2, 0
    add $s3, $zero, $v0
    
check_diag_left_up_square_for_match_skip_color:
    # cap increment at 3
    li $t0, 3
    beq $s2, $t0, check_diag_left_up_square_for_match_skip_increment
    addi $s2, $s2, 1
    
check_diag_left_up_square_for_match_skip_increment:
    # if not 3 stored skip backfill
    li $t0, 3
    bne $s2, $t0, check_diag_left_up_square_for_match_skip_fill
    # skip if colour is black
    beq $s3, $zero, check_diag_left_up_square_for_match_skip_fill
    
    # Fill the past 3 squares with 0
    addi $a0, $s1, 0
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -1
    addi $a1, $s0, 1
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -2
    addi $a1, $s0, 2
    li $a2, 1
    jal set_removal_board_value
    
check_diag_left_up_square_for_match_skip_fill:
    # increment x, != 6 go back
    addi $s1, $s1, 1
    addi $s0, $s0, -1
    li $t8, -1
    beq $s0, $t8, check_diag_left_up_skip_to_next
    li $t8, 6
    bne $s1, $t8, check_diag_left_up_square_for_match
check_diag_left_up_skip_to_next:
    # increment row
    addi $s4, $s4, 1
    li $t9, 13
    bne $s4, $t9, check_diag_left_up_for_matching
    
    j end_check_diag_left_up_for_matching
    
end_check_diag_left_up_for_matching:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra
    
# -----------------------------------------------------------------------
# check_diag_right_bots_for_matching: Check diag in \ on floor
# -----------------------------------------------------------------------
check_diag_right_bots_for_matching:
    addi  $sp, $sp, -24
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # cur row
    sw    $s1, 8($sp) # cur pos
    sw    $s2, 12($sp) # seq count
    sw    $s3, 16($sp) # cur color
    sw    $s4, 20($sp) # start row
    
    li $s4, 0
check_diag_right_bot_for_matching:
    li $s2, 0
    add $s1, $zero, $s4 # pos in row
    li $s0, 12
check_diag_right_bot_square_for_match:
    # Arguments:
    #   $a0 - x coordinate (0-5)
    #   $a1 - y coordinate (0-12)
    # Return:
    #   $v0 - type (0-6)
    add   $a0, $zero, $s1
    add   $a1, $zero, $s0
    jal   read_board_value
    
    # Skip if colours are the same, otherwise reset
    beq $v0, $s3, check_diag_right_bot_square_for_match_skip_color
    li $s2, 0
    add $s3, $zero, $v0
    
check_diag_right_bot_square_for_match_skip_color:
    # cap increment at 3
    li $t0, 3
    beq $s2, $t0, check_diag_right_bot_square_for_match_skip_increment
    addi $s2, $s2, 1
    
check_diag_right_bot_square_for_match_skip_increment:
    # if not 3 stored skip backfill
    li $t0, 3
    bne $s2, $t0, check_diag_right_bot_square_for_match_skip_fill
    # skip if colour is black
    beq $s3, $zero, check_diag_right_bot_square_for_match_skip_fill
    
    # Fill the past 3 squares with 0
    addi $a0, $s1, 0
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -1
    addi $a1, $s0, 1
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -2
    addi $a1, $s0, 2
    li $a2, 1
    jal set_removal_board_value
    
check_diag_right_bot_square_for_match_skip_fill:
    # incremenet x, != 6 go back
    addi $s1, $s1, 1
    addi $s0, $s0, -1
    li $t8, -1
    beq $s0, $t8, check_diag_right_bot_skip_to_next
    li $t8, 6
    bne $s1, $t8, check_diag_right_bot_square_for_match
check_diag_right_bot_skip_to_next:
    # increment row
    addi $s4, $s4, 1
    li $t9, 13
    bne $s4, $t9, check_diag_right_bot_for_matching
    
    j end_check_diag_right_bot_for_matching
    
end_check_diag_right_bot_for_matching:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra
    
# -----------------------------------------------------------------------
# check_diag_left_downs_for_matching: Check diag in \ on left wall
# -----------------------------------------------------------------------
check_diag_left_downs_for_matching:
    addi  $sp, $sp, -24
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # cur row
    sw    $s1, 8($sp) # cur pos
    sw    $s2, 12($sp) # seq count
    sw    $s3, 16($sp) # cur color
    sw    $s4, 20($sp) # start row
    
    li $s4, 0
check_diag_left_down_for_matching:
    li $s2, 0
    li $s1, 0 # pos in row
    add $s0, $zero, $s4
check_diag_left_down_square_for_match:
    # Arguments:
    #   $a0 - x coordinate (0-5)
    #   $a1 - y coordinate (0-12)
    # Return:
    #   $v0 - type (0-6)
    add   $a0, $zero, $s1
    add   $a1, $zero, $s0
    jal   read_board_value
    
    # Skip if colours are the same, otherwise reset
    beq $v0, $s3, check_diag_left_down_square_for_match_skip_color
    li $s2, 0
    add $s3, $zero, $v0
    
check_diag_left_down_square_for_match_skip_color:
    # cap increment at 3
    li $t0, 3
    beq $s2, $t0, check_diag_left_down_square_for_match_skip_increment
    addi $s2, $s2, 1
    
check_diag_left_down_square_for_match_skip_increment:
    # if not 3 stored skip backfill
    li $t0, 3
    bne $s2, $t0, check_diag_left_down_square_for_match_skip_fill
    # skip if colour is black
    beq $s3, $zero, check_diag_left_down_square_for_match_skip_fill
    
    # Fill the past 3 squares with 0
    addi $a0, $s1, 0
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -1
    addi $a1, $s0, -1
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -2
    addi $a1, $s0, -2
    li $a2, 1
    jal set_removal_board_value
    
check_diag_left_down_square_for_match_skip_fill:
    # y++ != 13 and x++ != 6 go back 
    addi $s1, $s1, 1 # change x
    addi $s0, $s0, 1 # change y
    li $t8, 13
    beq $s0, $t8, check_diag_left_down_skip_to_next
    li $t8, 6
    bne $s1, $t8, check_diag_left_down_square_for_match
check_diag_left_down_skip_to_next:
    # increment row
    addi $s4, $s4, 1
    li $t9, 13
    bne $s4, $t9, check_diag_left_down_for_matching
    
    j end_check_diag_left_down_for_matching
    
end_check_diag_left_down_for_matching:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra
    
# -----------------------------------------------------------------------
# check_diag_right_tops_for_matching: Check diag in / on ceil
# -----------------------------------------------------------------------
check_diag_right_tops_for_matching:
    addi  $sp, $sp, -24
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # cur row
    sw    $s1, 8($sp) # cur pos
    sw    $s2, 12($sp) # seq count
    sw    $s3, 16($sp) # cur color
    sw    $s4, 20($sp) # start row
    
    li $s4, 0 # x pos
check_diag_right_top_for_matching:
    li $s2, 0
    add $s1, $zero, $s4 # cur x
    li $s0, 0 # cur y
check_diag_right_top_square_for_match:
    # Arguments:
    #   $a0 - x coordinate (0-5)
    #   $a1 - y coordinate (0-12)
    # Return:
    #   $v0 - type (0-6)
    add   $a0, $zero, $s1
    add   $a1, $zero, $s0
    jal   read_board_value
    
    # Skip if colours are the same, otherwise reset
    beq $v0, $s3, check_diag_right_top_square_for_match_skip_color
    li $s2, 0
    add $s3, $zero, $v0
    
check_diag_right_top_square_for_match_skip_color:
    # cap increment at 3
    li $t0, 3
    beq $s2, $t0, check_diag_right_top_square_for_match_skip_increment
    addi $s2, $s2, 1
    
check_diag_right_top_square_for_match_skip_increment:
    # if not 3 stored skip backfill
    li $t0, 3
    bne $s2, $t0, check_diag_right_top_square_for_match_skip_fill
    # skip if colour is black
    beq $s3, $zero, check_diag_right_top_square_for_match_skip_fill
    
    # Fill the past 3 squares with 0
    addi $a0, $s1, 0
    addi $a1, $s0, 0
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -1
    addi $a1, $s0, -1
    li $a2, 1
    jal set_removal_board_value
    addi $a0, $s1, -2
    addi $a1, $s0, -2
    li $a2, 1
    jal set_removal_board_value
    
check_diag_right_top_square_for_match_skip_fill:
    # y++ != 13 and x++ != 6 go back 
    addi $s1, $s1, 1 # change x
    addi $s0, $s0, 1 # change y
    li $t8, 13
    beq $s0, $t8, check_diag_right_top_skip_to_next
    li $t8, 6
    bne $s1, $t8, check_diag_right_top_square_for_match
check_diag_right_top_skip_to_next:
    # increment col
    addi $s4, $s4, 1
    li $t9, 13
    bne $s4, $t9, check_diag_right_top_for_matching
    
    j end_check_diag_right_top_for_matching
    
end_check_diag_right_top_for_matching:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra




remove_marked_squares:
    addi  $sp, $sp, -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)           # i (loop counter)
    li    $s0, 0                # i = 0 (cell index)
    sw $zero, found_match_flag

remove_marked_loop:
    # Loop 78 times (13 rows * 6 cols)
    beq   $s0, 78, end_remove_marked_squares

    # Load the value from game_board[i]
    la    $t0, removal_game_board       # Load base address of the board
    sll   $t1, $s0, 2           # offset = i * 4
    add   $t1, $t0, $t1         # address = &game_board[i]
    lw    $t0, 0($t1)           # $a2 = game_board[i] (the color value)
    
    beq $t0, $zero, skip_set_removed_marked_flag
    li $t0, 1
    sw $t0, found_match_flag
skip_set_removed_marked_flag:
    sw    $zero, 0($t1)

    # Calculate 2D grid coordinates (row, col) from 1D index (i)
    li    $t1, 6
    divu  $s0, $t1
    mflo  $a1                   # $s2 (row) = i / 6 (quotient)
    mfhi  $a0                   # $s3 (col) = i % 6 (remainder)
    li $a2, 0
    
    # if not marked, skip iter
    beq $t0, $zero, continue_remove_marked_loop
    jal set_board_value

continue_remove_marked_loop:
    addi  $s0, $s0, 1
    j    remove_marked_loop

end_remove_marked_squares:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

remove_empty_gaps:
    addi  $sp, $sp, -20
    sw    $ra, 0($sp)
    sw    $s0, 4($sp) # cur row
    sw    $s1, 8($sp) # cur col
    sw    $s2, 12($sp) # place row
    sw    $s3, 16($sp) # cur color
    
    lw $t0, piece_placed_flag
    beq $zero, $t0, skip_reset_piece_placed_flag
    
    li $s1, 0
pull_down_col_loop:
    li $s0, 12
    li $s2, 12
pull_down_col:
    # Arguments:
    #   $a0 - x coordinate (0-5)
    #   $a1 - y coordinate (0-12)
    # Return:
    #   $v0 - type (0-6)
    # Read at bottom position
    add   $a0, $zero, $s1
    add   $a1, $zero, $s2
    jal   read_board_value
    
    # Skip if not void
    bne $v0, $zero, pull_down_col_inc_bottom
    
    # read top position
    add   $a0, $zero, $s1
    add   $a1, $zero, $s0
    jal   read_board_value
    
    beq $v0, $zero, pull_down_col_skip_inc_bottom
    
    add   $a0, $zero, $s1
    add   $a1, $zero, $s2
    add   $a2, $zero, $v0
    jal   set_board_value
    
    add   $a0, $zero, $s1
    add   $a1, $zero, $s0
    li $a2, 0
    jal   set_board_value
    
pull_down_col_inc_bottom:    
    addi $s2, $s2, -1
    
pull_down_col_skip_inc_bottom:
    # incremenet x, != 6 go back
    addi $s0, $s0, -1
    li $t8, -1
    lw $t7, cursor_row
    beq $t7, $s0, pull_down_col_skip_col
    bne $s0, $t8, pull_down_col
pull_down_col_skip_col:
    # increment col
    addi $s1, $s1, 1
    li $t9, 6
    bne $s1, $t9, pull_down_col_loop


end_remove_empty_gaps:
    lw $t0, found_match_flag
    bne $zero, $t0, skip_reset_piece_placed_flag
    sw $zero, piece_placed_flag
    
    # set cursor to (3, 0)
    sw $zero, cursor_row
    sw $zero, last_cursor_row
    
    # if the center square is filled after flag check, end game
    li $a0, 3
    li $a1, 0
    jal read_board_value
    bne $v0, $zero, end_game
    
skip_reset_piece_placed_flag:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra
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
    # BROKEN SINCE COLLIDING WITH ITSELF.
    lw $t3, KEY_UP
    beq $s0, $t3, move_up

    lw $t3, KEY_DOWN
    beq $s0, $t3, move_down

    lw $t3, KEY_LEFT
    beq $s0, $t3, move_left

    lw $t3, KEY_RIGHT
    beq $s0, $t3, move_right
    
    lw $t3, KEY_Z
    beq $s0, $t3, press_z
    
    lw $t3, KEY_Q
    beq $s0, $t3, end_game

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
    beq   $s0, $t0, active_botton_collison  # If row is 12 (max), skip
    addi  $s0, $s0, 1               # Increment otherwise
    
    # Check collision
    lw    $a0, cursor_col
    add   $a1, $zero, $s0
    jal   read_board_value
    bne   $v0, $zero, active_botton_collison
    
    # Store value
    sw    $s0, cursor_row
    j move_down_done
    
active_botton_collison:
    jal generate_next_column
    
    # set cursor to (3, -1)
    # we do not draw the cursor if the flag is on
    li $t0, -1
    sw $t0, cursor_row
    sw $t0, last_cursor_row
    li $t0, 3
    sw $t0, cursor_col
    sw $t0, last_cursor_col
    
    li $t0, 1
    sw $t0, piece_placed_flag
    
    li $v0, 1
    li $a0, 12
    syscall
    
    j move_down_done
    
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

press_z:
    jal shift_current_column
    j input_done

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
#   $a2 - color index (0-60)
# -----------------------------------------------------------------------
draw_pixel:
    # --- SAVE REGISTERS ---
    # Save any temporary registers we are about to modify ($t0, $t1, $t2)
    # as well as the return address ($ra).
    addi  $sp, $sp, -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)

    # --- FUNCTION BODY ---
    lw    $t0, DISPLAY_ADDRESS  # $t0 = base display address
    # Calculate pixel offset in display memory:
    # address = base + (y * 64 + x) * 4
    sll   $t1, $a1, 6           # $t1 = y * 64
    add   $t1, $t1, $a0         # $t1 = y * 64 + x
    sll   $t1, $t1, 2           # $t1 = (y * 64 + x) * 4 (byte offset)
    add   $s0, $t0, $t1         # $t2 = final address
    
    # Load colour via id
    add $a0, $zero, $a2
    jal get_color
    sw    $v0, 0($s0)           # Draw the pixel by writing the color

    # --- RESTORE REGISTERS ---
    lw    $ra, 0($sp)
    lw    $s0, 4($sp)
    addi  $sp, $sp, 8

    jr    $ra
    
# ------------------------------------------------------------------
# get_color: given a colour id, return the hex code
# INPUT:    $a0 = Color Index (0 to 60+)
# OUTPUT:   $v0 = 32-bit Hex Color Code
# ------------------------------------------------------------------
get_color:
    addi  $sp, $sp, -4
    sw    $ra, 0($sp)
    # 1. Calculate Offset: Multiply Index ($a0) by 4
    #    Bitwise shift left by 2 is the fastest way to multiply by 4
    sll $t0, $a0, 2     
    
    # 2. Get Base Address of the palette
    la  $t1, COLOUR_PALETTE
    
    # 3. Add Offset to Base Address
    add $t2, $t1, $t0   # $t2 = Address of the specific color
    
    # 4. Load the color value from that address
    lw  $v0, 0($t2)     # Load value into return register
    
    lw    $ra, 0($sp)
    addi  $sp, $sp, 4

    jr  $ra
    

# -----------------------------------------------------------------------
# draw_board: Iterates through the game_board array and draws a pixel
#             for each cell with the corresponding color.
# -----------------------------------------------------------------------
draw_board:
    # --- SAVE REGISTERS ---
    addi  $sp, $sp, -20
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)           # i (loop counter)
    sw    $s1, 8($sp)
    sw    $s2, 12($sp)
    SW    $s3, 16($sp)

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
    lw    $a2, 0($t1)           # $a2 = game_board[i] (the color value)

    # Calculate 2D grid coordinates (row, col) from 1D index (i)
    li    $t1, 6
    divu  $s0, $t1
    mflo  $a1                   # $s2 (row) = i / 6 (quotient)
    mfhi  $a0                   # $s3 (col) = i % 6 (remainder)
    
    # this should be unreachable
    # maybe use for special logic for
    # different pixel types?
    
draw_board_pixel:
    # TODO:
    # - here would be the logic to scale pixels,
    #       for now we draw 1x1 -> 2x2 mapping
    addi $s1, $a0, 1 # x offset
    addi $s2, $a1, 1 # y offset
    sll $s1, $s1, 2 # x * 4
    sll $s2, $s2, 2 # y * 4
    
    li $s3, 0
draw_board_pixel_loop:
    li    $t1, 4
    divu  $s3, $t1
    mflo  $a1                   # dy (row) = i / 4 (quotient)
    mfhi  $a0                   # dx (col) = i % 4 (remainder)

    # Compute pixel location
    add $a0, $a0, $s1
    add $a1, $a1, $s2
    
    # Add game board shift
    addi $a0, $a0, 3
    addi $a1, $a1, 3
    
    jal   draw_pixel
    
    addi $s3, $s3, 1
    li $t0, 16
    bne $t0, $s3, draw_board_pixel_loop
    
    j    continue_board_loop
    
continue_board_loop:
    addi  $s0, $s0, 1           # Increment draw iteration
    j    draw_board_loop

draw_board_done:
    # --- RESTORE REGISTERS ---
    lw    $ra, 0($sp)
    lw    $s0, 4($sp)
    lw    $s1, 8($sp)
    lw    $s2, 12($sp)
    lw    $s3, 16($sp)
    addi  $sp, $sp, 20
    jr    $ra
    
    
# --------------------------
# draw_score
# -------------------------
draw_score:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    la $s0, next_column_colours
    li $s1, 9
draw_next_piece_loop:
    # Draw next piece
    addi $a0, $zero, 36
    add $a1, $zero, $s1
    lw $a2, 0($s0) 
    jal draw_pixel
    addi $a0, $zero, 37
    add $a1, $zero, $s1
    lw $a2, 0($s0) 
    jal draw_pixel
    addi $a0, $zero, 36
    addi $a1, $s1, 1
    lw $a2, 0($s0) 
    jal draw_pixel
    addi $a0, $zero, 37
    addi $a1, $s1, 1
    lw $a2, 0($s0) 
    jal draw_pixel
    
    addi $s1, $s1, 2
    addi $s0, $s0, 4
    li $t0, 15
    bne $s1, $t0, draw_next_piece_loop

end_draw_score:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    
    jr $ra

# -----------------------------------------------------------------------
# draw_background:
#   Renders the "Overgrown Lab" UI.
#   Order:
#   1. Patch Colors (Earthy Tones)
#   2. Draw 3D Slate Wall
#   3. Draw Vines (DFS from top, every 4px)
#   4. Draw Industrial Pipe (Right Aligner)
#   5. Draw Board Bezel
#   6. Draw HUD UI
# -----------------------------------------------------------------------
draw_background:
    # --- PROLOGUE ---
    # Save $ra, $s0-$s7, $fp
    addi $sp, $sp, -44
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)   # x / loop counter
    sw   $s1, 8($sp)   # y
    sw   $s2, 12($sp)  # color / temp
    sw   $s3, 16($sp)  # temp / row calc
    sw   $s4, 20($sp)  # border / brick x
    sw   $s5, 24($sp)  # fill / local x
    sw   $s6, 28($sp)  # text color / local y
    sw   $s7, 32($sp)  # temp / sum
    sw   $fp, 36($sp)  # frame pointer

    # ==================================================================
    # PHASE 0: COLOR PALETTE OVERRIDE
    # ==================================================================
    la   $t0, COLOUR_PALETTE
    
    # Patch Dark Leafy Greens (Vine Palette)
    li   $t1, 0x002F7D3F # Dark Green (Almost Black-Green shadow)
    sw   $t1, 128($t0)
    li   $t1, 0x002F7D3F # Deep Forest Green (Rich, cold dark green)
    sw   $t1, 132($t0)
    li   $t1, 0x002F7D3F # Deep Vine (Lush, organic dark green)
    sw   $t1, 136($t0)
    li   $t1, 0x002F7D3F # British Racing Green (Classic, premium deep leaf)
    sw   $t1, 144($t0)
    li   $t1, 0x002F7D3F # Phthalo Green (Cold, lush shadow tint)
    sw   $t1, 148($t0)
    li   $t1, 0x002F7D3F # Vine Green (The specific color of vine leaves)
    sw   $t1, 156($t0)

    # ==================================================================
    # PHASE 1: 3D SLATE WALL
    # ==================================================================
    li   $s1, 0
wall_y:
    li   $t0, 64
    beq  $s1, $t0, wall_end
    li   $s0, 0
wall_x:
    li   $t0, 64
    beq  $s0, $t0, wall_next

    # Exclusion: x[7..30], y[7..58]
    li   $t0, 7
    blt  $s0, $t0, brick_logic
    li   $t0, 31
    bge  $s0, $t0, brick_logic
    li   $t0, 7
    blt  $s1, $t0, brick_logic
    li   $t0, 59
    bge  $s1, $t0, brick_logic
    j    skip_draw

brick_logic:
    srl  $s3, $s1, 3        # row = y / 8
    andi $t1, $s3, 1
    move $s4, $s0
    beq  $t1, $zero, calc_local
    addi $s4, $s4, 8
calc_local:
    andi $s5, $s4, 15       # local x
    andi $s6, $s1, 7        # local y
    
    # Grout
    li   $t0, 15
    beq  $s5, $t0, col_dark
    li   $t0, 7
    beq  $s6, $t0, col_dark
    
    # Gradient
    add  $s7, $s5, $s6
    li   $t0, 6
    blt  $s7, $t0, col_light
    li   $t0, 14
    bgt  $s7, $t0, col_shadow
    j    col_mid

col_dark:
    li   $a2, 9
    j plot
col_shadow:
    li   $a2, 9
    j plot
col_mid:
    li   $a2, 10
    j plot
col_light:
    li   $a2, 11
    j plot

plot:
    move $a0, $s0
    move $a1, $s1
    jal  draw_pixel

skip_draw:
    addi $s0, $s0, 1
    j    wall_x
wall_next:
    addi $s1, $s1, 1
    j    wall_y
wall_end:

    # ==================================================================
    # PHASE 2: VINES (Behind UI)
    # Start at y=0, every 4th pixel along X
    # We reuse $s0 as the loop counter (x)
    # ==================================================================
    li   $s0, 0         # Start x = 0

vine_loop:
    li   $t0, 64
    bge  $s0, $t0, end_vines

    # Call DFS(x=$s0, y=0, depth=0)
    move $a0, $s0
    li   $a1, 0
    li   $a2, 0
    jal  vine_dfs
    
    addi $s0, $s0, 4    # Step 4
    j    vine_loop

end_vines:

    # ==================================================================
    # PHASE 3: INDUSTRIAL PIPE (Right Aligner)
    # Location: x = 59 to 63 (Width 5)
    # ==================================================================
    # x=59 (Dark Edge)
    li   $a0, 59
    li $a1, 0
    li $a2, 64
    li $a3, 53
    jal draw_vline_f
    # x=60 (Mid)
    li   $a0, 60
    li $a1, 0
    li $a2, 64
    li $a3, 52
    jal draw_vline_f
    # x=61 (Highlight)
    li   $a0, 61
    li $a1, 0
    li $a2, 64
    li $a3, 50
    jal draw_vline_f
    # x=62 (Mid)
    li   $a0, 62
    li $a1, 0
    li $a2, 64
    li $a3, 52
    jal draw_vline_f
    # x=63 (Dark Edge)
    li   $a0, 63
    li $a1, 0
    li $a2, 64
    li $a3, 53
    jal draw_vline_f

    # ==================================================================
    # PHASE 4: BEZEL (Around Board)
    # ==================================================================
    li   $a0, 6
    li $a1, 6
    li $a2, 54
    li $a3, 11
    jal draw_vline_f
    li   $a0, 6
    li $a1, 6
    li $a2, 26
    li $a3, 11
    jal draw_hline_f
    li   $a0, 31
    li $a1, 6
    li $a2, 54
    li $a3, 9
    jal draw_vline_f
    li   $a0, 6
    li $a1, 59
    li $a2, 26
    li $a3, 9
    jal draw_hline_f

    # ==================================================================
    # PHASE 5: HUD UI (Over Vines)
    # ==================================================================
    # li   $s6, 54    # Text: Lavender
    li   $s6, 0    # Text: Lavender
    li   $s7, 58    # Border: Dark Orchid
    li   $s5, 59    # Fill: Indigo

    # --- NEXT PIECE ---
    # Box
    li   $a0, 34
    li $a1, 7
    li $a2, 6
    li $a3, 10
    move $s4, $s7
    jal draw_box_f
    # Label
    li   $a0, 41
    li $a1, 9
    li $a2, 10
    move $a3, $s6
    jal draw_char # N
    li   $a0, 45
    li $a1, 9
    li $a2, 4
     move $a3, $s6
    jal draw_char # E
    li   $a0, 49
    li $a1, 9
    li $a2, 11
    move $a3, $s6
    jal draw_char # X
    li   $a0, 53
    li $a1, 9
    li $a2, 7
     move $a3, $s6
    jal draw_char # T

    # --- SCORE ---
    # Label
    li   $a0, 37
    li $a1, 19
    li $a2, 0
    move $a3, $s6
    jal draw_char # S
    li   $a0, 41
    li $a1, 19
    li $a2, 1
    move $a3, $s6
    jal draw_char # C
    li   $a0, 45
    li $a1, 19
    li $a2, 2
    move $a3, $s6
    jal draw_char # O
    li   $a0, 49
    li $a1, 19
    li $a2, 3
    move $a3, $s6
    jal draw_char # R
    li   $a0, 53
    li $a1, 19
    li $a2, 4
    move $a3, $s6
    jal draw_char # E
    # Box
    li   $a0, 34
    li $a1, 24
    li $a2, 23
    li $a3, 7
    move $s4, $s7
    jal draw_box_f

    # --- LEVEL ---
    # Box
    li   $a0, 34
    li $a1, 38
    li $a2, 23
    li $a3, 7 
    move $s4, $s7
    jal draw_box_f
    # Label
    li   $a0, 45
    li $a1, 33
    li $a2, 5 # use 8 for I
    move $a3, $s6
    jal draw_char
    li   $a0, 49
    li $a1, 33
    li $a2, 6
    move $a3, $s6
    jal draw_char
    li   $a0, 53
    li $a1, 33
    li $a2, 5
    move $a3, $s6
    jal draw_char

    # --- TIME ---
    # Box
    li   $a0, 34
    li $a1, 52
    li $a2, 23
    li $a3, 7
    move $s4, $s7
    jal draw_box_f
    # Label
    li   $a0, 41
    li $a1, 47
    li $a2, 7
    move $a3, $s6
    jal draw_char
    li   $a0, 45
    li $a1, 47
    li $a2, 8
    move $a3, $s6
    jal draw_char
    li   $a0, 49
    li $a1, 47
    li $a2, 9
    move $a3, $s6
    jal draw_char
    li   $a0, 53
    li $a1, 47
    li $a2, 4
    move $a3, $s6
    jal draw_char

    # --- EPILOGUE ---
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    lw   $s5, 24($sp)
    lw   $s6, 28($sp)
    lw   $s7, 32($sp)
    lw   $fp, 36($sp)
    addi $sp, $sp, 44
    jr   $ra


# -----------------------------------------------------------------------
# FUNCTION: vine_dfs
# Recursive. Thickness 1. Split every 5. Sprawling logic.
# -----------------------------------------------------------------------
vine_dfs:
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)   # x
    sw   $s1, 8($sp)   # y
    sw   $s2, 12($sp)  # depth
    sw   $s4, 16($sp)  # color

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    # 1. Base Case: Depth > 63 or Bounds
    li   $t0, 63
    bgt  $s2, $t0, dfs_exit
    blt  $s0, $zero, dfs_exit
    bgt  $s0, $t0, dfs_exit # x > 63
    bgt  $s1, $t0, dfs_exit # y > 63

    # 2. Color based on depth (Earthy Tones)
    # 0-20: Deep Earth (37)
    # 20-40: Moss (36)
    # 40+: Sage (39)
    li   $t0, 20
    blt  $s2, $t0, col_v_deep
    li   $t0, 40
    blt  $s2, $t0, col_v_mid
    li   $s4, 39    # Sage
    j    draw_v_px
col_v_deep:
    li   $s4, 37    # Deep Earth
    j    draw_v_px
col_v_mid:
    li   $s4, 36    # Moss

draw_v_px:
    # 3. Draw (Thickness 1)
    move $a0, $s0
    move $a1, $s1
    move $a2, $s4
    jal  draw_pixel

    # 4. Calculate Next Step
    # Y is always +1 (gravity)
    addi $t2, $s1, 1
    
    # X is Sprawling: Random(-1, 0, 1)
    li   $v0, 42
    li   $a0, 0
    li   $a1, 3     # Range 0,1,2
    syscall
    addi $t1, $a0, -1 # -1, 0, 1
    add  $t1, $s0, $t1 # New X

    # 5. Split Logic (Every 5 depths)
    li   $t0, 5
    div  $s2, $t0
    mfhi $t3        # remainder
    bne  $t3, $zero, dfs_recurse_single

    # -- SPLIT POINT --
    # Branch 1: Current calculated direction
    move $a0, $t1
    move $a1, $t2
    addi $a2, $s2, 1
    jal  vine_dfs
    
    # Branch 2: Opposite-ish direction (Random again for sprawl)
    li   $v0, 42
    li   $a0, 0
    li   $a1, 3
    syscall
    addi $t3, $a0, -1
    add  $t3, $s0, $t3 # Another X
    
    move $a0, $t3
    move $a1, $t2
    addi $a2, $s2, 1
    jal  vine_dfs
    j    dfs_exit

dfs_recurse_single:
    move $a0, $t1
    move $a1, $t2
    addi $a2, $s2, 1
    jal  vine_dfs

dfs_exit:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s4, 16($sp)
    addi $sp, $sp, 20
    jr   $ra

# -----------------------------------------------------------------------
# HELPER: draw_box_f
# -----------------------------------------------------------------------
draw_box_f:
    addi $sp, $sp, -28
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)
    sw   $s6, 20($sp)
    sw   $s7, 24($sp)
    move $s0, $a0
    move $s1, $a1
    add  $s2, $a0, $a2
    add  $s3, $a1, $a3
    move $s7, $s1
db_y:
    beq  $s7, $s3, db_end
    move $s6, $s0
db_x:
    beq  $s6, $s2, db_next
    beq  $s6, $s0, db_bord
    sub  $t9, $s2, 1
    beq  $s6, $t9, db_bord
    beq  $s7, $s1, db_bord
    sub  $t9, $s3, 1
    beq  $s7, $t9, db_bord
    move $a2, $s5
    j    db_p
db_bord:
    move $a2, $s4
db_p:
    move $a0, $s6
    move $a1, $s7
    jal  draw_pixel
    addi $s6, $s6, 1
    j    db_x
db_next:
    addi $s7, $s7, 1
    j    db_y
db_end:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s6, 20($sp)
    lw   $s7, 24($sp)
    addi $sp, $sp, 28
    jr   $ra

# -----------------------------------------------------------------------
# HELPER: draw_char
# -----------------------------------------------------------------------
draw_char:
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a3
    beq $a2, 0, l_S
    beq $a2, 1, l_C
    beq $a2, 2, l_O
    beq $a2, 3, l_R
    beq $a2, 4, l_E
    beq $a2, 5, l_L
    beq $a2, 6, l_V
    beq $a2, 7, l_T
    beq $a2, 8, l_I
    beq $a2, 9, l_M
    beq $a2, 10, l_N
    beq $a2, 11, l_X
    beq $a2, 12, l_G
    beq $a2, 13, l_A
    j l_end
l_S:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    addi $a0, $s0, 2
    addi $a1, $s1, 3
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_C:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_O:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_R:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_E:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_L:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_V:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 4
    jal draw_pixel
    j l_end
l_T:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 4
    jal draw_pixel
    j l_end
l_I:
    addi $a0, $s0, 1
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 4
    jal draw_pixel
    j l_end
l_M:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_N:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_X:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    addi $a0, $s0, 1
    addi $a1, $s1, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    j l_end
l_G:
    # Top bar
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    addi $a0, $s0, 1
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    # Left bar
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    # Bottom bar
    addi $a0, $s0, 1
    addi $a1, $s1, 4
    jal draw_pixel
    addi $a0, $s0, 2
    jal draw_pixel
    # Hook
    addi $a0, $s0, 2
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    addi $a1, $s1, 2
    jal draw_pixel
    j l_end
l_A:
    # Top center
    addi $a0, $s0, 1
    move $a1, $s1
    move $a2, $s2
    jal draw_pixel
    # Left leg
    move $a0, $s0
    addi $a1, $s1, 1
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 2
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 3
    jal draw_pixel
    move $a0, $s0
    addi $a1, $s1, 4
    jal draw_pixel
    # Right leg
    addi $a0, $s0, 2
    addi $a1, $s1, 1
    jal draw_pixel
    addi $a0, $s0, 2
    addi $a1, $s1, 2
    jal draw_pixel
    addi $a0, $s0, 2
    addi $a1, $s1, 3
    jal draw_pixel
    addi $a0, $s0, 2
    addi $a1, $s1, 4
    jal draw_pixel
    # Middle bar
    addi $a0, $s0, 1
    addi $a1, $s1, 2
    jal draw_pixel
    j l_end
l_end:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    addi $sp, $sp, 20
    jr   $ra

# -----------------------------------------------------------------------
# HELPER: draw_hline_f
# -----------------------------------------------------------------------
draw_hline_f:
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    move $s0, $a0
    add  $s1, $a0, $a2
dh_loop:
    beq  $s0, $s1, dh_x_end
    move $a0, $s0
    move $a2, $a3
    jal  draw_pixel
    addi $s0, $s0, 1
    j    dh_loop
dh_x_end:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    addi $sp, $sp, 12
    jr   $ra

# -----------------------------------------------------------------------
# HELPER: draw_vline_f
# -----------------------------------------------------------------------
draw_vline_f:
    addi $sp, $sp, -16
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    move $s2, $a0
    move $s0, $a1
    add  $s1, $a1, $a2
dv_loop:
    beq  $s0, $s1, dv_x_end
    move $a0, $s2
    move $a1, $s0
    move $a2, $a3
    jal  draw_pixel
    addi $s0, $s0, 1
    j    dv_loop
dv_x_end:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    addi $sp, $sp, 16
    jr   $ra

end_game:
    # 1. Paint a black box over the play area (approx x=6 to 31, y=6 to 58)
    li $a0, 6
    li $a1, 6
    li $a2, 26    # Width
    li $a3, 53    # Height
    li $s5, 0     # Black color 
    #jal draw_box_f
    # Drawong text over the mess, it looks cooler. 
    # Gave up on setting registeers for jal draw_box_f :P
    
    # 2. Draw "GAME"
    li $s6, 3      # RED color for "GAME OVER"
    
    li $a0, 10
    li $a1, 20
    li $a2, 12     # G
    move $a3, $s6
    jal draw_char
    
    li $a0, 14
    li $a1, 20
    li $a2, 13     # A
    move $a3, $s6
    jal draw_char
    
    li $a0, 18
    li $a1, 20
    li $a2, 9      # M
    move $a3, $s6
    jal draw_char
    
    li $a0, 22
    li $a1, 20
    li $a2, 4      # E
    move $a3, $s6
    jal draw_char

    # 3. Draw "OVER"
    li $a0, 10
    li $a1, 26
    li $a2, 2      # O
    move $a3, $s6
    jal draw_char

    li $a0, 14
    li $a1, 26
    li $a2, 6      # V
    move $a3, $s6
    jal draw_char

    li $a0, 18
    li $a1, 26
    li $a2, 4      # E
    move $a3, $s6
    jal draw_char

    li $a0, 22
    li $a1, 26
    li $a2, 3      # R
    move $a3, $s6
    jal draw_char
    
    game_over_input_loop:
    # Poll keyboard
    lw $t0, KEYBOARD_FLAG
    lw $t1, 0($t0)
    beq $t1, $zero, game_over_wait
    
    lw $t0, KEYBOARD_DATA
    lw $s0, 0($t0)
    
    # Check for 'r' (Retry)
    lw $t3, KEY_R
    beq $s0, $t3, reset_game
    
    # Check for 'q' (Quit)
    lw $t3, KEY_Q
    beq $s0, $t3, real_exit

game_over_wait:
    li $v0, 32
    li $a0, 50
    syscall
    j game_over_input_loop

real_exit:
    li $v0, 10
    syscall
    
# -----------------------------------------------------------------------
# reset_game: Zeros out the board and jumps to main
# -----------------------------------------------------------------------
reset_game:
    # 1. Zero out game_board memory
    la $t0, game_board
    li $t1, 312      # 78 words * 4 bytes
    add $t2, $t0, $t1 # End address
    
reset_loop:
    beq $t0, $t2, reset_done
    sw $zero, 0($t0)
    addi $t0, $t0, 4
    j reset_loop

reset_done:
    # 2. Reset removal board too (just in case)
    la $t0, removal_game_board
    li $t1, 312
    add $t2, $t0, $t1
    
reset_rem_loop:
    beq $t0, $t2, finish_reset
    sw $zero, 0($t0)
    addi $t0, $t0, 4
    j reset_rem_loop

finish_reset:
    # 3. Reset Cursor defaults
    sw $zero, cursor_col
    sw $zero, cursor_row
    
    # 4. Jump to start
    j main