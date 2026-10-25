`timescale 1ns / 1ps

module tb_tffchain;

    // DUT I/O
    reg  [4:0] i_x1;
    reg        i_rst;
    wire [4:0] o_x2;
    wire [4:0] o_x4;

    // Instantiate DUT
    tffchain dut (
        .i_x1  (i_x1),
        .i_rst (i_rst),
        .o_x2  (o_x2),
        .o_x4  (o_x4)
    );

    // Helper task to pulse a clock bit
    task pulse_clk(input integer bit_index);
        begin
            i_x1[bit_index] = 1'b1;
            #5;
            i_x1[bit_index] = 1'b0;
            #5;
        end
    endtask

    // Simulation
    initial begin
        // Initialize
        i_x1  = 5'b00000;
        i_rst = 1;

        // Apply reset
        #10;
        i_rst = 0;
        #10;

        // Stimulate bit 0
        $display("Pulsing bit 0...");
        pulse_clk(0); // o_x2[0] = 1, o_x4[0] = 1
        pulse_clk(0); // o_x2[0] = 0
        pulse_clk(0); // o_x2[0] = 1, o_x4[0] = 0
        pulse_clk(0); // o_x2[0] = 0
        pulse_clk(0); // o_x2[0] = 1, o_x4[0] = 1
        pulse_clk(0); // o_x2[0] = 0
        pulse_clk(0); // o_x2[0] = 1, o_x4[0] = 0

        // Stimulate bit 1
        $display("Pulsing bit 1...");
        pulse_clk(1);
        pulse_clk(1);
        pulse_clk(1);

        // Stimulate bit 2
        $display("Pulsing bit 2...");
        pulse_clk(2);
        pulse_clk(2);
        pulse_clk(2);

        // Reset again
        $display("Applying reset...");
        i_rst = 1;
        #10;
        i_rst = 0;
        #10;

        // Stimulate multiple bits in sequence
        pulse_clk(3);
        pulse_clk(4);
        pulse_clk(0);
        pulse_clk(1);
        pulse_clk(2);

        #50;
        $finish;
    end

    // Optional waveform dump for GTKWave or other tools
    initial begin
        $dumpfile("tb_tffchain.vcd");
        $dumpvars(0, tb_tffchain);
    end

endmodule