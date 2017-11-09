`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Maria Watters 
// 
// Create Date: 05/25/2017 12:10:04 AM
// Design Name: VGADriver
// Module Name: Clk25Mhz
// Project Name: Lab 5
// Description: Divides system clock to the pixel clock using a synchronous counter
// Revision:
// Revision 1.01 - Clock Divider written
//////////////////////////////////////////////////////////////////////////////////
module Clk10Khz(
    input CLKIN, ACLR_L,
    output wire CLKOUT
    );
    wire aclr_i;
    reg q1_i, q2_i, q3_i, q4_i, q5_i, q6_i;
    assign aclr_i = ~ACLR_L;
    
    //Divides the clock by 2
    always @(posedge CLKIN or posedge aclr_i)
    begin
        if(aclr_i == 1'b1)
            q1_i <= 1'b0;
        else begin
            q1_i <= ~(q1_i);
        end      
    end
    //Divides by 4
    always @(posedge q1_i or posedge aclr_i)
    begin
        if(aclr_i == 1'b1)
            q2_i <= 1'b0;
        else begin
            q2_i <= ~(q2_i);
        end                
    end
    //Divides by 8
    always @(posedge q2_i or posedge aclr_i)
    begin
        if(aclr_i == 1'b1)
            q3_i <= 1'b0;
        else begin
            q3_i <= ~(q3_i);
        end                
    end
    //Divides by 16
    always @(posedge q3_i or posedge aclr_i)
    begin
        if(aclr_i == 1'b1)
            q4_i <= 1'b0;
        else begin
            q4_i <= ~(q4_i);
        end                
    end
    //Divides by 32
    always @(posedge q4_i or posedge aclr_i)
    begin
        if(aclr_i == 1'b1)
            q5_i <= 1'b0;
        else begin
            q5_i <= ~(q5_i);
        end                
    end
    //Divides by 64
    always @(posedge q5_i or posedge aclr_i)
    begin
        if(aclr_i == 1'b1)
            q6_i <= 1'b0;
        else begin
            q6_i <= ~(q6_i);
        end                
    end
    assign CLKOUT = q6_i; 
endmodule