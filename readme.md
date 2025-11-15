# CSC258 - Assembly Language Project: Columns

This repository contains the template for the "Columns" game project for CSC258.

## Overview

The goal of this project is to implement the classic falling-block puzzle game "Columns" in MIPS assembly language. You will be working with memory-mapped I/O to control a 64x64 pixel display and read keyboard input.

This template provides a starting point with basic code structure, including:
- A main game loop.
- Functions for clearing the screen and drawing pixels.
- A data structure for the game board.
- Basic input handling for moving a cursor.

## Files

- `Columns.asm`: The main source file for the Columns game. This is where you will write your code. The file is pre-populated with a basic structure and comments to guide you.
- `tictactoe.asm`: A complete, well-commented example of a Tic-Tac-Toe game. Use this file as a reference for how to structure your code, handle graphics, and manage game state. It demonstrates many of the concepts you will need for your own project.
- `CSC258_Project_Columns.pdf`: The official project handout with detailed requirements, grading criteria, and submission instructions.

## Getting Started

1.  **Familiarize yourself with the `tictactoe.asm` example.** Run it in the SATURN simulator and study the code to understand how it works. Pay close attention to:
    *   The game loop structure.
    *   How graphics are drawn to the screen using the `DISPLAY_ADDRESS`.
    *   How keyboard input is read using `KEYBOARD_FLAG` and `KEYBOARD_DATA`.
    *   The use of the stack to save and restore registers (`$ra`, `$s` registers) in subroutines.
    *   The commenting style and code organization.

2.  **Review the `Columns.asm` template.** Understand the existing data structures (`game_board`, `cursor_col`, `cursor_row`) and the purpose of the provided subroutines (`main`, `game_loop`, `update_game_logic`, `handle_input`, `draw_pixel`, etc.).

3.  **Read the `CSC258_Project_Columns.pdf` handout carefully.** This document contains the full specification for the project.

## Your Task

Your main task is to complete the implementation of `Columns.asm`. This involves:

1.  **Game Logic (`update_game_logic`):**
    *   Implement the falling behavior of the columns/pieces.
    *   Generate new falling pieces.
    *   Detect when a piece has landed.

2.  **Collision and Matching:**
    *   Detect when three or more jewels of the same color are aligned vertically, horizontally, or diagonally.
    *   Remove the matched jewels from the board.
    *   Implement logic for jewels above the matched set to fall down and fill the empty space.

3.  **Graphics (`draw_board`):**
    *   Modify the `draw_board` function to render the different colored jewels correctly. The current implementation just draws single pixels. You will need to draw larger blocks or shapes to represent the jewels.

4.  **Input Handling (`handle_input`):**
    *   Add functionality for the player to drop pieces faster and rotate the jewels within a falling column.

## Running the Code

To run this project, you will need the **SATURN MIPS simulator**.

1.  Launch SATURN.
2.  Open the `.asm` file you want to run.
3.  Assemble the code (F3).
4.  Open the "Bitmap Display" and "Keyboard and Display MMIO" tools from the Tools menu.
5.  Run the code (F5).

You should see the game running in the Bitmap Display window. You can interact with it using the keyboard.
