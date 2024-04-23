`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ray Valenzuela
// 
// Create Date: 
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

    // fetch_decode wires

    logic staticPCWrite = 1'b1;
    logic staticRDEN = 1'b1;

    logic [31:0] alu_inA;
    logic [31:0] alu_inB;

    logic [1:0] pcSource;

    logic [31:0] pcIn;
    logic [31:0] pcOutWire;
    logic [31:0] nextPcOutWire;
    logic [31:0] instrWire;

    logic [31:0] jalrWire;
    logic [31:0] branchWire;
    logic [31:0] jalWire;

    assign nextPcOutWire = pcOutWire + 4;

    // decode_execute wires

    logic [31:0] r_out1_wire;
    logic [31:0] r_out2_wire;

    logic [1:0] alu_srcA_sel;
    logic [2:0] alu_srcB_sel;
    logic [3:0] alu_fun_wire;
    logic [1:0] rf_wr_sel_wire;

    logic [31:0] b_wire;
    logic [31:0] u_wire;
    logic [31:0] j_wire;
    logic [31:0] i_wire;
    logic [31:0] s_wire;

    logic memRd1_wire;

    logic memRd2_wire;
    logic regWrite_wire;
    logic memWrite_wire;
    
    // execute_memory wires

    logic [31:0] aluOut_wire;
    logic [31:0] alu_srcA_data_wire;
    logic [31:0] alu_srcB_data_wire;

    // memory_writeback wires

    logic [31:0] d_out2_wire;

    assign IOBUS_OUT = ex_mem.r_out2;
    assign IOBUS_ADDR = ex_mem.aluOut;

    logic[31:0] rf_wd_w;

    typedef struct packed {

        // data out
        logic[31:0] pcOut;
        logic[31:0] nextPcOut;
        logic[31:0] instr;


    } fetch_decode;

    typedef struct packed {
        // control in

        // data in_out
        logic[31:0] instr;
        logic[31:0] pcOut;
        logic[31:0] nextPcOut;

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
        logic [1:0]alu_srcA;
        logic[1:0] alu_srcB;
        logic[1:0] rf_wr_sel;
        //logic pcWrite;
        logic regWrite;
        logic memWe2;
        logic memRden1;
        logic memRden2;
        logic[1:0] pcSource;

    } decode_execute;

    typedef struct packed {
        // control in
        logic[1:0] rf_wr_sel;
        logic regWrite;
        logic memWe2;
        logic memRden2;
        logic memRden1;
        logic [1:0] memSize;
        logic memSign;
        logic [31:0] nextPcOut;

        // data in_out
        logic[31:0] instr;
        //logic[31:0] r_out1;
        logic[31:0] r_out2;
        logic[31:0] aluOut;
        logic[31:0] jal;
        logic[31:0] jalr;
        logic[31:0] branch;
        logic[31:0] d_out2;
        logic[31:0] pcOut;

        //control out
        logic [3:0] alu_fun;
        logic [1:0]alu_srcA;
        logic [1:0] alu_srcB;
        logic[1:0] pcSource;

    } execute_memory;

    typedef struct packed {
        //data in
        logic[31:0] d_out2;
        logic[31:0] instr;
        logic[31:0] pcOut; // + 4
        logic[31:0] nextPcOut;
        logic[31:0] aluOut;
        logic[31:0] wd;
        // control in
        logic[1:0] rf_wr_sel;
        logic regWrite;

    } writeback;

    fetch_decode ft_dc;
    decode_execute dc_ex;
    execute_memory ex_mem;
    writeback wb;

    always_ff @(posedge CLK) begin
        if (RST) begin
            ft_dc <= 0;
            dc_ex <= 0;
            ex_mem <= 0;
            wb <= 0;
        end
        else begin
            // ft_dec
            ft_dc.pcOut <= pcOutWire;
            ft_dc.nextPcOut <= nextPcOutWire;
            ft_dc.instr <= instrWire;

            // dc_ex
            dc_ex.pcOut <= ft_dc.pcOut;
            dc_ex.nextPcOut <= ft_dc.nextPcOut;
            dc_ex.instr <= ft_dc.instr;
            dc_ex.regWrite <= regWrite_wire;
            dc_ex.memWe2 <= memWrite_wire;
            dc_ex.memRden2 <= memRd2_wire;
            dc_ex.alu_fun <= alu_fun_wire;
            dc_ex.alu_srcA <= alu_srcA_sel;
            dc_ex.alu_srcB <= alu_srcB_sel;
            dc_ex.rf_wr_sel <= rf_wr_sel_wire;
            dc_ex.r_out1 <= r_out1_wire;
            dc_ex.r_out2 <= r_out2_wire;
            dc_ex.U <= u_wire;
            dc_ex.S <= s_wire;
            dc_ex.J <= j_wire;
            dc_ex.I <= i_wire;
            dc_ex.B <= b_wire;

            // ex_mem
            ex_mem.nextPcOut <= dc_ex.nextPcOut;
            ex_mem.memSize <= dc_ex.instr[13:12];
            ex_mem.memSign <= dc_ex.instr[14];
            ex_mem.regWrite <= dc_ex.regWrite;
            ex_mem.memWe2 <= dc_ex.memWe2;
            ex_mem.memRden2 <= dc_ex.memRden2;
            ex_mem.rf_wr_sel <= dc_ex.rf_wr_sel;
            ex_mem.r_out2 <= dc_ex.r_out2;
            ex_mem.aluOut <= aluOut_wire;
            ex_mem.instr <= dc_ex.instr;

            // mem_wb
            wb.nextPcOut <= ex_mem.nextPcOut;
            wb.regWrite <= ex_mem.regWrite;
            wb.rf_wr_sel <= ex_mem.rf_wr_sel;
            wb.d_out2 <= d_out2_wire;
            wb.aluOut <= ex_mem.aluOut;
            wb.instr <= ex_mem.instr;
        end
    end

    // ---------------PHASE 1 ------------------------------------

        
    Memory Memory (
        .MEM_CLK  (CLK),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),

        // stage 1 ft_dc
        .MEM_RDEN1(staticRDEN),
        .MEM_ADDR1(pcOutWire[15:2]),
        .MEM_DOUT1(instrWire),

        // stage 4 ex_mem
        .MEM_RDEN2(ex_mem.memRden2),
        .MEM_WE2(ex_mem.memWe2),
        .MEM_ADDR2(ex_mem.aluOut),
        .MEM_DIN2 (ex_mem.r_out2),
        .MEM_SIZE(ex_mem.memSize),
        .MEM_SIGN(ex_mem.memSign),
        .MEM_DOUT2(d_out2_wire)
    );

    PC ProgramCounter (
        .PC_WRITE(staticPCWrite),
        .PC_RST  (RST),
        .PC_COUNT(pcOutWire),
        .CLK     (CLK),
        .PC_DIN  (pcIn)
    );

    mux_2bit_sel pc_mux (
        .A  (nextPcOutWire),
        .B  (jalrWire),
        .C  (branchWire),
        .D  (jalWire),
        .O  (pcIn),
        .sel(pcSource)
    );

//----------------------------PHASE 2--------------------------------------------

    RF reg_file (
        .RF_ADR1(ft_dc.instr[19:15]),
        .RF_ADR2(ft_dc.instr[24:20]),
        .RF_WA(wb.instr[11:7]), // should come from wb
        .RF_WD(rf_wd_w),
        .RF_EN(wb.regWrite),
        .CLK(CLK),
        .RF_RS1(r_out1_wire),
        .RF_RS2(r_out2_wire)
    );

    CU_DCDR dcdr (
        .opcode(ft_dc.instr[6:0]),
        .funct3(ft_dc.instr[14:12]),
        .funct7(ft_dc.instr[30]),
        .alu_srcA(alu_srcA_sel),
        .alu_srcB(alu_srcB_sel),
        .rf_wr_sel(rf_wr_sel_wire),
        .alu_fun (alu_fun_wire),
        .memRead2 (memRd2_wire), // POINT OF BREAK POSSIBLY
        .memWrite (memWrite_wire),
        .regWrite (regWrite_wire),
        .csr_WE (),
        .memRead1 (memRd1_wire)
    );

    IMMED_GEN immed_gen (
        .INSTRUCT(ft_dc.instr[31:7]),
        .U_TYPE  (u_wire),
        .I_TYPE  (i_wire),
        .S_TYPE  (s_wire),
        .J_TYPE  (j_wire),
        .B_TYPE  (b_wire)
    );

//----------------------------PHASE 3--------------------------------------------

    BRANCH_COND_GEN branch_cd (
        .RS1(dc_ex.r_out1),
        .RS2(dc_ex.r_out2),
        .INSTR(dc_ex.instr),
        .pcSource(pcSource)
    );

    BRANCH_ADDR_GEN branch_ad (
        .J_TYPE(dc_ex.J),
        .B_TYPE(dc_ex.B),
        .I_TYPE(dc_ex.I),
        .PC(dc_ex.pcOut),
        .RS1(dc_ex.r_out1),
        .JAL(jalWire),
        .BRANCH(branchWire),
        .JALR(jalrWire)
    );

    mux_2bit_sel alu_srcA_mux (
        .A (dc_ex.r_out1),
        .B (dc_ex.U),
        .C (0),
        .D (0),
        .sel(dc_ex.alu_srcA),
        .O (alu_inA)
    );

    mux_2bit_sel alu_srcB_mux (
        .A (dc_ex.r_out2),
        .B (dc_ex.I),
        .C (dc_ex.S),
        .D (dc_ex.pcOut),
        .sel(dc_ex.alu_srcB),
        .O (alu_inB)
    );

    ALU ALU (
        .srcA(alu_inA),
        .srcB(alu_inB),
        .ALU_FUN(dc_ex.alu_fun),
        .RESULT(aluOut_wire)
    );

//----------------------------PHASE 4--------------------------------------------

//----------------------------PHASE 5------------------------------------

    mux_2bit_sel reg_file_mux (
        .A (wb.nextPcOut),
        .B (0),
        .C (wb.d_out2),
        .D (wb.aluOut),
        .sel (wb.rf_wr_sel),
        .O (rf_wd_w)
    );
    
    endmodule
