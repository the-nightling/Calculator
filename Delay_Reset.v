module Delay_Reset(
 input      Clk, 
 input      Button,
 output reg Reset
);
//------------------------------------------------------------------------------

reg [22:0]Count; // Assume Count is null on FPGA configuration
//------------------------------------------------------------------------------

always @(posedge Clk) begin
 if(Button) begin
  Count <= 0;
  Reset <= 1'b1;

 end else if(~&Count) begin 
  Count <= Count + 1'b1;
  Reset <= 1'b1;

 end else begin
  Reset <= 1'b0;
 end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------
