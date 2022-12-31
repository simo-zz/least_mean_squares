`timescale 1ns/1ps

/*
    y bits = 17
    err bits = 16
    wLMS bits = 11
                                         d_in(n)
                ________________             | 
                |               | y_out(n) - |
    x_in(n) --> |      W(z)     |---------->`+´---> err_out
                |_______________|            |
                      ´|`                    | 
                       |_____________________|                                    

*/

module n_adder #(

        parameter DATA_WIDTH = 32
    )
    (
        input signed [DATA_WIDTH-1:0] data_a,
        input signed [DATA_WIDTH-1:0] data_b,
        output signed [DATA_WIDTH-1:0] data_o
    );

    assign data_o = data_a + data_b;

endmodule

module n_mult #(

        parameter DATA_WIDTH = 32
    )
    (
        input signed [DATA_WIDTH-1:0] data_a,
        input signed [DATA_WIDTH-1:0] data_b,
        output signed [DATA_WIDTH-1:0] data_o
    );

    assign data_o = data_a * data_b;

endmodule

module lms_filter
    #(
        parameter DATA_WIDTH = 32,
        parameter MU_BITS = 16,
        parameter FILTER_ORDER = 5
    )
    (
        (* direct_reset = "true" *) input wire reset,
        (* direct_enable = "true" *) input wire clk,
        input wire signed[DATA_WIDTH-1:0] d_in,
        input wire signed[DATA_WIDTH-1:0] x_in,
        input wire signed[DATA_WIDTH-1:0] y_in,
        output wire signed[DATA_WIDTH-1:0] y_out,
        output wire signed[DATA_WIDTH-1:0] err_out
        // output wire in_en
    );

    reg signed [DATA_WIDTH-1:0] d_reg;
    reg signed [DATA_WIDTH-1:0] x_reg [FILTER_ORDER-1:0];
    reg signed [DATA_WIDTH-1:0] y_reg [FILTER_ORDER-1:0];
    reg signed [DATA_WIDTH-1:0] y_sum;
    reg signed [DATA_WIDTH-1:0] w_reg [FILTER_ORDER-1:0];

    wire signed [DATA_WIDTH-1:0] e_w;
    wire signed [DATA_WIDTH-1:0] y_w;

    wire signed [DATA_WIDTH-1:0] xw_mult_w [FILTER_ORDER-1:0];
    wire signed [DATA_WIDTH-1:0] yx_csum_w [FILTER_ORDER-1:0];

    assign y_w = yx_csum_w[FILTER_ORDER-2];
    assign y_out = y_w;
    assign e_w = (d_reg - y_w);

    genvar ic;
    integer i;

    generate
        for (ic = 0; ic < FILTER_ORDER; ic = ic + 1) begin
            n_mult #(
                .DATA_WIDTH(DATA_WIDTH)
            ) n_mult_inst (.data_a(x_reg[ic]), .data_b(w_reg[ic]), .data_o(xw_mult_w[ic]));
        end
    endgenerate

    generate
        for (ic = 0; ic < FILTER_ORDER; ic = ic + 1) begin
            
            if (ic == 0) begin
                n_adder #(
                    .DATA_WIDTH(DATA_WIDTH)
                ) n_adder_inst (.data_a(xw_mult_w[ic]), .data_b(xw_mult_w[ic+1]), .data_o(yx_csum_w[ic]));
            end
            else begin
                n_adder #(
                    .DATA_WIDTH(DATA_WIDTH)
                ) n_adder_inst (.data_a(yx_csum_w[ic-1]), .data_b(xw_mult_w[ic+1]), .data_o(yx_csum_w[ic]));
            end
        end
    endgenerate

    /*
        x data shift in
        [a][.][.][.][.]
        [b][a][.][.][.]
        [c][b][a][.][.]
    */
    always @(posedge clk) begin
        if (! reset) begin
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                x_reg[i] <= 0;
            end
        end
        else begin
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                if (! i)
                    x_reg[i] <= x_in;
                else
                    x_reg[i] <= x_reg[i-1];
            end
        end
    end

    // d update
    always @(posedge clk) begin
        if (! reset)
            d_reg <= 0;
        else begin
            d_reg <= d_in;
        end
    end

    // weight update
    always @(posedge clk) begin
        if (! reset)
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                w_reg[i] <= 0;
            end
        else begin
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                w_reg[i] <= w_reg[i] + ((e_w * x_reg[i]) >>> MU_BITS);
            end
        end
    end
    
endmodule
