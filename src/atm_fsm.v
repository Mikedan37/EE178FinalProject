// atm_fsm.v
// Finite State Machine for ATM Machine
// Written for EE178 Final Project - Michael Danylchuk

// atm_fsm.v
// Finite State Machine for ATM Machine
// Written for EE178 Final Project - Michael Danylchuk

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
    output reg [3:0] seg_value,  // 7-segment display (abstracted)
    output reg beep
);

    // Define state encoding manually
    parameter IDLE = 3'b000,
              CARD_CHECK = 3'b001,
              MENU = 3'b010,
              DISPLAY_BALANCE = 3'b011,
              DEPOSITING = 3'b100,
              WITHDRAWING = 3'b101,
              EXIT = 3'b110;

    reg [2:0] state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Output and next state logic
    always @(*) begin
        next_state = state;
        leds = 11'b0;
        beep = 0;
        seg_value = 4'b0000;

        case (state)
            IDLE: begin
                if (card_input == 2'b10) begin
                    leds[0] = 1; // LD0: Card valid
                    beep = 1;
                    next_state = MENU;
                end else if (card_input == 2'b01) begin
                    leds[1] = 1; // LD1: Card invalid
                end
            end

            MENU: begin
                case (menu_input)
                    3'b001: next_state = DISPLAY_BALANCE;
                    3'b010: next_state = WITHDRAWING;
                    3'b011: next_state = WITHDRAWING;
                    3'b100: next_state = DEPOSITING;
                    3'b101: next_state = EXIT;
                    default: next_state = MENU;
                endcase
            end

            DISPLAY_BALANCE: begin
                leds[2] = 1; // LD2: Display balance
                seg_value = balance[3:0]; // Show balance low nibble
                beep = 1;
                next_state = MENU;
            end

            DEPOSITING: begin
                leds[5] = 1; // LD5: Deposit in progress
                if (confirm_btn) begin
                    balance = balance + deposit_amount;
                    beep = 1;
                    next_state = MENU;
                end
            end

            WITHDRAWING: begin
                leds[4] = 1; // LD4: Withdraw in progress
                if (confirm_btn) begin
                    if (balance >= withdraw_amount) begin
                        balance = balance - withdraw_amount;
                        leds[10] = 1; // Green LED: Enough balance
                        beep = 1;
                    end else begin
                        leds[9] = 1; // Red LED: Not enough balance
                        beep = 1;
                    end
                    next_state = MENU;
                end
            end

            EXIT: begin
                leds[8] = 1; // LD8: Exit
                beep = 1;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule

