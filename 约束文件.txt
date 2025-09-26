# FPGAOL ZYNQ XDC v2.1
# device xc7a35tfgg484-1

# Clock signal
set_property -dict { PACKAGE_PIN V18  IOSTANDARD LVCMOS33 } [get_ports {clk}]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# FPGAOL SWITCH
set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports { in[0] }]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { in[1] }]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { in[2] }]
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { in[3] }]
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports { in[4] }]
set_property -dict { PACKAGE_PIN C19   IOSTANDARD LVCMOS33 } [get_ports { ctrl[0] }]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports { ctrl[1] }]
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { rst }]

# FPGAOL HEXPLAY
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { seg_data[0] }]
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { seg_data[1] }]
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports { seg_data[2] }]
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports { seg_data[3] }]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { seg_an[0] }]
set_property -dict { PACKAGE_PIN A19   IOSTANDARD LVCMOS33 } [get_ports { seg_an[1] }]
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports { seg_an[2] }]

# FPGAOL BUTTON & SOFT_CLOCK
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports { enable }]