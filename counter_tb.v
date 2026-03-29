`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: self
// Engineer: sampath
// 
// Create Date: 29.03.2026 13:13:42
// Design Name: 
// Module Name: counter_tb


module counter_tb;

    // Declare testbench signals
    reg clk;
    reg reset;
    reg enable;
    wire [2:0] count;

    // Instantiate the counter module
    counter uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    // Clock generation (10ns period, 5ns high/low)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        enable = 0;

        // Test 1: Reset the counter
        #10 reset = 0;
        
        // Test 2: Enable counter and count from 0 to 15
        #10 enable = 1;
        #160;  // Wait 16 clock cycles (16 * 10ns)
        
        // Test 3: Disable counter
        #10 enable = 0;
        #40;
        
        // Test 4: Re-enable counter
        #10 enable = 1;
        #80;
        
        // Test 5: Reset while counting
        #10 reset = 1;
        #20 reset = 0;
        #80;
        
        // End simulation
        #10 $finish;
    end

endmodule
