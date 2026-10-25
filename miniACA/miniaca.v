// -----------------------------------------------------------------------------
// MiniACA - 5-cell automaton with programmable rule via serial config register
// -----------------------------------------------------------------------------

module miniaca (
    output [4:0] o_cx,     // Outputs of each cell

    input  [4:0] i_cx,     // Input 2 of each cell, Inter-cell signals (shared inputs)
    input        i_c00,    // Input 0 of cell 0
    input        i_c01,    // Input 1 of cell 0, and input 0 of cell 1
    input        i_c43,    // Input 3 of cell 4, and input 4 of cell 3
    input        i_c44,    // Input 4 of cell 4
    input        i_prg,    // Mode: 0 = run, 1 = program
    input        i_clk     // Clock signal
);

    // Internal configuration register: [36:32] = initial state, [31:0] = rule table
    reg  [36:0] cfg_reg;
    wire [ 4:0] initial_state = cfg_reg[36:32];
    wire [31:0] rule_table    = cfg_reg[31: 0];

    // Control signals from interconnect
    wire reset_cfg   = i_cx[0];
    wire shift_en    = i_cx[1];
    wire serial_data = i_cx[2];

    // Shift register for serial configuration input (active only during programming)
    always @(posedge i_clk) begin
        if (i_prg) begin
            if (reset_cfg)
                cfg_reg <= {5'b01011, 32'h699695FF}; // Default: Init + Rule
            else if (shift_en)
                cfg_reg <= {cfg_reg[35:0], serial_data}; // Shift in data
        end
    end

    // Inputs to each of the 5 logic cells (5-bit input per cell)
    wire [4:0] cell_in [0:4];
    assign cell_in[0] = {i_cx[2], i_cx[1], i_cx[0], i_c01  , i_c00  };
    assign cell_in[1] = {i_cx[3], i_cx[2], i_cx[1], i_cx[0], i_c01  };
    assign cell_in[2] = {i_cx[4], i_cx[3], i_cx[2], i_cx[1], i_cx[0]};
    assign cell_in[3] = {i_c43  , i_cx[4], i_cx[3], i_cx[2], i_cx[1]};
    assign cell_in[4] = {i_c44  , i_c43  , i_cx[4], i_cx[3], i_cx[2]};

    // Output of each cell in run mode
    wire [4:0] cell_out;
    assign cell_out[0] = rule_table[cell_in[0]];
    assign cell_out[1] = rule_table[cell_in[1]];
    assign cell_out[2] = rule_table[cell_in[2]];
    assign cell_out[3] = rule_table[cell_in[3]];
    assign cell_out[4] = rule_table[cell_in[4]];

    // Select between RUN and PROGRAM mode output
    assign o_cx[0] = (i_prg == 1'b0) ? cell_out[0] : initial_state[0];
    assign o_cx[1] = (i_prg == 1'b0) ? cell_out[1] : initial_state[1];
    assign o_cx[2] = (i_prg == 1'b0) ? cell_out[2] : initial_state[2];
    assign o_cx[3] = (i_prg == 1'b0) ? cell_out[3] : initial_state[3];
    assign o_cx[4] = (i_prg == 1'b0) ? cell_out[4] : initial_state[4];

endmodule