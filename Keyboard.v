
//*
module Keyboard(
    input Clk, 
	 input [7:0] dataInput,
	 input key_pressed,
	 output reg [8:0] dataOutput
);

//keyboard interface connections.
//reg [8:0]data;
//reg extended;
reg [7:0] prev_dataInput;
reg [15:0] prev_curr_dataInput;
//reg key_pressed;

//keyboard protocol
always @(posedge Clk) begin
	dataOutput = {key_pressed,dataInput};
end


endmodule
//*/