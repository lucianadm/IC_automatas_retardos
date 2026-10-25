// -----------------------------------------------------------------------------
// TFFCHAIN - Cadena de flip-flops tipo toggle (T-FF) con relojes individuales
// Cada bit de entrada i_x1[i] controla un flip-flop T que genera o_x2[i]
// A su vez, o_x2[i] alimenta otro T-FF que genera o_x4[i]
// Reset asincrono comun (activo en alto)
// -----------------------------------------------------------------------------

module tffchain (
    output reg  [4:0] o_x2,  // Salida de primer nivel (toggle con i_x1)
    output reg  [4:0] o_x4,  // Salida de segundo nivel (toggle con o_x2)
    
    input  wire [4:0] i_x1, // Entradas de reloj independientes para o_x2
    input  wire       i_rst // Reset asincrono global (activo en alto)
);

    // Toggle 1: Flip-flops que responden a cada i_x1[i]
    always @(posedge i_x1[0] or posedge i_rst) begin
        if (i_rst)
            o_x2[0] <= 1'b0;
        else
            o_x2[0] <= ~o_x2[0];
    end

    always @(posedge i_x1[1] or posedge i_rst) begin
        if (i_rst)
            o_x2[1] <= 1'b0;
        else
            o_x2[1] <= ~o_x2[1];
    end

    always @(posedge i_x1[2] or posedge i_rst) begin
        if (i_rst)
            o_x2[2] <= 1'b0;
        else
            o_x2[2] <= ~o_x2[2];
    end

    always @(posedge i_x1[3] or posedge i_rst) begin
        if (i_rst)
            o_x2[3] <= 1'b0;
        else
            o_x2[3] <= ~o_x2[3];
    end

    always @(posedge i_x1[4] or posedge i_rst) begin
        if (i_rst)
            o_x2[4] <= 1'b0;
        else
            o_x2[4] <= ~o_x2[4];
    end

    // Toggle 2: Flip-flops que responden a cada o_x2[i] (segunda etapa)
    always @(posedge o_x2[0] or posedge i_rst) begin
        if (i_rst)
            o_x4[0] <= 1'b0;
        else
            o_x4[0] <= ~o_x4[0];
    end

    always @(posedge o_x2[1] or posedge i_rst) begin
        if (i_rst)
            o_x4[1] <= 1'b0;
        else
            o_x4[1] <= ~o_x4[1];
    end

    always @(posedge o_x2[2] or posedge i_rst) begin
        if (i_rst)
            o_x4[2] <= 1'b0;
        else
            o_x4[2] <= ~o_x4[2];
    end

    always @(posedge o_x2[3] or posedge i_rst) begin
        if (i_rst)
            o_x4[3] <= 1'b0;
        else
            o_x4[3] <= ~o_x4[3];
    end

    always @(posedge o_x2[4] or posedge i_rst) begin
        if (i_rst)
            o_x4[4] <= 1'b0;
        else
            o_x4[4] <= ~o_x4[4];
    end

endmodule