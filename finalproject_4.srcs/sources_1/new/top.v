`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2020 04:56:53 PM
// Design Name: 
// Module Name: top
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


module top(
    inout [14:0]DDR_addr,
    inout [2:0]DDR_ba,
    inout DDR_cas_n,
    inout DDR_ck_n,
    inout DDR_ck_p,
    inout DDR_cke,
    inout DDR_cs_n,
    inout [3:0]DDR_dm,
    inout [31:0]DDR_dq,
    inout [3:0]DDR_dqs_n,
    inout [3:0]DDR_dqs_p,
    inout DDR_odt,
    inout DDR_ras_n,
    inout DDR_reset_n,
    inout DDR_we_n,
    inout FIXED_IO_ddr_vrn,
    inout FIXED_IO_ddr_vrp,
    inout [53:0]FIXED_IO_mio,
    inout FIXED_IO_ps_clk,
    inout FIXED_IO_ps_porb,
    inout FIXED_IO_ps_srstb,
    output bclk,
    output heartbeat,
    output lrclk,
    output mclk,
    input miso,
    output mosi,
    output sclk,
    output sdata,
    output ss,
    input  wire CLK,                // board clock: 100 MHz on Arty/Basys3/Nexys
    input  wire RST_BTN,
    inout  wire hdmi_tx_cec,        // CE control bidirectional
    input  wire hdmi_tx_hpd,        // hot-plug detect
    inout  wire hdmi_tx_rscl,       // DDC bidirectional
    inout  wire hdmi_tx_rsda,
    output wire hdmi_tx_clk_n,      // HDMI clock differential negative
    output wire hdmi_tx_clk_p,      // HDMI clock differential positive
    output wire [2:0] hdmi_tx_n,    // Three HDMI channels differential negative
    output wire [2:0] hdmi_tx_p,     // Three HDMI channels differential positive
    output wire de,
    input wire btn1,
    input wire btn2,
    input wire btn3,
    input wire sw0,
    input wire sw1
    );
    
    
    wire HCLK;
    wire [31:0]M_AHB_0_haddr;
    wire [2:0]M_AHB_0_hburst;
    wire M_AHB_0_hmastlock;
    wire [3:0]M_AHB_0_hprot;
    wire [31:0]M_AHB_0_hrdata;
    wire M_AHB_0_hready;
    wire M_AHB_0_hresp;
    wire [2:0]M_AHB_0_hsize;
    wire [1:0]M_AHB_0_htrans;
    wire [31:0]M_AHB_0_hwdata;
    wire M_AHB_0_hwrite;
        
    
    design_1_wrapper zynq_module(
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
         .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .HCLK(HCLK),
        .M_AHB_0_haddr(M_AHB_0_haddr),
        .M_AHB_0_hburst(M_AHB_0_hburst),
        .M_AHB_0_hmastlock(M_AHB_0_hmastlock),
        .M_AHB_0_hprot(M_AHB_0_hprot),
        .M_AHB_0_hrdata(M_AHB_0_hrdata),
        .M_AHB_0_hready(M_AHB_0_hready),
        .M_AHB_0_hresp(M_AHB_0_hresp),
        .M_AHB_0_hsize(M_AHB_0_hsize),
        .M_AHB_0_htrans(M_AHB_0_htrans),
        .M_AHB_0_hwdata(M_AHB_0_hwdata),
        .M_AHB_0_hwrite(M_AHB_0_hwrite),
        .bclk(bclk),
        .heartbeat(heartbeat),
        .lrclk(lrclk),
        .mclk(mclk),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .sdata(sdata),
        .ss(ss)
        );
    
    
    HDMI_TOP HDMI_top(
    .CLK(CLK),                // board clock: 100 MHz on Arty/Basys3/Nexys
    .RST_BTN(RST_BTN),
    .hdmi_tx_cec(hdmi_tx_cec),        // CE control bidirectional
    .hdmi_tx_hpd(hdmi_tx_hpd),        // hot-plug detect
    .hdmi_tx_rscl(hdmi_tx_rscl),       // DDC bidirectional
    .hdmi_tx_rsda(hdmi_tx_rsda),
    .hdmi_tx_clk_n(hdmi_tx_clk_n),      // HDMI clock differential negative
    .hdmi_tx_clk_p(hdmi_tx_clk_p),      // HDMI clock differential positive
    .hdmi_tx_n(hdmi_tx_n),    // Three HDMI channels differential negative
    .hdmi_tx_p(hdmi_tx_p),     // Three HDMI channels differential positive
    .de(de),
    .btn1(btn1),
    .btn2(btn2),
    .btn3(btn3),
    .sw0(sw0),
    .sw1(sw1),
    .HCLK(HCLK),
    .M_AHB_0_haddr(M_AHB_0_haddr),
    .M_AHB_0_hburst(M_AHB_0_hburst),
    .M_AHB_0_hmastlock(M_AHB_0_hmastlock),
    .M_AHB_0_hprot(M_AHB_0_hprot),
    .M_AHB_0_hrdata(M_AHB_0_hrdata),
    .M_AHB_0_hready(M_AHB_0_hready),
    .M_AHB_0_hresp(M_AHB_0_hresp),
    .M_AHB_0_hsize(M_AHB_0_hsize),
    .M_AHB_0_htrans(M_AHB_0_htrans),
    .M_AHB_0_hwdata(M_AHB_0_hwdata),
    .M_AHB_0_hwrite(M_AHB_0_hwrite)
    );
endmodule
