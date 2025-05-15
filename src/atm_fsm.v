// atm_fsm.v
// Finite State Machine for ATM Machine
// Written for EE178 Final Project - Michael Danylchuk

// atm_fsm.v
// Finite State Machine for ATM Machine
// Written for EE178 Final Project - Michael Danylchuk

// atm_fsm.v
// Finite State Machine for ATM Machine
// Updated with PREVIEW state flash for menu actions

// atm_fsm.v
// Final FSM for ATM Machine - with preview_active output

module atm_fsm (
    input clk,
    input rst,
    input [1:0] card_input,      // 00: No card, 01: Invalid, 10: Valid
    input [2:0] menu_input,      // 001: Balance, 010: Rapid Withdraw, 011: Withdraw, 100: Deposit, 101: Exit
    input confirm_btn,
    input [7:0] deposit_amount,
    input [7:0] withdraw_amount,
    output reg [7:0] balance,
    output reg [10:0] leds,      // LD0-LD10
    output reg [3:0] seg_value,  // 7-segment preview digit
    output reg beep,
    output reg preview_active    // NEW output for top.v to use
);

    // FSM State Definitions
    parameter IDLE             = 4'b0000,
              CARD_CHECK       = 4'b0001,
              MENU             = 4'b0010,
              PREVIEW          = 4'b0011,
              DISPLAY_BALANCE  = 4'b0100,
              DEPOSITING       = 4'b0101,
              WITHDRAWING      = 4'b0110,
              EXIT             = 4'b0111;

    reg [3:0] state, next_state;
    reg [2:0] selected_mode;
    reg [23:0] preview_timer;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Output logic
    always @(*) begin
        // Default values
        next_state = state;
        leds = 11'b0;
        beep = 0;
        seg_value = 4'd0;
        preview_active = 0;

        case (state)
            IDLE: begin
                if (card_input != 2'b00)
                    next_state = CARD_CHECK;
            end

            CARD_CHECK: begin
                if (card_input == 2'b10) begin
                    leds[0] = 1; // Card valid
                    beep = 1;
                    next_state = MENU;
                end else if (card_input == 2'b01) begin
                    leds[1] = 1; // Card invalid
                    beep = 1;
                    next_state = IDLE;
                end
            end

            MENU: begin
                case (menu_input)
                    3'b001: begin selected_mode = 3'b001; next_state = PREVIEW; end
                    3'b010: begin selected_mode = 3'b010; next_state = PREVIEW; end
                    3'b011: begin selected_mode = 3'b011; next_state = PREVIEW; end
                    3'b100: begin selected_mode = 3'b100; next_state = PREVIEW; end
                    3'b101: begin selected_mode = 3'b101; next_state = PREVIEW; end
                    default: next_state = MENU;
                endcase
            end

            PREVIEW: begin
                preview_active = 1;
                beep = 1;
                case (selected_mode)
                    3'b001: seg_value = 4'd1;
                    3'b010: seg_value = 4'd2;
                    3'b011: seg_value = 4'd3;
                    3'b100: seg_value = 4'd4;
                    3'b101: seg_value = 4'd5;
                    default: seg_value = 4'd0;
                endcase

                if (preview_timer < 24'd5_000_000)
                    next_state = PREVIEW;
                else begin
                    case (selected_mode)
                        3'b001: next_state = DISPLAY_BALANCE;
                        3'b010: next_state = WITHDRAWING;
                        3'b011: next_state = WITHDRAWING;
                        3'b100: next_state = DEPOSITING;
                        3'b101: next_state = EXIT;
                        default: next_state = MENU;
                    endcase
                end
            end

            DISPLAY_BALANCE: begin
                leds[2] = 1;
                seg_value = balance[3:0];
                beep = 1;
                next_state = MENU;
            end

            DEPOSITING: begin
                leds[5] = 1;
                if (confirm_btn) begin
                    balance = balance + deposit_amount;
                    beep = 1;
                    next_state = MENU;
                end
            end

            WITHDRAWING: begin
                leds[4] = 1;
                if (confirm_btn) begin
                    if (balance >= withdraw_amount) begin
                        balance = balance - withdraw_amount;
                        leds[10] = 1; // Green
                        beep = 1;
                    end else begin
                        leds[9] = 1; // Red
                        beep = 1;
                    end
                    next_state = MENU;
                end
            end

            EXIT: begin
                leds[8] = 1;
                beep = 1;
                balance = 0;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Preview timer logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            preview_timer <= 0;
        else if (state == PREVIEW)
            preview_timer <= preview_timer + 1;
        else
            preview_timer <= 0;
    end

endmodule


