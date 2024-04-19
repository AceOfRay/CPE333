`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ray Valenzuela
// 
// Create Date: 10/28/2023 10:49:26 AM
// Design Name: OTTER MCU
// Module Name: OTTER_MCU
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


module OTTER_MCU(
    input RST,
    input INTR,
    input CLK,
    input [31:0] IOBUS_IN,
    output IOBUS_WR,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR
    );

    logic staticPCWrite = 1'b1;
    logic staticRDEN = 1'b1;

    struct packed {
        // control in
        logic [1:0] pcSource;

        logic[31:0] pcIn;

        // data out
        logic[31:0] pcOut;
        logic[31:0] instr;


    } ft_dc;

    struct packed {
        // control in

        // data in_out
        logic[31:0] instr;
        logic[31:0] pcOut;

        // data out
        logic[31:0] r_out1;
        logic[31:0] r_out2;
        logic[31:0] aluOut;

        logic[31:0] I;
        logic[31:0] J;
        logic[31:0] B;
        logic[31:0] S;
        logic[31:0] U;

        // control out
        logic[3:0] alu_fun;
        logic alu_srcA;
        logic[1:0] alu_srcB;
        logic[1:0] rf_wr_sel;
        //logic pcWrite;
        logic regWrite;
        logic memWe2;
        logic memRden1;
        logic memRden2;
        logic[1:0] pcSource;

    } dc_ex;

    struct packed {
        // control in
        logic[1:0] rf_wr_sel;
        logic regWrite;
        logic memWe2;
        logic memRden2;
        logic memRden1;

        // data in_out
        logic[31:0] instr;
        logic[31:0] r_out1;
        logic[31:0] r_out2;
        logic[31:0] aluOut;
        logic[31:0] jal;
        logic[31:0] jalr;
        logic[31:0] branch;
        logic[31:0] d_out2;
        logic[31:0] pcOut;

        //control out
        logic [3:0] alu_fun;
        logic alu_srcA;
        logic [1:0] alu_srcB;
        logic[1:0] pcSource;


    } ex_mem;

    struct packed {
        //data in
        
        logic[31:0] d_out2;
        logic[31:0] instr;
        logic[31:0] pcOut; // + 4
        logic[31:0] aluOut;

        logic[31:0] wd;
        // control in
        logic[1:0] rf_wr_sel;
        logic regWrite;
    } wb;

    ft_dc ft_dc;
    dc_ex dc_ex;
    ex_mem ex_mem;
    wb wb;


    always_ff @(posedge CLK) begin
        
        //---------------------------------------------------------------------------------
        // ft_dc to dc_ex

        ft_dc.pcOut <= dc_ex.pcOut;
        ft_dc.instr <= dc_ex.instr;

        //---------------------------------------------------------------------------------

        // dc_ex to ex_mem

        // data signals
        dc_ex.pcOut <= ex_mem.pcOut;
        dc_ex.r_out2 <= ex_mem.r_out2;
        dc_ex.r_out1 <= ex_mem.r_out1;
        dc_ex.instr <= ex_mem.instr;
        dc_ex.aluOut <= ex_mem.aluOut;

        // control signals
        dc_ex.alu_fun <= ex_mem.alu_fun;
        dc_ex.alu_srcA <= ex_mem.alu_srcA;
        dc_ex.alu_srcB <= ex_mem.alu_srcB;
        dc_ex.regWrite <= ex_mem.regWrite;
        dc_ex.rf_wr_sel <= ex_mem.rf_wr_sel;
        dc_ex.memWe2 <= ex_mem.memWe2;
        dc_ex.memRden1 <= ex_mem.memRden1;
        dc_ex.memRden2 <= ex_mem.memRden2;

        //---------------------------------------------------------------------------------
        
        // ex_mem to wb
        ex_mem.rf_wr_sel <= wb.rf_wr_sel;
        ex_mem.pcOut <= wb.pcOut;
        ex_mem.instr <= wb.instr;
        ex_mem.d_out2 <= wb.d_out2;
        ex_mem.aluOut <= wb.aluOut;
        ex_mem.regWrite <= wb.regWrite;

        //---------------------------------------------------------------------------------

    end

    // ---------------PHASE 1 ------------------------------------

        
    Memory Memory (
        .MEM_CLK  (CLK),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),

        // stage 1 ft_dec
        .MEM_RDEN1(staticRDEN),
        .MEM_ADDR1(ft_dec.pcOut[15:2]),
        .MEM_DOUT1(ft_dec.instr),

        // stage 4 ex_mem
        .MEM_RDEN2(ex_mem.memRden2),
        .MEM_WE2(ex_mem.memWe2),
        .MEM_ADDR2(ex_mem.aluOut),
        .MEM_DIN2 (ex_mem.r_out2),
        .MEM_SIZE(ex_mem.instr[13:12]),
        .MEM_SIGN(ex_mem.instr[14]),
        .MEM_DOUT2(wb.d_out2)
    );

    PC ProgramCounter (
        .PC_WRITE(staticPCWrite),
        .PC_RST  (RST),
        .PC_COUNT(ft_dc.pcOut),
        .CLK     (CLK),
        .PC_DIN  (ft_dc.pcIn)
    );

    mux_2bit_sel pc_mux (
        .A  (ft_dc.pcOut + 4),
        .B  (ex_mem.jalr),
        .C  (ex_mem.branch),
        .D  (ex_mem.jal),
        .O  (ft_dc.pcIn),
        .sel(ex_mem.pcSource),
    );

//----------------------------PHASE 2--------------------------------------------

    
    RF reg_file (
        .RF_ADR1(ft_dc.instr[19:15]),
        .RF_ADR2(ft_dc.instr[24:20]),
        .RF_WA(ft_dc.instr[11:7]),
        .RF_WD(wb.wd),
        .RF_EN(wb.regWrite),
        .CLK(CLK),
        .RF_RS1(dc_ex.r_out1),
        .RF_RS2(dc_ex.r_out2),
    ); 

    CU_DCDR dcdr (
        .opcode(ft_dc.instr[6:0]),
        .funct3(ft_dc.instr[14:12]),
        .funct7(ft_dc.instr[30]),
        .alu_fun(ex_mem.alu_fun),
        .alu_srcA(ex_mem.alu_srcA),
        .alu_srcB(ex_mem.alu_srcB),
        //.pcSource(), // modify decoder and come back
        .rf_wr_sel(ex_mem.rf_wr_sel)
    );

    IMMED_GEN immed_gen (
        .INSTRUCT(ft_dc.instr[31:7]),
        .U_TYPE  (dc_ex.U),
        .I_TYPE  (dc_ex.I),
        .S_TYPE  (dc_ex.S),
        .J_TYPE  (dc_ex.J),
        .B_TYPE  (dc_ex.B)
    );

//----------------------------PHASE 3--------------------------------------------

    