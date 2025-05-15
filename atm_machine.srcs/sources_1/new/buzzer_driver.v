module buzzer_driver (
    input clk,
    input beep_en,
    output reg buzzer
);
    reg [15:0] counter;
    always @(posedge clk) begin
        if (beep_en) begin
            counter <= counter + 1;
            buzzer <= counter[10]; // ~1kHz
        end else begin
            counter <= 0;
            buzzer <= 0;
        end
    end
endmodule
