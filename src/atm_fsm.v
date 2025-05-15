module atm_fsm (
    input clk,
    input rst,
    input [1:0] card_input,         // 00: No card, 01: Invalid, 10: Valid
    input [2:0] menu_input,         // 001: Balance, 010: Rapid Withdraw, etc.
    input confirm_btn,
    input [3:0] deposit_amount,     // Use only 4 bits now
    input [2:0] withdraw_amount,    // Use only 3 bits now
    output reg [7:0] balance,
    output reg [10:0] leds,         // LD0-LD10
    output reg [3:0] seg_value,     // preview code (still usable via LEDs if desired)
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
    reg [23:0] preview_timer;

    // State transition
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // selected_mode update (synchronously to avoid latch)
    always @(posedge clk or posedge rst) begin
        if (rst)
            selected_mode <= 3'b000;
        else if (state == MENU) begin
            case (menu_input)
                3'b001: selected_mode <= 3'b001;
                3'b010: selected_mode <= 3'b010;
                3'b011: selected_mode <= 3'b011;
                3'b100: selected_mode <= 3'b100;
                3'b101: selected_mode <= 3'b101;
                default: selected_mode <= 3'b000;
            endcase
        end
    end

    // Output logic and next state
    always @(*) begin
        // Default outputs
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
                    leds[0] = 1; // Valid card
                    beep = 1;
                    next_state = MENU;
                end else if (card_input == 2'b01) begin
                    leds[1] = 1; // Invalid card
                    beep = 1;
                    next_state = IDLE;
                end
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

                if (preview_timer < 24'd5_000_000)
                    next_state = PREVIEW;
                else begin
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
                leds[7:0] = balance; // Display balance in binary on LD0-LD7
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
                        leds[10] = 1; // Success (green)
                        beep = 1;
                    end else begin
                        leds[9] = 1;  // Fail (red)
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



