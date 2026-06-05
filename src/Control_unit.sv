`timescale 1ns/1ps

module Control_unit(
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic       Zero,
    
    output logic       PCSrc,
    output logic [1:0] ResultSrc, // Upgraded to 2 bits!
    output logic       MemWrite,
    output logic [2:0] ALUControl,
    output logic       ALUSrc,
    output logic [1:0] ImmSrc,
    output logic       RegWrite,
    output logic       Jump       // NEW: Jump wire for jal
);

    logic [1:0] ALUOp;
    logic       Branch;

    // -----------------------------------------------------
    // PART 1: The Main Decoder
    // -----------------------------------------------------
    always_comb begin
        // Default values to prevent hardware latches
        RegWrite = 0; ImmSrc = 2'b00; ALUSrc = 0; MemWrite = 0; 
        ResultSrc = 2'b00; Branch = 0; ALUOp = 2'b00; Jump = 0;
        
        case (op)
            7'b0000011: begin // lw (Load Word)
                RegWrite = 1; ImmSrc = 2'b00; ALUSrc = 1; MemWrite = 0; 
                ResultSrc = 2'b01; Branch = 0; ALUOp = 2'b00; Jump = 0;
            end
            
            7'b0100011: begin // sw (Store Word)
                RegWrite = 0; ImmSrc = 2'b01; ALUSrc = 1; MemWrite = 1; 
                ResultSrc = 2'b00; Branch = 0; ALUOp = 2'b00; Jump = 0; // ResultSrc is 'don't care' (00)
            end
            
            7'b0110011: begin // R-type (add, sub, etc.)
                RegWrite = 1; ImmSrc = 2'b00; ALUSrc = 0; MemWrite = 0; 
                ResultSrc = 2'b00; Branch = 0; ALUOp = 2'b10; Jump = 0; // ImmSrc is 'don't care' (00)
            end
            
            7'b1100011: begin // beq (Branch Equal)
                RegWrite = 0; ImmSrc = 2'b10; ALUSrc = 0; MemWrite = 0; 
                ResultSrc = 2'b00; Branch = 1; ALUOp = 2'b01; Jump = 0; // ResultSrc is 'don't care' (00)
            end

            7'b0010011: begin // I-type ALU (addi, etc.) -> NEW!
                RegWrite = 1; ImmSrc = 2'b00; ALUSrc = 1; MemWrite = 0; 
                ResultSrc = 2'b00; Branch = 0; ALUOp = 2'b10; Jump = 0;
            end

            7'b1101111: begin // jal (Jump and Link) -> NEW!
                RegWrite = 1; ImmSrc = 2'b11; ALUSrc = 0; MemWrite = 0; 
                ResultSrc = 2'b10; Branch = 0; ALUOp = 2'b00; Jump = 1; // ALUSrc/ALUOp are 'don't care'
            end
            
            default: begin
                 RegWrite = 0; ImmSrc = 2'b00; ALUSrc = 0; MemWrite = 0; 
                 ResultSrc = 2'b00; Branch = 0; ALUOp = 2'b00; Jump = 0;
            end
        endcase
    end


// aluDecoder

always_comb begin
    case (ALUOp)
    2'b00: ALUControl = 3'b000;
    2'b01: ALUControl = 3'b001;
    2'b10: begin // r-type and itype alu
        case (funct3)
        3'b000: begin
            // i type has op[5] =0  and no valid funct7
            // rtype has op[5] =1 and valid func7
            if (op[5] == 1'b1 && funct7_5 == 1'b1)
            ALUControl = 3'b001; // subtract(r-type only)
            else ALUControl = 3'b000; // add (rtype or i type addi)
        end
        3'b010: ALUControl = 3'b101;
        3'b110: ALUControl = 3'b011;
        3'b111: ALUControl = 3'b000;
        endcase
    end
    default: ALUControl = 3'b000;
    endcase
end
//  logic
// pc changes its target if we hit a branch and its zero or
// if we hit jal
assign PCSrc = (Branch & Zero) | Jump;
endmodule