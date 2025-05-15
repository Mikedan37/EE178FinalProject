// top.v
// Top-level wrapper for ATM FSM
// Connects physical switches, buttons, and LEDs to atm_fsm

// top.v
// Top-level wrapper for ATM FSM
// Connects physical switches, buttons, and LEDs to atm_fsm

module top (
    input clk,
    input rst,
    input [1:0] sw_card_input,         // SW0-SW1
    input [2:0] sw_menu_input,         // SW2-SW4
    input btn_confirm,                 // BTN0
    input [7:0] sw_deposit_amount,     // SW5-SW12
    input [7:0] sw_withdraw_amount,    // SW13-SW20
    output [10:0] leds_out,
    output [6:0] seg,                  // 7-segment output
    output [1:0] an,                   // 2-digit anode control
    output buzzer                      // Square wave output for piezo
);

    // Internal wires
    wire [7:0] balance;
    wire [10:0] leds;
    wire [3:0] seg_value;
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

    // === 7-Segment Logic ===
    wire [3:0] ones_digit, tens_digit;
    wire [6:0] seg_ones, seg_tens, seg_preview;

    bcd_converter bcd (
        .binary(balance),
        .tens(tens_digit),
        .ones(ones_digit)
    );

    seven_segment_decoder dec_ones (
        .digit(ones_digit),
        .seg(seg_ones)
    );

    seven_segment_decoder dec_tens (
        .digit(tens_digit),
        .seg(seg_tens)
    );

    seven_segment_decoder dec_preview (
        .digit(seg_value),
        .seg(seg_preview)
    );

    // Display refresh logic
    reg [15:0] refresh_counter;
    reg digit_select;

    initial begin
        refresh_counter = 0;
        digit_select = 0;
    end

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 0)
            digit_select <= ~digit_select;
    end

    // Final display multiplexer
    assign an = preview_active ? 2'b10 : (digit_select ? 2'b10 : 2'b01);
    assign seg = preview_active ? seg_preview : (digit_select ? seg_tens : seg_ones);

    // === Buzzer ===
    wire buzzer_pwm;
    buzzer_driver u_buzzer (
        .clk(clk),
        .beep_en(beep),
        .buzzer(buzzer_pwm)
    );

    assign buzzer = buzzer_pwm;

endmodule
