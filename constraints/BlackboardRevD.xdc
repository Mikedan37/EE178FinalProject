## Master .xdc for the Blackboard

## Clock
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## Reset Button (use BTN1 as Reset)
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { rst }];

## Card Input Switches (SW0, SW1)
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { sw_card_input[0] }];
set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { sw_card_input[1] }];

## Menu Input Switches (SW2, SW3, SW4)
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { sw_menu_input[0] }];
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { sw_menu_input[1] }];
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { sw_menu_input[2] }];

## Confirm Button (BTN0)
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { btn_confirm }];

## Deposit Amount Switches (SW5-SW12) (Optional)
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { sw_deposit_amount[0] }];
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { sw_deposit_amount[1] }];
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { sw_deposit_amount[2] }];
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { sw_deposit_amount[3] }];
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { sw_deposit_amount[4] }];
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { sw_deposit_amount[5] }];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { sw_deposit_amount[6] }];
# Only 7 bits mapped so far - if you want full 8 bits, we'll need to reassign

## Withdraw Amount Switches (could reuse same as deposit or SW6-SW13 if expanded)

## LEDs (LD0-LD9)
set_property -dict { PACKAGE_PIN N20   IOSTANDARD LVCMOS33 } [get_ports { leds_out[0] }];
set_property -dict { PACKAGE_PIN P20   IOSTANDARD LVCMOS33 } [get_ports { leds_out[1] }];
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { leds_out[2] }];
set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { leds_out[3] }];
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { leds_out[4] }];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { leds_out[5] }];
set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { leds_out[6] }];
set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { leds_out[7] }];
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { leds_out[8] }];
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { leds_out[9] }];

## Optional: RGB LED (LD10_R)
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { leds_out[10] }];

## Speaker (Optional) - connect buzzer to the audio out
#set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports { buzzer }];

