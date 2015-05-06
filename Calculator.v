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
reg [2:0]line;				// determines line position on VGA
reg [2:0] stack_line;
reg [7:0]glyph;			// determines character displayed on VGA
reg[31:0]stack[7:0];		// stack (32bits wide, 8addresses high)
reg[2:0]top; 				// stack pointer
reg display_results;		// flag used to indicate when to display arithmetic results from stack
reg[3:0] digit;
reg[1:0] count;

Delay_Reset Delay_Reset1(CLK_25M, ~Reset_Button, Reset);
Process_Keyboard Process_Keyboard1(Key_Clk, Key_Data, ext, Output_Data, key_pressed);
SS_Driver SS_Driver1(CLK_25M, Reset,Fourth_Char, Third_Char, Second_Char, First_Char,SS_Drivers,SS_Segments);
VGA_PLL VGA_PLL1(CLK_100M, CLK_25M, LOCKED);

VGA_Text VGA_Text1(
 ~LOCKED,
 CLK_25M,      // The interface clock
 CLK_25M, 		// The pixel clock (25.152 MHz for 640 x 480 x 60 Hz)

 {2'd0, line},			//input [ 4:0]Line,
 character,		//input [ 6:0]Character,
 glyph,	//input [ 7:0]Glyph,      // Glyph index
 12'h0FF,	//input [11:0]Foreground, // RGB, 4-bit each
 12'h000,	//input [11:0]Background, // RGB, 4-bit each
 1'b1,			//input  Latch,

 Red,
 Green,
 Blue,
 H_Sync,
 V_Sync
);


always @(posedge CLK_25M) begin
if(~LOCKED) begin
 stack[0] <= 32'h12345678;
 stack[1] <= 32'hABCDEF90;
 stack[2] <= 0;
 stack[3] <= 0;
 stack[4] <= 0;
 stack[5] <= 0;
 stack[6] <= 0;
 stack[7] <= 0;

end else begin
	// output keyboard hex onto SS displays
	First_Char  <= Output_Data[3:0];
	Second_Char <= Output_Data[7:4];
	Third_Char  <= {3'b0,ext};				// indicates whether extended key was pressed
	Fourth_Char <= {3'b0,key_pressed};	// indicates whether a key is being pressed
	
	// on positive edge of a key press,
	/*
	stack[0] = {4'h1,4'h1,4'h1,4'h1,4'h1,4'h1,4'h1,4'h1};
	stack[1] = {4'h2,4'h2,4'h2,4'h2,4'h2,4'h2,4'h2,4'h2};
	stack[2] = {4'h3,4'h3,4'h3,4'h3,4'h3,4'h3,4'h3,4'h3};
	stack[3] = {4'h4,4'h4,4'h4,4'h4,4'h4,4'h4,4'h4,4'h4};
	stack[4] = {4'h5,4'h5,4'h5,4'h5,4'h5,4'h5,4'h5,4'h5};
	stack[5] = {4'h6,4'h6,4'h6,4'h6,4'h6,4'h6,4'h6,4'h6};
	stack[6] = {4'h7,4'h7,4'h7,4'h7,4'h7,4'h7,4'h7,4'h7};
	stack[7] = {4'h8,4'h8,4'h8,4'h8,4'h8,4'h8,4'h8,4'h8};
	//*/
	//*

	if({prev_key_pressed, key_pressed} == 2'b01) begin
		//*
		case({ext, Output_Data})
		 9'h016: stack[top] <= {stack[top][27:0],4'h1};
		 9'h01E: stack[top] <= {stack[top][27:0],4'h2};
		 9'h026: stack[top] <= {stack[top][27:0],4'h3};
		 9'h025: stack[top] <= {stack[top][27:0],4'h4};
		 9'h02E: stack[top] <= {stack[top][27:0],4'h5};
		 9'h036: stack[top] <= {stack[top][27:0],4'h6};
		 9'h03D: stack[top] <= {stack[top][27:0],4'h7};
		 9'h03E: stack[top] <= {stack[top][27:0],4'h8};
		 9'h046: stack[top] <= {stack[top][27:0],4'h9};
		 9'h045: stack[top] <= {stack[top][27:0],4'h0};
		 9'h01C: stack[top] <= {stack[top][27:0],4'hA};
		 9'h032: stack[top] <= {stack[top][27:0],4'hB};
		 9'h021: stack[top] <= {stack[top][27:0],4'hC};
		 9'h023: stack[top] <= {stack[top][27:0],4'hD};
		 9'h024: stack[top] <= {stack[top][27:0],4'hE};
		 9'h02B: stack[top] <= {stack[top][27:0],4'hF};
		 9'h055: begin // +
			stack[top-1'b1] <= stack[top-1'b1] + stack[top];
			stack[top] <= 0;
			top <= top - 1'b1;
		 end
		 9'h04E: begin // -
			stack[top-1'b1] <= stack[top-1'b1] - stack[top];
			stack[top] <= 0;
			top <= top - 1'b1;
		 end
		 9'h07C: begin // *
			stack[top-1'b1] <= stack[top-1'b1] * stack[top];
			stack[top] <= 0;
			top <= top - 1'b1;
		 end
		 9'h05A: begin	// enter
			top <= top + 1'b1;
		 end
		 default:;
		endcase
	end
	//*/
	
	if(character == 7'd7) character <= 7'd0;
	else                  character <= character + 1'b1;
	
	if(character == 7'd7) begin
		if(stack[stack_line+1'b1][31:28] > 32'h9) glyph <= stack[stack_line+1'b1][31:28]+8'h37;
		else glyph <= 8'h30+stack[stack_line+1'b1][31:28]; 
		line       <= line      +1'b1;
		stack_line <= stack_line+1'b1;
	end else if(character == 7'd0) begin
		if(stack[stack_line][27:24] > 32'h9) glyph <= stack[stack_line][27:24]+8'h37;
		else glyph <= 8'h30+stack[stack_line][27:24]; 
	end else if(character == 7'd1) begin
		if(stack[stack_line][23:20] > 32'h9) glyph <= stack[stack_line][23:20]+8'h37;
		else glyph <= 8'h30+stack[stack_line][23:20]; 
	end else if(character == 7'd2) begin
		if(stack[stack_line][19:16] > 32'h9) glyph <= stack[stack_line][19:16]+8'h37;
		else glyph <= 8'h30+stack[stack_line][19:16]; 
	end else if(character == 7'd3) begin
		if(stack[stack_line][15:12] > 32'h9) glyph <= stack[stack_line][15:12]+8'h37;
		else glyph <= 8'h30+stack[stack_line][15:12]; 
	end else if(character == 7'd4) begin
		if(stack[stack_line][11:8] > 32'h9) glyph <= stack[stack_line][11:8]+8'h37;
		else glyph <= 8'h30+stack[stack_line][11:8]; 
	end else if(character == 7'd5) begin
		if(stack[stack_line][7:4] > 32'h9) glyph <= stack[stack_line][7:4]+8'h37;
		else glyph <= 8'h30+stack[stack_line][7:4]; 
	end else if(character == 7'd6) begin
		if(stack[stack_line][3:0] > 32'h9) glyph <= stack[stack_line][3:0]+8'h37;
		else glyph <= 8'h30+stack[stack_line][3:0]; 
	end
	
	

//	if(character == 7'd8) begin
//		line = line+1'b1;
//		stack_line = stack_line+1'b1;
//		character = 7'b1111111;
//	end
	
//	if(stack_line == 4'd8) begin
//		stack_line = 0;
//		line = 0;
//	end
	
	// store previous key pressed state to check for positive edge
end
	prev_key_pressed <= key_pressed;
	
end

endmodule
