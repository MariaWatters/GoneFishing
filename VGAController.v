`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Maria Watters
// 
// Create Date: 05/17/2017 03:34:35 PM
// Design Name: Video Game
// Module Name: VGAController
// Project Name: Lab 6
// Description: The functionality of the game is written in this module.
//////////////////////////////////////////////////////////////////////////////////
module VGAController(
    input CLK, ARST_L, KBSTROBE,
    input [7:0] KBCODE,
    input [9:0] HCOORD, VCOORD,
    output reg SCORE, TICK,
    output [7:0] TIMER,    
    output reg [11:0] CSEL,
    output reg [19:0] POINTS
    );
    wire arst_i;
    reg [3:0] xrate_i, vrate_i;
    reg [3:0] q0_i, q1_i, q2_i;
    reg xspeed_i, vspeed_i, timeout_i;
    reg [7:0] timer_i;
    reg [9:0] fishy1_i, fishx1_i; 
    reg [9:0] fishy2_i, fishx2_i; 
    reg [9:0] fishy3_i, fishx3_i; 
    reg [9:0] fishy4_i, fishx4_i;
    reg [9:0] xpos_i, vpos_i;
    reg [3:0] point1_i, point2_i, point3_i, point4_i;
    reg [19:0] temppoints_i;
    reg [22:0] xcounter_i, vcounter_i, fishtime1_i, fishtime2_i, fishtime3_i, fishtime4_i; 
    reg [25:0] gamecounter_i;
    //Key declaration:
    parameter [7:0] W = 8'h1D;
    parameter [7:0] A = 8'h1C;
    parameter [7:0] S = 8'h1B;
    parameter [7:0] D = 8'h23;
    //Background color declaration:
    parameter [11:0] WATER = 12'b010010011111;
    parameter [11:0] PANTS = 12'b100000000000;
    parameter [11:0] POLE = 12'b100010000100;
    parameter [11:0] DOCK = 12'b011101000010;
    parameter [11:0] SHOES = 12'b000000000000;
    parameter [11:0] SKY = 12'b110011101111;
    parameter [11:0] FACE = 12'b111111111110;
    parameter [11:0] HAIR = 12'b100101100000;
    parameter [11:0] FISH = 12'b111110000111;
    parameter [11:0] HOOK = 12'b110011001100;
    parameter [11:0] LINE = 12'b111111111111;
    parameter [11:0] SHIRT = 12'b010000001001;

    assign arst_i = ~ARST_L;   
    
    always @(posedge CLK or posedge arst_i)
    begin
    //If a key is pressed the counter is increased and the velocity is changed by one
        if(arst_i) begin
            xrate_i <= 4'sb0000;
            vrate_i  <= 4'sb0000;
            xspeed_i <= 1'b0;
            vspeed_i <= 1'b0;            
        end
        else if(KBSTROBE) begin
            case(KBCODE)
                W : begin
                vspeed_i <= 1'b1;
                vrate_i <= vrate_i - 2;              
                end
                A : begin
                xspeed_i <= 1'b0;
                xrate_i <= xrate_i - 2;              
                end
                S : begin
                vspeed_i <= 1'b0;
                vrate_i <= vrate_i + 2;                
                end
                D : begin
                xspeed_i <= 1'b1;
                xrate_i <= xrate_i + 2;               
                end
            endcase
        end
        else begin
            //Bounce if Little Guy collides with a wall
            case(xpos_i)
                159 : if(xspeed_i == 1'b1) xrate_i <= 0;
                    else; 
                6 : if(xspeed_i == 1'b0) xrate_i <= 0;
                    else;
            endcase
            case(vpos_i)
                479 : if(vspeed_i == 1'b0) vrate_i <= 0;                 
                    else;
                240 : if(vspeed_i == 1'b1) vrate_i <= 0;                    
                    else;
            endcase          
        end
    end
    //Adjust the horizontal speed of the sprite by changing the rate of the xcounter
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            xcounter_i <= 22'b0000000000000000000000;
            xpos_i <= 48;
        end
        else if(xcounter_i < 0) xcounter_i <= 0; 
        else if(xcounter_i > 2500000) begin
            //Sprite moves by a fixed amount of pixels
            case(xspeed_i)
                 1'b0:  xpos_i <= xpos_i - 1;                
                 1'b1:  xpos_i <= xpos_i + 1;
            endcase
            xcounter_i <= 0;   
        end
        else 
            xcounter_i <= xcounter_i + xrate_i;                        
    end
    //Adjust the vertical speed of the sprite by changing the rate of the vcounter
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            vcounter_i <= 22'b0000000000000000000000;
            vpos_i <= 248;
        end
        else if(vcounter_i < 0) vcounter_i <= 0;
        else if(vcounter_i > 2500000) begin
            //Sprite moves by a fixed amount of pixels
            case(vspeed_i)
                 1'b0 : vpos_i <= vpos_i + 1;
                 1'b1 : vpos_i <= vpos_i - 1;
            endcase
            vcounter_i <= 0; 
        end
        else vcounter_i <= vcounter_i + vrate_i;                                     
    end
    //This is the Internal LFSR for the randomization of the fish speeds
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) q0_i <= 15; 
        else q0_i <= q2_i;
    end
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) q1_i <= 6; 
        else q1_i <= (q0_i ^ q2_i);
    end
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) q2_i <= 15; 
        else q2_i <= q1_i;
    end    
    //Fish on 1st timer
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            fishtime1_i <= 22'b0000000000000000000000;
            fishx1_i <= 643;
        end
        //If fish 1 is caught
        else if((((xpos_i - 2) >= (fishx1_i - 8)) && ((xpos_i + 2) <= (fishx1_i + 8))) && 
                (((vpos_i + 2) <= (fishy1_i + 2)) && ((vpos_i - 2) >= (fishy1_i - 2)))) begin
            fishx1_i <= 643;
            fishtime1_i <= 0;
            point1_i <= point1_i + 5;
        end
        else if(fishtime1_i > 2500000) begin
            fishx1_i <= fishx1_i - 1;
            fishtime1_i <= 0;
        end
        else begin 
            fishtime1_i <= fishtime1_i + 5;                        
            //Randomize the vertical position of the first fish when it spawns
            case(fishx1_i)
                338 : fishy1_i <= 250 + q1_i + q2_i + q1_i;
                4 : fishx1_i <= 643;
                default: ;
            endcase
        end
    end
    //Fish on 2nd timer
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            fishtime2_i <= 22'b0000000000000000000000;
            fishx2_i <= 643;
        end
        //If fish 2 is caught
        else if((((xpos_i - 2) >= (fishx2_i - 8)) && ((xpos_i + 2) <= (fishx2_i + 8))) && 
                (((vpos_i + 2) <= (fishy2_i + 2)) && ((vpos_i - 2) >= (fishy2_i - 2)))) begin
            fishx2_i <= 643;
            fishtime2_i <= 0; 
            point2_i <= point2_i + 5;
        end        
        else if(fishtime2_i > 2500000) begin
            fishx2_i <= fishx2_i - 1;
            fishtime2_i <= 0;
        end
        else begin
            fishtime2_i <= fishtime2_i + q1_i + 1; 
            //Randomize the vertical position of the second fish when it spawns
            case(fishx2_i)
                318 : fishy2_i <= 250 + q1_i + q2_i;
                4 : fishx2_i <= 643; 
            endcase
        end    
    end
    //Fish on 3rd timer
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            fishtime3_i <= 22'b0000000000000000000000;
            fishx3_i <= 635;
        end
        //If fish 3 is caught
        else if((((xpos_i - 2) >= (fishx3_i - 8)) && ((xpos_i + 2) <= (fishx3_i + 8))) && 
                (((vpos_i + 2) <= (fishy3_i + 2)) && ((vpos_i - 2) >= (fishy3_i - 2)))) begin
            fishx3_i <= 635;
            fishtime3_i <= 0; 
            point3_i <= point3_i + 1;
        end
        else if(fishtime3_i > 2500000) begin
            fishx3_i <= fishx3_i - 1;
            fishtime3_i <= 0;
        end
        else begin
            fishtime3_i <= fishtime3_i + 5; 
            //Randomize the vertical position of the third fish when it spawns
            case(fishx3_i)
                635 : fishy3_i <= 250 + q1_i + 25;
                4 : fishx3_i <= 635; 
            endcase
        end               
    end
    
    //Fish on 4th timer
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            fishtime4_i <= 22'b0000000000000000000000;
            fishx4_i <= 643;
        end  
        //If fish 4 is caught  
        else if((((xpos_i - 2) >= (fishx4_i - 8)) && ((xpos_i + 2) <= (fishx4_i + 8))) && 
                (((vpos_i + 2) <= (fishy4_i + 2)) && ((vpos_i - 2) >= (fishy4_i - 2)))) begin
            fishx4_i <= 643;
            fishtime4_i <= 0;
            point4_i <= point4_i + 1;
        end        
        else if(fishtime4_i > 2500000) begin
            fishx4_i <= fishx4_i - 1;
            fishtime4_i <= 0;
        end
        else begin
            fishtime4_i <= fishtime4_i + 5; 
            //Randomize the vertical position of the fourth fish when it spawns  
            case(fishx4_i)
                635 : fishy4_i <= 245 + q2_i + 10;
                4 : fishx4_i <= 643;
            endcase
        end  
    end
    //Tally all the points from catching the different kinds of fish
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) temppoints_i <= 0;
        else temppoints_i <= point1_i + point2_i + point3_i + point4_i;
    end
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            SCORE <= 0;
            POINTS <= 0;
        end
        else if(POINTS != temppoints_i) begin
            SCORE <= 1;
            POINTS <= temppoints_i;
        end
        else;
    end
    //Game count down timer
    assign TIMER = timer_i;
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i) begin
            timeout_i <= 1'b1;
            timer_i <= 0;
            TICK <= 0;
            gamecounter_i <= 0;
        end
        else if(timer_i >= 60) timeout_i <= 1'b1;
        else if(gamecounter_i > 25000000) begin
            timer_i <= timer_i + 1;
            TICK <= 1;
            gamecounter_i <= 0;
        end
        else begin
            gamecounter_i <= gamecounter_i + 1;
            TICK <= 0;
            timeout_i <= 1'b0;
        end         
    end
               
    //Dictates what color should be displayed on the screen
    always @(posedge CLK or posedge arst_i)
    begin
        if(arst_i)
            CSEL <= 12'b000000000000;
        else if((HCOORD >= (fishx1_i - 8)) && (HCOORD <= (fishx1_i + 8)) && (VCOORD >= (fishy1_i - 2)) && (VCOORD <= (fishy1_i + 2)) && (timeout_i == 1'b0))
            CSEL <= FISH;   
        else if((HCOORD >= (fishx2_i - 8)) && (HCOORD <= (fishx2_i + 8)) && (VCOORD >= (fishy2_i - 2)) && (VCOORD <= (fishy2_i + 2)) && (timeout_i == 1'b0))
            CSEL <= FISH;
        else if((HCOORD >= (fishx3_i - 8)) && (HCOORD <= (fishx3_i + 8)) && (VCOORD >= (fishy3_i - 2)) && (VCOORD <= (fishy3_i + 2)) && (timeout_i == 1'b0))
            CSEL <= FISH;
        else if((HCOORD >= (fishx4_i - 8)) && (HCOORD <= (fishx4_i + 8)) && (VCOORD >= (fishy4_i - 2)) && (VCOORD <= (fishy4_i + 2)) && (timeout_i == 1'b0))
            CSEL <= FISH; 
        else if((((HCOORD > xpos_i-2) && (HCOORD < xpos_i+2) && (VCOORD > vpos_i) && (VCOORD < vpos_i+2)) || 
            ((HCOORD > xpos_i-2) && (HCOORD < xpos_i) && (VCOORD > vpos_i-2) && (VCOORD < vpos_i+2))) && (timeout_i == 1'b0))
            CSEL <= HOOK;
        else if((((HCOORD >= 36) && (HCOORD <= 40) && (VCOORD >= 205) && (VCOORD <= 207)) || 
            ((HCOORD >= 32) && (HCOORD <= 36) && (VCOORD >= 205) && (VCOORD <= 213)) ||
            ((HCOORD >= 30) && (HCOORD <= 32) && (VCOORD >= 207) && (VCOORD <= 211))) && (timeout_i == 1'b0))
            CSEL <= HAIR;
        else if((HCOORD >= 37) && (HCOORD <= 40) && (VCOORD >= 208) && (VCOORD <= 212) && (timeout_i == 1'b0))
            CSEL <= FACE;
        else if((((HCOORD >= 34) && (HCOORD <= 38) && (VCOORD >= 213) && (VCOORD <= 222)) || 
            ((HCOORD >= 38) && (HCOORD <= 40) && (VCOORD >= 216) && (VCOORD <= 218))) && (timeout_i == 1'b0))
            CSEL <= SHIRT;
        else if((HCOORD >= 34) && (HCOORD <= 38) && (VCOORD >= 223) && (VCOORD <= 232) && (timeout_i == 1'b0))
            CSEL <= PANTS;
        else if((HCOORD >= 34) && (HCOORD <= 40) && (VCOORD >= 233) && (VCOORD <= 234)  && (timeout_i == 1'b0)) 
            CSEL <= SHOES;   
        else if((((HCOORD == 38) && (VCOORD == 218)) || ((HCOORD == 40) && (VCOORD == 217)) || ((HCOORD == 41) && (VCOORD == 216)) 
            || ((HCOORD == 42) && (VCOORD == 215)) || ((HCOORD == 43) && (VCOORD == 214)) || ((HCOORD == 44) && (VCOORD == 213)) 
            || ((HCOORD == 45) && (VCOORD == 212)) || ((HCOORD == 46) && (VCOORD == 211)) || ((HCOORD == 47) && (VCOORD == 210))
            || ((HCOORD == 48) && (VCOORD == 209)) || ((HCOORD == 49) && (VCOORD == 208))) && (timeout_i == 1'b0))            
            CSEL <= POLE;
        else if(((HCOORD >= 0) && (HCOORD <= 40) && (VCOORD >= 232) && (VCOORD <= 248)) || 
            ((HCOORD >= 28) && (HCOORD <= 32) && (VCOORD >= 232) && (VCOORD <= 479))) 
            CSEL <= DOCK;
        else if(VCOORD < 240)
            CSEL <= SKY;
        else if(VCOORD >= 240)
            CSEL <= WATER;
        else
            CSEL <= 12'b000000000000;
    end         
endmodule