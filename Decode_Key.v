module Decode_Key(
	input Clk,
	input[7:0] key,
	output reg[7:0] number
    );

always @(posedge Clk) begin
	if(key == 8'h45) number = 8'd0;
	else if(key == 8'h16) number = 8'd1;
	else if(key == 8'h1e) number = 8'd2;
	else if(key == 8'h26) number = 8'd3;
	else if(key == 8'h25) number = 8'd4;
	else if(key == 8'h2e) number = 8'd5;
	else if(key == 8'h36) number = 8'd6;
	else if(key == 8'h3d) number = 8'd7;
	else if(key == 8'h3e) number = 8'd8;
	else if(key == 8'h46) number = 8'd9;
	else number = 8'd47;
end

endmodule
