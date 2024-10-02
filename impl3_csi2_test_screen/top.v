`include "synthesis_directives.v"

module p2m_top (
	input        								pix_clk_i,
	input        								reset_n_i,
	`ifdef MISC_ON
	output       								pll_lock_o , 
	`endif // MISC_ON
	input        								fv_i       , 
	input        								lv_i       , 
	input        								dvalid_i   , 
	input [`PIX_WIDTH * `NUM_PIX_LANE - 1:0]	pixdata_i,
	inout [`NUM_TX_LANE - 1:0] 				d_p_io   ,
	inout [`NUM_TX_LANE - 1:0] 				d_n_io   ,
	inout        								clk_p_io ,
	inout        								clk_n_io
);

//-----------------------------------------------------------------------------
// LOCAL PARAMETERS
//-----------------------------------------------------------------------------
parameter DT           = `DT;
parameter PIX_WIDTH    = `PIX_WIDTH;
parameter NUM_PIX_LANE = `NUM_PIX_LANE;
parameter NUM_PIXELS   = `NUM_PIXELS;
parameter NUM_TX_LANE  = `NUM_TX_LANE;
parameter VC		   = `VC;

wire 		byte_clk;
wire        p2b_fv_start   ;
wire        p2b_fv_end     ;
wire        p2b_lv_start   ;
wire        p2b_lv_end     ;
wire        p2b_vsync_start;
wire        p2b_vsync_end  ;
wire        p2b_hsync_start;
wire        p2b_hsync_end  ;
wire [ 5:0] p2b_data_type  ;
wire        p2b_c2d_ready  ;
wire        p2b_txfr_en    ;
wire        p2b_txfr_req   ;
wire        p2b_byte_en    ;
wire [63:0] p2b_byte_data  ;

wire        tx_pd_dphy      ;
wire [63:0] tx_byte_data    ;
wire        tx_byte_data_en ;
wire        tx_vsync_start  ;
wire        tx_hsync_start  ;
wire [ 7:0] tx_frame_max    ;
wire [ 1:0] tx_vc           ;
wire [ 5:0] tx_dt           ;
wire [15:0] tx_wc           ;
wire        tx_tinit_done   ;
wire        tx_pll_lock     ;
wire        tx_pix2byte_rstn;
wire        tx_clk_hs_en    ;
wire        tx_d_hs_en      ;
wire        tx_d_hs_rdy     ;
wire        tx_c2d_ready    ;
wire 		tx_lp_en		;
wire 		tx_sp_en		;
wire 		tx_ld_pyld		;


`ifdef NUM_PIX_LANE_1
wire [PIX_WIDTH - 1:0] pixdata0;
	 assign pixdata0 = pixdata_i[(PIX_WIDTH  ) - 1:0            ];
`elsif NUM_PIX_LANE_2
wire [PIX_WIDTH - 1:0] pixdata0;
wire [PIX_WIDTH - 1:0] pixdata1;
	 assign pixdata0 = pixdata_i[(PIX_WIDTH  ) - 1:0            ];
	 assign pixdata1 = pixdata_i[(PIX_WIDTH*2) - 1:(PIX_WIDTH  )];
`elsif NUM_PIX_LANE_4
wire [PIX_WIDTH - 1:0] pixdata0;
wire [PIX_WIDTH - 1:0] pixdata1;
wire [PIX_WIDTH - 1:0] pixdata2;
wire [PIX_WIDTH - 1:0] pixdata3;
	 assign pixdata0 = pixdata_i[(PIX_WIDTH  ) - 1:0            ];
	 assign pixdata1 = pixdata_i[(PIX_WIDTH*2) - 1:(PIX_WIDTH  )];
	 assign pixdata2 = pixdata_i[(PIX_WIDTH*3) - 1:(PIX_WIDTH*2)];
	 assign pixdata3 = pixdata_i[(PIX_WIDTH*4) - 1:(PIX_WIDTH*3)];
`elsif NUM_PIX_LANE_6
wire [PIX_WIDTH - 1:0] pixdata0;
wire [PIX_WIDTH - 1:0] pixdata1;
wire [PIX_WIDTH - 1:0] pixdata2;
wire [PIX_WIDTH - 1:0] pixdata3;
wire [PIX_WIDTH - 1:0] pixdata4;
wire [PIX_WIDTH - 1:0] pixdata5;
	 assign pixdata0 = pixdata_i[(PIX_WIDTH  ) - 1:0            ];
	 assign pixdata1 = pixdata_i[(PIX_WIDTH*2) - 1:(PIX_WIDTH  )];
	 assign pixdata2 = pixdata_i[(PIX_WIDTH*3) - 1:(PIX_WIDTH*2)];
	 assign pixdata3 = pixdata_i[(PIX_WIDTH*4) - 1:(PIX_WIDTH*3)];
	 assign pixdata4 = pixdata_i[(PIX_WIDTH*5) - 1:(PIX_WIDTH*4)];
	 assign pixdata5 = pixdata_i[(PIX_WIDTH*6) - 1:(PIX_WIDTH*5)];
`elsif NUM_PIX_LANE_8
wire [PIX_WIDTH - 1:0] pixdata0;
wire [PIX_WIDTH - 1:0] pixdata1;
wire [PIX_WIDTH - 1:0] pixdata2;
wire [PIX_WIDTH - 1:0] pixdata3;
wire [PIX_WIDTH - 1:0] pixdata4;
wire [PIX_WIDTH - 1:0] pixdata5;
wire [PIX_WIDTH - 1:0] pixdata6;
wire [PIX_WIDTH - 1:0] pixdata7;
	 assign pixdata0 = pixdata_i[(PIX_WIDTH  ) - 1:0            ];
	 assign pixdata1 = pixdata_i[(PIX_WIDTH*2) - 1:(PIX_WIDTH  )];
	 assign pixdata2 = pixdata_i[(PIX_WIDTH*3) - 1:(PIX_WIDTH*2)];
	 assign pixdata3 = pixdata_i[(PIX_WIDTH*4) - 1:(PIX_WIDTH*3)];
	 assign pixdata4 = pixdata_i[(PIX_WIDTH*5) - 1:(PIX_WIDTH*4)];
	 assign pixdata5 = pixdata_i[(PIX_WIDTH*6) - 1:(PIX_WIDTH*5)];
	 assign pixdata6 = pixdata_i[(PIX_WIDTH*7) - 1:(PIX_WIDTH*6)];
	 assign pixdata7 = pixdata_i[(PIX_WIDTH*8) - 1:(PIX_WIDTH*7)];
`elsif NUM_PIX_LANE_10
wire [PIX_WIDTH - 1:0] pixdata0;
wire [PIX_WIDTH - 1:0] pixdata1;
wire [PIX_WIDTH - 1:0] pixdata2;
wire [PIX_WIDTH - 1:0] pixdata3;
wire [PIX_WIDTH - 1:0] pixdata4;
wire [PIX_WIDTH - 1:0] pixdata5;
wire [PIX_WIDTH - 1:0] pixdata6;
wire [PIX_WIDTH - 1:0] pixdata7;
wire [PIX_WIDTH - 1:0] pixdata8;
wire [PIX_WIDTH - 1:0] pixdata9;
	 assign pixdata0 = pixdata_i[(PIX_WIDTH  ) - 1:0            ];
	 assign pixdata1 = pixdata_i[(PIX_WIDTH*2) - 1:(PIX_WIDTH  )];
	 assign pixdata2 = pixdata_i[(PIX_WIDTH*3) - 1:(PIX_WIDTH*2)];
	 assign pixdata3 = pixdata_i[(PIX_WIDTH*4) - 1:(PIX_WIDTH*3)];
	 assign pixdata4 = pixdata_i[(PIX_WIDTH*5) - 1:(PIX_WIDTH*4)];
	 assign pixdata5 = pixdata_i[(PIX_WIDTH*6) - 1:(PIX_WIDTH*5)];
	 assign pixdata6 = pixdata_i[(PIX_WIDTH*7) - 1:(PIX_WIDTH*6)];
	 assign pixdata7 = pixdata_i[(PIX_WIDTH*8) - 1:(PIX_WIDTH*7)];
	 assign pixdata8 = pixdata_i[(PIX_WIDTH*9) - 1:(PIX_WIDTH*8)];
	 assign pixdata9 = pixdata_i[(PIX_WIDTH*10)- 1:(PIX_WIDTH*9)];
`endif

//Required for tb
wire fv_start, fv_end, lv_start, lv_end;
wire hsync_start, hsync_end, vsync_start, vsync_end;
wire p2b_byte_data_en;
wire [5:0] data_type;
wire ready           ;
wire txfr_req        ;

assign tx_pd_dphy   = ~reset_n_i;
assign tx_frame_max = 8'd10;

assign fv_start = p2b_fv_start;
assign fv_end   = p2b_fv_end;
assign lv_start = p2b_lv_start;
assign lv_end   = p2b_lv_end;

assign vsync_start = p2b_vsync_start;
assign vsync_end   = p2b_vsync_end;
assign hsync_start = p2b_hsync_start;
assign hsync_end   = p2b_hsync_end;

assign p2b_byte_data_en = p2b_byte_en;
assign ready            = tx_tinit_done;
assign txfr_req         = p2b_txfr_req;
assign data_type = p2b_data_type;

p2b i_p2b (
	.pix_clk_i    			(pix_clk_i                   ),
	.byte_clk_i   			(byte_clk                    ),
	.rst_n_i      			(reset_n_i ),
	.fv_i       			(fv_i         ),
	.lv_i       			(lv_i         ),
	.dvalid_i   			(dvalid_i     ),
	.fv_start_o 			(p2b_fv_start ),
	.fv_end_o   			(p2b_fv_end   ),
	.lv_start_o 			(p2b_lv_start ),
	.lv_end_o   			(p2b_lv_end   ),
  // Input DATA  
`ifdef NUM_PIX_LANE_1
	.pix_data0_i            (pixdata0      ),
`elsif NUM_PIX_LANE_2
	.pix_data0_i            (pixdata0      ),
	.pix_data1_i            (pixdata1      ),
`elsif NUM_PIX_LANE_4       
	.pix_data0_i            (pixdata0      ),
	.pix_data1_i            (pixdata1      ),
	.pix_data2_i            (pixdata2      ), 
	.pix_data3_i            (pixdata3      ), 
`elsif NUM_PIX_LANE_6       
	.pix_data0_i            (pixdata0      ),
	.pix_data1_i            (pixdata1      ),
	.pix_data2_i            (pixdata2      ),
	.pix_data3_i            (pixdata3      ),
	.pix_data4_i            (pixdata4      ),
	.pix_data5_i            (pixdata5      ),
`elsif NUM_PIX_LANE_8       
	.pix_data0_i            (pixdata0      ),
	.pix_data1_i            (pixdata1      ),
	.pix_data2_i            (pixdata2      ),
	.pix_data3_i            (pixdata3      ),
	.pix_data4_i            (pixdata4      ),
	.pix_data5_i            (pixdata5      ),
	.pix_data6_i            (pixdata6      ),
	.pix_data7_i            (pixdata7      ),
`elsif NUM_PIX_LANE_10
	.pix_data0_i            (pixdata0      ),
	.pix_data1_i            (pixdata1      ),
	.pix_data2_i            (pixdata2      ),
	.pix_data3_i            (pixdata3      ),
	.pix_data4_i            (pixdata4      ),
	.pix_data5_i            (pixdata5      ),
	.pix_data6_i            (pixdata6      ),
	.pix_data7_i            (pixdata7      ),
	.pix_data8_i            (pixdata8      ),
	.pix_data9_i            (pixdata9      ),
`endif // NUM_PIX_LANE 
`ifdef MISC_ON
	.data_type_o  			(p2b_data_type    ),
`endif // MISC_ON
	.c2d_ready_i  			(p2b_c2d_ready    ),
	.txfr_en_i    			(p2b_txfr_en      ),
	.txfr_req_o   			(p2b_txfr_req     ),
	.byte_en_o    			(p2b_byte_en      ),
	.byte_data_o  			(p2b_byte_data    )
);


tx_dphy i_tx_dphy (
	.ref_clk_i      		(pix_clk_i       ),
	.reset_n_i      		(reset_n_i       ),
	.pd_dphy_i      		(tx_pd_dphy      ),
	.byte_data_i    		(tx_byte_data    ),
	.byte_data_en_i 		(tx_byte_data_en ),

	.vc_i           		(tx_vc           ),
	.dt_i           		(tx_dt           ),
	.wc_i           		(tx_wc           ),
	.tinit_done_o   		(tx_tinit_done   ),
 `ifdef MISC_ON
	.pix2byte_rstn_o(tx_pix2byte_rstn),
 `endif // MISC_ON
	.ld_pyld_o              (tx_ld_pyld     ),
	.sp_en_i                (tx_sp_en       ), 
	.lp_en_i                (tx_lp_en       ), 

`ifdef MISC_ON
	.pll_lock_o             (pll_lock     	 ), 
`endif // MISC_ON
	.clk_hs_en_i    		(tx_clk_hs_en    ),
	.d_hs_en_i      		(tx_d_hs_en      ),
	.d_hs_rdy_o     		(tx_d_hs_rdy     ),
	.byte_clk_o     		(byte_clk        ),
	.c2d_ready_o    		(tx_c2d_ready    ),
	
`ifdef NUM_TX_LANE_1
	.d0_p_io        		(d_p_io[0]       ),
	.d0_n_io        		(d_n_io[0]       ),
`elsif NUM_TX_LANE_2
	.d0_p_io        		(d_p_io[0]       ),
	.d0_n_io        		(d_n_io[0]       ),
	.d1_p_o         		(d_p_io[1]       ),
	.d1_n_o         		(d_n_io[1]       ),
`elsif NUM_TX_LANE_4
	.d0_p_io        		(d_p_io[0]       ),
	.d0_n_io        		(d_n_io[0]       ),
	.d1_p_o         		(d_p_io[1]       ),
	.d1_n_o         		(d_n_io[1]       ),
	.d2_p_o         		(d_p_io[2]       ),
	.d2_n_o         		(d_n_io[2]       ),
	.d3_p_o       		    (d_p_io[3]       ),
	.d3_n_o         		(d_n_io[3]       ),
`endif
	.clk_p_o        		(clk_p_io        ),
	.clk_n_o        		(clk_n_io        )
);

leds (
	.CLKI(CLKI),
	.CLKOS(CLKOS),
	.Reset_n(Reset_n),
	.LED1(LED1),
	.LED2(LED2)
);

//------CSI2 glue logic
p2m_csi2_glue #(
	.NUM_PIXELS 	  (NUM_PIXELS),
	.PIX_WIDTH		  (PIX_WIDTH),
	.DT				  (DT),
	.VC				  (VC)
	) 
i_p2m_csi2_glue (
	.reset_byte_n_i   (reset_n_i      ),
	.byte_clk_i       (byte_clk       ),
	.p2b_byte_data_i  (p2b_byte_data  ),
	.p2b_byte_en_i    (p2b_byte_en    ),
	.p2b_fv_start_i   (p2b_fv_start   ),
	.p2b_fv_end_i     (p2b_fv_end     ),
	.p2b_txfr_req_i   (p2b_txfr_req   ),
	.p2b_c2d_ready_o  (p2b_c2d_ready  ),
	.p2b_txfr_en_o    (p2b_txfr_en    ),
	.tx_c2d_ready_i   (tx_c2d_ready   ),
	.tx_d_hs_rdy_i    (tx_d_hs_rdy    ),
	.tx_d_hs_en_o     (tx_d_hs_en     ),
	.tx_clk_hs_en_o   (tx_clk_hs_en   ),
	.tx_byte_data_en_o(tx_byte_data_en),
	.tx_byte_data_o   (tx_byte_data   ),
	.tx_sp_en_o       (tx_sp_en       ),
	.tx_lp_en_o       (tx_lp_en       ),
	.tx_dt_o          (tx_dt          ),
	.tx_vc_o          (tx_vc          ),
	.tx_wc_o          (tx_wc          )
);

endmodule
