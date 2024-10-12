//===========================================================================
// Filename: dphy_tx_tb.v
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved.
//===========================================================================
// --------------------------------------------------------------------
//
// This is the test bench module of the DPHYTX design.
//
// --------------------------------------------------------------------
// #include <orcapp_head>

`timescale 1 ps / 1 ps

`include "dphy_tx_model.v"
`include "rx_model.v"
`include "tb_setup_params.v"

module tb();
   `include "csi2_output_params.v"
   // Testbench parameters for video data
   parameter num_frames                   = `NUM_FRAMES; // number of frames
   parameter num_lines                    = `NUM_LINES;   //number of video lines
   parameter num_bytes                    = `NUM_BYTES;   //number of initial bytes/word count /// *** NOTE if PKT_FORMATTER is OFF num_bytes must be k*GEAR*NUM_TX_LANE (ONLY for Test bench)
   parameter data_type                    = `TEST_DATA_TYPE; // video data type DI. example: 6'h3E = RGB888
   parameter virtual_channel              = `VIRTUAL_CHANNEL; // video data type DI. example: 6'h3E = RGB888
   parameter tinit_duration               = `TINIT_DURATION; // used when MISC_ON is NOT defined. this is for setting the wait time duration (in ps) of TINIT ROM done
   parameter debug_on                     = `DPHY_DEBUG_ON; // for enabling/disabling DPHY data debug messages
   parameter refclk_period                = 1000000/REF_CLK_FREQ;
   parameter driving_edge                 = `DRIVING_EDGE; //1 byte data is driven at positive edge; 0 byte data is driven at negative edge
   // Design parameters
   parameter pd_ch                        = `PD_CH;                      
   //for CSI2                                
   parameter hs_rdy_to_sp_en_dly          = `HS_RDY_TO_SP_EN_DLY;        
   parameter hs_rdy_to_lp_en_dly          = `HS_RDY_TO_LP_EN_DLY;        
   parameter lp_en_to_byte_data_en_dly    = `LP_EN_TO_BYTE_DATA_EN_DLY;
   parameter hs_rdy_neg_to_hs_clk_en_dly  = `HS_RDY_NEG_TO_HS_CLK_EN_DLY;
   parameter d_hs_rdy_to_d_hs_clk_en_dly  = `D_HS_RDY_TO_D_HS_CLK_EN_DLY;
   parameter ls_le_en                     = `LS_LE_EN;                   
   parameter gen_fr_num                   = `GEN_FR_NUM;                 
   parameter gen_ln_num                   = `GEN_LN_NUM;                 
   //for DSI                                
   parameter hs_rdy_to_vsync_start_dly    = `HS_RDY_TO_VSYNC_START_DLY;  
   parameter hs_rdy_to_hsync_start_dly    = `HS_RDY_TO_HSYNC_START_DLY;  
   parameter hs_rdy_to_byte_data_en_dly   = `HS_RDY_TO_BYTE_DATA_EN_DLY; 
   parameter hsync_pulse_front            = `HSYNC_PULSE_FRONT;          
   parameter hsync_pulse_back             = `HSYNC_PULSE_BACK;           
   parameter vsync_to_hsync_dly           = `VSYNC_TO_HSYNC_DLY;         
   parameter hsync_to_hsync_dly           = `HSYNC_TO_HSYNC_DLY;         
   //packet without formatter               
   parameter hs_rdy_to_dphy_pkten_dly     = `HS_RDY_TO_DPHY_PKTEN_DLY;   

   //DUT input ports
   reg resetn;
   reg pd_ch_i;
   reg refclk_i;
   reg rx_model_reset_r = 1;
   wire sp_en_w;
   wire lp_en_w;
   wire vsync_start_w;
   wire hsync_start_w;
   wire eotp_w;
   wire clk_hs_en_w;
   wire d_hs_en_w;
   wire [63:0] dphy_pkt_w;
   wire dphy_pkten_w;
   wire byte_data_en_w;
   wire [63:0] byte_data_w;
   wire [1:0] vc_w;
   wire [5:0] dt_w;
   wire [15:0] wc_w;

   //DUT output ports
   
   wire d0_p_io;
   wire d0_n_io;
   wire d1_p_o; 
   wire d1_n_o; 
   wire d2_p_o; 
   wire d2_n_o; 
   wire d3_p_o; 
   wire d3_n_o; 
   
   wire clk_p_o;
   wire clk_n_o;
   ///
   wire tinit_done_w;
   wire pll_lock_w;

   /// DUT
   wire        reset_n_i;
   wire        ref_clk_i;
   wire        pd_dphy_i;
   
   wire        sp_en_i;
   wire        lp_en_i;
   wire        ld_pyld_o;
   
   wire        vsync_start_i;
   wire        hsync_start_i;
   
   wire        clk_hs_en_i;
   wire        d_hs_en_i;
   
   wire [63:0] dphy_pkt_i;
   wire        dphy_pkten_i;
   
   wire        byte_data_en_i;
   wire [63:0] byte_data_i;
   wire [ 1:0] vc_i;
   wire [ 5:0] dt_i;
   wire [15:0] wc_i;
   
   wire       byte_clk_o;
   wire       d_hs_rdy_o;
   wire       tinit_done_o;
   wire       pll_lock_o;
   wire [7:0] frame_max_i = num_frames;
   wire       c2d_ready_o;
   
   
   assign reset_n_i      = resetn;
   assign ref_clk_i      = refclk_i;
   assign pd_dphy_i      = pd_ch_i;
   
   assign sp_en_i        = sp_en_w;
   assign lp_en_i        = lp_en_w;
   
   assign vsync_start_i  = vsync_start_w;
   assign hsync_start_i  = hsync_start_w;
   
   assign clk_hs_en_i    = clk_hs_en_w;
   assign d_hs_en_i      = d_hs_en_w;
   
   
   assign dphy_pkt_i     = dphy_pkt_w;
   assign dphy_pkten_i   = dphy_pkten_w;
   
   assign byte_data_en_i = byte_data_en_w;
   assign byte_data_i    = byte_data_w;
   assign vc_i           = vc_w;
   assign dt_i           = dt_w;
   assign wc_i           = wc_w;
   
   assign byte_clk_w     = byte_clk_o;
   assign d_hs_rdy_w     = d_hs_rdy_o;
   
   assign tinit_done_w   = tinit_done_o;
   
   assign pll_lock_w     = pll_lock_o;
  
  reg fail = 0;
  
  ////////////////////////////////////////////////////////////////////////
  /// Check if clock in HS state if clk_hs_en_i is hi (HS_LP mode only)
  ////////////////////////////////////////////////////////////////////////
  
  reg clk_line_err_r = 0;
  
  generate
    if (CLK_MODE == "HS_ONLY") begin
      ///
    end
    else begin
      always @(negedge u_rx_model.clk_state_hs_lpn) begin
        if (clk_hs_en_i) begin
          clk_line_err_r = 1;
        end 
      end
    end
  endgenerate
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
   
   task wait_tinit();
   begin
      $display("%0t Waiting for TINIT Done ...",$realtime);
      if(pd_ch_i == 0) begin
         @(posedge tinit_done_w);
         $display("%0t TINIT DONE !",$realtime);
      end
   end
   endtask

   task wait_pll();
   begin
      $display("%0t Waiting for PLL Lock Done ...",$realtime);
      if(pd_ch_i == 0) begin
         @(posedge pll_lock_w);
         $display("%0t PLL Lock DONE !",$realtime);
      end
   end
   endtask


   initial begin
      $timeformat(-12,0,"",10);
      resetn = 0; //reset at start of sim
      refclk_i = 0;
      pd_ch_i = pd_ch;

      $display("%0t TEST START\n",$realtime);
      #100000;
      resetn = 1;
      if (MISC == "ON") begin
        wait_pll;
        if (TINIT_COUNT == "ON") begin
          wait_tinit;
        end
        else begin
          #tinit_duration;
        end
      end
      else begin
        #tinit_duration;
      end
      rx_model_reset_r = 1'd0;
      #10000;
      tx_model0.drive_video_data;
      // tx_model0.optional_test;
      #1000000;
      $display("%0t TEST END\n",$realtime);
      tx_model0.eotb  = 1'd1;
      u_rx_model.eotb = 1'd1;
      data_check_t;
      $finish;
   end

   // initial begin
      // $shm_open("./dump.shm");
      // $shm_probe(tb, ("AC"));
   // end

   always #(refclk_period/2) refclk_i =~ refclk_i;

    //DUT instance
   PUR PUR_INST(resetn);

   dphy_tx_model #(
   .NUM_FRAMES                  (num_frames                   ),
   .NUM_LINES                   (num_lines                    ),
   .NUM_BYTES                   (num_bytes                    ),
   .DATA_TYPE                   (data_type                    ),
   .VIRTUAL_CHANNEL             (virtual_channel              ),
   .DPHY_LANES                  (NUM_TX_LANE                  ),
   .GEAR                        (TX_GEAR                      ),
   .DRIVING_EDGE                (driving_edge                 ),
   .DEVICE_TYPE                 (INTF_TYPE                    ),
   .PACKET_FORMATTER            (PKT_FORMATTER                ),
   //FOR CSI2
   .HS_RDY_TO_SP_EN_DLY         (hs_rdy_to_sp_en_dly          ),
   .HS_RDY_TO_LP_EN_DLY         (hs_rdy_to_lp_en_dly          ),
   .LP_EN_TO_BYTE_DATA_EN_DLY   (lp_en_to_byte_data_en_dly    ),
   .HS_RDY_NEG_TO_HS_CLK_EN_DLY (hs_rdy_neg_to_hs_clk_en_dly  ),
   .LS_LE_EN                    (ls_le_en                     ),
   .GEN_FR_NUM                  (gen_fr_num                   ),
   .GEN_LN_NUM                  (gen_ln_num                   ),
   //FOR DSI
   .HS_RDY_TO_VSYNC_START_DLY   (hs_rdy_to_vsync_start_dly    ),
   .HS_RDY_TO_HSYNC_START_DLY   (hs_rdy_to_hsync_start_dly    ),
   .HS_RDY_TO_BYTE_DATA_EN_DLY  (hs_rdy_to_byte_data_en_dly   ),
   .HSYNC_PULSE_FRONT           (hsync_pulse_front            ),
   .HSYNC_PULSE_BACK            (hsync_pulse_back             ),
   .HSYNC_TO_HSYNC_DLY          (hsync_to_hsync_dly           ),
   .VSYNC_TO_HSYNC_DLY          (vsync_to_hsync_dly           ),
   //PACKET WITHOUT FORMATTER
   .HS_RDY_TO_DPHY_PKTEN_DLY    (hs_rdy_to_dphy_pkten_dly     ),
   .DEBUG_ON                    (debug_on                     )
      )
   tx_model0 (
   .reset(resetn),
   .ref_clk(byte_clk_w),
   .clk_hs_en(clk_hs_en_w),
   .d_hs_en(d_hs_en_w),
   .ld_pyld_i(ld_pyld_o),
   .c2d_ready_i(c2d_ready_o),
   //CSI2/DSI ports
   .byte_data_en(byte_data_en_w),
   .byte_data(byte_data_w),
   .vc(vc_w),
   .dt(dt_w),
   .wc(wc_w),
   .eotp(eotp_w),
   //CSI2 specific
   .sp_en(sp_en_w),
   .lp_en(lp_en_w),
   //DSI specific
   .vsync_start(vsync_start_w),
   .hsync_start(hsync_start_w),
   //packet format bypass ports
   .dphy_pkten(dphy_pkten_w),
   .dphy_pkt(dphy_pkt_w),
   //from DUT
   .d_hs_rdy(d_hs_rdy_w),
   .c_p_io(clk_p_o),
   .c_n_io(clk_n_o)
  );

