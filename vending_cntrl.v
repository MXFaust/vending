`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Maryland
// Faux Engineer: Benjamin Felbinger
// 
// Create Date: 04/01/2022 07:15:05 PM
// Design Name: Vending Machine Controller 
// Module Name: vending_cntrl
// Project Name: Project 9
// Target Devices: BASYS Board
// Tool Versions: 
// Description: To create a vending machine controller capable of meeting 
// project demands
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vending_cntrl(
input clk,
input reset,
input N,
input D,
input Qtr,
input wire [2:0]  snack_select,
output reg [2:0] open,
output reg [4:0] change,
output reg [5:0] balance
);
reg state;
reg next_state;
parameter zero = 0, five = 1, ten = 2, fifteen = 3, twenty = 4, twentyfive = 5, 
thirty = 6, thirtyfive = 7;

always @(N or D or Qtr or state)
begin
    case(state)
        zero: begin
            if(Qtr) next_state = twentyfive;
            else if (D) next_state = ten;
            else if (N) next_state = five;
            else next_state = zero;
            balance = 0;
         end
        five : begin
            if(reset) next_state = zero;
            else if(Qtr) next_state = thirty;
            else if (D) next_state = fifteen;
            else if (N) next_state = ten;
            else next_state = five;
            balance = 5;
        end
        ten : begin
            if(reset) next_state = zero;
            else if(Qtr) next_state = thirtyfive;
            else if (D) next_state = twenty;
            else if (N) next_state = fifteen ;
            else next_state = ten;
            balance = 10;
        end
        fifteen : begin
            if(reset) next_state = zero;
            else if(Qtr) next_state = thirtyfive;
            else if (D) next_state = twentyfive;
            else if (N) next_state = twenty;
            else next_state = fifteen;
            balance = 15;
        end
        twenty : begin
            if(reset) next_state = zero;
            else if(Qtr) next_state = thirtyfive;
            else if (D) next_state = thirty;
            else if (N) next_state = twentyfive;
            else next_state = zero;
            balance = 20;
        end
        twentyfive : begin
            if(reset) next_state = zero;
            else if(Qtr) next_state = thirtyfive ;
            else if (D) next_state = thirtyfive ;
            else if (N) next_state = thirty ;
            else next_state = twentyfive;
            balance = 25;
        end
        thirty  : begin
            if(reset) next_state = zero;
            else if(Qtr) next_state = thirtyfive ;
            else if (D) next_state = thirtyfive ;
            else if (N) next_state = thirtyfive;
            else next_state = zero;
            balance = 30;
        end
          thirtyfive : begin
            if(reset) next_state = zero;
            else next_state = thirtyfive ;
            balance = 35;
        end
    endcase 
end
    always @(posedge clk)
    begin
    if(reset || (!Qtr && !D && !N))begin
    state <= zero;
    change = 0;
    open = 0;
    end
    else state <= next_state;
    end
    
    
    // 0 is nothing, 1 is 15 cent, 2 is 20 cent, 3 is 25 cent, 4 is 30 cent
    always @(posedge clk)
        case(snack_select)
        //No selection
        3'd0 : open = 0;
        //Selecting the 15 cent snack
        3'd1 : begin
            if(state == 15) begin
            change = 0;
            next_state = 0;
            open = 1;
            end
            else if(state == 20) begin
            change = 5;
            next_state = 0;
            open = 1;
            end
            else if(state == 25) begin
            change = 10;
            next_state = 0;
            open = 1;
            end
            else if(state == thirty) begin
            change = 15;
            next_state = 0;
            open = 1;
            end
            else if(state == thirtyfive) begin
            change = 20;
            next_state = 0;
            open = 1;
            end
            else open = 0;
        end
        //Selecting the 20 cent snack
        3'd2 : begin
            if(state == 20) begin
            change = 0;
            open = 2;
            end
            else if(state == 25) begin
            change = 5;
            open = 2;
            end
            else if(state == 30) begin
            change = 10;
            open = 2;
            end
            else if(state == 35) begin
            change = 15;
            open = 2;
            end
            else open = 0;
        end
        // Selecting the 25 cent snack
        3'd3 : begin
            if(state == 25) begin
            change = 0;
            open = 3;
            end
            else if(state == 30) begin
            change = 5;
            open = 3;
            end
            else if(state == 35) begin
            change = 10;
            open = 3;
            end
            else  open = 0;
        end
        //Selecting the 30 cent
        3'd4 : begin
            if(state == 30) begin
            change = 0; 
            open = 4;
            end
            else if(state == 35) begin
            change = 5;
            open = 4;
            end
            else open = 0;
            
        end            
        endcase    
endmodule

module vending_display(
input clr,
input clk,
input N,
input D,
input Qtr,
input wire [2:0] snack_select,
output wire [3:0] AN,
output wire [6:0] CA,
output reg [3:0] open_led
);
    reg [4:0] cost;
    wire [2:0] open;
    wire [5: 0] balance;
    wire [4 : 0] change; 
    vending_cntrl ctrl(.reset(clr), .clk(clk), .N(N), .D(D), .Qtr(Qtr), .snack_select(snack_select),
    .open(open), .change(change), .balance(balance));
    always @(snack_select) begin
    case(snack_select)
    3'b000 : cost = 5'd0;
    3'b001 : cost = 5'd15;
    3'b010 : cost = 5'd20;
    3'b011 : cost = 5'd25;
    3'b100 : cost = 5'd30;
    endcase
    end
    always @(open) begin
    case(open)
    3'd0 : open_led <= 4'b0000;
    3'd1 : open_led <= 4'b0001;
    3'd2 : open_led <= 4'b0010;
    3'd3 : open_led <= 4'b0100;
    3'd4 : open_led <= 4'b1000;
    endcase
    end
    
    // Display balance and cost selected
    
    display bal(.clr(clr), .clk(clk), .dig1(balance[5:4]), .dig2(balance[3:0]), .dig3(cost[4]),
    .dig4(cost[3:0]), .AN(AN), .CA(CA));
    
    //Display change and cost selected
    
    display cha(.clr(clr), .clk(clk), .dig1(change[4]), .dig2(change[3:0]), .dig3(cost[4]),
    .dig4(cost[3:0]), .AN(AN), .CA(CA));
    

endmodule 
