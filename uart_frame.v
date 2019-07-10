`timescale 1ns/1ps

/****************************************
模块功能：串口接收数据帧解析
输入参数：时钟clk、复位信号rst_n、接收数据rx_data、数据位结束标志rdsig（上升沿有效）
输出参数：频率数据freq、幅度数据amp、帧出错标志frame_error、帧解析完成标志frame_sig
说明：
****************************************/ 
module uart_frame(clk, rst_n, rx_data, rdsig, freq_out, amp_out, frame_error, frame_sig, led);
//端口声明
input clk;								//时钟
input rst_n;							//复位信号
input[7:0] rx_data;					//接收数据
input rdsig;							//一个字节接收结束标志（上升沿有效）
output reg[16:0] freq_out;				//频率控制字输出
output reg[16:0] amp_out;				//幅度控制字输出
output reg frame_error, frame_sig;	//帧出错标志、帧解析完成标志
output reg[3:0] led;

//变量声明
reg[31:0] freq, amp;
reg[7:0] cnt;
reg rdsigbuf, rdsigrise, receive;
reg idle;								//线路状态
reg[15:0] freq_extra;				//频率额外两个字节
reg[3:0] state_machine;	//数据帧解析状态机

//初始化
initial
begin
	freq_out <= 16'd100;
	amp_out <= 16'd20;
	led[0] <= 1'b1;
	led[1] <= 1'b1;
	led[2] <= 1'b1;
	led[3] <= 1'b1;
end

always @(posedge clk)		//检测rdsig上升沿
begin
	rdsigbuf <= rdsig;
	rdsigrise <= (~rdsigbuf) & rdsig;
end

always @(posedge clk)		//启动接收数据帧
begin
  if (rdsigrise && (~idle)) begin
		receive <= 1'b1;
  end
  else if(cnt == 8'd16)	begin
		receive <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)		//数据帧解析
begin
	if(!rst_n)
	begin
		led[0] <= 1'b0;
		led[1] <= 1'b1;
		led[2] <= 1'b1;
		led[3] <= 1'b1;
		
		idle <= 1'b0;
		cnt <= 8'd0;
		frame_sig <= 1'b0;
		frame_error <= 1'b0;
		state_machine <= 4'd0;
	end
	else if(receive == 1'b1) begin
		case(cnt)
		8'd0:begin
			idle <= 1'd1;
			cnt <= cnt + 8'd1;
			frame_sig <= 1'b0;
		end
		8'd16:begin
			idle <= 1'd1;
			case(state_machine)
			4'd0 : 
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				if(rx_data == 8'd80)			//帧头P
					state_machine <= 4'd1;
			end
			4'd1 : 
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				amp[31:24] <= rx_data - 8'd48;		//幅度第一位
				state_machine <= 4'd2;
			end
			4'd2 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				amp[23:16] <= rx_data - 8'd48;		//幅度第二位
				state_machine <= 4'd3;
			end
			4'd3 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				amp[15:8] <= rx_data - 8'd48;		//幅度第三位
				state_machine <= 4'd4;
			end
			4'd4 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				amp[7:0] <= rx_data - 8'd48;			//幅度第四位
				state_machine <= 4'd5;
			end
			4'd5 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				freq[31:24] <= rx_data - 8'd48;		//频率第一位
				state_machine <= 4'd6;
			end
			4'd6 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				freq[23:16] <= rx_data - 8'd48;		//频率第二位
				state_machine <= 4'd7;
			end
			4'd7 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				freq[15:8] <= rx_data - 8'd48;		//频率第三位
				state_machine <= 4'd8;
			end
			4'd8 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				freq[7:0] <= rx_data - 8'd48;		//频率第四位
				state_machine <= 4'd9;
			end
			4'd9 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				freq_extra[15:8] <= rx_data - 8'd48;		//频率第五位
				state_machine <= 4'd10;
			end
			4'd10 :
			begin
				frame_sig <= 1'b0;
				cnt <= cnt + 8'd1;
				freq_extra[7:0] <= rx_data - 8'd48;		//频率第六位
				state_machine <= 4'd11;
			end

			4'd11 :
			begin
				cnt <= cnt + 8'd1;
				if(rx_data == 8'd13)			//帧尾d
				begin
					led[2] <= 1'b0;
					frame_sig <= 1'b1;
					state_machine <= 4'd12;
				end
				else
				begin
					frame_error <= 1'b1;	//数据帧出错
					state_machine <= 4'd0;
				end
			end
			4'd12 :
			begin
				cnt <= cnt + 8'd1;
				if(rx_data == 8'd10)			//帧尾a
				begin
					led[3] <= 1'b0;
					frame_sig <= 1'b1;		//数据帧解析完成
					amp_out <= amp[31:24] * 16'd10 + amp[23:16];
					freq_out <= freq[31:24] * 16'd1000 + freq[23:16] * 16'd100 + freq[15:8] * 16'd10 + freq[7:0];
				end
				else
					frame_error <= 1'b1;		//数据帧出错
				state_machine <= 4'd0;
			end
			endcase
		end
		default: begin
			cnt <= cnt + 8'd1;
		end
		endcase
	end
	else begin
		cnt <= 8'd0;
		idle <= 1'b0;
		frame_sig <= 1'b0;
	end
end
	
endmodule
