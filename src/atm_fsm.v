module atm_fsm (
    input clk,
    input rst,
    input [1:0] card_input,
    input [2:0] menu_input,
    input confirm_btn,
    input [3:0] deposit_amount,
    input [2:0] withdraw_amount,
    output reg [7:0] balance,
    output reg [10:0] leds,
    output reg [3:0] seg_value,
    output reg beep,
    output reg preview_active
);

    // FSM States
    parameter IDLE             = 4'b0000,
              CARD_CHECK       = 4'b0001,
              CARD_VALID_ACK   = 4'b0010,
              MENU             = 4'b0011,
              PREVIEW          = 4'b0100,
              DISPLAY_BALANCE  = 4'b0101,
              DEPOSITING       = 4'b0110,
              WITHDRAWING      = 4'b0111,
              EXIT             = 4'b1000;

    reg [3:0] state, next_state;
    reg [2:0] selected_mode;
    reg [23:0] card_ack_timer;

    wire [7:0] withdraw_extended = {5'b00000, withdraw_amount};

    // State and selected_mode register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            selected_mode <= 3'b000;
        end else begin
            state <= next_state;
            if (state == MENU) begin
                selected_mode <= menu_input;
            end
        end
    end

    // Output and transition logic
    always @(*) begin
        next_state = state;
        leds = 11'b0;
        beep = 0;
        seg_value = 4'd0;
        preview_active = 0;

        case (state)
            IDLE: begin
                leds[6:5] = card_input;  // Debug display for card status
                if (card_input != 2'b00)
                    next_state = CARD_CHECK;
            end

            CARD_CHECK: begin
                if (card_input == 2'b10) begin
                    next_state = CARD_VALID_ACK;
                end else if (card_input == 2'b01) begin
                    leds[1] = 1;  // Card invalid
                    beep = 1;
                    next_state = IDLE;
                end
            end

            CARD_VALID_ACK: begin
                leds[0] = 1;  // Card valid
                beep = 1;
                if (card_ack_timer > 24'd3_000_000)
                    next_state = MENU;
            end

            MENU: begin
                case (menu_input)
                    3'b001,
                    3'b010,
                    3'b011,
                    3'b100,
                    3'b101: next_state = PREVIEW;
                    default: next_state = MENU;
                endcase
            end

            PREVIEW: begin
                preview_active = 1;
                beep = 1;
                case (selected_mode)
                    3'b001: seg_value = 4'd1; // Balance
                    3'b010: seg_value = 4'd2; // Rapid Withdraw
                    3'b011: seg_value = 4'd3; // Withdraw
                    3'b100: seg_value = 4'd4; // Deposit
                    3'b101: seg_value = 4'd5; // Exit
                    default: seg_value = 4'd0;
                endcase

                if (confirm_btn) begin
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
                leds[7:0] = balance;
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
                    if (balance < withdraw_extended) begin
                        leds[9] = 1;  // Error
                        beep = 1;
                    end else begin
                        balance = balance - withdraw_extended;
                        leds[10] = 1; // Success
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

    // Timer logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            card_ack_timer <= 0;
        end else begin
            if (state == CARD_VALID_ACK)
                card_ack_timer <= card_ack_timer + 1;
            else
                card_ack_timer <= 0;
        end
    end

endmodule

