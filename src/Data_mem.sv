`timescale 1ns/1ps

module Data_mem(
    input logic clk ,
    input logic WE,
    input logic [31:0] A , WD,
    output logic [31:0] RD
);
// 4kb or ram 
logic [31:0] RAM [0:1023];
//divide the incoming address by 4.ca
  assign RD = RAM[A[11:2]];  // need 10 wires only ie from 11:2 to select any of of the 1024 memory location ,
always_ff @( posedge clk ) begin
    if(WE) begin
        RAM[A[11:2]] <= WD;
    end 
end
endmodule