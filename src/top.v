// top.v
// Top-level wrapper for ATM FSM
// Connects physical switches, buttons, and LEDs to atm_fsm

module top (
    input clk,
    input rst,
    input [1:0] sw_card_input,        // SW0-SW1
    input [2:0] sw_menu_input,         // SW2-SW4
    input btn_confirm,                 // BTN0
    input [7:0] sw_deposit_amount,     // SW8-SW15 (optional)
    input [7:0] sw_withdraw_amount,    // SW16-SW23 (optional)
    output [7:0] balance_out,
    output [10:0] leds_out,
    output [3:0] seg_display,
    output buzzer
);

    // Internal wires to connect ATM FSM
    wire [7:0] balance;
    wire [10:0] leds;
    wire [3:0] seg_value;
    wire beep;

    // Instantiate your ATM FSM
    atm_fsm u_atm_fsm (
        .clk(clk),
        .rst(rst),
        .card_input(sw_card_input),
        .menu_input(sw_menu_input),
        .confirm_btn(btn_confirm),
        .deposit_amount(sw_deposit_amount),
        .withdraw_amount(sw_withdraw_amount),
        .balance(balance),
        .leds(leds),
        .seg_value(seg_value),
        .beep(beep)
    );

    // Connect internal outputs to top-level outputs
    assign balance_out = balance;
    assign leds_out = leds;
    assign seg_display = seg_value;
    assign buzzer = beep;

endmodule
