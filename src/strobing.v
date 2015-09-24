
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:43:06 06/10/2015 
// Design Name: 
// Module Name:    Strobing 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Strobing(switch, btn, clk, led, cat, an);

	input [3:0] switch;
	input [3:0] btn;
	input clk;

	output [3:0] led;
	output [6:0] cat;
	output [3:0] an;
	
	reg [3:0] led;
	reg [6:0] cat;
	reg [3:0] an;

	reg [3:0] dig;
	reg slow_clock;
	integer count;
	integer current_val, v1, v2, v3, v4;
	
	always @(posedge clk)
		create_slow_clock(clk, slow_clock);

	always @(posedge slow_clock)
	begin
		case(an)
			14: an = 7;
			13: an = 14;
			11: an = 13;
			7:	an = 11;
			15:	an = 7;
			default: an = 15;
		endcase
		dig=0;
		case(an)
			14: dig = v4;
			13: dig = v3;
			11: dig = v2;
			7:	dig = v1;
		endcase
		cat = cat_val(dig);
	end

	always @(switch)
	begin
		led = switch;
		current_val = switch;
	end

	always @(btn)
	begin
		case(btn)
			8: v1 = current_val;
			4: v2 = current_val;
			2: v3 = current_val;
			1: v4 = current_val;
		endcase
	end

	function [6:0] cat_val;
		input [3:0] dig;
		begin
			case(dig)
				0: cat_val=64;
				1: cat_val=121;
				2: cat_val=36;
				3: cat_val=48;
				4: cat_val=25;
				5: cat_val=18;
				6: cat_val=2;
				7: cat_val=120;
				8: cat_val=0;
				9: cat_val=24;
			   10: cat_val=8;
			   11: cat_val=3;
			   12: cat_val=70;
			   13: cat_val=33;
			   14: cat_val=6;
			   15: cat_val=14;
				default: cat_val=127;
			endcase
		end
	endfunction

	task create_slow_clock;
		input clock;
		inout slow_clock;
		integer count;
		
		begin
			if (count > 25000)
			begin
				count=0;
				slow_clock = ~slow_clock;
			end
			count = count+1;
		end
	endtask

endmodule