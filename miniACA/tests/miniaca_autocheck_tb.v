`timescale 1ns / 1ps
// Testbench adicional: comprueba reset, lectura de condicion inicial,
// programacion serial de 37 bits y tabla de transicion en modo RUN.
module tb_miniaca_autocheck;
    reg [4:0] i_cx;
    reg i_c00, i_c01, i_c43, i_c44, i_prg, i_clk;
    wire [4:0] o_cx;
    integer errors;

    miniaca dut (
        .o_cx(o_cx), .i_cx(i_cx), .i_c00(i_c00), .i_c01(i_c01),
        .i_c43(i_c43), .i_c44(i_c44), .i_prg(i_prg), .i_clk(i_clk)
    );

    initial i_clk = 1'b0;
    always #5 i_clk = ~i_clk;

    // Modelo independiente de la seleccion de una entrada de la LUT.
    function [4:0] expected_outputs;
        input [31:0] rule;
        input [4:0] cx;
        input c00, c01, c43, c44;
        reg [4:0] s0, s1, s2, s3, s4;
        begin
            s0 = {cx[2], cx[1], cx[0], c01, c00};
            s1 = {cx[3], cx[2], cx[1], cx[0], c01};
            s2 = {cx[4], cx[3], cx[2], cx[1], cx[0]};
            s3 = {c43, cx[4], cx[3], cx[2], cx[1]};
            s4 = {c44, c43, cx[4], cx[3], cx[2]};
            expected_outputs = {rule[s4],rule[s3],rule[s2],rule[s1],rule[s0]};
        end
    endfunction

    task assert_equal;
        input [4:0] got, expected;
        input [255:0] context;
        begin
            if (got !== expected) begin
                $display("ERROR %0s: esperado %b, obtenido %b (t=%0t)",
                         context, expected, got, $time);
                errors = errors + 1;
            end
        end
    endtask

    // Evita carreras: el dato se presenta en flanco negativo y se captura
    // en el siguiente flanco positivo del reloj.
    task load_serial;
        input [36:0] cfg;
        integer b;
        begin
            for (b = 36; b >= 0; b = b - 1) begin
                @(negedge i_clk);
                i_prg   = 1'b1;
                i_cx[0] = 1'b0;   // reset deshabilitado
                i_cx[1] = 1'b1;   // shift_en
                i_cx[2] = cfg[b]; // MSB primero
            end
            @(negedge i_clk);
            i_cx[1] = 1'b0;
            i_cx[2] = 1'b0;
            #1;
        end
    endtask

    task check_run;
        input [31:0] rule;
        input [4:0] cx;
        input c00, c01, c43, c44;
        begin
            @(negedge i_clk);
            i_prg = 1'b0;
            i_cx = cx;
            i_c00 = c00; i_c01 = c01; i_c43 = c43; i_c44 = c44;
            #1;
            assert_equal(o_cx, expected_outputs(rule,cx,c00,c01,c43,c44),
                         "tabla LUT modo RUN");
        end
    endtask

    initial begin
        $dumpfile("miniaca_autocheck.vcd");
        $dumpvars(0,tb_miniaca_autocheck);
        errors = 0;
        i_prg = 1'b1;
        i_cx = 5'b00000;
        i_c00 = 0; i_c01 = 0; i_c43 = 0; i_c44 = 0;

        // El reset de cfg es sincrono y carga la configuracion por defecto.
        @(negedge i_clk);
        i_cx[0] = 1'b1;
        @(negedge i_clk);
        i_cx[0] = 1'b0;
        #1;
        assert_equal(o_cx, 5'b01011, "estado inicial por defecto en PRG");

        check_run(32'h699695FF, 5'b10101, 1,0,1,0);
        check_run(32'h699695FF, 5'b11011, 0,1,0,1);
        check_run(32'h699695FF, 5'b00000, 0,0,0,0);

        // Programacion por entrada serial de regla+condicion inicial.
        @(negedge i_clk);
        i_prg = 1;
        i_cx = 5'b00000;
        load_serial({5'b10010,32'hAAAAAAAA});
        assert_equal(o_cx, 5'b10010, "condicion inicial recibida serialmente");

        // Una LUT AAAAAAAA devuelve el bit 0 del indice (paridad).
        check_run(32'hAAAAAAAA, 5'b10101, 1,0,1,0);
        check_run(32'hAAAAAAAA, 5'b11011, 0,1,0,1);
        check_run(32'hAAAAAAAA, 5'b00000, 1,1,0,0);

        // El registro no se altera en RUN al cambiar el reloj y entradas.
        @(negedge i_clk);
        i_prg = 1;
        i_cx = 5'b00000; // sin reset ni shift
        #1;
        assert_equal(o_cx, 5'b10010, "retencion de condicion inicial");

        // Segunda configuracion con otra LUT, verificando orden de bits.
        load_serial({5'b00101,32'hA5C30F69});
        assert_equal(o_cx, 5'b00101, "segundo estado inicial programado");
        check_run(32'hA5C30F69, 5'b10101, 1,0,1,0);
        check_run(32'hA5C30F69, 5'b11011, 0,1,0,1);
        check_run(32'hA5C30F69, 5'b11111, 1,1,1,1);

        if (errors == 0) begin
            $display("PASS miniACA: todos los chequeos pasaron");
            $finish;
        end else begin
            $display("FAIL miniACA: %0d errores", errors);
            $fatal(1, "Fallo en miniACA");
        end
    end
endmodule
