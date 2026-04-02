`timescale 1ns / 1ps


module system_top(
    input  wire clk,
    input  wire reset_n,
    input  wire [31:0] im_addr,
    input  wire [31:0] im_wdata,
    input  wire        im_we
);
    wire [31:0] im_addr;
    wire [31:0] im_wdata;
    wire        im_we;
    wire [31:0] im_rdata;

    ram inst_ram (
        .clk   (clk),
        .addr  (im_addr),
        .wdata (im_wdata),
        .rdata (im_rdata),
        .we    (im_we),
        .ret   (reset_n)
    );
    
    
    
     wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire        mem_we;
    wire [31:0] mem_rdata;

    ram data_ram (
        .clk   (clk),
        .addr  (mem_addr),
        .wdata (mem_wdata),
        .rdata (mem_rdata),
        .we    (mem_we),
        .ret   (reset_n)
    );
    
    top_module m_cpu(
        .clk        (clk),
        .reset_n    (reset_n),
        
        .im_addr    (im_addr),
        .im_wd   (im_wdata),
        .im_we      (im_we),
        .im_rd   (im_rdata),
        
        .mem_addr   (mem_addr),
        .mem_wd  (mem_wdata),
        .mem_we     (mem_we),
        .mem_rd  (mem_rdata)
    );
    initial begin
    $dumpfile("wave.vcd");  // 生成波形文件
    $dumpvars(0, tb_cpu);   //  dump 所有信号，包括PC
    #1000;
    $finish;
end
endmodule
