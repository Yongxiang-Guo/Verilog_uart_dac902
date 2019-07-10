`timescale 1ns/1ps

/****************************************
模块功能：DA主模块
输入参数：系统时钟
输出参数：DA时钟、DA数据12位、PW位
说明：本模块设定总时钟为100MHz
****************************************/ 
module da_test(
	input clk,              //fpga clock:50MHz
	input rst_n,				//reset
	input rx,					//uart rx
	output daclk,           //da clock
	output[11:0] dadata,    //da data 12bit
	output reg pw = 0,
	output[3:0] led
	);

//变量定义
reg[9:0] rom_addr;         //rom addr 10bit
wire[11:0] rom_data;       //rom data 12bit
wire clk_uart,clk_100M;		//串口时钟、PLL产生100M时钟
wire[31:0] step;				//分频累加控制字
wire[7:0] rx_data;			//串口接收数据
wire rdsig, dataerror, frameerror;		//串口数据接收完成标志、数据错误标志、数据帧接收标志
wire[15:0] freq_out;			//频率输出
wire[15:0] amp_out;			//幅度输出
wire frame_error, frame_sig;		//数据帧解析错误、数据帧解析完成标志

//幅度输出控制
assign dadata= rom_data * amp_out;
//assign daclk=clk;

//DA output sin wave
always @(negedge daclk)
begin
   rom_addr=rom_addr+4'd4;
	if(rom_addr == 10'h3E8)
		rom_addr=10'h0;
end

//串口通信实例
uart_clkdiv uart_clkdiv_inst(clk, rst_n, clk_uart);
uartrx uartrx_inst(clk_uart, rst_n, rx, rx_data, rdsig, dataerror, frameerror);
uart_frame uart_frame_inst(clk_uart, rst_n, rx_data, rdsig, freq_out, amp_out, frame_error, frame_sig, led);
//分频器实例
da_clk_control da_clk_control_inst(freq_out, step);
clk_div clk_div_inst(clk_100M, step, daclk);

rom rom_inst (
 .clock(clk), // input clk 
 .address(rom_addr), // input [9:0] addr 
 .q(rom_data) // output [11:0]  
);

pll pll_inst(
 .inclk0(clk),
 .c0(clk_100M)
);

endmodule
