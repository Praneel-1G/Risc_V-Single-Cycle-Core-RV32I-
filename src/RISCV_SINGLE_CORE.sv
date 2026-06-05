`timescale 1ns/1ps

module RISCV_SINGLE_CORE(
    input logic clk,
    input logic rst,
    output logic [31:0] debug_pc_out
);
// program counter wires
logic [31:0] PCNext , PC , PCPlus4 , PCTarget;
// instr mem wire
logic [31:0] Instr;
// Control Unit Wires (The Blue Lines in your diagram)
logic       PCSrc, MemWrite, ALUSrc, RegWrite, Jump, Zero;
logic [1:0] ResultSrc, ImmSrc;
logic [2:0] ALUControl;
// Datapath Data Wires
logic [31:0] RD1, RD2, ImmExt, Result;
logic [31:0] SrcA, SrcB, ALUResult, ReadData, WriteData;

assign PCPlus4 = PC + 32'd4;
assign PCTarget = PC + ImmExt;

// pc mux
assign PCNext = PCSrc ? PCTarget : PCPlus4;
assign SrcA = RD1;
assign WriteData = RD2;
assign SrcB = ALUSrc ?  ImmExt : WriteData;

always_comb begin
    case (ResultSrc)
    2'b00: Result = ALUResult; // r-type
    2'b01: Result = ReadData;
    2'b10: Result = PCPlus4;
    default: Result = 32'bx;
    endcase
end

Program_Counter pc_reg (
        .clk(clk), .rst(rst), .PCNext(PCNext), .PC(PC)
    );

    Instr_mem imem (
        .A(PC), .RD(Instr)
    );

    Control_unit cu (
        // The instruction bits are sliced perfectly according to the diagram
        .op(Instr[6:0]), .funct3(Instr[14:12]), .funct7_5(Instr[30]), .Zero(Zero), 
        
        .PCSrc(PCSrc), .ResultSrc(ResultSrc), .MemWrite(MemWrite), 
        .ALUControl(ALUControl), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc), 
        .RegWrite(RegWrite), .Jump(Jump)
    );

    Reg_file rf (
        .clk(clk), .rst(rst), 
        .A1(Instr[19:15]), .A2(Instr[24:20]), .A3(Instr[11:7]), // Instruction slices
        .WD3(Result), .WE3(RegWrite), 
        .RD1(RD1), .RD2(RD2)
    );

    Extend ext (
        .Instr(Instr[31:7]), .ImmSrc(ImmSrc), .ImmExt(ImmExt)
    );

    ALU alu (
        .SrcA(SrcA), .SrcB(SrcB), .ALUControl(ALUControl),
        .Zero(Zero), .ALUResult(ALUResult)
    );

    Data_mem dmem (
        .clk(clk), .WE(MemWrite), .A(ALUResult), .WD(WriteData), .RD(ReadData)
    );

    assign debug_pc_out = PC;

endmodule