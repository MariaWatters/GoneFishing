`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Maria Watters 
// 
// Create Date: 05/17/2017 03:10:11 PM
// Design Name: Video Game
// Module Name: EksBox
// Project Name: Lab 6
// Description: This is the top level module for my game design.
// Revision: Creation of Module
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////
module EksBox(
    input CLK, ARST_L, SCLK, SDATA,
    output HSYNC, VSYNC,
    output [3:0] RED, GREEN, BLUE,
    output [6:0] SEGS_L,
    output [7:0] SEGEN_L
    );
    wire [19:0] points_i;
    wire [11:0] csel_i;
    wire [9:0] hcoord_i, vcoord_i;
    wire [7:0] kbcode_i, timer_i;
    wire [3:0] kbcode0_i, kbcode1_i, timerout0_i, timerout1_i, points0_i, points1_i;
    wire [3:0] points2_i, points3_i, points4_i, ground_i;
    wire ground2_i;
    wire sync21_i, sync22_i, clkout_i, segclk_i, keyup_i, swdb_i, strobe1_i, strobe2_i, score_i, tick_i;
    
    assign kbcode_i = {kbcode1_i,kbcode0_i};
    assign ground_i = 1'b0;
    assign ground2_i =1'b0;
    
    Sync2 U1( .SYNC(sync21_i), .CLK(CLK), .ASYNC(SCLK), .ACLR_L(ARST_L) );
    
    Sync2 U2( .SYNC(sync22_i), .CLK(CLK), .ASYNC(SDATA), .ACLR_L(ARST_L) );
    
    Clk25Mhz U3( .CLKOUT(clkout_i), .CLKIN(CLK), .ACLR_L(ARST_L) );  
      
    KBDecoder U4( .HEX1(kbcode1_i), .HEX0(kbcode0_i), .KEYUP(keyup_i), 
            .CLK(sync21_i), .SDATA(sync22_i), .ARST_L(ARST_L) );
            
    SwitchDB U5( .SWDB(swdb_i), .SW(keyup_i), .CLK(clkout_i), .ACLR_L(ARST_L) );
    
    VGAController U6( .TIMER(timer_i), .POINTS(points_i), .TICK(tick_i), .SCORE(score_i),
            .CSEL(csel_i), .CLK(clkout_i), .KBCODE(kbcode_i), .HCOORD(hcoord_i), 
            .VCOORD(vcoord_i), .KBSTROBE(swdb_i), .ARST_L(ARST_L) );
            
    VGAEncoder U7( .HSYNC(HSYNC), .VSYNC(VSYNC), .RED(RED), .GREEN(GREEN), 
            .BLUE(BLUE), .HCOORD(hcoord_i), .VCOORD(vcoord_i), .CLK(clkout_i), 
            .CSEL(csel_i), .ARST_L(ARST_L) );
            
    BCDto7Seg U8( .TIMEROUT0(timerout0_i), .TIMEROUT1(timerout1_i), .POINT0(points0_i), 
            .POINT1(points1_i), .POINT2(points2_i), .POINT3(points3_i), .POINT4(points4_i), 
            .TIMER(timer_i), .POINTS(points_i), .CLK(clkout_i), .ARST_L(ARST_L) ); 
    
    Clk10Khz U9( .CLKOUT(segclk_i), .CLKIN(clkout_i), .ACLR_L(ARST_L) );
    
    Sync2 U10( .SYNC(strobe1_i), .CLK(segclk_i), .ASYNC(tick_i), .ACLR_L(ARST_L) );
    
    Sync2 U11( .SYNC(strobe2_i), .CLK(segclk_i), .ASYNC(score_i), .ACLR_L(ARST_L) );
    
    SevenSeg U12( .SEGS_L(SEGS_L), .SEGEN_L(SEGEN_L), .DP(ground2_i), .CLK(segclk_i), 
            .ARST_L(ARST_L), .HEXIN0(points0_i), .HEXIN1(points1_i), .HEXIN2(points2_i), 
            .HEXIN3(points3_i), .HEXIN4(points4_i), .HEXIN5(ground_i), .HEXIN6(timerout0_i), 
            .HEXIN7(timerout1_i), .TICK(strobe1_i), .SCORE(strobe2_i) );
    
endmodule