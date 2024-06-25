`include "Defines.vh"

module Fixed_Point_Unit 
#(
    parameter WIDTH = 32,
    parameter FBITS = 10
)
(
    input wire clk,
    input wire reset,
    
    input wire [WIDTH - 1 : 0] operand_1,
    input wire [WIDTH - 1 : 0] operand_2,
    
    input wire [ 1 : 0] operation,

    output reg [WIDTH - 1 : 0] result,
    output reg ready
);

    always @(*)
    begin
        case (operation)
            `FPU_ADD    : begin result <= operand_1 + operand_2; ready <= 1; end
            `FPU_SUB    : begin result <= operand_1 - operand_2; ready <= 1; end
            `FPU_MUL    : begin result <= product[WIDTH + FBITS - 1 : FBITS]; ready <= product_ready; end
            `FPU_SQRT   : begin result <= root; ready <= root_ready; end
            default     : begin result <= 'bz; ready <= 0; end
        endcase
    end

    always @(posedge reset)
    begin
        if (reset)  ready = 0;
        else        ready = 'bz;
    end
    // ------------------- //
    // Square Root Circuit //
    // ------------------- //
    reg [WIDTH - 1 : 0] root;
    reg root_ready;

        /*
         *  Describe Your Square Root Calculator Circuit Here.
         */

    // ------------------ //
    // Multiplier Circuit //
    // ------------------ //   
    reg [64 - 1 : 0] product;
    reg product_ready;

    reg     [15 : 0] multiplierCircuitInput1;
    reg     [15 : 0] multiplierCircuitInput2;
    wire    [31 : 0] multiplierCircuitResult;

    Multiplier multiplier_circuit
    (
        .operand_1(multiplierCircuitInput1),
        .operand_2(multiplierCircuitInput2),
        .product(multiplierCircuitResult)
    );

    reg     [31 : 0] partialProduct1;
    reg     [31 : 0] partialProduct2;
    reg     [31 : 0] partialProduct3;
    reg     [31 : 0] partialProduct4;

        /*
         *  Describe Your 32-bit Multiplier Circuit Here.
         */
    //Three bit register to store 32-bit multiplication state
    reg [2:0] state;

    //Define parameters for each state
    localparam INITIALSTATE = 3'b000;
    localparam FIRSTMUL = 3'b001;
    localparam SECONDMUL = 3'b010;
    localparam THIRDMUL = 3'b011;
    localparam FOURTHMUL = 3'b100;
    localparam ADD = 3'b101;

    always @(posedge clk) begin
        if (reset) begin
            state <= INITIALSTATE;
            product <= 0;
            product_ready <= 0;
        end else begin
            case (state)
                //Initial state to initialize registers
                INITIALSTATE: begin
                    if (operation == `FPU_MUL) begin
                        //In FIRSTMUL stage inpust will be first 16-bit of each input
                        multiplierCircuitInput1 <= operand_1[15 : 0];
                        multiplierCircuitInput2 <= operand_2[15 : 0];
                        //Partial products should be 0 at start
                        partialProduct1 <= 0;
                        partialProduct2 <= 0;
                        partialProduct3 <= 0;
                        partialProduct4 <= 0;
                        // Change state to FIRSTMUL at the next cycle
                        state <= FIRSTMUL;
                    end
                end
                FIRSTMUL: begin
                    // Store partial product result
                    partialProduct1 <= multiplierCircuitResult;
                    // Update multiplier inputs to calculate partial proct 2
                    multiplierCircuitInput1 <= operand_1[31 : 16];
                    multiplierCircuitInput2 <= operand_2[15 : 0];
                    // Change state to be SECONDMUL at next cycle
                    state <= SECONDMUL;
                end
                SECONDMUL: begin
                    // Store partial product result with 16-bit shift to the left
                    partialProduct2 <= multiplierCircuitResult << 16;
                    // Update multiplier inputs to calculate partial proct 3
                    multiplierCircuitInput1 <= operand_1[15 : 0];
                    multiplierCircuitInput2 <= operand_2[31 : 16];
                    // Change state to be THIRDMUL at next cycle
                    state <= THIRDMUL;
                end
                THIRDMUL: begin
                    // Store partial product with 16-bit shift to the left
                    partialProduct3 <= multiplierCircuitResult << 16;
                    // Update multiplier inputs to calculate partial proct 4
                    multiplierCircuitInput1 <= operand_1[31 : 16];
                    multiplierCircuitInput2 <= operand_2[31 : 16];
                    // Change state to be FOURTHMUL at next cycle
                    state <= FOURTHMUL;
                end
                FOURTHMUL: begin
                    // Store partial product with 32-bit shift to the left
                    partialProduct4 <= multiplierCircuitResult << 32;
                    //  Change state to be ADD at next cycle
                    state <= ADD;
                end
                ADD: begin
                    // Store partial product
                    product <= partialProduct1 + partialProduct2 + partialProduct3 + partialProduct4;
                    // Move to next state
                    state <= INITIALSTATE;
                    product_ready <= 1; 
                end
                default: begin
                    state <= INITIALSTATE;
                end
            endcase
        end
    end
         
endmodule

module Multiplier
(
    input wire [15 : 0] operand_1,
    input wire [15 : 0] operand_2,

    output reg [31 : 0] product
);

    always @(*)
    begin
        product <= operand_1 * operand_2;
    end
endmodule