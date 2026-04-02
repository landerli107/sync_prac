`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/28 21:47:21
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module(
       input wire reset_n,
       input wire clk,
       
       input wire[31:0] im_rd,
       output wire[31:0] im_addr,
       output wire[31:0] im_wd,
       output wire       im_we,
       
       input wire [31:0] mem_rd,
       output wire[31:0] mem_addr,
       output wire[31:0] mem_wd,
       output wire       mem_we
       
    );
    wire reset;
    assign reset = ~reset_n;
    
    wire [31:0] inst;
    assign inst=im_rd;
    
    wire [5:0]opc_31_26;
    wire [3:0]opc_25_22;
    wire [5:0]opc_21_15;
    wire [15:0] offs;
    wire [11:0] i12;
    wire [4:0] rj;
    wire [4:0] rk;
    wire [4:0] rd;
    
    assign opc_31_26 = inst[31:26];
    assign opc_25_22 = inst[25:22];
    assign opc_21_15 = inst[21:15];
    assign offs      = inst[25:10];
    assign rd        = inst[4:0];
    assign rk        = inst[14:10];
    assign rj        = inst[9:5];
    
    wire        inst_add_w;
    wire        inst_addi_w;
    wire        inst_ld_w;
    wire        inst_st_w;
    wire        inst_bne;
    
    //instruction translation
    
    assign inst_add_w = ({opc_31_26,opc_25_22,opc_21_15}==17'b00000000000100000);
    assign inst_addi_w= ({opc_31_26,opc_25_22}==10'b0000001001);
    assign inst_ld_w  = ({opc_31_26,opc_25_22}==10'b0010100011);
    assign inst_st_w  = ({opc_31_26,opc_25_22}==10'b0010100110);
    assign inst_bne   = (opc_31_26==6'b010101);
    
    // ADDI.W rd,rj,si12    0 0 0 0 0 0 1 0 1 0 si12 rj rd

    //ADD.W rd,rj,rk 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 rk rj rd

    //LD.W rd,rj,si12  0 0 1 0 1 0 0 0 1 0 si12 rj rd

    //ST.W rd,rj,si12 0 0 1 0 1 0 0 1 1 0 si12 rj rd

    //BNE rj,rd,offs 0 1 0 1 1 1 offs[15:0] rj rd
    
    //  control sign conductor
    
    wire src2_is_imm;
    wire res_from_mem;
    wire gr_we;
    wire src_reg_is_rd;
    
    assign src2_is_imm  = inst_addi_w | inst_ld_w | inst_st_w;
    assign res_from_mem = inst_ld_w;
    assign gr_we        = inst_add_w | inst_addi_w | inst_ld_w;
    assign src_reg_is_rd= inst_st_w | inst_bne;
    
    // module realization
    
    wire [31:0] pc;
    wire br_taken;
    wire [31:0] br_target;
    
    pc m_pc (
    .clk(clk),
    .br_taken(br_taken),
    .br_target(br_target),
    .ret(reset_n),
    .pc(pc)
    );
    
    wire [31:0] rj_value;
    wire [31:0] rkd_value;
    wire [31:0] rf_wdata;
    
    reg_file m_regfile (
        .clk     (clk),
        .rst_n   (reset_n),
        .raddr1  (rj),
        .raddr2  (src_reg_is_rd ? rd : rk),
        .waddr   (rd),
        .wdata   (rf_wdata),
        .we      (gr_we),
        .rdata1  (rj_value),
        .rdata2  (rkd_value)
    );
    
    wire [31:0] alu_src1;
    wire [31:0] alu_src2;
    wire [31:0] alu_result;
    wire [31:0] imm;
    
    assign imm={{20{i12[11]}},i12};
    //expend with sign
    assign alu_src1=rj_value;
    assign alu_src2=src2_is_imm ? imm:rkd_value;
    
    alu m_alu (
    .src1(alu_src1),
    .src2(alu_src2),
    .addres(alu_result)
    );
    
    wire rj_eq_rk;
    assign rj_eq_rj = (rj_value==rkd_value);
    assign br_taken = inst_bne && (!rj_eq_rj);
    assign br_target= pc + {{14{offs[15]}}, offs, 2'b0};
    
    assign rf_data   = res_from_mem ? mem_rd : alu_result;
    assign mem_we    = inst_st_w;
    assign mem_addr  = alu_result;
    assign mem_wdata = rkd_value;
    
endmodule
