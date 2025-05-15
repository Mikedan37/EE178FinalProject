// top.v
// Top-level wrapper for ATM FSM
// Connects physical switches, buttons, and LEDs to atm_fsm

// top.v
// Final version - no 7-segment display, LED-only display

module top (
    input clk,
    input rst,
    input [1:0] sw_card_input,         // SW0-SW1
    input [2:0] sw_menu_input,         // SW2-SW4
    input btn_confirm,                 // BTN0
    input [3:0] sw_deposit_amount,     // SW5-SW8
    input [2:0] sw_withdraw_amount,    // SW9-SW11
    output [10:0] leds_out             // LD0-LD10
);

    // Internal wires
    wire [7:0] balance;
    wire [10:0] leds;
    wire [3:0] seg_value;       // Still needed internally by FSM
    wire beep;
    wire preview_active;

    // Instantiate FSM
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
        .beep(beep),
        .preview_active(preview_active)
    );

    assign leds_out = leds;

endmodule

