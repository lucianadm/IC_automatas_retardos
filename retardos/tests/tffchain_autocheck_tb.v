`timescale 1ns / 1ps
// Testbench adicional: comprueba cascada TFF y reset asincrono de 5 canales.
module tb_tffchain_autocheck;
    reg [4:0] i_x1;
    reg i_rst;
    wire [4:0] o_x2, o_x4;
    reg [4:0] expected_x2, expected_x4;
    integer errors;
    integer k, j;

    tffchain dut (
        .o_x2(o_x2), .o_x4(o_x4), .i_x1(i_x1), .i_rst(i_rst)
    );

    task verify;
        input [255:0] msg;
        begin
            if ((o_x2 !== expected_x2) || (o_x4 !== expected_x4)) begin
                $display("ERROR %0s: esperado x2=%b x4=%b; recibido x2=%b x4=%b (t=%0t)",
                         msg,expected_x2,expected_x4,o_x2,o_x4,$time);
                errors = errors + 1;
            end
        end
    endtask

    task pulse;
        input integer bit_index;
        begin
            #3;
            i_x1[bit_index] = 1;
            // El TFF 2 conmuta solo si el primer TFF pasa de 0 a 1.
            if (expected_x2[bit_index] == 0)
                expected_x4[bit_index] = ~expected_x4[bit_index];
            expected_x2[bit_index] = ~expected_x2[bit_index];
            #2;
            verify("flanco ascendente");
            i_x1[bit_index] = 0;
            #2;
            verify("flanco descendente (sin cambio)");
        end
    endtask

    initial begin
        $dumpfile("tffchain_autocheck.vcd");
        $dumpvars(0,tb_tffchain_autocheck);
        errors = 0;
        i_x1 = 5'b00000;
        i_rst = 1'b1;
        expected_x2 = 0;
        expected_x4 = 0;
        #2;
        verify("reset inicial");
        i_rst = 1'b0;
        #1;
        verify("salida de reset");

        // Para todos los canales, verifica 8 flancos y que los otros no cambien.
        for (k=0; k<5; k=k+1)
            for (j=0; j<8; j=j+1)
                pulse(k);

        // Activar el reset entre flancos, sin aplicar relojes.
        #1;
        i_rst = 1'b1;
        expected_x2 = 0;
        expected_x4 = 0;
        #1;
        verify("reset asincrono despues de actividad");
        i_rst = 1'b0;
        #2;
        for (k=4; k>=0; k=k-1)
            for (j=0; j<3; j=j+1)
                pulse(k);

        if (errors==0) begin
            $display("PASS retardos: todos los chequeos pasaron");
            $finish;
        end else begin
            $display("FAIL retardos: %0d errores", errors);
            $fatal(1,"Fallo en retardos");
        end
    end
endmodule
