`timescale 1ns/1ps

module Reg_file(
    input logic [4:0] A1, A2 , A3 ,
    input logic [31:0] WD3,
    input logic WE3,
    input clk,rst,
    output logic [31:0] RD1 , RD2
);
// register memory has 32 bit wide and 32 floors of registers os using packed array
logic [31:0] reg_mem [31:0];


always_ff @( posedge clk or posedge rst ) begin 
    if (rst) begin
        // on reset put all 32 registers to 0
        for(int i = 0 ; i < 32 ; i = i+1) begin
            reg_mem[i] <= 32'b0;
        end
    end
    else if (WE3) begin
        if(A3 != 5'b0) begin
            reg_mem[A3] <= WD3;
        end
    end
end

// reading is combinational logic 
assign RD1 = (A1== 5'b0) ? 32'b0: reg_mem[A1];
assign RD2 = (A2== 5'b0) ? 32'b0: reg_mem[A2];
endmodule 

// 2. THE INTERFACE & ASSERTIONS
interface reg_if(input logic clk, rst);
    logic [4:0]  A1, A2, A3;
    logic [31:0] WD3, RD1, RD2;
    logic        WE3;

    // --- SystemVerilog Assertions (White-Box Checking) ---
    property p_reg0_rd1_zero;
        @(posedge clk) disable iff (rst)
        (A1 == 5'b0) |-> (RD1 == 32'b0);
    endproperty
    
    property p_reg0_rd2_zero;
        @(posedge clk) disable iff (rst)
        (A2 == 5'b0) |-> (RD2 == 32'b0);
    endproperty

    assert property (p_reg0_rd1_zero) else $error("SVA FAIL: RD1 != 0 when A1 is 0!");
    assert property (p_reg0_rd2_zero) else $error("SVA FAIL: RD2 != 0 when A2 is 0!");

    // --- Clocking Block (Race Condition Prevention) ---
    clocking cb @(posedge clk);
        default input #1step output #1ns;
        output A1, A2, A3, WD3, WE3;
        input  RD1, RD2;
    endclocking
endinterface