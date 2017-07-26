`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/25 13:10:22
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
	input wire sys_clk,
	input wire rst_n,
	input wire CS_N,
	input wire SCK,
	input wire MOSI,
	input wire [7:0] txd_data,
	output wire MISO,
	output reg [7:0] rxd_data,
	output rxd_flag_r
    );
    
    wire rxd_flag;
    wire [7:0] rxd_data_r;
    
    spi_slave test(
    	.sys_clk(sys_clk),
    	.rst_n(rst_n),
    	.CS_N(CS_N),
    	.SCK(SCK),
    	.MOSI(MOSI),
    	.txd_data(txd_data),
    	.MISO(MISO),
    	.rxd_data(rxd_data_r),
    	.rxd_flag(rxd_flag)
    );
    
    assign rxd_flag_r = ~ rxd_flag;
    always @ (posedge rxd_flag) begin
    	rxd_data <= rxd_data_r;
    end
endmodule
