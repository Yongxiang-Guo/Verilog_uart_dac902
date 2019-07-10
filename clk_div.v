`timescale 1ns/1ps

/****************************************
模块功能：326分频
输入参数：总时钟clk 50MHz、 复位信号rst_n
输出参数：分频时钟clkout
说明：16个时钟接收一个bit，波特率为9600
****************************************/ 
module uart_clkdiv(clk50, rst_n, clkout);
input clk50;              //系统时钟
input rst_n;              //复位信号
output clkout;            //采样时钟输出
reg clkout;
reg [15:0] cnt;

/////分频进程, 50Mhz的时钟326分频/////////
always @(posedge clk50 or negedge rst_n)   
begin
  if (!rst_n) begin
     clkout <=1'b0;
	  cnt<=0;
  end	  
  else if(cnt == 16'd162) begin
    clkout <= 1'b1;
    cnt <= cnt + 16'd1;
  end
  else if(cnt == 16'd325) begin
    clkout <= 1'b0;
    cnt <= 16'd0;
  end
  else begin
    cnt <= cnt + 16'd1;
  end
end
endmodule

/****************************************
模块功能：时钟分频控制
输入参数：所需频率freq
输出参数：分频器控制字
说明：本模块设定总时钟为100MHz
****************************************/ 
module da_clk_control(freq, freq_control_step);
//端口声明
input[15:0] freq;						//所需频率信息：16bit
output[31:0] freq_control_step;	//分频器累加控制字

//变量声明
parameter clk_sys = 1000;			//主时钟为100MHz,精度0.1

assign freq_control_step = 32'hffffffff / clk_sys / 4 * freq;//频率freq精度0.1KHz，所需分频时钟精度0.1MHz（1000个点/2）

endmodule

/****************************************
模块功能：实现任意分频
输入参数：总时钟clk	累加器控制字step
输出参数：分频时钟clkdiv
说明：累加器控制字=2^32	/分频数
****************************************/           
module clk_div(clk,step,clkdiv);
//端口声明
input clk;				//时钟100M
input[31:0] step;
output clkdiv;

//变量声明
//parameter STEP=32'h 49249249;//累加器控制字
reg[31:0] result;
wire clkdiv;

always @(posedge clk)
	result<=result+step;
	
assign clkdiv=result[31];

endmodule

/****************************************************************
******************自己写的其他整数分频模块***************************
****************************************************************/

/*        //二分频
module clk_div_2(clk, clk_n);
//端口声明
input clk;
output reg clk_n;

always @(posedge clk)
begin 
	clk_n = ~clk_n;
end

endmodule
*/



/*        //十分频
module clk_div_10(clk, clk_n);
//端口声明
input clk;
output reg clk_n;

//变量声明
integer count = 0;

always @(posedge clk)
begin 
	count = count+1;
	if(count == 5)
	begin
		count = 0;
		clk_n = ~clk_n;
	end
end

endmodule
*/

/*        //三分频_非50%占空比
module clk_div_3(clk, clk_n);
//端口声明
input clk;
output reg clk_n;

//变量声明
integer count = 0;

always @(posedge clk)
begin 
	count = count+1;
	if(count == 2)
	begin
		clk_n = ~clk_n;
	end
	if(count == 3)
	begin
*/

/*        //五分频_非50%占空比
module clk_div_5(clk, clk_n);
//端口声明
input clk;
output reg clk_n;

//变量声明
integer count = 0;

always @(posedge clk)
begin 
	count = count+1;
	if(count == 3)
	begin
		clk_n = ~clk_n;
	end
	if(count == 5)
	begin
		clk_n = ~clk_n;
		count = 0;
	end
end

endmodule
*/

/*        //七分频_非50%占空比
module clk_div_7(clk, clk_n);
//端口声明
input clk;
output reg clk_n;

//变量声明
integer count = 0;

always @(posedge clk)
begin 
	count = count+1;
	if(count == 4)
	begin
		clk_n = ~clk_n;
	end
	if(count == 7)
	begin
		clk_n = ~clk_n;
		count = 0;
	end
end

endmodule
*/
/****************************************************************
******************自己写的其他整数分频模块***************************
*****************************************************************/