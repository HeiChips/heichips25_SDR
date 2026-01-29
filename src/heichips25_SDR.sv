// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

// Adapted from the Tiny Tapeout template

`default_nettype none

module heichips25_SDR (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
	wire _unused = &{ena, ui_in[0]};


logic [3:0]in_data_I;
logic [3:0]in_data_Q;
logic [3:0]in_data_I2;
logic [3:0]in_data_Q2;
 
 assign in_data_I = ui_in[3:0];
 
assign in_data_Q =ui_in[7:4];
assign in_data_I2 = uio_in[7:4];

assign in_data_Q2 = uio_in[3:0];
 
 
 logic [8:0] [8:0]matrix1;
 logic [8:0] [8:0]matrix2;
  logic [8:0] [8:0]matrix3;
 logic [8:0] [8:0]matrix4;
 
 
 
  DP_Matrix_G  #(
        .RANGE_X_MIN_o(32),
        .RANGE_X_MAX_o(34),
        .RANGE_Y_MIN_o(40),
        .RANGE_Y_MAX_o(42))DP_1(
 	clk,
    rst_n,  // Active-low synchronous reset
    in_data_I,  // Q5.10 fixed-point input
	in_data_Q,

    matrix1 // 8-bit counters
);

   DP_Matrix_G  #(
        .RANGE_X_MIN_o(32),
        .RANGE_X_MAX_o(34),
        .RANGE_Y_MIN_o(40),
        .RANGE_Y_MAX_o(42))DP_2(
 	clk,
    rst_n,  // Active-low synchronous reset
    in_data_I,  // Q5.10 fixed-point input
	in_data_Q,

    matrix2 // 8-bit counters
);


  DP_Matrix_G  #(
        .RANGE_X_MIN_o(32),
        .RANGE_X_MAX_o(34),
        .RANGE_Y_MIN_o(40),
        .RANGE_Y_MAX_o(42))DP_3(
 	clk,
    rst_n,  // Active-low synchronous reset
    in_data_I2,  // Q5.10 fixed-point input
	in_data_Q2,

    matrix3 // 8-bit counters
);

   DP_Matrix_G  #(
        .RANGE_X_MIN_o(32),
        .RANGE_X_MAX_o(34),
        .RANGE_Y_MIN_o(40),
        .RANGE_Y_MAX_o(42))DP_4(
 	clk,
    rst_n,  // Active-low synchronous reset
    in_data_I2,  // Q5.10 fixed-point input
	in_data_Q2,

    matrix4 // 8-bit counters
);



 
 logic [21:0]  total_sum;
 logic [20:0]  total_sum1;
 logic [20:0]  total_sum2;
 
 MAC4x4 mac1(
     clk,
     rst_n,
    matrix1 ,      // 4x4 matrix A, flattened
    matrix2 ,      // 4x4 matrix B, flattened
    total_sum1      // Registered output
);
 
 
  MAC4x4 mac2(
     clk,
     rst_n,
    matrix3 ,      // 4x4 matrix A, flattened
    matrix4 ,      // 4x4 matrix B, flattened
    total_sum2      // Registered output
);
 
	assign total_sum = total_sum1+total_sum2;
    assign uo_out = total_sum[7:0];  // Output data from demodulation
	assign uio_out= total_sum[15:8];



assign uio_oe  = '1;




endmodule
