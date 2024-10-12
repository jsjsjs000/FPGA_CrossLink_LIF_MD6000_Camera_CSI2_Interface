// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2017 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
// --------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               : DPHY_TX (#BU, #Crosslink, #Lifmd)
// File                  : dphy_tx_model.v
// Title                 : This is the test bench module of the DPHY_TX design.
// Dependencies          : 1.
//                       : 2.
// Description           :
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0
// Author(s)             :
// Mod. Date             : 
// Changes Made          : Initial version of RTL.
// -----------------------------------------------------------------------------
// Version               : 1.1
// Author(s)             : Davit Tamazyan (IMT)
// Mod. Date             : 9/16/2019
// Changes Made          : 
// =============================================================================

`timescale 1ps/1ps

`ifndef __dphy_tx_model__ 
`define __dphy_tx_model__ 
module dphy_tx_model#
// -----------------------------------------------------------------------------
// Module Parameters
// -----------------------------------------------------------------------------
(
parameter           NUM_FRAMES                   = 1,
parameter           NUM_LINES                    = 1080,
parameter           NUM_BYTES                    = 5760,
parameter           DATA_TYPE                    = "RGB888", 
parameter           VIRTUAL_CHANNEL              = 2'h0,
parameter           DPHY_LANES                   = 4,       
parameter           GEAR                         = 8,       
parameter           DRIVING_EDGE                 = 0,       //  byte data driving edge: 0 => negedge , 1 => posedge
parameter           DEVICE_TYPE                  = "CSI2",  
parameter           PACKET_FORMATTER             = "ON",    
parameter           EOTP_ENABLE                  = (PACKET_FORMATTER == "ON"),
parameter           D_HS_RDY_TO_D_HS_CLK_EN_DLY  = 10,
//for CSI2  
parameter           HS_RDY_TO_SP_EN_DLY          = 10,
parameter           HS_RDY_TO_LP_EN_DLY          = 10,
parameter           LP_EN_TO_BYTE_DATA_EN_DLY    = 0,
parameter           HS_RDY_NEG_TO_HS_CLK_EN_DLY  = 200,
parameter           LS_LE_EN                     = 0,
parameter           GEN_FR_NUM                   = 0,       
parameter           GEN_LN_NUM                   = 0,       
//for DSI         
parameter           HS_RDY_TO_VSYNC_START_DLY    = 10,
parameter           HS_RDY_TO_HSYNC_START_DLY    = 10,
parameter           HS_RDY_TO_BYTE_DATA_EN_DLY   = 10,
parameter           HSYNC_PULSE_FRONT            = 10,
parameter           HSYNC_PULSE_BACK             = 10,
parameter           HSYNC_TO_HSYNC_DLY           = 10,
parameter           VSYNC_TO_HSYNC_DLY           = 10,
//for packet without formatter
parameter           HS_RDY_TO_DPHY_PKTEN_DLY     = 2,
//for debug purposes
parameter           DEBUG_ON                     = 0 // for enabling/disabling DPHY data debug messages
)
// -----------------------------------------------------------------------------
// Input/Output Ports
// -----------------------------------------------------------------------------
(
input  wire         reset,
input  wire         d_hs_rdy,
input  wire         ref_clk, //connect to byte_clk_o of DUT
input  wire         c2d_ready_i,
input  wire         ld_pyld_i,
output reg          clk_hs_en,
output reg          d_hs_en,
output reg          byte_data_en,
output reg  [63:0]  byte_data,
output reg  [ 1:0]  vc,
output reg  [ 5:0]  dt,
output reg  [15:0]  wc,
output reg          eotp,
output reg          sp_en,
output reg          lp_en,
output reg          vsync_start,
output reg          hsync_start,
output reg          dphy_pkten,
output reg  [63:0]  dphy_pkt,
input  wire         c_p_io,
input  wire         c_n_io
);

// -----------------------------------------------------------------------------
// Generate Variables
// -----------------------------------------------------------------------------
integer frame_count;
integer line_count;
integer byte_count;
integer tx_input_data_file; /// File for tx input data writing
integer k;

// -----------------------------------------------------------------------------
// Sequential Registers
// -----------------------------------------------------------------------------
reg [63:0] byte_data_temp;
reg [ 1:0] fs_num;
reg [15:0] ls_num;
reg [15:0] crc;
reg [ 5:0] ecc;
reg [23:0] pkt_hdr_tmp;
reg [23:0] hdr_tmp;
reg [15:0] crc_tmp;
reg [15:0] cur_crc;
reg [15:0] word_count;
reg        eotb;                   /// Register for closing file from TB hierarchically
reg [15:0] num_bytes; initial begin num_bytes = NUM_BYTES; end

// -----------------------------------------------------------------------------
// Wire Declarations
// -----------------------------------------------------------------------------
wire [ 5:0] data_type_int_w;

// -----------------------------------------------------------------------------
// Assign Statements
// -----------------------------------------------------------------------------
assign data_type_int_w = (DATA_TYPE == "RGB888")? 6'h24 : 
                         (DATA_TYPE ==   "RAW8")? 6'h2A : 
                         (DATA_TYPE ==  "RAW10")? 6'h2B : 
                         (DATA_TYPE ==  "RAW12")? 6'h2C : 
                                                  6'h00;


// -----------------------------------------------------------------------------
// Sequential Blocks
// -----------------------------------------------------------------------------
initial begin
  ecc            = 0;
  crc            = 16'hFFFF;
  fs_num         = 1;
  ls_num         = 1;
  frame_count    = 0;
  line_count     = 0;
  byte_count     = 0;
  clk_hs_en      = 0;
  d_hs_en        = 0;
  byte_data_en   = 0;
  byte_data      = 0;
  byte_data_temp = 0;
  vc             = 0;
  dt             = 0;
  wc             = 0;
  sp_en          = 0;
  lp_en          = 0;
  vsync_start    = 0;
  hsync_start    = 0;
  dphy_pkten     = 0;
  dphy_pkt       = 0;
  eotp           = 0;
  eotb = 0;
  tx_input_data_file  = $fopen("tx_input_data_file.txt","w"); // file where writes DPHY_TX's input data
  @(posedge eotb);
  // $fwrite(tx_input_data_file,"END\n");
  $fclose(tx_input_data_file);
end

task drive_video_data();
begin
  ////////////////////////////////////////////////////////////////////////////////////
  /// START
  ////////////////////////////////////////////////////////////////////////////////////
  // $display("***DATA***");
  // $display("Frames  = %d",NUM_FRAMES);
  // $display("Lines   = %d",NUM_LINES);
  // $display("Bytes   = %d",num_bytes);
  // $display("Type    = %s %s",DATA_TYPE,DEVICE_TYPE);
  // $display("***CONFIG***");
  // $display("Lanes   = %d",DPHY_LANES);
  // $display("Gear    = %d",GEAR);
  // $display("PacketF = %s",PACKET_FORMATTER);
if(PACKET_FORMATTER == "ON") begin
  if(DEVICE_TYPE == "DSI") begin //DSI format
    $display("%0t DSI TX, Packet formatter is enabled",$realtime);
    for(frame_count=0;frame_count<NUM_FRAMES;frame_count=frame_count+1) begin
      $display("%0t FRAME #%0d START",$realtime,frame_count+1);
      //drive vsync
      drive_vsync_st;

      //drive hsync
      repeat(HSYNC_PULSE_FRONT-1) begin
        drive_hsync_st;   
      end

      for(line_count=0;line_count<NUM_LINES;line_count=line_count+1) begin
        num_bytes = num_bytes + 1;
        drive_hsync_st;

        repeat(HS_RDY_TO_BYTE_DATA_EN_DLY) begin
          wait_clock_edge;
        end   

        drive_hs_req;
        @(posedge d_hs_rdy);

        repeat(HS_RDY_TO_BYTE_DATA_EN_DLY) begin
          wait_clock_edge;
        end
        drive_byte;
      end

      //drive hsync
      repeat(HSYNC_PULSE_BACK-1) begin
        drive_hsync_st;   
      end
      $display("%0t FRAME #%0d END",$realtime,frame_count+1);
    end
  end
  else begin //CSI2 format
    $display("%0t CSI2 TX, Packet formatter is enabled",$realtime);
    for(frame_count=0;frame_count<NUM_FRAMES;frame_count=frame_count+1) begin
      $display("%0t FRAME #%0d START",$realtime,frame_count+1);
      //drive FS 
      drive_sp(6'h00);

      for(line_count=0;line_count<NUM_LINES;line_count=line_count+1) begin
        num_bytes = num_bytes + 1;
        if(LS_LE_EN) begin//drive LS
          drive_sp(6'h02);
        end
        drive_lp;
        repeat(LP_EN_TO_BYTE_DATA_EN_DLY) begin
          wait_clock_edge;
        end
        drive_byte;
        if(LS_LE_EN) begin//drive LE
          drive_sp(6'h03);
        end
      end
      drive_sp(6'h01); //drive FE
      $display("%0t FRAME #%0d END",$realtime,frame_count+1);
    end
  end
end
else begin //without packet formatter
  if(DEVICE_TYPE == "DSI") begin //DSI
    $display("%0t DSI TX, Packet formatter is disabled",$realtime);
    for(frame_count=0;frame_count<NUM_FRAMES;frame_count=frame_count+1) begin
      $display("%0t FRAME #%0d START",$realtime,frame_count+1);
      //drive vsync
      drive_spkt(6'h01);

      //drive hsync
      repeat(HSYNC_PULSE_FRONT-1) begin
        drive_spkt(6'h21);   
      end

      for(line_count=0;line_count<NUM_LINES;line_count=line_count+1) begin
        drive_spkt(6'h21);

        repeat(HS_RDY_TO_DPHY_PKTEN_DLY) begin
          wait_clock_edge;
        end

        drive_lpkt;
      end

      //drive hsync
      repeat(HSYNC_PULSE_BACK-1) begin
        drive_spkt(6'h21);   
      end
      $display("%0t FRAME #%0d END",$realtime,frame_count+1);
    end
  end
  else begin //CSI2
    $display("%0t CSI2 TX, Packet formatter is disabled",$realtime);
    for(frame_count=0;frame_count<NUM_FRAMES;frame_count=frame_count+1) begin
      $display("%0t FRAME #%0d START",$realtime,frame_count+1);
      //drive FS 
      drive_spkt(6'h00);

      for(line_count=0;line_count<NUM_LINES;line_count=line_count+1) begin
        if(LS_LE_EN) begin//drive LS
          drive_spkt(6'h02);
        end
        repeat(HS_RDY_TO_DPHY_PKTEN_DLY) begin
          wait_clock_edge;
        end
        crc=16'hFFFF; //reset crc
        drive_lpkt;
        if(LS_LE_EN) begin//drive LE
          drive_spkt(6'h03);
        end
      end
      drive_spkt(6'h01); //drive FE
      $display("%0t FRAME #%0d END",$realtime,frame_count+1);
    end
  end
end
// $finish;
end
endtask

task drive_hs_req();
begin
  if(DEBUG_ON)
    $display("%0t drive_hs_req START",$realtime);
  repeat(D_HS_RDY_TO_D_HS_CLK_EN_DLY) begin
    wait_clock_edge;
  end
  
  while (!c2d_ready_i) begin
    wait_clock_edge;
  end
  
  d_hs_en <= 1;
  clk_hs_en <= 1;

  repeat(5) begin
    wait_clock_edge;
  end
  d_hs_en <= 0;
  clk_hs_en <= 0;
  if(DEBUG_ON)
    $display("%0t drive_hs_req END",$realtime);
end
endtask

task display_data(input [63:0] disp);
begin
  if(DEBUG_ON)
    $display("%0t data = %0h",$realtime,disp);
end
endtask

task drive_spkt(input [5:0] dtype);
begin
  $display("%0t Transmitting short packet: %0h",$realtime,dtype);
  if(DEBUG_ON)
    $display("%0t drive_spkt START",$realtime);
  hdr_tmp = {fs_num,8'h00,VIRTUAL_CHANNEL,dtype};
  drive_hs_req();

  @(posedge d_hs_rdy);
  repeat(HS_RDY_TO_DPHY_PKTEN_DLY) begin
    wait_clock_edge;
  end
  dphy_pkten  = 1;
  compute_ecc(hdr_tmp,ecc);
  case(DPHY_LANES)
    1 : begin
      if(GEAR == 8) begin
        dphy_pkt[7:0] <= 8'hB8;
        wait_clock_edge;
        dphy_pkt[7:0] <= {VIRTUAL_CHANNEL,dtype};
        wait_clock_edge;
        dphy_pkt[7:0] <= 8'h00;
        wait_clock_edge;
        dphy_pkt[7:0] <= fs_num;
        wait_clock_edge;
        dphy_pkt[7:0] <= {2'h0,ecc};
        wait_clock_edge;
        if(EOTP_ENABLE == 1) begin
          dphy_pkt[7:0] <= 8'h08;
          wait_clock_edge;
          dphy_pkt[7:0] <= 8'h0F;
          wait_clock_edge;
          dphy_pkt[7:0] <= 8'h0F;
          wait_clock_edge;
          dphy_pkt[7:0] <= 8'h01;
          wait_clock_edge;
        end
      end
      else begin
        dphy_pkt[7:0] <= 8'h00;
        dphy_pkt[15:8] <= 8'hB8;
        wait_clock_edge;
        dphy_pkt[7:0] <= {VIRTUAL_CHANNEL,dtype};
        dphy_pkt[15:8] <= 8'h00;
        wait_clock_edge;
        dphy_pkt[7:0] <= fs_num;
        dphy_pkt[15:8] <= {2'h0,ecc};
        wait_clock_edge;
        if(EOTP_ENABLE == 1) begin
          dphy_pkt[7:0] <= 8'h08;
          dphy_pkt[15:8] <= 8'h0F;
          wait_clock_edge;
          dphy_pkt[7:0] <= 8'h0F;
          dphy_pkt[15:8] <= 8'h01;
          wait_clock_edge;
        end
      end
    end
    2 : begin
      if(GEAR == 8) begin
        dphy_pkt[7:0]   <= 8'hB8;
        dphy_pkt[23:16] <= 8'hB8;
        wait_clock_edge;
        dphy_pkt[ 7: 0] <= {VIRTUAL_CHANNEL,dtype};
        dphy_pkt[23:16] <= 8'h00;
        wait_clock_edge;
        dphy_pkt[ 7: 0] <= fs_num;
        dphy_pkt[23:16] <= {2'h0,ecc};
        wait_clock_edge;
        if(EOTP_ENABLE == 1) begin
          dphy_pkt[15: 0] <= 8'h08;   
          dphy_pkt[31:16] <= 8'h0F;
          wait_clock_edge;
          dphy_pkt[15: 0] <= 8'h0F;
          dphy_pkt[31:16] <= 8'h01;
          wait_clock_edge;
        end
      end
      else begin
        dphy_pkt[ 7: 0] <= 8'd0;
        dphy_pkt[15: 8] <= 8'hB8;
        dphy_pkt[23:16] <= 8'd0;
        dphy_pkt[31:24] <= 8'hB8;
        wait_clock_edge;
        dphy_pkt[ 7: 0] <= {VIRTUAL_CHANNEL,dtype};
        dphy_pkt[15: 8] <= {6'd0,fs_num};
        dphy_pkt[23:16] <= 8'h00;
        dphy_pkt[31:24] <= {2'h0,ecc};
        wait_clock_edge;
        if(EOTP_ENABLE == 1) begin
          dphy_pkt[ 7: 0] <= 8'h08;
          dphy_pkt[23:16] <= 8'h0F;
          dphy_pkt[15: 8] <= 8'h0F;
          dphy_pkt[31:24] <= 8'h01;
          wait_clock_edge;
        end
      end
    end 
    4 : begin
      if (GEAR == 16) begin /// GEAR 16
        dphy_pkt[15: 0] <= {VIRTUAL_CHANNEL[1:0],dtype[5:0],8'hB8};
        dphy_pkt[31:16] <= {8'd0,                    8'hB8};
        dphy_pkt[47:32] <= {fs_num,                           8'hB8};
        dphy_pkt[63:48] <= {2'd0,ecc,                       8'hB8};
        wait_clock_edge;
      end 
      else begin /// GEAR 8
        dphy_pkt[15: 0] <= {16'h00B8};
        dphy_pkt[31:16] <= {16'h00B8};
        dphy_pkt[47:32] <= {16'h00B8};
        dphy_pkt[63:48] <= {16'h00B8};
      wait_clock_edge;
        dphy_pkt[15: 0] <= {8'h00,VIRTUAL_CHANNEL,dtype};
        dphy_pkt[31:16] <= {8'h00,8'd0};
        dphy_pkt[47:32] <= {8'h00,6'd0,fs_num};
        dphy_pkt[63:48] <= {8'h00,2'h0,ecc};
      end
      wait_clock_edge;
      if(EOTP_ENABLE == 1) begin
        dphy_pkt[ 7: 0] <= {8'd0,8'h08};
        dphy_pkt[15: 8] <= {8'd0,8'h0F};
        dphy_pkt[23:16] <= {8'd0,8'h0F};
        dphy_pkt[31:24] <= {8'd0,8'h01};
        wait_clock_edge;
      end
    end
  endcase
  if (GEAR == 16) begin
    dphy_pkt <= {
                  {16{!dphy_pkt[63]}},
                  {16{!dphy_pkt[47]}},
                  {16{!dphy_pkt[31]}},
                  {16{!dphy_pkt[15]}}
                };
  end
  else begin
    dphy_pkt <= {
                  {16{!dphy_pkt[55]}},
                  {16{!dphy_pkt[39]}},
                  {16{!dphy_pkt[23]}},
                  {16{!dphy_pkt[ 7]}}
                };
  end
               
  wait_clock_edge;
  dphy_pkten <= 0;
  dphy_pkt   <= 'd0;
  if(dtype == 6'h01) begin
    fs_num = fs_num^2'b11;
    ls_num=1;
  end
  if(dtype == 6'h03) begin
    ls_num=ls_num+1;
  end
  if(DEBUG_ON)
    $display("%0t drive_spkt END",$realtime);
end
endtask

task drive_lpkt(); /// Modified by Davit Tamazyan (IMT) 08/27/2019
begin
  $display("%0t Transmitting video data data type : %0h , word count = %0d ...",$realtime,DATA_TYPE,num_bytes);
  if(DEBUG_ON) $display("%0t drive_lpkt START",$realtime); 
  ///////////////////////////////////////////////////////////////////////////
  /// Initialization
  ///////////////////////////////////////////////////////////////////////////
  crc_tmp            = 0;
  word_count         = num_bytes;
  pkt_hdr_tmp[ 5: 0] = data_type_int_w;
  pkt_hdr_tmp[ 7: 6] = VIRTUAL_CHANNEL;
  pkt_hdr_tmp[15: 8] = word_count[7:0];
  pkt_hdr_tmp[23:16] = word_count[15:8];
  compute_ecc(pkt_hdr_tmp,ecc);
  // dphy_pkt[63:0]     = 64'd0; 
  drive_hs_req;
  @(posedge d_hs_rdy);
  repeat(HS_RDY_TO_DPHY_PKTEN_DLY) begin
    wait_clock_edge;
  end
  dphy_pkten    <= 1;
  ///////////////////////////////////////////////////////////////////////////
  /// Sync Char and Header
  ///////////////////////////////////////////////////////////////////////////
  if (GEAR == 8 && DPHY_LANES == 1) begin
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 8 1 LANE START
    ///////////////////////////////////////////////////////////////////////////
    dphy_pkt[7:0] <= 8'hB8;
    wait_clock_edge;
    dphy_pkt[7:0] <= pkt_hdr_tmp[ 7: 0];
    wait_clock_edge;
    
    dphy_pkt[7:0] <= pkt_hdr_tmp[15: 8];
    wait_clock_edge;
    
    dphy_pkt[7:0] <= pkt_hdr_tmp[23:16];
    wait_clock_edge;
    
    dphy_pkt[7:0] <= ecc;
    wait_clock_edge;
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 8 1 LANE END
    ///////////////////////////////////////////////////////////////////////////
  end else
  if (GEAR == 8 && DPHY_LANES == 2) begin
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 8 2 LANE START
    ///////////////////////////////////////////////////////////////////////////
    dphy_pkt[15: 0] <= 16'h00B8;             dphy_pkt[31:16] <= 16'h00B8;
    wait_clock_edge;
    
    dphy_pkt[15: 0] <= pkt_hdr_tmp[7:0]; dphy_pkt[31:16] <= pkt_hdr_tmp[15:8];
    wait_clock_edge;
    
    dphy_pkt[15: 0] <= pkt_hdr_tmp[23:16]; dphy_pkt[31:16] <= {2'd0,ecc};
    wait_clock_edge;
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 8 2 LANE END
    ///////////////////////////////////////////////////////////////////////////
  end else
  if (GEAR == 8 && DPHY_LANES == 4) begin
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 8 4 LANE START
    ///////////////////////////////////////////////////////////////////////////
    dphy_pkt[15: 0] <= 16'hB8;             dphy_pkt[31:16] <= 16'hB8;             
    dphy_pkt[47:32] <= 16'hB8;             dphy_pkt[63:48] <= 16'hB8;
    wait_clock_edge;
    
    dphy_pkt[15: 0] <= pkt_hdr_tmp[7:0]; dphy_pkt[31:16] <= pkt_hdr_tmp[15: 8];
    dphy_pkt[47:32] <= pkt_hdr_tmp[23: 16]; dphy_pkt[63:48] <= {2'd0,ecc};
    wait_clock_edge;
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 8 4 LANE END
    ///////////////////////////////////////////////////////////////////////////
  end else
  if (GEAR == 16 && DPHY_LANES == 1) begin
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 16 1 LANE START
    ///////////////////////////////////////////////////////////////////////////
    dphy_pkt[31: 0] <= 16'hB800;
    wait_clock_edge;
    
    dphy_pkt[15: 0] <= pkt_hdr_tmp[ 15: 0]; 
    wait_clock_edge;
    
    dphy_pkt[15: 0] <= {ecc,pkt_hdr_tmp[23:16]};
    wait_clock_edge;
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 16 2 LANE END
    ///////////////////////////////////////////////////////////////////////////
  end else
  if (GEAR == 16 && DPHY_LANES == 2) begin
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 16 2 LANE START
    ///////////////////////////////////////////////////////////////////////////
    dphy_pkt[31: 0] <= 32'hB800B800;
    wait_clock_edge;
    
    dphy_pkt[15: 0] <= {pkt_hdr_tmp[23: 16],pkt_hdr_tmp[ 7: 0]}; 
    dphy_pkt[31:16] <= {ecc,pkt_hdr_tmp[15: 8]};
    wait_clock_edge;
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 16 2 LANE END
    ///////////////////////////////////////////////////////////////////////////
  end else
  if (GEAR == 16 && DPHY_LANES == 4) begin
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 16 4 LANE START
    ///////////////////////////////////////////////////////////////////////////
    dphy_pkt[63: 0] <= {
                        2'd0,ecc          ,8'hB8,
                        pkt_hdr_tmp[23:16],8'hB8,
                        pkt_hdr_tmp[15: 8],8'hB8,
                        pkt_hdr_tmp[ 7: 0],8'hB8
                        };
    wait_clock_edge;
    ///////////////////////////////////////////////////////////////////////////
    /// GEAR 16 4 LANE END
    ///////////////////////////////////////////////////////////////////////////
  end

  byte_count=0;       /// minus if num_bytes aren't multiple of byte per trans
  while(byte_count < (num_bytes - (num_bytes % ((((GEAR-8)/8)+1)*DPHY_LANES)))) begin 
    ///////////////////////////////////////////////////////////////////////////
    /// Byte data transmit(display and write in file)
    ///////////////////////////////////////////////////////////////////////////
    byte_data_temp = $random;           
                     wr_in_file(0);                       /// Task which write data in file
    dphy_pkt       = byte_data_temp;                      /// Transmit data
                     display_data(dphy_pkt);              /// Display
                     wait_clock_edge;                     /// Wait for Byte Clock
    byte_count     = byte_count + (((GEAR-8)/8)+1)*DPHY_LANES;    /// Update byte counter
    ///////////////////////////////////////////////////////////////////////////
    /// CRC calculation
    ///////////////////////////////////////////////////////////////////////////
    crc = 16'hFFFF;
    if (GEAR == 16) begin : CRC_CALC
      if (DPHY_LANES == 1) begin
          compute_crc(dphy_pkt[ 7: 0]); compute_crc(dphy_pkt[15: 8]);
      end else
      if (DPHY_LANES == 2) begin
          compute_crc(dphy_pkt[ 7: 0]); compute_crc(dphy_pkt[23:16]);
          compute_crc(dphy_pkt[15: 8]); compute_crc(dphy_pkt[31:24]);
      end else
      if (DPHY_LANES == 4) begin
          compute_crc(dphy_pkt[ 7: 0]); 
          compute_crc(dphy_pkt[23:16]);  
          compute_crc(dphy_pkt[39:32]);  
          compute_crc(dphy_pkt[55:48]); 
          compute_crc(dphy_pkt[15: 8]);
          compute_crc(dphy_pkt[31:24]);
          compute_crc(dphy_pkt[47:40]);
          compute_crc(dphy_pkt[63:56]);
      end
    end
    else begin
      if (DPHY_LANES == 1) begin
          compute_crc(dphy_pkt[ 7: 0]);
      end else
      if (DPHY_LANES == 2) begin
          compute_crc(dphy_pkt[ 7: 0]); compute_crc(dphy_pkt[23:16]);
      end else
      if (DPHY_LANES == 4) begin
          compute_crc(dphy_pkt[ 7: 0]); compute_crc(dphy_pkt[23:16]); 
          compute_crc(dphy_pkt[39:32]); compute_crc(dphy_pkt[55:48]);
      end
    end
  end
    ///////////////////////////////////////////////////////////////////////////
    /// Transmit residue of data(if exist), crc and trail 
    ///////////////////////////////////////////////////////////////////////////
      if (DPHY_LANES == 1 && GEAR == 8) begin
        dphy_pkt = {56'd0,crc[7:0]};
        wait_clock_edge;
        dphy_pkt = {56'd0,crc[15:8]};
        wait_clock_edge;
        dphy_pkt = {16{!dphy_pkt[7]}};/// HS_TRAIL start
        wait_clock_edge;
      end else 
      if (DPHY_LANES == 2 && GEAR == 8) begin
        if (num_bytes % ((((GEAR-8)/8)+1)*DPHY_LANES)) begin /// if residue data exist, 1 byte still didn't send
        byte_data_temp = $random;
        compute_crc(byte_data_temp[ 7: 0]); /// CRC calculation
        dphy_pkt = {
                    8'd0,8'd0,
                    8'd0,8'd0,
                    8'd0,crc[7:0],
                    8'd0,byte_data_temp[7:0]};
        wait_clock_edge;
        dphy_pkt = {
                      8'd0,8'd0,
                      8'd0,8'd0,
                      8'd0,{8{!dphy_pkt[23]}}, /// HS_TRAIL start
                      8'd0,crc[15:8]
                    };
        wait_clock_edge;
        dphy_pkt = {
                      8'd0,8'd0,
                      8'd0,8'd0,
                      8'd0,{8{dphy_pkt[23]}},/// HS_TRAIL continue
                      8'd0,{8{!dphy_pkt[ 7]}}
                    };
        wait_clock_edge;
        end
        else begin
        dphy_pkt = {
                    8'd0,8'd0,
                    8'd0,8'd0,
                    8'd0,crc[15:8],
                    8'd0,crc[7:0]};
        wait_clock_edge;
        dphy_pkt = {
                      8'd0,8'd0,
                      8'd0,8'd0,
                      8'd0,{8{!dphy_pkt[23]}}, /// HS_TRAIL start
                      8'd0,{8{!dphy_pkt[ 7]}}  /// HS_TRAIL start
                    };
        wait_clock_edge;
        end
      end else 
      if (DPHY_LANES == 4 && GEAR == 8) begin
        if (num_bytes % ((((GEAR-8)/8)+1)*DPHY_LANES)) begin /// if residue data exist, 1, 2 or 3 byte still didn't send
          byte_data_temp = $random;
          if ((num_bytes % ((((GEAR-8)/8)+1)*DPHY_LANES)) == 1) begin
            compute_crc(dphy_pkt[ 7: 0]);
            dphy_pkt  = {
                          {16{!dphy_pkt[55]}},/// HS_TRAIL start
                          {8'd0,crc[15:8]},
                          {8'd0,crc[7:0]},
                          {8'd0,byte_data_temp[7:0]}
                        };
            wait_clock_edge;
            dphy_pkt  = {
                          {16{ dphy_pkt[55]}}, /// HS_TRAIL continue
                          {16{!dphy_pkt[39]}}, /// HS_TRAIL start
                          {16{!dphy_pkt[23]}}, /// HS_TRAIL start
                          {16{!dphy_pkt[ 7]}}  /// HS_TRAIL start
                        };
          end else
          if ((num_bytes % ((((GEAR-8)/8)+1)*DPHY_LANES)) == 2) begin 
            compute_crc(dphy_pkt[ 7: 0]); compute_crc(dphy_pkt[15:8]);
            dphy_pkt  = {
                          {8'd0,crc[15:8]},
                          {8'd0,crc[ 7:0]},
                          {8'd0,byte_data_temp[15:8]},
                          {8'd0,byte_data_temp[7:0]}
                        };
            wait_clock_edge;
            dphy_pkt  = {
                          {16{!dphy_pkt[55]}}, /// HS_TRAIL start
                          {16{!dphy_pkt[39]}}, /// HS_TRAIL start
                          {16{!dphy_pkt[23]}}, /// HS_TRAIL start
                          {16{!dphy_pkt[ 7]}}  /// HS_TRAIL start
                        };
          end else
          if ((num_bytes % ((((GEAR-8)/8)+1)*DPHY_LANES)) == 4) begin 
          compute_crc(dphy_pkt[ 7: 0]); compute_crc(dphy_pkt[15: 8]); 
          compute_crc(dphy_pkt[23:16]); compute_crc(dphy_pkt[31:24]);
            dphy_pkt  = {
                          {8'd0,crc[7:0]},
                          {8'd0,byte_data_temp[23:16]},
                          {8'd0,byte_data_temp[15: 8]},
                          {8'd0,byte_data_temp[ 7: 0]}
                        };
            wait_clock_edge;
            dphy_pkt  = {
                          {16{!dphy_pkt[55]}}, /// HS_TRAIL start
                          {16{!dphy_pkt[39]}}, /// HS_TRAIL start
                          {16{!dphy_pkt[23]}}, /// HS_TRAIL start
                          {8'd0,crc[15:8]}
                         };
            wait_clock_edge;
            dphy_pkt  = {
                          {16{ dphy_pkt[55]}}, /// HS_TRAIL continue
                          {16{ dphy_pkt[39]}}, /// HS_TRAIL continue
                          {16{ dphy_pkt[23]}}, /// HS_TRAIL continue
                          {16{!dphy_pkt[ 7]}}  /// HS_TRAIL start
                         };
          end
        end
        else begin
          dphy_pkt <= {
                        {16{!dphy_pkt[55]}},/// HS_TRAIL start
                        {16{!dphy_pkt[39]}},/// HS_TRAIL start
                        {8'd0,crc[15:8]},
                        {8'd0,crc[7:0]}
                      };
          wait_clock_edge;
          dphy_pkt <= {
                        {16{ dphy_pkt[55]}},/// HS_TRAIL continue
                        {16{ dphy_pkt[39]}},/// HS_TRAIL continue
                        {16{!dphy_pkt[23]}},/// HS_TRAIL start
                        {16{!dphy_pkt[ 7]}} /// HS_TRAIL start
                      };
          wait_clock_edge;
        
        end
      end else 
      if (DPHY_LANES == 1 && GEAR == 16) begin
        dphy_pkt = {40'd0,crc[15:8], 8'd0,crc[7:0]};
        wait_clock_edge;
        dphy_pkt = {48'd0,{16{!crc[15]}}};/// HS_TRAIL start
        wait_clock_edge;
        dphy_pkt = {48'd0,{16{!crc[15]}}};
        wait_clock_edge;
      end else 
      if (DPHY_LANES == 2 && GEAR == 16) begin
        dphy_pkt = {8'd0,8'd0,
                    8'd0,8'd0,
                    {8{!crc[15]}},crc[15:8],
                    {8{!crc[7]}},crc[7:0]
                    };
        wait_clock_edge;
        dphy_pkt = {8'd0,8'd0,
                    8'd0,8'd0,
                    {16{!crc[15]}},
                    {16{!crc[7]}}
                    };
        wait_clock_edge;
      end else 
      if (DPHY_LANES == 4 && GEAR == 16) begin
        dphy_pkt[63: 0] <= {
                              {16{!dphy_pkt[63]}},        /// HS_TRAIL start
                              {16{!dphy_pkt[47]}},        /// HS_TRAIL start
                              {8{!crc[15]}},crc[15:8],
                              {8{!crc[7]}},crc[7:0]
                            };
        wait_clock_edge;
        dphy_pkt[63: 0] <= {
                              {16{dphy_pkt[63]}},        /// HS_TRAIL continue
                              {16{dphy_pkt[47]}},        /// HS_TRAIL continue
                              {16{dphy_pkt[31]}},        /// HS_TRAIL continue
                              {16{dphy_pkt[15]}}         /// HS_TRAIL continue
                            };
          wait_clock_edge;
      end
      dphy_pkten <= 0;

  // if (GEAR) begin
    // dphy_pkt <= {
                  // {16{!dphy_pkt[63]}},
                  // {16{!dphy_pkt[47]}},
                  // {16{!dphy_pkt[31]}},
                  // {16{!dphy_pkt[15]}}
                // };
  // end
  // else begin
    // dphy_pkt <= {
                  // {16{!dphy_pkt[55]}},
                  // {16{!dphy_pkt[39]}},
                  // {16{!dphy_pkt[23]}},
                  // {16{!dphy_pkt[ 7]}}
                // };
  // end
  // wait_clock_edge;
  $display("%0t Transmit video data DONE!",$realtime);
  if(DEBUG_ON) $display("%0t drive_lpkt END",$realtime);
end 
endtask

task compute_crc(input [7:0] pkt_val);
begin
  for(k=0;k<8;k=k+1) begin
    cur_crc = crc;
    cur_crc[15] = pkt_val[k]^cur_crc[0];
    cur_crc[10] = cur_crc[11]^cur_crc[15];
    cur_crc[3]  = cur_crc[4]^cur_crc[15];
    crc = crc >> 1;
    crc[15] = cur_crc[15];
    crc[10] = cur_crc[10];
    crc[3]  = cur_crc[3]; 
  end
end
endtask

task compute_ecc(input [23:0] d, output [5:0] ecc_val);
begin
  ecc_val[0] =d[0]^d[1]^d[2]^d[4]^d[5]^d[7]^d[10]^d[11]^d[13]^d[16]^d[20]^d[21]^d[22]^d[23];
  ecc_val[1] = d[0]^d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[12]^d[14]^d[17]^d[20]^d[21]^d[22]^d[23];
  ecc_val[2] = d[0]^d[2]^d[3]^d[5]^d[6]^d[9]^d[11]^d[12]^d[15]^d[18]^d[20]^d[21]^d[22];
  ecc_val[3] = d[1]^d[2]^d[3]^d[7]^d[8]^d[9]^d[13]^d[14]^d[15]^d[19]^d[20]^d[21]^d[23];
  ecc_val[4] = d[4]^d[5]^d[6]^d[7]^d[8]^d[9]^d[16]^d[17]^d[18]^d[19]^d[20]^d[22]^d[23];
  ecc_val[5] = d[10]^d[11]^d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[21]^d[22]^d[23];
end
endtask

task drive_byte();
begin
  $display("%0t Transmitting data, data type : %0h , word count = %0d ...",$realtime,DATA_TYPE,num_bytes);
  if (DEVICE_TYPE == "CSI2") begin @(negedge ld_pyld_i); end
  wait_clock_edge;
  wait_clock_edge;
  dt           <= data_type_int_w;
  wc           <= num_bytes;
  byte_data_en <= 1;
  byte_count    = 0;
  while(byte_count<num_bytes) begin
    byte_data_temp = $random;
    /////////////////////////////////////////////////////////////////////////////
    /// Write data in log file (Davit)
    /////////////////////////////////////////////////////////////////////////////
    if (GEAR == 16 & DPHY_LANES == 4) begin
      if ((num_bytes-byte_count) == 32'd1) begin
        wr_in_file(4'd1);
      end else
      if ((num_bytes-byte_count) == 32'd2) begin
        wr_in_file(4'd2);
      end else
      if ((num_bytes-byte_count) == 32'd3) begin
        wr_in_file(4'd3);
      end else
      if ((num_bytes-byte_count) == 32'd4) begin
        wr_in_file(4'd4);
      end else
      if ((num_bytes-byte_count) == 32'd5) begin
        wr_in_file(4'd5);
      end else
      if ((num_bytes-byte_count) == 32'd6) begin
        wr_in_file(4'd6);
      end else
      if ((num_bytes-byte_count) == 32'd7) begin
        wr_in_file(4'd7);
      end
      else begin
        wr_in_file(0);/// Task which will write data in file
      end
    end
    else if (GEAR == 8 & DPHY_LANES == 4) begin
      if ((num_bytes-byte_count) == 32'd1) begin
        wr_in_file(4'd1);
      end else
      if ((num_bytes-byte_count) == 32'd2) begin
        wr_in_file(4'd2);
      end else
      if ((num_bytes-byte_count) == 32'd3) begin
        wr_in_file(4'd3);
      end
      else begin
        wr_in_file(0);/// Task which will write data in file
      end
    end
    else if (GEAR == 16 & DPHY_LANES == 2) begin
      if ((num_bytes-byte_count) == 32'd1) begin
        wr_in_file(4'd1);
      end else
      if ((num_bytes-byte_count) == 32'd2) begin
        wr_in_file(4'd2);
      end else
      if ((num_bytes-byte_count) == 32'd3) begin
        wr_in_file(4'd3);
      end
      else begin
        wr_in_file(0);/// Task which will write data in file
      end
    end
    else if (GEAR == 16 & DPHY_LANES == 1) begin
      if ((num_bytes-byte_count) == 32'd1) begin
        wr_in_file(4'd1);
      end
      else begin
        wr_in_file(0);/// Task which will write data in file
      end
    end
    else if (GEAR == 8 & DPHY_LANES == 2) begin
      if ((num_bytes-byte_count) == 32'd1) begin
        wr_in_file(4'd1);
      end
      else begin
        wr_in_file(0);/// Task which will write data in file
      end
    end
    else begin
      wr_in_file(0);/// Task which will write data in file
    end
    /////////////////////////////////////////////////////////////////////////////
    /// End
    /////////////////////////////////////////////////////////////////////////////
    byte_data <= byte_data_temp;
    display_data(byte_data);
    wait_clock_edge;
    case(DPHY_LANES)
      1 : byte_count = byte_count + ((GEAR == 8) ? 1 : 2);
      2 : byte_count = byte_count + ((GEAR == 8) ? 2 : 4);
      4 : byte_count = byte_count + ((GEAR == 8) ? 4 : 8);
    endcase
  end
  byte_data_en <= 0;
  byte_data <= 0;
  $display("%0t Transmitting data DONE!",$realtime);
end
endtask

task drive_lp();
begin
  if(DEBUG_ON)
    $display("%0t drive_lp START",$realtime);
  repeat(HS_RDY_NEG_TO_HS_CLK_EN_DLY) begin
    wait_clock_edge;
  end
  drive_hs_req;
  @(posedge d_hs_rdy);

  repeat(HS_RDY_TO_LP_EN_DLY) begin
    wait_clock_edge;
  end
  lp_en <= 1;
  dt <= data_type_int_w;
  vc <= VIRTUAL_CHANNEL;
  wc <= num_bytes;
  wait_clock_edge;
  lp_en <= 0;
  if(DEBUG_ON)
    $display("%0t drive_lp END",$realtime);
end
endtask

task drive_sp(input [5:0] dtype);
begin
  $display("%0t Transmitting short packet : %0h",$realtime,dtype);
  if(DEBUG_ON)
    $display("%0t drive_sp START",$realtime);
  repeat(HS_RDY_NEG_TO_HS_CLK_EN_DLY) begin
    wait_clock_edge;
  end
  drive_hs_req;
  @(posedge d_hs_rdy);

  repeat(HS_RDY_TO_SP_EN_DLY) begin
    wait_clock_edge;
  end

  sp_en <= 1;
  dt <= dtype;
  vc <= VIRTUAL_CHANNEL;

  if(GEN_FR_NUM == 1) begin
    if(dtype == 6'h00) begin
      wc      <= 0;
      wc[1:0] <= fs_num;
    end
    else if(dtype == 6'h01) begin
      wc      <= 0;
      wc[1:0] <= fs_num;
      fs_num = fs_num^2'b11;
      ls_num=1;
    end
  end
  if(GEN_LN_NUM == 1) begin
    if(dtype == 6'h02) begin
      wc <= ls_num;
    end
    else if(dtype == 6'h03) begin
      wc <= ls_num;
      ls_num=ls_num+1;
    end
  end
  wait_clock_edge;
  sp_en <= 0;
  @(negedge d_hs_rdy); 
  if(DEBUG_ON)
    $display("%0t drive_sp END",$realtime);
end  
endtask

task drive_vsync_st();
begin
  $display("%0t Transmitting vsync start",$realtime);
  if(DEBUG_ON)
    $display("%0t drive_vsync_st START",$realtime);
  repeat(HS_RDY_TO_LP_EN_DLY) begin
    wait_clock_edge;
  end
  drive_hs_req;
  @(posedge d_hs_rdy);

  repeat(HS_RDY_TO_VSYNC_START_DLY) begin
    wait_clock_edge;
  end

  vsync_start <= 1;
  dt <= 6'h01;
  vc <= VIRTUAL_CHANNEL;
  eotp <= EOTP_ENABLE;
 
  wait_clock_edge;
  vsync_start <= 0;
  @(negedge d_hs_rdy);
  repeat(VSYNC_TO_HSYNC_DLY) begin
    wait_clock_edge;
  end
  if(DEBUG_ON)
    $display("%0t drive_vsync_st END",$realtime);
end
endtask

task drive_hsync_st();
begin
  $display("%0t Transmitting hsync start",$realtime);
  if(DEBUG_ON)
    $display("%0t drive_hsync_st START",$realtime);
  repeat(HS_RDY_TO_LP_EN_DLY) begin
    wait_clock_edge;
  end
  drive_hs_req;
  @(posedge d_hs_rdy);

  repeat(HS_RDY_TO_HSYNC_START_DLY) begin
    wait_clock_edge;
  end

  hsync_start <= 1;
  dt <= 6'h21;
  vc <= VIRTUAL_CHANNEL;
  eotp <= EOTP_ENABLE;
 
  wait_clock_edge;
  hsync_start <= 0;
  @(negedge d_hs_rdy);
  repeat(HSYNC_TO_HSYNC_DLY) begin
    wait_clock_edge;
  end
  if(DEBUG_ON)
    $display("%0t drive_hsync_st END",$realtime);
end
endtask

task wait_clock_edge();
begin
  if(DRIVING_EDGE == 1) begin
    @(posedge ref_clk);
  end
  else begin
    @(negedge ref_clk);
  end
end
endtask

task wr_in_file(
  input [3:0] add_data
  );
  reg in_process;/// For debug
  begin
    #1;
    in_process = 1;
    if (GEAR == 16 & DPHY_LANES == 4) begin
      if (add_data == 4'd0) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n%0x\n%0x\n%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32],byte_data_temp[55:48],byte_data_temp[15:8],byte_data_temp[31:24],byte_data_temp[47:40],byte_data_temp[63:56]);
      end else
      if (add_data == 4'd7) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n%0x\n%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32],byte_data_temp[55:48],byte_data_temp[15:8],byte_data_temp[31:24],byte_data_temp[47:40]);
      end else
      if (add_data == 4'd6) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32],byte_data_temp[55:48],byte_data_temp[15:8],byte_data_temp[31:24]);
      end else
      if (add_data == 4'd5) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32],byte_data_temp[55:48],byte_data_temp[15:8]);
      end else
      if (add_data == 4'd4) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32],byte_data_temp[55:48]);
      end else
      if (add_data == 4'd3) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32]);
      end else
      if (add_data == 4'd2) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16]);
      end else
      if (add_data == 4'd1) begin
        $fwrite(tx_input_data_file,"%0x\n",byte_data_temp[7:0]);
      end
    end else
    if (GEAR == 16 & DPHY_LANES == 2) begin
      if (add_data == 4'd3) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[15:8]);
      end else
      if (add_data == 4'd2) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16]);
      end else
      if (add_data == 4'd1) begin
        $fwrite(tx_input_data_file,"%0x\n",byte_data_temp[7:0]);
      end else
      if (add_data == 4'd0) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[15:8],byte_data_temp[31:24]);
      end
    end else
    if (GEAR == 16 & DPHY_LANES == 1) begin
      if (add_data == 4'd1) begin
        $fwrite(tx_input_data_file,"%0x\n",byte_data_temp[7:0]);
      end
      else begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[15:8]);
      end
    end else
    if (GEAR == 8 & DPHY_LANES == 4) begin
      if (add_data == 4'd3) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32]);
      end else
      if (add_data == 4'd2) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16]);
      end else
      if (add_data == 4'd1) begin
        $fwrite(tx_input_data_file,"%0x\n",byte_data_temp[7:0]);
      end else
      if (add_data == 4'd0) begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16],byte_data_temp[39:32],byte_data_temp[55:48]);
      end
    end else
    if (GEAR == 8 & DPHY_LANES == 2) begin
      if (add_data == 4'd1) begin
        $fwrite(tx_input_data_file,"%0x\n",byte_data_temp[7:0]);
      end
      else begin
        $fwrite(tx_input_data_file,"%0x\n%0x\n",byte_data_temp[7:0],byte_data_temp[23:16]);
      end
    end else
    if (GEAR == 8 & DPHY_LANES == 1) begin
      $fwrite(tx_input_data_file,"%0x\n",byte_data_temp[7:0]);
    end
    #1;
    in_process = 0;
  end
endtask

task optional_test;
  begin
    $display("Optional start");
    fork
      begin /// Test
        repeat(9) begin
          $display("Request");
          d_hs_en   = 1;
          clk_hs_en = 1;
          wait_clock_edge;
          d_hs_en   = 0;
          @(posedge d_hs_rdy); $display("Response");
          repeat (40) begin
            dphy_pkt      = $random;
            dphy_pkten    = 1'd1;
            byte_data     = $random;
            byte_data_en  = 1'd1;
            wait_clock_edge;
          end
          dphy_pkten    = 1'd0;
          byte_data_en  = 1'd0;
          @(posedge c2d_ready_i)
          wait_clock_edge;
        end
        if (clock_check.fail) begin
          $display("FAIL");
        end 
        else begin
          $display("PASS");
        end
        // $stop;
      end
      begin /// Check
        @(posedge d_hs_rdy); $display("Response");
        clock_check;
      end
    join
  end
endtask
task clock_check;
  reg fail;
  begin
    @(posedge clk_hs_en);
    @(posedge d_hs_rdy);
    fail = 0;
    while (!fail) begin
      #1;
      if (c_p_io ^ c_n_io) begin
        /// Pass
      end
      else begin
        fail = 1;
      end
    end
  end
endtask

endmodule
// =============================================================================
// dphy_tx_model.v
// =============================================================================
`endif


