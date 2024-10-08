//===========================================================================
// Verilog file generated by Clarity Designer    10/02/2024    19:39:36  
// Filename  : tx_dphy_synchronizer.v                                                
// IP package: CSI-2/DSI D-PHY Transmitter 1.4                           
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================
  
module tx_dphy_synchronizer 
(
input  wire clk,
input  wire rstn,
input  wire in,
output wire out
);

reg [1:0] sync_ff_r;

assign out = sync_ff_r[1];

always @(posedge clk or negedge rstn) begin
  if (rstn == 1'd0) begin
    sync_ff_r     <= 0;
  end
  else begin
    sync_ff_r[0]  <= in;
    sync_ff_r[1]  <= sync_ff_r[0];
  end
end

endmodule


