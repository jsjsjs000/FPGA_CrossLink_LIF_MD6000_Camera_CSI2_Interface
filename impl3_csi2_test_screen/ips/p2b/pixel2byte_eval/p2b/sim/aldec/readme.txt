
================================================================================
1. Create new project using Lattice Diamond for Windows.
2. Open Active-HDL Lattice Edition GUI tool.
3. Modify the "tb_params.v" file located in 
   \<project_dir>\<core_instance_name>\<core_name>_eval\testbench\.
   a. Update testbench parameters to customize data size and/or other settings. 
      See additional info related to Testbench Parameters below.
      Please note that it is required to update the SIP_PCLK, SIP_BCLK,and
      NUM_BYTES to be consistent with the target for simulations.
4. Click Tools -> Execute macro, then select the *run.do file.
5. Wait for simulation to finish.

################################################################################
Testbench Parameters

Below are the testbench directives which can be modified by setting the define 
in the "tb_params.v" file.

   * SIP_PCLK     - Used to set the period of the input pixel clock (in ps)
                    Must include at least 1 decimal
   * SIP_BCLK     - Used to set the period of the input byte clock (in ps) 
                    Must include at least 1 decimal
   * NUM_FRAMES   - Used to set the number of video frames
   * NUM_LINES    - Used to set the number of lines per frame
   * HFRONT       - Number of cycles before HSYNC signal asserts 
                    (Horizontal Front Blanking)
   * HPULSE       - Number of cycles HSYNC signal asserts
   * HBACK        - Number of cycles after HSYNC signal asserts 
                    (Horizontal Rear Blanking)
   * VFRONT       - Number of cycles before VSYNC signal asserts 
                    (Vertical Front Blanking)
   * VPULSE       - Number of cycles VSYNC signal asserts
   * VBACK        - Number of cycles after VSYNC signal asserts 
                    (Vertical Rear Blanking)
   * NUM_BYTES    - Number of bytes sent per line

   *User can override the default timing parameters using defines above.
================================================================================
