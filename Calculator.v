  module Calculator(
  input CLK_100M, Reset_Button,
  input Key_Clk,
  input Key_Data,
  
 output [3:0]SS_Drivers,
 output [7:0]SS_Segments,
 output [3:0]Red,
 output [3:0]Green,
 output [3:0]Blue,
 output H_Sync,
 output V_Sync
);

//clock, seven segment, ppl and reset connections.
wire CLK_25M;
wire LOCKED;
wire Reset;

//keyboard interface connections.
reg [3:0]First_Char;		// for SS display
reg [3:0]Second_Char;	// for SS display
reg [3:0]Third_Char;		// for SS display
reg [3:0]Fourth_Char;	// for SS display
wire [7:0] Output_Data;	// stores keyboard hex output
wire key_pressed;			// check keyboard press
reg prev_key_pressed;	// check previous state of keyboard press (for edge triggering)
wire ext;					// check extended key press
reg [6:0]character;		// determines character position on VGA
reg [4:0]line;				// determines line position on VGA
reg [7:0]glyph;			// determines character displayed on VGA
reg[31:0]stack[7:0];		// stack (32bits wide, 8addresses high)
reg[2:0]top; 				// stack pointer
reg display_results;		// flag used to indicate when to display arithmetic results from stack

Delay_Reset Delay_Reset1(CLK_25M, ~Reset_Button, Reset);
Process_Keyboard Process_Keyboard1(Key_Clk, Key_Data, ext, Output_Data, key_pressed);
SS_Driver SS_Driver1(CLK_25M, Reset,Fourth_Char, Third_Char, Second_Char, First_Char,SS_Drivers,SS_Segments);
VGA_PLL VGA_PLL1(CLK_100M, CLK_25M, LOCKED);

VGA_Text VGA_Text1(
 ~LOCKED,
 CLK_25M,      // The interface clock
 CLK_25M, 		// The pixel clock (25.152 MHz for 640 x 480 x 60 Hz)

 line,			//input [ 4:0]Line,
 character,		//input [ 6:0]Character,
 glyph,	//input [ 7:0]Glyph,      // Glyph index
 12'h0000F0,	//input [11:0]Foreground, // RGB, 4-bit each
 12'h000000,	//input [11:0]Background, // RGB, 4-bit each
 1'b1,			//input  Latch,

 Red,
 Green,
 Blue,
 H_Sync,
 V_Sync
);


always @(posedge CLK_25M) begin
	// output keyboard hex onto SS displays
	First_Char = Output_Data[3:0];
	Second_Char = Output_Data[7:4];
	Third_Char = {3'b0,ext};				// indicates whether extended key was pressed
	Fourth_Char = {3'b0,key_pressed};	// indicates whether a key is being pressed
	
	// on positive edge of a key press,
	if({prev_key_pressed, key_pressed} == 2'b01) begin
	
		if(Output_Data == 8'h16) begin	// number 1 pressed
			glyph = 8'h30+8'd1;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h1e) begin	// number 2 pressed
			glyph = 8'h30+8'd2;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h26) begin	// number 3 pressed
			glyph = 8'h30+8'd3;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h25) begin	// number 4 pressed
			glyph = 8'h30+8'd4;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h2e) begin	// number 5 pressed
			glyph = 8'h30+8'd5;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h36) begin	// number 6 pressed
			glyph = 8'h30+8'd6;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h3d) begin	// number 7 pressed
			glyph = 8'h30+8'd7;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h3e) begin	// number 8 pressed
			glyph = 8'h30+8'd8;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h46) begin	// number 9 pressed
			glyph = 8'h30+8'd9;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h45) begin	// number 0 pressed
			glyph = 8'h30+8'd0;
			stack[top] = {stack[top][23:0],glyph-8'h30};
			character = character+1;
		end else if(Output_Data == 8'h55) begin	// + pressed
			line = line+1;
			character = 0;
			stack[top-1'b1] = stack[top-1'b1] + stack[top];
			top = top - 1'b1;
			//display_results = 1'b1;
			glyph = 8'h30+stack[top][31:24];
			character = character+1;
			glyph = 8'h30+stack[top][23:16];
			character = character+1;
			glyph = 8'h30+stack[top][15:8];
			character = character+1;
			glyph = 8'h30+stack[top][7:0];
		end
		else if(ext == 1'b0 && Output_Data == 8'h66) character = character-1;	// backspace pressed
		else if(ext == 1'b0 && Output_Data == 8'h5a)begin		// enter pressed
			glyph = 8'd0;
			line = line+1'b1;
			character = 0;
			top = top + 1'b1;
		end
		else glyph = 8'h30+8'd47;		// other key pressed (set to underscore)
		
		// if end of line reached, move to next line
		if(character == 7'b0111111) begin
			line = line+1;
			character = 0;
		end
		
		/*
		if(display_results == 1'b1) begin
			if(character == 7'd0) begin
				glyph = stack[top][31:24];
				character = character+1;
			end else if(character == 7'd1) begin
				glyph = stack[top][23:16];
				character = character+1;
			end else if(character == 7'd2) begin
				glyph = stack[top][15:8];
				character = character+1;
			end else if(character == 7'd3) begin
				glyph = stack[top][7:0];
				character = 0;
				line = line + 1'b1;
				display_results = 1'b0;
			end
		end
		//*/
	end
	// store previous key pressed state to check for positive edge
	prev_key_pressed = key_pressed;
	
end

endmodule
