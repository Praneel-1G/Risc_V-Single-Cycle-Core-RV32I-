`timescale 1ns/1ps

//COMBINATIONAL memory 
module Instr_mem(
    input logic [31:0] A,// adress from the program counter
    output logic [31:0] RD
);
logic [31:0] mem [1024];

initial begin
    // "program.hex" is jzt a simple text file that is to be read
    $readmemh("program.hex", mem);
end
// Notice A[31:2]: This automatically drops the bottom two bits (A[1] and A[0]),
    // which mathematically divides the PC by 4 to get the correct array index.
assign RD = mem[A[31:2]];
endmodule 