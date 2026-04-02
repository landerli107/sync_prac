`timescale 1ns / 1ps
module tb_cpu;

reg clk;
reg reset_n;
reg [31:0] im_addr;
reg [31:0] im_wdata;
reg        im_we;
system_top u_system (
    .clk(clk),
    .reset_n(reset_n)
);

initial begin
    clk = 0;
    forever #50 clk = ~clk;
end

initial begin
    reset_n = 0;
    #100;
    reset_n = 1;
end

initial begin
    
    #100
    im_we=1;
    im_addr=32'b0;
    im_wdata = 32'b000000101000000000000000100001;  // ADDI R1,R0,5
    #100
    im_we=1;
    im_addr=32'b1;
    im_wdata = 32'b000000101000000000000001000010;  // ADDI R2,R0,3
    #100
    im_we=1;
    im_addr=32'b1;
    im_wdata = 32'b0000000000010000000010000100011; // ADD  R3,R1,R2
    end

initial begin
    #2000;
    $stop;
end

endmodule