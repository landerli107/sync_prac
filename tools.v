`timescale 1ns / 1ps

module reg_file (
    input clk,
    input rst_n,
    input [4:0] raddr1,      
    input [31:0] wdata,
    input [4:0]  waddr,
    input we,            
    output [31:0] rdata1,
    output [31:0] rdata2,
    input  [4:0] raddr2
);
    reg [31:0] regs [0:31];  
    
    integer i;
    

    always @(posedge clk or negedge rst_n) 
    begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end 
        else if (we) begin
            regs[waddr] <= wdata;
        end
    end
    
    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];
    
endmodule


module alu(
input wire [31:0] src1,
input wire [31:0] src2,
output wire[31:0] addres

);
    assign addres=src1+src2;

endmodule

module pc(
    input wire br_taken ,
    input wire [31:0] br_target,
    input wire ret,
    input wire clk,
    output reg [31:0] pc
);
    always @(posedge clk or negedge ret)
    begin 
        if(!ret)
        begin
            if(!br_taken)begin
                pc<=pc+4;
                end
            else 
            pc <= br_target;
        
        end
        else 
            pc <= 32'b0;
        
    end
    

endmodule

module ram(
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,
    input wire we,
    input wire ret
);
    reg [31:0] ram [0:1023];
    integer i;

always @(posedge clk or negedge ret) begin 
    if(!ret) begin 
        for(i=0;i<1024;i=i+1)
            ram[i] <= 32'b0;
        rdata <= 32'b0;
    end
    else begin   
        if(we) begin
            ram[addr] <= wdata;
        end
        rdata <= ram[addr];
    end
end 

endmodule


