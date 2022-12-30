`timescale 1ns/1ps

`define XDYE_TXT_PATH "/customdevs/least_mean_squares.github/verilog/src/lms_tb/xdye.txt"

module lms_filter_tb();

    localparam DATA_WIDTH = 32;
    localparam FILTER_ORDER = 5;
    localparam MU_BITS = 11;
    localparam N_ELEMS = 1000;

    reg reset_r, clk_r;
    reg signed [DATA_WIDTH-1:0] din_r, xin_r, yt_r, errt_r;
    wire signed [DATA_WIDTH-1:0] y_w;
    wire signed [DATA_WIDTH-1:0] err_w;
    wire in_en_w;

    real td = FILTER_ORDER + 1;

    lms_filter #(
        .DATA_WIDTH(DATA_WIDTH),
        .FILTER_ORDER(FILTER_ORDER),
        .MU_BITS(MU_BITS)
    ) lms_filter_inst (
        .reset(reset_r),
        .clk(clk_r),
        .x_in(xin_r),
        .d_in(din_r),
        .y_in(yt_r),
        .y_out(y_w),
        .err_out(err_w)
        //.in_en(in_en_w)
    );

    integer i, fp_xd, fp_err, fp_y, n_read, n_write;
    initial
    begin : file_read

        $dumpfile("lms_filter_tb.vcd");
        $dumpvars(0, lms_filter_tb);
        $dumpvars(0, lms_filter_inst);

        for (i = 0; i < FILTER_ORDER; i = i + 1) begin
            $dumpvars(0, lms_filter_inst.x_reg[i]);
            $dumpvars(0, lms_filter_inst.xw_mult_w[i]);
            $dumpvars(0, lms_filter_inst.w_reg[i]);
        end

        for (i = 0; i < FILTER_ORDER-1; i = i + 1) begin
            $dumpvars(0, lms_filter_inst.yx_csum_w[i]);
        end

        $display("XDYE_TXT_PATH = %s", `XDYE_TXT_PATH);

        fp_xd = $fopen(`XDYE_TXT_PATH, "r");

        #0 reset_r <= 0; clk_r <= 0; din_r <= 0; xin_r <= 0; yt_r <= 0; errt_r <= 0;
        #9.5 reset_r <= 1;

        while (!$feof(fp_xd)) begin
            #1 n_read = $fscanf(fp_xd, "%d,%d,%d,%d", xin_r, din_r, yt_r, errt_r); $display("xin_r = %d, din_r = %d, yt_r = %d, errt_r = %d", xin_r, din_r, yt_r, errt_r);
        end
        #1 $fclose(fp_xd);$finish;
    end

    always 
    begin
        #0.5 clk_r <= ~clk_r;
    end

endmodule