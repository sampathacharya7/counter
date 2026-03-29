`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: self
// Engineer: sampath
// 
// Create Date: 29.03.2026 13:11:20
// Design Name: counter logic
// Module Name: counter

module counter(
    input clk,
    input reset,
    input enable,
    output reg [2:0] count
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 3'b0;
        else if (enable)
            count <= count + 1;
    end

endmodule
