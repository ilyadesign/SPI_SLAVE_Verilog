`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/24 13:17:48
// Design Name: 
// Module Name: spi_slave
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


module spi_slave(
	input    wire    sys_clk,
	input    wire    rst_n,
	input    wire    CS_N,
	input    wire    SCK,
	input    wire    MOSI,
	input    wire    [7:0] txd_data,
	output   reg     MISO,
	output   reg     [7:0] rxd_data,
	output   wire    rxd_flag
    );
    
    wire    sck_pos_detect, sck_neg_detect;
    reg     sck_pos_detect_r0, sck_pos_detect_r1;
    
    wire    CS_N_pos_detect, CS_N_neg_detect;
    reg     CS_N_pos_detect_r0, CS_N_pos_detect_r1;
    
    reg     rxd_flag_r;
    reg     rxd_flag_r0;
    reg     rxd_flag_r1;
    
    reg     [3:0] rxd_data_cnt;
    reg     [1:0] rxd_current_state;
    reg     [1:0] rxd_next_state;
    
    reg     [7:0] txd_data_buf;
    reg     [3:0] txd_data_cnt;
    
    initial begin
    	sck_pos_detect_r0 <= 1'b1;
    	sck_pos_detect_r1 <= 1'b1;
    	
    	rxd_flag_r <= 1'b0;
    	rxd_current_state <= 2'd0;
    	rxd_next_state <= 2'd0;
    	
    	txd_data_buf <= 8'd0;
    	txd_data_cnt <= 4'd0;
    end
    
    // -- TODO: detect the posedge& negedge of sck
    assign sck_pos_detect = (sck_pos_detect_r0 && 
    						 !sck_pos_detect_r1) ? 1'b1: 1'b0;
    assign sck_neg_detect = (!sck_pos_detect_r0 && 
    					     sck_pos_detect_r1) ? 1'b1: 1'b0;
    always @ (posedge sys_clk or negedge rst_n) begin
    	if (!rst_n) begin
    		sck_pos_detect_r0 <= 1'b1;
    	    sck_pos_detect_r1 <= 1'b1;
    	end
    	else begin
    		sck_pos_detect_r0 <= SCK;
    		sck_pos_detect_r1 <= sck_pos_detect_r0;
    	end
    end
    
    // -- TODO: detect the posedge of rxd_flag
    assign rxd_flag = (rxd_flag_r0 &&
                       !rxd_flag_r1) ? 1'b1: 1'b0;
    always @ (posedge sys_clk or rst_n) begin
    	if (!rst_n) begin
    	    rxd_flag_r0 <= 1'b0;
    	    rxd_flag_r1 <= 1'b0;
    	end
    	else begin
    	    rxd_flag_r0 <= rxd_flag_r;
    	    rxd_flag_r1 <= rxd_flag_r0;
    	end
    end
    
    // --TODO: detect the posedge& negedge of CS_N
    assign CS_N_pos_detect = (CS_N_pos_detect_r0 && 
							 !CS_N_pos_detect_r1) ? 1'b1: 1'b0;
	assign CS_N_neg_detect = (!CS_N_pos_detect_r0 && 
							 CS_N_pos_detect_r1) ? 1'b1: 1'b0;
	always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			CS_N_pos_detect_r0 <= 1'b1;
			CS_N_pos_detect_r1 <= 1'b1;
		end
		else begin
			CS_N_pos_detect_r0 <= CS_N;
			CS_N_pos_detect_r1 <= CS_N_pos_detect_r0;
		end
	end
    
    // -- TODO: receive data& set read data flag
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            rxd_data <= 8'd0;
            rxd_data_cnt <= 4'd0;
            rxd_flag_r = 1'b0;
        end
        else if (sck_pos_detect && !CS_N && 
                        rxd_data_cnt != 4'd7) begin
			rxd_data <= {rxd_data[6:0], MOSI};
			rxd_data_cnt <= rxd_data_cnt + 1;
        end
        else if (sck_pos_detect && !CS_N &&
                        rxd_data_cnt == 4'd7) begin
            rxd_data <= {rxd_data[6:0], MOSI};
            rxd_data_cnt <= 4'd0;
        end
        else if (CS_N_pos_detect) begin
        	rxd_flag_r <= 1'b1;
        end
        else if (CS_N_neg_detect) begin
            rxd_data_cnt <= 4'd0;
            rxd_flag_r <= 1'b0;
        end
        else begin
        	rxd_data <= rxd_data;
        	rxd_data_cnt <= rxd_data_cnt;
        	rxd_flag_r <= rxd_flag_r;
        end
    end
    
    // -- TODO: synchronize data
    always @ (posedge sys_clk or negedge rst_n) begin
    	if (!rst_n) begin
    		txd_data_buf <= 8'd0;
    	end
    	else if (CS_N_neg_detect) begin
    		txd_data_buf <= txd_data;
    	end
    end
    
    // -- TODO: send data
    always @ (posedge sys_clk or negedge rst_n) begin
    	if (!rst_n) begin
    		txd_data_cnt <= 4'd0;
    	end
    	else if (sck_neg_detect && !CS_N &&
    	                txd_data_cnt != 4'd7) begin
    	    MISO <= txd_data_buf[7];
    		txd_data_buf <= txd_data_buf << 1;
    		txd_data_cnt <= txd_data_cnt + 1;
    	end
        else if (sck_neg_detect && !CS_N &&
    	    	        txd_data_cnt == 4'd7) begin
    	    MISO <= txd_data_buf[7];
    	    txd_data_cnt <= 4'd0;
    	end
    end
           
    
endmodule
