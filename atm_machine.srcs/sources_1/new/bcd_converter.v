`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2025 08:17:13 PM
// Design Name: 
// Module Name: bcd_converter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bcd_converter (
    input [7:0] binary,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    always @(*) begin
        if (binary > 99) begin
            tens = 9;
            ones = 9;
        end else begin
            tens = binary / 10;
            ones = binary % 10;
        end
    end
endmodule


