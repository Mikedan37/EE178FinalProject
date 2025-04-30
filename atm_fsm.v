module atm_fsm (
    input clk,
    input rst,
    input [1:0] card_input,         // 00 = No Card, 01 = Invalid, 10 = Valid
    input [2:0] menu_input,         // 1 = Balance, 2 = Rapid Withdraw, 3 = Withdraw, 4 = Deposit, 5 = Exit
    input [7:0] deposit_amount,
    input [7:0] withdraw_amount,
    output reg [10:0] leds,         // LD0 - LD10
    output reg [3:0] seg_value,     // Value to 7-segment decoder
    output reg beep,
    output reg [7:0] balance
);

    // FSM states
    parameter IDLE = 3'd0,
              CARD_CHECK = 3'd1,
              MENU = 3'd2,
              DISPLAY_BALANCE = 3'd3,
              DEPOSIT = 3'd4,
              WITHDRAW = 3'd5,
              EXIT = 3'd6;

    reg [2:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        // Default outputs
        leds = 11'b0;
        seg_value = 4'b0000;
        beep = 0;
        next_state = state;

        case (state)
            IDLE: begin
                if (card_input == 2'b10) begin
                    leds[0] = 1; // LD0: Card valid
                    beep = 1;
                    next_state = MENU;
                end else if (card_input == 2'b01) begin
                    leds[1] = 1; // LD1: Card invalid
                    next_state = IDLE;
                end
            end

            MENU: begin
                case (menu_input)
                    3'b001: next_state = DISPLAY_BALANCE;
                    3'b010: next_state = WITHDRAW; // Rapid withdrawal
                    3'b011: next_state = WITHDRAW;
                    3'b100: next_state = DEPOSIT;
                    3'b101: next_state = EXIT;
                    default: next_state = MENU;
                endcase
            end

            DISPLAY_BALANCE: begin
                leds[2] = 1; // LD2: Balance check
                seg_value = balance[3:0]; // Show balance (4 LSB)
                next_state = MENU;
            end

            DEPOSIT: begin
                leds[5] = 1; // LD5: Deposit
                balance = balance + deposit_amount;
                beep = 1;
                next_state = MENU;
            end

            WITHDRAW: begin
                if (balance >= withdraw_amount) begin
                    leds[4] = 1; // LD4: Withdraw
                    leds[10] = 1; // LD10 GREEN: Sufficient balance
                    balance = balance - withdraw_amount;
                    leds[7] = 1; // LD7: Cash dispensed
                    beep = 1;
                end else begin
                    leds[10] = 3'b100; // LD10 RED: Insufficient
                    leds[9] = 1;       // LD9: Error
                end
                next_state = MENU;
            end

            EXIT: begin
                leds[9] = 1; // Goodbye
                next_state = IDLE;
            end
        endcase
    end
endmodule
