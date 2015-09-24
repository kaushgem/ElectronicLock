`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// School: University at Buffalo
// Student: Kaushik
// 
// Create Date:    20:32:15 06/18/2015 
// Design Name: 
// Module Name:    Lock 
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

module Lock(switch, btn, lock, latch, clk, led, cat, an);

	input [3:0] switch;
	input [3:0] btn;
	input lock;
	input latch;
	input clk;

	output [7:0] led;
	output [6:0] cat;
	output [3:0] an;
	
	reg [7:0] led;
	reg [6:0] cat;
	reg [3:0] an;

	integer count;
	integer attempts = 0;
	integer pause_count = 0;
	integer blink_count = 0;
	integer timeout_count = 0;
	reg slow_clock;
	reg [4:0] dig;
	reg [4:0] v3, v2, v1, v0;
	reg [20:0] unlock_code = 20'b00011000100100000011; //'3283
	reg [20:0] code;
	reg lock_flag = 0;
	reg latch_flag = 0;
	reg pause_flag = 1;
	reg blink = 0;
	reg btn_first_press = 0;
	reg timeout_flag = 0;
	
	always @(posedge clk)
		create_slow_clock(clk, slow_clock);
	
	always @(posedge slow_clock)
	begin
		// Strobing Anode
		case(an)
			14: an = 7;
			13: an = 14;
			11: an = 13;
			7:  an = 11;
			15: an = 7;
			default: an = 14;
		endcase
		
		// 30 seconds timeout
		if(timeout_flag == 1)
		begin
			timeout_count = timeout_count + 1;
			if(timeout_count > 30000)
			begin
				timeout_flag = 0;
				btn_first_press = 0;
				timeout_count = 0;
				// LOC
				v3 = 16;
				v2 = 23;
				v1 = 24;
				v0 = 25;
			end
		end
		
		// PAUSE after 2 wrong attempts
		if(pause_count != 0)
		begin
			// PAUS for 20 seconds
			pause_count = pause_count - 1;
			pause_flag = 1;
			led = 0;
		end
		else
		begin
			// After 20 second PAUSE
			if(pause_flag == 1)
			begin
				// Reset PAUS
				pause_flag = 0;
				// Reset TIMEOUT
				timeout_flag = 0;
				btn_first_press = 0;
				timeout_count = 0;
				// LOC
				v3 = 16;
				v2 = 23;
				v1 = 24;
				v0 = 25;
			end
			
			// LED blink during Unlock
			if(blink == 1)
			begin
				if(blink_count != 0)
				begin
					blink_count = blink_count - 1;
				end
				else
				begin
					if(led != 0)
					begin
						led = 8'b11111111;		//'Led ON
					end
					led = ~led;
					blink_count = 500;
				end
			end
			else
			begin
				led = switch;
				led[4] = latch;
				led[5] = lock;
			end

			// Getting values from switch
			case(btn)
				8: v0 = switch;
				4: v1 = switch;
				2: v2 = switch;
				1: v3 = switch;
			endcase
			// Start time for 30 seconds timeout (Flag set)
			if(btn !=0 && btn_first_press == 0)
			begin
				timeout_flag = 1;
				btn_first_press = 1;
			end
			
			// Lock switch
			if(lock == 1)
			begin
				lock_flag = 1;
				blink = 0;
			end
			else if(lock == 0 && lock_flag == 1)
			begin
				lock_flag = 0;
				attempts = 0;
				// LOC
				v3 = 16;
				v2 = 23;
				v1 = 24;
				v0 = 25;
				// Reset timeout flag
				timeout_flag = 0;
				btn_first_press = 0;
				timeout_count = 0;
			end
			
			// Latch switch
			if(latch == 1)
			begin
				latch_flag = 1;
				blink = 0;
			end
			else if(latch == 0 && latch_flag == 1)
			begin
				latch_flag = 0;
				// Check code
				code = {v3, v2, v1, v0};
				if(code == unlock_code)
				begin
					// UnLC
					v3 = 21;
					v2 = 22;
					v1 = 23;
					v0 = 25;
					
					// LED Blink
					blink = 1;
					blink_count = 500;
					
					// Reset timeout flag
					timeout_flag = 0;
					btn_first_press = 0;
					timeout_count = 0;

					attempts = 0;
				end
				else
				begin
					attempts = attempts + 1;
					if(attempts == 1)				// First wrong attempt - LOC
					begin
						// LOC
						v3 = 16;
						v2 = 23;
						v1 = 24;
						v0 = 25;
					end
					else if(attempts == 2)		// Second wrong attempt - PAUS
					begin
						attempts = 0;
						pause_count = 20000;
						// PAUS
						v3 = 26;
						v2 = 27;
						v1 = 28;
						v0 = 29;
					end
				end
			end
		end
	
		// Assign values to dig from v3,v2,v1,v0 according to anode value
		case(an)
			14: dig = v3;
			13: dig = v2;
			11: dig = v1;
			7:  dig = v0;
			default: dig = 16;
		endcase
		// Cathode value assign
		cat = cat_val(dig);
	end
	
	
	// Cathode Value
	function [6:0] cat_val;
		input [4:0] dig;
		begin
			case(dig)
				0: cat_val = 64;
				1: cat_val = 121;
				2: cat_val = 36;
				3: cat_val = 48;
				4: cat_val = 25;
				5: cat_val = 18;
				6: cat_val = 2;
				7: cat_val = 120;
				8: cat_val = 0;
				9: cat_val = 16;
			   10: cat_val = 8;
			   11: cat_val = 3;
			   12: cat_val = 70;
			   13: cat_val = 33;
			   14: cat_val = 6;
			   15: cat_val = 14;
				
				// SevenSegment OFF
				16: cat_val = 127;
				
				// UnLOC
				21: cat_val = 7'b1000001;
				22: cat_val = 7'b0101011;
				23: cat_val = 7'b1000111;
				24: cat_val = 7'b1000000;
				25: cat_val = 7'b1000110;
				
				// PAUS
				26: cat_val = 7'b0001100;
				27: cat_val = 7'b0001000;
				28: cat_val = 7'b1000001;
				29: cat_val = 7'b0010010;
				
				default: cat_val = 127;
			endcase
		end
	endfunction

	// Slow clock
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
