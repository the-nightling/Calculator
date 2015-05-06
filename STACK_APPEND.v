module STACK_APPEND(
	input Clk,
	input[3:0] digit,
	input[31:0] prev_stack,
	output[31:0] new_stack
);

always@(posedge Clk)begin
	new_stack = {pre_stack[27:0],digit};
end

endmodule
