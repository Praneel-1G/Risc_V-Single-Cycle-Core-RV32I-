`timescale 1ns/1ps

module Program_Counter(
    input logic clk, rst,
    input logic [31:0] PCNext,
    output logic [31:0] PC
);

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        PC <= 32'b0;
    end else begin
        PC <= PCNext;
    end    
end
endmodule