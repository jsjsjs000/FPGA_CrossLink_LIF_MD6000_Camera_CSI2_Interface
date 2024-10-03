#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LIFMD
set_option -part LIF_MD6000
set_option -package KMG80I
set_option -speed_grade -6

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency 1
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false
set_option -frequency 1
set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -seqshift_no_replicate 0

#-- add_file options
set_option -hdl_define -set SBP_SYNTHESIS
set_option -include_path {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/csi2_output/csi2_output.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/csi2_output/csi2_output_dphy_tx.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/csi2_output/csi2_output_synchronizer.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/csi2_output/csi2_output_dci_wrapper.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/csi2_output/csi2_output_pkt_formatter_bb.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/csi2_output/csi2_output_tinit_count_bb.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/csi2_output/csi2_output_tx_global_operation_bb.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/ip_cores/ip_cores.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/i2c_slave_top.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/image_generator.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/simulator_top.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/csi2_tx_simulator_ctrl.v}
add_file -verilog -vlog_std v2001 {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/i2c_slave_logic.v}

#-- top module name
set_option -top_module simulator_top

#-- set result format/file last
project -result_file {C:/jarsulk-pco/projects/CrossLink-IR-Camera-CSI2-Interface/impl4_csi2_hackster_test_screen/CrossLink_IR_Camera_CSI2_Interface_impl4_csi2_hackster_test_screen.edi}

#-- error message log file
project -log_file {CrossLink_IR_Camera_CSI2_Interface_impl4_csi2_hackster_test_screen.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
