/*
Glue logic between Pixel to Byte and TX DPHY IP for CSI-2 Crosslink.
Note:
1. Since LV start/end sync short packet is optional, this module will not handle it.
	a. Testbench is sending asserting LV and dvalid_i together.
2. TX DPHY requires 4 cycles after assertion of lp_en, before sending the data in.
	a. In this glue logic implementation, the data/en will be delayed by 5 cycles from p2b
*/
module p2m_csi2_glue #(
	parameter NUM_PIXELS = 240  , // Number of pixels per line
	parameter PIX_WIDTH  = 8    , // Number of bits per pixel, dependent on the DATA type
	parameter DT         = 6'h2A, // Active video data type code
	parameter VC         = 2'b00  // VC number
) (
	input         reset_byte_n_i   , // Active-low reset synchronized to the byte clock
	input         byte_clk_i       ,
	// P2B interface
	input  [63:0] p2b_byte_data_i  ,
	input         p2b_byte_en_i    ,
	input         p2b_fv_start_i   ,
	input         p2b_fv_end_i     ,
	input         p2b_txfr_req_i   ,
	output        p2b_c2d_ready_o  ,
	output        p2b_txfr_en_o    ,
	// TX DPHY interface
	input         tx_c2d_ready_i   ,
	input         tx_d_hs_rdy_i    ,
	output        tx_d_hs_en_o     ,
	output        tx_clk_hs_en_o   ,
	output        tx_byte_data_en_o,
	output [63:0] tx_byte_data_o   ,
	output        tx_sp_en_o       ,
	output        tx_lp_en_o       ,
	output [ 5:0] tx_dt_o          ,
	output [ 1:0] tx_vc_o          ,
	output [15:0] tx_wc_o
);

	localparam PAYLOAD_WC = (NUM_PIXELS*PIX_WIDTH)/8; // Fix word count

	// Sync short packet Data Type encoding
	localparam FV_START_DT = 6'h00;
	localparam FV_END_DT   = 6'h01;

	// FSM Encoding
	localparam WAIT_C2D_READY    = 4'h0; // Wait for tx dphy c2d_ready signal, and then go to WAIT_TXFR_REQ
	localparam WAIT_TXFR_REQ     = 4'h1; // Wait for p2b txfr_req signal, then wait go to WAIT_HS_READY
	localparam WAIT_HS_RDY       = 4'h2; // Wait for tx dphy d_hs_rdy_i signal to indicate
	localparam SEND_SP1_FV_START = 4'h3; // Assert sp_en and send fv start short packet - 1 cycle only
	localparam SEND_SP0_FV_START = 4'h4; // De-Assert sp_en and send fv start short packet - Until d_hs_rdy deassertion
	localparam SEND_SP1_FV_END   = 4'h5; // Assert sp_en and send fv end short packet - 1 cycle only
	localparam SEND_SP0_FV_END   = 4'h6; // De-Assert sp_en and send fv end short packet - Until d_hs_rdy deassertion
	localparam SEND_LP_EN        = 4'h7; // Assert lp_en for 1 cycle and send packet header
	localparam SEND_LP_DATA      = 4'h8; // State to send the data while keep packet header - Until d_hs_rdy deassertion

	reg [3:0] cur_fsm_st, nxt_fsm_st;

	// Registered outputs to p2b. Possible to just create a passthru instead?
	reg p2b_c2d_ready_r; // 1 cycle delay from tx_c2d_ready_i
	reg p2b_txfr_en_r  ; // 1 cycle delay from tx_d_hs_rdy_i

	// FSM combinational logic outputs
	reg        tx_d_hs_en_c  ;
	reg        tx_clk_hs_en_c;
	reg        tx_sp_en_c    ;
	reg        tx_lp_en_c    ;
	reg [ 5:0] tx_dt_c       ;
	reg [ 1:0] tx_vc_c       ;
	reg [15:0] tx_wc_c       ;

	// Delay the data/en from P2B to meet the timing requirement of TX DPHY
	// r0 - 1st cycle after p2b_byte_en assertion, r1 - 2nd cycle, r2 - 3rd cycle ...
	reg        tx_byte_data_en_r0;
	reg        tx_byte_data_en_r1;
	reg        tx_byte_data_en_r2;
	reg        tx_byte_data_en_r3;
	reg        tx_byte_data_en_r4;
	reg [63:0] tx_byte_data_r0   ;
	reg [63:0] tx_byte_data_r1   ;
	reg [63:0] tx_byte_data_r2   ;
	reg [63:0] tx_byte_data_r3   ;
	reg [63:0] tx_byte_data_r4   ;

	// Module Output assignments
	assign p2b_c2d_ready_o   = p2b_c2d_ready_r;    // 1 cycle delay of tx_c2d_ready_i
	assign p2b_txfr_en_o     = p2b_txfr_en_r;      // 1 cycle delay of tx_d_hs_rdy_i
	assign tx_byte_data_en_o = tx_byte_data_en_r4; // 5 cycle delay of p2b_byte_en_i
	assign tx_byte_data_o    = tx_byte_data_r4;    // 5 cycle delay of p2b_byte_data_i
	assign tx_d_hs_en_o      = tx_d_hs_en_c;
	assign tx_clk_hs_en_o    = tx_clk_hs_en_c;
	assign tx_sp_en_o        = tx_sp_en_c;
	assign tx_lp_en_o        = tx_lp_en_c;
	assign tx_dt_o           = tx_dt_c;
	assign tx_vc_o           = tx_vc_c;
	assign tx_wc_o           = tx_wc_c;

	// Handshaking signal from tx dphy to p2b - delayed by 1 cycle
	always @(posedge byte_clk_i or negedge reset_byte_n_i) begin: p2b_flag_ff
		if (~reset_byte_n_i) begin
			p2b_c2d_ready_r <= 1'b0;
			p2b_txfr_en_r   <= 1'b0;
		end
		else begin
			p2b_c2d_ready_r <= tx_c2d_ready_i;
			p2b_txfr_en_r   <= tx_d_hs_rdy_i;
		end
	end

	// Delay enable and data bus to the TX DPHY by 5 cycles.
	// TX DPHY requires 4 cycles from assertion of lp_en
	// lp_en is generated from byte_en too, which will be delayed by 1 cycle
	always @(posedge byte_clk_i or negedge reset_byte_n_i) begin: delay_data_n_en_ff
		if (~reset_byte_n_i) begin
			tx_byte_data_en_r0 <= 'h0;
			tx_byte_data_en_r1 <= 'h0;
			tx_byte_data_en_r2 <= 'h0;
			tx_byte_data_en_r3 <= 'h0;
			tx_byte_data_en_r4 <= 'h0;
			tx_byte_data_r0    <= 'h0;
			tx_byte_data_r1    <= 'h0;
			tx_byte_data_r2    <= 'h0;
			tx_byte_data_r3    <= 'h0;
			tx_byte_data_r4    <= 'h0;
		end
		else begin
			tx_byte_data_en_r0 <= p2b_byte_en_i;
			tx_byte_data_en_r1 <= tx_byte_data_en_r0;
			tx_byte_data_en_r2 <= tx_byte_data_en_r1;
			tx_byte_data_en_r3 <= tx_byte_data_en_r2;
			tx_byte_data_en_r4 <= tx_byte_data_en_r3;
			tx_byte_data_r0    <= p2b_byte_data_i;
			tx_byte_data_r1    <= tx_byte_data_r0;
			tx_byte_data_r2    <= tx_byte_data_r1;
			tx_byte_data_r3    <= tx_byte_data_r2;
			tx_byte_data_r4    <= tx_byte_data_r3;
		end
	end

	always @(posedge byte_clk_i or negedge reset_byte_n_i) begin: fsm_ff
		if (~reset_byte_n_i) begin
			cur_fsm_st <= WAIT_C2D_READY;
		end
		else begin
			cur_fsm_st <= nxt_fsm_st;
		end
	end

	always @* begin: fsm_comb
		tx_d_hs_en_c   = 1'b0;
		tx_clk_hs_en_c = 1'b0;
		tx_sp_en_c     = 1'b0;
		tx_lp_en_c     = 1'b0;
		tx_dt_c        = 6'h0;
		tx_vc_c        = 2'h0;
		tx_wc_c        = 16'h0;
		nxt_fsm_st     = cur_fsm_st;
		case (cur_fsm_st)
			WAIT_C2D_READY : begin
				// Wait for TX DPHY to assert c2d_ready_i signal
				if(tx_c2d_ready_i) begin
					nxt_fsm_st = WAIT_TXFR_REQ;
				end
			end
			WAIT_TXFR_REQ : begin
				// Pass the c2d_ready_i signal to the P2B, then wait for txfr_req_i for P2B
				if(p2b_txfr_req_i) begin
					nxt_fsm_st = WAIT_HS_RDY;
				end
			end
			WAIT_HS_RDY : begin
				// Now wait for TX DPHY goes into HS mode
				// Assert d/clk_hs_en of TX DPHY
				if(tx_d_hs_rdy_i) begin
					case ({p2b_fv_start_i, p2b_fv_end_i, p2b_byte_en_i}) // lv_i and dvalid_i are the same signals, thus we are not going to implement sp for lv
						3'b000  : nxt_fsm_st = WAIT_HS_RDY;        // If none of p2b flags asserted, keep waiting...
						3'b100  : nxt_fsm_st = SEND_SP1_FV_START;
						3'b010  : nxt_fsm_st = SEND_SP1_FV_END;
						3'b001  : nxt_fsm_st = SEND_LP_EN;
						default : nxt_fsm_st = WAIT_C2D_READY; // only 1 flag should be asserted at one time or none
					endcase
				end
				// Drive both clk and data enable of TX DPHY until hs_ready asserted
				tx_d_hs_en_c   = 1'b1;
				tx_clk_hs_en_c = 1'b1;
			end
			SEND_SP1_FV_START : begin
				// Send FV start packets, while asserting sp_en for 1 cycle
				nxt_fsm_st = SEND_SP0_FV_START;
				tx_sp_en_c = 1'b1; // Assert sp_en for 1 cycle
				tx_dt_c    = FV_START_DT;
				tx_vc_c    = VC;
				tx_wc_c    = 16'h0;
			end
			SEND_SP0_FV_START : begin
				// Send FV start packets, while retaining sp_en low, until hs_ready de-assertion assertion
				if(~tx_d_hs_rdy_i) begin
					nxt_fsm_st = WAIT_C2D_READY;
				end
				tx_sp_en_c = 1'b0; // De-Assert sp_en
				tx_dt_c    = FV_START_DT;
				tx_vc_c    = VC;
				tx_wc_c    = 16'h0;
			end
			SEND_SP1_FV_END : begin
				// Send FV end packets, while asserting sp_en for 1 cycle
				nxt_fsm_st = SEND_SP0_FV_END;
				tx_sp_en_c = 1'b1; // Assert sp_en for 1 cycle
				tx_dt_c    = FV_END_DT;
				tx_vc_c    = VC;
				tx_wc_c    = 16'h0;
			end
			SEND_SP0_FV_END : begin
				// Send FV end packets, while retaining sp_en low, until hs_ready de-assertion assertion
				if(~tx_d_hs_rdy_i) begin
					nxt_fsm_st = WAIT_C2D_READY;
				end
				tx_sp_en_c = 1'b0; // De-Assert sp_en
				tx_dt_c    = FV_END_DT;
				tx_vc_c    = VC;
				tx_wc_c    = 16'h0;
			end
			SEND_LP_EN : begin
				// Send LP enable and it's packet headers
				nxt_fsm_st = SEND_LP_DATA;
				tx_lp_en_c = 1'b1; // Assert lp_en for 1 cycle
				tx_dt_c    = DT;
				tx_vc_c    = VC;
				tx_wc_c    = PAYLOAD_WC;
			end
			SEND_LP_DATA : begin
				// State where we send the actual data + delay. Retain the packet header till hs_ready_i deassertion
				// the actual byte data and byte enable is handled by the delay registers
				if(~tx_d_hs_rdy_i) begin
					nxt_fsm_st = WAIT_C2D_READY;
				end
				tx_lp_en_c = 1'b0; // Continue driving lp_en low
				tx_dt_c    = DT;
				tx_vc_c    = VC;
				tx_wc_c    = PAYLOAD_WC;
			end
			default : begin
				nxt_fsm_st = WAIT_C2D_READY;
			end
		endcase
	end

endmodule
