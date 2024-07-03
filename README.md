# <img src="https://github.com/IUST-Computer-Organization/.github/blob/main/images/CompOrg_orange.png" alt="Image" width="85" height="85" style="vertical-align:middle"> LUMOS RISC-V

> Light Utilization with Multicycle Operational Stages (LUMOS) RISC-V Processor Core
#### Computer Organization Spring 2024 (Final Project)
#### Iran Univeristy of Science and Technology
Name : Ehsan Seyfibonab
Student number : 97412229
Date : 07/02/2024
<div align="justify">

## Multiplication result bit selection

```
product[WIDTH + FBITS - 1 : FBITS]
```

## Explain Assembly.S

```
li sp, 0x3C00
```

This instruction loads the immediate value 0x3C00 into the stack pointer register sp, setting the stack pointer to point to memory address 0x3C00

```
addi gp, sp, 392
```

This instruction adds the immediate value 392 to the stack pointer sp and stores the result in the global pointer register gp. It moves the global pointer to a location 392 bytes above the stack pointer.

```
loop:
```

This indicates the beginning of a loop labeled loop

```
flw f1, 0(sp)
```

Load a single-precision floating-point value from memory at the address pointed to by the stack pointer sp and store it in floating-point register f1

```
flw f2, 4(sp)
```

Load a single-precision floating-point value from memory at the address 4 bytes above the stack pointer sp and store it in floating-point register f2.

```
fmul.s f10, f1, f1
```

Multiply the floating-point values in registers f1 and f1, storing the result in floating-point register f10.

```
fmul.s f20, f2, f2
```

Multiply the floating-point values in registers f2 and f2, storing the result in floating-point register f20.

```
fadd.s f30, f10, f20
```

Add the floating-point values in registers f10 and f20, storing the result in floating-point register f30.

```
fsqrt.s x3, f30
```

Compute the square root of the floating-point value in register f30 and store the result in the x3 register.

```
fadd.s f0, f0, f3
```

Add the floating-point value in register f3 to the floating-point value in register f0, storing the result in register f0.

```
addi sp, sp, 8
```

Increment the stack pointer sp by 8 bytes, effectively moving it to the next set of floating-point values in memory.

```
blt sp, gp, loop
```

Branch to the loop label if the value in the stack pointer sp is less than the value in the global pointer gp, effectively looping back to load more floating-point values.

```
ebreak
```

This instruction triggers a breakpoint exception, which is commonly used for debugging purposes to pause program execution.

Overally this code loads x axis and y axis values at each iteration and calculates
distance for each set And then it increases the stack pointer and continues this iteration.

## LUMOS waveform

# <img src="https://github.com/seyfi1998/Seyfi_LUMOS_FPU/blob/main/Images/1.png" alt="Image" width="85" height="85" style="vertical-align:middle"> First

# <img src="https://github.com/seyfi1998/Seyfi_LUMOS_FPU/blob/main/Images/2.png" alt="Image" width="85" height="85" style="vertical-align:middle"> Second

# <img src="https://github.com/seyfi1998/Seyfi_LUMOS_FPU/blob/main/Images/3.png" alt="Image" width="85" height="85" style="vertical-align:middle"> Third

# <img src="https://github.com/seyfi1998/Seyfi_LUMOS_FPU/blob/main/Images/4.png" alt="Image" width="85" height="85" style="vertical-align:middle"> Fourth

## Code description

### 32-bit multiplication

First I defined 6 states for different situations in multiplication. First stage is the initializatio stage where I set partialproducts to be 0 and multiplierCircuitInput1 and multiplierCircuitInput2 to be the first 16 bit of input operands. At the end I set the next state to be FIRSTMUL.
At FIRSTMUL state I store multiplierCircuitResult to partialProduct1. And the I set multiplierCircuitInput1 to be the last 16 bit of operand_1 and multiplierCircuitInput2 to be the first 16 bits of operand_2. And the I set the next state to be SECONDMUL.
At SECONDMUL state I store multiplierCircuitResult to partialProduct2 with 16 bit shift to left. And the I set multiplierCircuitInput1 to be the first 16 bit of operand_1 and multiplierCircuitInput2 to be the last 16 bits of operand_2. And the I set the next state to be THIRDMUL.
At SECONDMUL state I store multiplierCircuitResult to partialProduct3 with 16 bit shift to left. And the I set multiplierCircuitInput1 to be the last 16 bit of operand_1 and multiplierCircuitInput2 to be the last 16 bits of operand_2. And the I set the next state to be FOURTHMUL.
At SECONDMUL state I store multiplierCircuitResult to partialProduct3 with 32 bit shift to left. And the I set the next state to be ADD.
At ADD state I add the four partial products and store the result in product and I set product_ready to 1 and state to INITIALSTATE.

### Square root calculation

In this block radicant is the register to hold radicant which appends the next two bits of operand to itself.
temp_root is the register which will substracted from radicant. This register is the result with 01 appending to the right of it.
We will have `(WIDTH + FBITS) / 2` iterations and the final_result will be the root register and root_ready will be 1.
