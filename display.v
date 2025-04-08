`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2022 09:17:05 PM
// Design Name: 
// Module Name: display
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


module display(
    input clr,
    input clk,
    input wire [3:0] dig1,
    input wire [3:0] dig2,
    input wire [3:0] dig3,
    input wire [3:0] dig4,
    output wire [3:0] AN,
    output wire [6:0] CA
    );
    
    wire en;
    wire [1:0] S;
    reg [3:0] X;
    
    clockConverter clk_en (.clk(clk), .reset(clr), .en(en));
    anode_driver ad (.clk(clk), .en(en), .reset(clr), .AN(AN), .S(S));
    
    always @ (dig1 or dig2 or dig3 or dig4 or S) begin
        case (S)
        2'b00 : X <= dig1;
        2'b01 : X <= dig2;
        2'b10 : X <= dig3;
        2'b11 : X <= dig4;
        endcase
    end
    hex2sevseg dec (.x(X), .ca(CA));
endmodule


module hex2sevseg(
   input wire [3:0] x,
    output reg [6:0] ca

    );
      always @ (x)
    case (x)
        4'h0 : ca = 7'b0000001;
        4'h1 : ca = 7'b1001111;
        4'h2 : ca = 7'b0010010;
        4'h3 : ca = 7'b0000110;
        4'h4 : ca = 7'b1001100;
        4'h5 : ca = 7'b0100100;
        4'h6 : ca = 7'b0100000;
        4'h7 : ca = 7'b0001111;
        4'h8 : ca = 7'b0000000;
        4'h9 : ca = 7'b0000100;
        4'hA : ca = 7'b0001000;
        4'hB : ca = 7'b1100000;
        4'hC : ca = 7'b0110001;
        4'hD : ca = 7'b1000010;
        4'hE : ca = 7'b0110000;
        4'hF : ca = 7'b0111000;        
    endcase
endmodule

  


module clockConverter(
    input clk,
    input reset,
    output reg en
    );
    integer count = 0;
    always @(posedge clk or posedge reset)
    if (reset == 1)
        count <= 0;
    else if(count == 99999999) begin
		count <= 0;
		en <= 1;
	end else begin
		count <= count + 1;
		en <= 0;
	end
endmodule

module anode_driver(
    input clk,
    input en,
    input reset,
    output reg [3:0] AN,
    output reg [1:0] S
    );
    
    integer q = 0;
    always@ (posedge en)
    begin
        if(q == 3)
        begin
            q <= 0;
        end
        else
            q <= q + 1;
        end
     
     always@(q or reset)
     begin
        if(reset == 1)
            begin
                AN = 4'b1110;
                S = 2'b00;
            end
        else
        begin
        case(q)
        0: begin
            AN = 4'b1110;
            S = 2'b00;
            end
        1 : begin
            AN = 4'b1101;
            S = 2'b01;
            end
        2 : begin
            AN = 4'b1011;
            S = 2'b10;
            end
        3 : begin
        AN = 4'b0111;
        S = 2'b11;
        end
        endcase
        end
        end
            
        
    
endmodule
