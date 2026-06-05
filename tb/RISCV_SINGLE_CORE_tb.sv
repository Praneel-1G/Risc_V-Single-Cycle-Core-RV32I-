`timescale 1ns/1ps
module RISCV_SINGLE_CORE_tb;
logic clk;
logic rst;

RISCV_SINGLE_CORE dut(
    .clk(clk),
    .rst(rst)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("risc.vcd");
    $dumpvars(0,RISCV_SINGLE_CORE_tb);

    $display("Risc-v simulation");
    $display("Fibonacci(7) program");

    clk = 0;
    rst =1;
    #20;
    rst = 0;
    
    #2000;
    $display("SIMULATION TIMED OUT");
    $finish;
end

// self checking monitor
always @( posedge clk ) begin
    if (!rst) begin
        if(dut.MemWrite == 1'b1) begin
            // check if wrote to target adress 0x40
            if (dut.ALUResult == 32'h00000040) begin
                $display("Wrote data: %0d", dut.WriteData);
                if(dut.WriteData == 32'd13) begin
                    $display("done");
                end else begin
                    $display("expected 13 but got %0d", dut.WriteData);
                end
                #10;
                $finish;
            end
        end
    end
end
endmodule