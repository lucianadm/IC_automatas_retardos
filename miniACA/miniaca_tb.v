`timescale 1ns / 1ps

module tb_miniaca;

    // DUT interface signals
    reg  [4:0] i_cx;
    reg        i_c00, i_c01, i_c43, i_c44;
    reg        i_prg;
    reg        i_clk;
    wire [4:0] o_cx;

    // Instantiate the DUT (Device Under Test)
    miniaca uut (
        .o_cx  (o_cx),
        .i_cx  (i_cx),
        .i_c00 (i_c00),
        .i_c01 (i_c01),
        .i_c43 (i_c43),
        .i_c44 (i_c44),
        .i_prg (i_prg),
        .i_clk (i_clk)
    );

    // Clock generation
    initial i_clk = 0;
    always #5 i_clk = ~i_clk;  // 100 MHz clock

    // Task to shift one bit into the config register
    task shift_bit(input bit);
        begin
            i_cx[2] = bit;    // serial_data
            i_cx[1] = 1;      // shift_en = 1
            @(posedge i_clk); // shift on rising edge
            i_cx[1] = 0;
            i_cx[2] = 0;
            @(posedge i_clk); // ensure clean cycle
        end
    endtask

    // Reset configuration to default
    task reset_config;
        begin
            i_cx[0] = 1;      // reset_cfg = 1
            @(posedge i_clk);
            i_cx[0] = 0;
            @(posedge i_clk);
        end
    endtask

    // Apply a 37-bit configuration (rule + init)
    task load_config(input [36:0] cfg_bits);
        integer i;
        begin
            for (i = 36; i >= 0; i = i - 1) begin
                shift_bit(cfg_bits[i]);
            end
        end
    endtask

    // Stimulus
    initial begin
        // Initialize inputs
        i_cx   = 5'b00000;
        i_c00  = 0;
        i_c01  = 0;
        i_c43  = 0;
        i_c44  = 0;
        i_prg  = 1;  // enter programming mode

        // Wait for global reset
        #20;

        // Reset to default configuration
        reset_config();

        // Enter run mode
        i_prg = 0;
        @(posedge i_clk);

        // Apply some test inputs
        i_cx   = 5'b10101;
        i_c00  = 1;
        i_c01  = 0;
        i_c43  = 1;
        i_c44  = 0;

        // Wait and observe output
        #50;

        // Change inputs again
        i_cx   = 5'b11011;
        i_c00  = 0;
        i_c01  = 1;
        i_c43  = 0;
        i_c44  = 1;

        // Wait and observe output
        #50;

        // Enter programming mode
        i_prg = 1;
        @(posedge i_clk);
        
        // Override default configuration
        load_config({5'b00001, 32'hAAAAAAAA});

        // Enter run mode
        i_prg = 0;
        @(posedge i_clk);

        // Apply some test inputs
        i_cx   = 5'b10101;
        i_c00  = 1;
        i_c01  = 0;
        i_c43  = 1;
        i_c44  = 0;

        // Wait and observe output
        #50;

        // Change inputs again
        i_cx   = 5'b11011;
        i_c00  = 0;
        i_c01  = 1;
        i_c43  = 0;
        i_c44  = 1;

        // Wait and observe output
        #50;

        $finish;
    end

endmodule
