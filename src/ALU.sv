`timescale 1ns/1ps

module ALU(
    input logic [31:0] SrcA , SrcB,
    input logic [2:0] ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);
always_comb begin
    case (ALUControl)
    3'b000: ALUResult = SrcA + SrcB;
    3'b001: ALUResult = SrcA - SrcB;
    3'b010: ALUResult = SrcA & SrcB;
    3'b011: ALUResult = SrcA | SrcB;
    // slt: set less than
    3'b101: ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0;
    default: ALUResult = 32'bx;
    endcase
end
assign Zero = (ALUResult == 32'b0);



endmodule