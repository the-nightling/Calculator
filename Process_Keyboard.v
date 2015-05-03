module Process_Keyboard(
	input Key_Clk, Data_in,
	output reg ext,
	output reg [7:0]Data_out,
	output reg key_pressed
);

reg [3:0] count;		// used to determine current negative edge
reg [10:0] data;		// stores hex of key pressed
reg [7:0] prev_data;	// stores hex of previous key pressed

always @(negedge Key_Clk) begin	// only read on negative edge
	data[count] = Data_in;			// read a bit
	count = count + 1'b1;
	
	if(count == 4'd9) begin			// if first 9 bits read,
		Data_out = data[8:1];		// discard start bit and output data
		
		// check for extended key press
		if(Data_out == 8'he0 || prev_data == 8'he0) ext = 1'b1;
		else ext = 1'b0;
		
		// check for key release
		if(Data_out == 8'hf0 || prev_data == 8'hf0) key_pressed = 1'b0;
		else key_pressed = 1'b1;
		
		// store previous key press to check for key release
		prev_data = Data_out;
		
	// reset count when all negative edges for a character have been read
	end else if(count == 4'd11) begin
		count = 1'b0;
	end
end

endmodule
