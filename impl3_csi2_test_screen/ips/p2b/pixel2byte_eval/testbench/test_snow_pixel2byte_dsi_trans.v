// =========================================================================
// Filename: test_snow_pixel2byte_dsi_trans.v
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved.
// =========================================================================

`ifdef DSI_TEST1

task test_snow_pixel2byte_dsi_trans;
   begin

      fork

`ifdef MISC_ON
      //while((frame_cnt !== num_frames)) begin

      //    @(vsync_start or vsync_end or hsync_start or hsync_end or byte_data or data_type or frame_cnt);
      //    #1;

      //    if(frame_cnt == num_frames) begin
      //        $display($time, " TEST DONE ", data_type);
      //    end
      //    else
      //    begin

      //        if(vsync_start) begin
      //            if(data_type !== 6'h00) begin
      //                $display($time, " ERROR : data_type_o not matched for vsync_start : %h ", data_type);
      //                testfail_cnt = testfail_cnt+1;
      //            end
      //        end
      //        else
      //        if(vsync_end) begin
      //            if(data_type !== 6'h01) begin
      //               $display($time, " ERROR : data_type_o not matched for vsync_end : %h ", data_type);
      //               testfail_cnt = testfail_cnt+1;
      //            end
      //        end
      //        else
      //        //if(hsync_start) begin
      //        if((hsync_start) | (data_type == 6'h02))  begin
      //            //if(data_type !== 6'h02)) begin
      //            //    $display($time, " ERROR : data_type_o not matched for hsync_start : %h ", data_type);
      //            //    testfail_cnt = testfail_cnt+1;
      //            //end
      //        end
      //        else
      //        if((hsync_end) | (data_type == 6'h02)) begin
      //            //if(data_type !== 6'h03)) begin
      //            //    $display($time, " ERROR : data_type_o not matched for hsync_end : %h ", data_type);
      //            //    testfail_cnt = testfail_cnt+1;
      //            //end
      //        end
      //        else
      //        `ifdef RGB666
      //        if(data_type !== 6'h23) begin
      //        `elsif RGB888
      //        if(data_type !== 6'h24) begin
      //        `elsif RAW8
      //        if(data_type !== 6'h2A) begin
      //        `elsif RAW10
      //        if(data_type !== 6'h2B) begin
      //        `elsif RAW12
      //        if(data_type !== 6'h2C) begin
      //        `elsif YUV420_8
      //        if(data_type !== 6'h18) begin
      //        `elsif YUV420_10
      //        if(data_type !== 6'h19) begin
      //        `elsif YUV422_8
      //        if(data_type !== 6'h1E) begin
      //        `elsif YUV422_10
      //        if(data_type !== 6'h1F) begin
      //        `endif
      //            $display($time, " ERROR : data_type_o not matched for respective data_type : %h ", data_type);
      //            testfail_cnt = testfail_cnt+1;
      //        end
      //    end
      //end
`endif

      //Stop test after Frame count reached to NumFrames
      $display($time, " Num Frames: %d", num_frames);
      while((frame_cnt !== num_frames)) begin
        @(posedge  eof);
        #1;
        if(eof) begin
          frame_cnt = frame_cnt+1;
        end
      end

      join
   end

endtask

`endif
