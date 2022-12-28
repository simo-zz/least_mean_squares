`timescale 1ns/1ps

/*
    y bits = 17
    err bits = 16
    wLMS bits = 11
                                         ref_in(n)
                ________________             | 
                |               | y_out(n) - |
    x_in(n) --> |      W(z)     |---------->`+´---> err_out
                |_______________|            |
                      ´|`                    | 
                       |_____________________|                                    

*/
module lms_filter
    #(
        parameter DATA_WIDTH = 12,
        parameter FILTER_ORDER = 5
    )
    (
        (* direct_reset = "true" *) input wire resetn_in,
        (* direct_enable = "true" *) input wire clk_in,
        input wire [DATA_WIDTH-1:0] ref_in,
        input wire [DATA_WIDTH-1:0] x_in,
        output wire [DATA_WIDTH-1:0] y_out,
        output wire [DATA_WIDTH-1:0] err_out,
        output wire [DATA_WIDTH-1:0] w_out
    );

    localparam LMS_INTERNAL_DATA_WIDTH = 32;
    localparam LMS_DATA_DIFF = (LMS_INTERNAL_DATA_WIDTH) - DATA_WIDTH;

    reg signed [LMS_INTERNAL_DATA_WIDTH-1:0] ref_reg;
    reg signed [LMS_INTERNAL_DATA_WIDTH-1:0] x_reg [FILTER_ORDER-1:0];
    reg signed [LMS_INTERNAL_DATA_WIDTH-1:0] y_reg;
    reg signed [LMS_INTERNAL_DATA_WIDTH-1:0] err_reg;
    reg signed [LMS_INTERNAL_DATA_WIDTH-1:0] w_reg [FILTER_ORDER-1:0];
    reg signed [LMS_INTERNAL_DATA_WIDTH-1:0] w_delta_reg;

    assign y_out = y_reg[DATA_WIDTH-1:0];
    assign err_out = err_reg[DATA_WIDTH-1:0];
    assign w_out = w_reg[0];

    integer i = 0;

    /*
        x data shift in
        [a][b][c][d][e]
        [b][c][d][e][f]
    */
    always @(posedge clk_in) begin
        if (! resetn_in)
            for (i = 0; i < FILTER_ORDER; i = i + 1)
                x_reg[i] <= 0;
        else begin
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                if (! i)
                    if (x_in < 0)
                        x_reg[i] <= {{{LMS_DATA_DIFF}{1'b1}}, x_in};
                    else
                        x_reg[i] <= {{{LMS_DATA_DIFF}{1'b0}}, x_in};
                else
                    x_reg[i] <= x_reg[i-1];
            end
        end
    end

    // y update
    always @(posedge clk_in) begin
        if (! resetn_in)
            y_reg <= 0;
        else begin
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                y_reg <= y_reg + (x_reg[i] * w_reg[i]);
            end
        end
    end

    // error update
    always @(posedge clk_in) begin
        if (! resetn_in)
            err_reg <= 0;
        else begin
            err_reg <= (ref_reg - y_reg);
        end
    end

    // weight update
    always @(posedge clk_in) begin
        if (! resetn_in)
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                w_reg[i] <= 0;
            end
        else begin
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                w_reg[i] <= w_reg[i] + ((err_reg * x_reg[i]) >> DATA_WIDTH);
            end
        end
    end
    
endmodule
