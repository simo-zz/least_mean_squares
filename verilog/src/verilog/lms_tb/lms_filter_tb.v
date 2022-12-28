`timescale 1ns/1ps

module lms_filter_tb();

    localparam DATA_WIDTH = 12;
    localparam FILTER_ORDER = 5;

    reg reset_r, clk_r;
    reg [DATA_WIDTH-1:0] ref_r, x_r;

    lms_filter #(
        .DATA_WIDTH(DATA_WIDTH),
        .FILTER_ORDER(FILTER_ORDER)
    ) lms_filter_inst (
        .resetn_in(reset_r),
        .clk_in(clk_r),
        .ref_in(ref_r),
        .x_in(x_r)
    );

    integer i;
    initial
    begin
        $dumpfile("lms_filter_tb.vcd");
        $dumpvars(0, lms_filter_tb);
        for (i = 0; i < FILTER_ORDER; i = i + 1) begin
            $dumpvars(0, lms_filter_inst.x_reg[i]);
            $dumpvars(0, lms_filter_inst.w_reg[i]);
        end

        #0 reset_r <= 0; clk_r <= 0; ref_r <= 0; x_r <= 0;
        #10 reset_r <= 1;

        #1000 $finish;

    end

    always 
    begin
        #0.5 clk_r <= ~clk_r;
    end

    always @(posedge clk_r)
    begin
        x_r <= $urandom%4096;
    end

endmodule