rx_model # (
  .NUM_LANE     (NUM_TX_LANE),
  .CLK_MODE     ((CLK_MODE == "HS_ONLY")? "CONTINUOUS" : "NON_CONTINUOUS"),
  .HEADER_CHECK ("OFF"),
  .EOTP_CHECK   ((INTF_TYPE == "DSI" && EOTP == "ON")? "ON" : "OFF"),
  .CRC_CHECK    ("ON"),
  .INTF_TYPE    (INTF_TYPE),
  .FRAME_CNT_EN (FRAME_CNT_EN),
  .NUM_FRAMES   (num_frames)
)
u_rx_model (
  .reset_i      (rx_model_reset_r),
  .c_p_i        (clk_p_o),           // Positive part of clock.
  .c_n_i        (clk_n_o),           // Negative part of clock.
  .d_p_i        ({d3_p_o,d2_p_o,d1_p_o,d0_p_io}),           // Positive part of data.
  .d_n_i        ({d3_n_o,d2_n_o,d1_n_o,d0_n_io})            // Negative part of data.
);

`include "csi2_output_inst.v"

task data_check_t();// Task which compare two text files
  reg [31:0] D_true_res;
  reg [31:0] D_false_res;
  reg [31:0] D_file_1_value;
  reg [31:0] D_file_2_value;
  reg [31:0] D_file_1;
  reg [31:0] D_file_2;
  reg        eof1; /// End of file 1
  reg        eof2; /// End of file 2
  integer    line;
  begin
    D_true_res       = 32'd0;
    D_false_res      = 32'd0;
    D_file_1_value   = 32'd0;
    D_file_2_value   = 32'd0;
    D_file_1         = $fopen("tx_input_data_file.txt","r");
    D_file_2         = $fopen("tx_output_data_file.txt","r");
    eof1             = 0;
    eof2             = 0;
    line             = 1;
    #1;
    // $display("Start of data comparing");
    while ((!$feof(D_file_1) | !$feof(D_file_1))) begin
      $fscanf(D_file_1,"%h\n",D_file_1_value);
      $fscanf(D_file_2,"%h\n",D_file_2_value);
      if (D_file_1_value == D_file_2_value) begin
        D_true_res   = D_true_res + 1;
      end
      else begin
        D_false_res  = D_false_res + 1;
        $display("Time : ERROR : Line %d",line);
      end
      line = line + 1;
    end
    
    if ((INTF_TYPE == "DSI" & EOTP == "ON")) begin
      ///////////////////////////////////////////////////
      /// EOTp Parameters Check after LP(if available)
      ///////////////////////////////////////////////////
      if (u_rx_model.global_EoTp_LP_failed_cases == 0 & u_rx_model.global_EoTp_LP_passed_cases) begin
        $display("   ***EoTp PACKET CHECK AFTER LP PASS***   ");
      end
      else if (u_rx_model.global_EoTp_LP_failed_cases == 0 & u_rx_model.global_EoTp_LP_passed_cases == 0) begin
        fail = 1;
        $display("   ***EoTp PACKET CHECK AFTER LP FAIL***   ");
        $display("   ***Something Wrong***");
      end
      else begin
        fail = 1;
        $display("   ***EoTp PACKET CHECK AFTER LP FAIL***   ");
        $display("Errors` ",u_rx_model.global_EoTp_LP_failed_cases,"/",u_rx_model.global_EoTp_LP_failed_cases + u_rx_model.global_EoTp_LP_passed_cases);
      end
  
      ///////////////////////////////////////////////////
      /// EOTp Parameters Check after SP(if available)
      ///////////////////////////////////////////////////
      if (u_rx_model.global_EoTp_SP_failed_cases == 0 & u_rx_model.global_EoTp_SP_passed_cases != 0) begin
        $display("   ***EoTp PACKET CHECK AFTER SP PASS***   ");
      end
      else if (u_rx_model.global_EoTp_SP_failed_cases == 0 & u_rx_model.global_EoTp_SP_passed_cases == 0) begin
        fail = 1;
        $display("   ***EoTp PACKET CHECK AFTER SP FAIL***   ");
        $display("   ***Something Wrong***");
      end
      else begin
        $display("   ***EoTp PACKET CHECK AFTER SP FAIL***   ");
        fail = 1;
        $display("Errors` ",u_rx_model.global_EoTp_SP_failed_cases,"/",u_rx_model.global_EoTp_SP_failed_cases + u_rx_model.global_EoTp_SP_passed_cases);
      end  
    end
    
    ///////////////////////////////////////////////////
    /// EOT bit Check 
    ///////////////////////////////////////////////////
    if (u_rx_model.global_EOT_bit_failed_cases == 0 & u_rx_model.global_EOT_bit_passed_cases != 0) begin
      $display("   ***EoT BIT CHECK PASS***   ");
    end
    else if (u_rx_model.global_EOT_bit_failed_cases == 0 & u_rx_model.global_EOT_bit_passed_cases == 0) begin
      fail = 1;
      $display("   ***EOT BIT CHECK FAIL***   ");
      $display("   ***Something Wrong***");
    end
    else begin
      fail = 1;
      $display("   ***EOT BIT CHECK FAIL***   ");
      $display("Errors` ",u_rx_model.global_EOT_bit_failed_cases,"/",u_rx_model.global_EOT_bit_failed_cases + u_rx_model.global_EOT_bit_passed_cases);
    end
      
    ///////////////////////////////////////////////////
    /// Payload Data Check
    ///////////////////////////////////////////////////
    if (D_false_res == 0 && D_true_res != 0) begin
      $display("   ***PAYLOAD DATA PASS***   ");
    end
    else if (D_false_res == 0 && D_true_res == 0) begin
      fail = 1;
      $display("   ***PAYLOAD DATA FAIL***   ");
      $display("   ***Something Wrong***");
    end
    else begin
      fail = 1;
      $display("   ***PAYLOAD DATA FAIL***   ");
      $display("Errors` ",D_false_res,"/",D_false_res + D_true_res);
    end
    ///////////////////////////////////////////////////
    /// CRC Check
    ///////////////////////////////////////////////////
    if (PKT_FORMATTER == "ON") begin
      if (u_rx_model.global_CRC_failed_cases == 0 & u_rx_model.global_CRC_passed_cases != 0) begin
        $display("   ***CRC PASS***   ");
      end
      else if (u_rx_model.global_CRC_failed_cases == 0 & u_rx_model.global_CRC_passed_cases == 0) begin
        fail = 1;
        $display("   ***CRC FAIL***   ");
        $display("   ***Something Wrong***");
      end
      else begin
        fail = 1;
        $display("   ***CRC FAIL***   ");
        $display("Errors` ",u_rx_model.global_CRC_failed_cases,"/",u_rx_model.global_CRC_failed_cases + u_rx_model.global_CRC_passed_cases);
      end
    end
    ///////////////////////////////////////////////////
    /// ECC Check
    ///////////////////////////////////////////////////
    if (u_rx_model.global_ECC_failed_cases == 0 & u_rx_model.global_ECC_passed_cases != 0) begin
      $display("   ***ECC PASS***   ");
    end
    else if (u_rx_model.global_ECC_failed_cases == 0 & u_rx_model.global_ECC_passed_cases == 0) begin
      fail = 1;
      $display("   ***ECC FAIL***   ");
      $display("   ***Something Wrong***");
    end
    else begin
      $display("   ***ECC FAIL***   ");
      fail = 1;
      $display("Errors` ",u_rx_model.global_ECC_failed_cases,"/",u_rx_model.global_ECC_failed_cases + u_rx_model.global_ECC_passed_cases);
    end
    ///////////////////////////////////////////////////
    /// SoT Check
    ///////////////////////////////////////////////////
    if (u_rx_model.global_SOT_failed_cases == 0 & u_rx_model.global_SOT_passed_cases != 0) begin
      $display("   ***SoT PASS***   ");
    end
    else if (u_rx_model.global_SOT_failed_cases == 0 & u_rx_model.global_SOT_passed_cases == 0) begin
      fail = 1;
      $display("   ***SoT FAIL***   ");
      $display("   ***Something Wrong***");
    end
    else begin
      fail = 1;
      $display("   ***SoT FAIL***   ");
      $display("Errors` ",u_rx_model.global_SOT_failed_cases,"/",u_rx_model.global_SOT_failed_cases + u_rx_model.global_SOT_passed_cases);
    end
    
    if (fail) begin
      $display("***SIMULATION FAILED***");
    end
    else begin
      $display("***SIMULATION PASSED***");
    end
    
    $fclose(D_file_1);
    $fclose(D_file_2);
  end
endtask

endmodule





