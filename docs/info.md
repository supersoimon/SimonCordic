<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## What this project is
This project is a CORDIC accelerator, designed to give me x and y coordinates for various angles. I chose to build this because I found it a cool project, and an intresting way to apply what I've learned about sine and cosine functions.

This accelerator uses a CORDIC algorithm to find X and Y coordinates when given various angles using bit shifting, addition, and subtraction, without any complicated multiplication hardware.

## How it works
This ASIC has 4 modules within it; a top level module, a Tiny Tapeout Top Level Module, a angle lookup table, and a rotation calculator. The lookup table and rotation calculator are connected through the top module, which is then fed into the Tiny Tapeout Top Level Module to link it to GPIO outputs.

The algorithm performs 15 "rotations". For each rotation, it adjusts the X and Y coordinates, adding/subtracting them to match the angle's position relative to the target angle. Once all the rotations are complete, the algorithm outputs a X and Y coordinate, being the sine and cosine values.

## How to test

The project can be tested by communicating with the ASIC through its GPIO pins;

 - Set the angle: Write the 17-bit signed angle value using the ui_in pins. The angle is written in three 8-bit sections:

   - uio_in[1:0] selects which byte to write

   - uio_in[2] acts as the write strobe

   - ui_in[7:0] carries the byte being written

- Start the calculation: Set uio_in[3] high to initiate a calculation

 - Wait for completion: Select output channel 6 using uio_in[6:4] to read the busy status
   - A value of 1 means the calculation is in progress, while 0 means it has finished

 - Read the results: Use uio_in[6:4] to select the output:

   - 000: X coordinate bits [7:0]

   - 001: X coordinate bits [15:8]

   - 010: X coordinate bit [16]

   - 011: Y coordinate bits [7:0]

   - 100: Y coordinate bits [15:8]

   - 101: Y coordinate bit [16]

 - 110: Busy status

The three coordinate sections can be combined to reconstruct the signed 17-bit X and Y values.
## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
