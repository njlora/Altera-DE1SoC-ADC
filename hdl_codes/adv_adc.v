// (C) 2001-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS
// IN THIS FILE.

//  - - - - - - - - - -ADC- - - - - - - - - - - - - - -
module adv_adc (clock, reset, go, sclk, cs_n, din, dout, done, chan, reading0, reading1, 
						reading2, reading3, reading4, reading5, reading6, reading7);
input go, dout, clock, reset;

output reg done;
output reg sclk, din, cs_n;
input [2:0] chan;
output reg [11:0] reading0, reading1, reading2, reading3, reading4, reading5, reading6, reading7;

parameter T_SCLK = 8'd4;
parameter NUM_CH = 3'd7;
parameter CH_CONF = 3'd0;
//FSM state values
parameter resetState = 3'd0, waitState=3'd1, transState=3'd2, doneState=3'd3, pauseState=3'd4, initCtrlRegState=3'd5;

reg [2:0] currState, nextState;
reg [14:0] dout_shift_reg;
reg [11:0] din_shift_reg;
reg [7:0] counter;
reg [7:0] pause_counter;
reg [3:0] sclk_counter;
reg [2:0] address, next_addr;
reg error;

always @(posedge clock)
	currState <=nextState;
	
// - - - - -NextState Selection Logic - - - - - - - -
	always @(*)
	begin
		din = din_shift_reg[11];
		if (reset)
			nextState=resetState;
		case (currState)
			resetState:begin
				cs_n=1;
				done=0;
				nextState=initCtrlRegState;
			end
			initCtrlRegState:begin
				cs_n=0;
				done=0;
				if (sclk_counter==4'd15&& counter==0 && !sclk)
					nextState=waitState;
				else
					nextState=initCtrlRegState;
			end
			waitState:begin
				cs_n=1;
				done=0;
				if (go)
					nextState=transState;
				else
					nextState=waitState;
			end
			transState:begin
				cs_n=0;
				done=0;
				if (sclk_counter==4'd15&& counter==0 && !sclk)
					nextState=pauseState;
				else
					nextState=transState;
			end
			// pause state must be >= 50ns! This is the "tquiet" required between conversions
			pauseState:begin
				cs_n=1;
				done=0;
				if (pause_counter > 8'd0)
					nextState=pauseState;
				else if(address==NUM_CH[2:0])
					nextState=doneState;
				else
					nextState=transState;
			end
			doneState:begin
				cs_n=1;
				done=1;
				if (go)
					nextState=doneState;
				else
					nextState=resetState;
			end
			default:begin
				cs_n=1;
				done=0;
				nextState = resetState;
			end
		endcase
	end
// - - - - - - - - - pause counter logic - - - - - - - - - - 
	always @(posedge clock)
	if (currState == pauseState)
		pause_counter <= pause_counter - 8'd1;
	else 
		pause_counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
// - - - - - - - - - counter logic - - - - - - - - - - 
	always @(posedge clock or posedge reset)
	if (reset)
		counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
	else if (cs_n)
		counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
	else if (counter == 0)
		counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
	else
		counter <= counter - 8'b1;
// - - - - - - - - ADC_SCLK generation - - - - - - - - - 
	always @(posedge clock or posedge reset)
	if (reset)
		sclk <= 1;
	else if (cs_n)
		sclk <= 1;
	else if (counter == 0)
		sclk <= ~sclk;
// - - - - - - - - - - - sclk_counter logic - - - - - - - -
	always @ (posedge clock)
		if (currState == doneState || currState == waitState || currState == resetState)
			sclk_counter <=4'b0;
		else if (counter == 0 && !sclk)
			sclk_counter <= sclk_counter + 4'b1;
// - - - - - - - - - - readings logic - - - - - - - - - -
	always @(posedge clock)
		if (sclk_counter == 4'd15 && counter == 0 && sclk)
			case (dout_shift_reg[13:11])
				3'd0: reading0 <= {dout_shift_reg[10:0],dout}; // should be {dout_shift_reg[10:0],dout}
				3'd1: reading1 <= {dout_shift_reg[10:0],dout};
				3'd2: reading2 <= {dout_shift_reg[10:0],dout};
				3'd3: reading3 <= {dout_shift_reg[10:0],dout};
				3'd4: reading4 <= {dout_shift_reg[10:0],dout};
				3'd5: reading5 <= {dout_shift_reg[10:0],dout};
				3'd6: reading6 <= {dout_shift_reg[10:0],dout};
				3'd7: reading7 <= {dout_shift_reg[10:0],dout};
			endcase
// - - - - - - - - - address logic - - - - - - - - -
	always @(posedge clock)
		if (currState == resetState)
			address <= 3'd0;
		else if (currState == pauseState && pause_counter == 8'd0)
			if (address >= NUM_CH[2:0])
				address <= 3'd0;
			else
				address <= next_addr;
// - - - - - - - - - - dout_shift_reg logic - - - - - - - - - - - - 
	always @(posedge clock)
		if (counter==0 && sclk && sclk_counter != 4'd15)
			dout_shift_reg [14:0] <= {dout_shift_reg [13:0], dout};
// - - - - - - - - - - din_shift_reg logic - - - - - - - - -
	always @(posedge clock)

		if (currState == resetState)
			//din_shift_reg <= {3'b110,NUM_CH[2:0],6'b111001};     //13'hDF9; // Ctrl reg initialize to 0xdf90. MSB is a dummy value that doesnt actually get used
			  din_shift_reg <= {3'b110,chan,6'b111001};
		else if ((currState == waitState && go) || (currState == pauseState && address != NUM_CH[2:0]))
			//din_shift_reg <= {3'b010,NUM_CH[2:0],6'b111001};     //13'h5DF9  WRITE=0,SEQ=1,DONTCARE,ADDR2,ADDR1,ADDR0,DONTCARE*6
			din_shift_reg <= {3'b010,chan,6'b111001};
		else if (counter==0 && !sclk)
			din_shift_reg <={din_shift_reg[10:0],1'b0};
// - - - - - - - - - - next_addr logic - - - - - - - - - - - -
	always @(posedge clock)
		next_addr <= address + 3'b1;

endmodule 
