module atm_fsm (
    input clk,
    input rst,
    input [1:0] card_input,         // 00: No card, 01: Invalid, 10: Valid
    input [2:0] menu_input,         // 001: Balance, 010: Rapid Withdraw, etc.
    input confirm_btn,
    input [3:0] deposit_amount,
    input [2:0] withdraw_amount,
    output reg [7:0] balance,
    output reg [10:0] leds,         // LD0-LD10
    output reg [3:0] seg_value,
    output reg beep,
    output reg preview_active
);

    // FSM States
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

    // State transition
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // selected_mode update
    always @(posedge clk or posedge rst) begin
        if (rst)
            selected_mode <= 3'b000;
        else if (state == MENU) begin
            case (menu_input)
                3'b001, 3'b010, 3'b011, 3'b100, 3'b101:
                    selected_mode <= menu_input;
                default:
                    selected_mode <= 3'b000;
            endcase
        end
    end

    // Output logic and next state
    always @(*) begin
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
                    leds[0] = 1;
                    beep = 1;
                    next_state = MENU;
                end else if (card_input == 2'b01) begin
                    leds[1] = 1;
                    beep = 1;
                    next_state = IDLE;
                end
            end

            MENU: begin
                case (menu_input)
                    3'b001, 3'b010, 3'b011, 3'b100, 3'b101:
                        next_state = PREVIEW;
                    default:
                        next_state = MENU;
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
                        3'b010,
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
                    if (balance >= withdraw_amount) begin
                        balance = balance - withdraw_amount;
                        leds[10] = 1;
                        beep = 1;
                    end else begin
                        leds[9] = 1;
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

endmodule
