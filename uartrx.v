`timescale 1ns/1ps

/****************************************
模块功能：串口接收
输入参数：时钟clk、复位信号rst_n、接收串行信号rx
输出参数：并行数据输出dataout
说明：16个时钟接收一个bit，波特率为9600
****************************************/
module uartrx(clk, rst_n, rx, dataout, rdsig, dataerror, frameerror);
//端口声明
input clk;             //采样时钟
input rst_n;           //复位信号
input rx;              //UART数据输入
output dataout;        //接收数据输出
output rdsig;			  //数据位标志，上升沿表示数据位全部接收完毕
output dataerror;      //数据出错指示
output frameerror;     //帧出错指示

//变量声明 
reg[7:0] dataout;
reg rdsig, dataerror;
reg frameerror;
reg [7:0] cnt;
reg rxbuf, rxfall, receive;
parameter paritymode = 1'b0;
reg presult, idle;		//奇偶校验、线路状态

always @(posedge clk)   //检测线路的下降沿
begin
  rxbuf <= rx;
  rxfall <= rxbuf & (~rx);
end

////////////////////////////////////////////////////////////////
//启动串口接收程序
////////////////////////////////////////////////////////////////
always @(posedge clk)
begin
  if (rxfall && (~idle)) begin//检测到线路的下降沿并且原先线路为空闲，启动接收数据进程  
    receive <= 1'b1;
  end
  else if(cnt == 8'd152) begin //接收数据完成
    receive <= 1'b0;
  end
end

////////////////////////////////////////////////////////////////
//串口接收程序, 16个时钟接收一个bit
////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) begin
     idle<=1'b0;
	  cnt<=8'd0;
     rdsig <= 1'b0;	 
	  frameerror <= 1'b0; 
	  dataerror <= 1'b0;	  
	  presult<=1'b0;
  end	  
  else if(receive == 1'b1) begin
		case (cnt)
		8'd0:begin
			idle <= 1'b1;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd24:begin                 //接收第0位数据
			idle <= 1'b1;
			dataout[0] <= rx;
			presult <= paritymode^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd40:begin                 //接收第1位数据  
			idle <= 1'b1;
			dataout[1] <= rx;
			presult <= presult^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd56:begin                 //接收第2位数据   
			idle <= 1'b1;
			dataout[2] <= rx;
			presult <= presult^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd72:begin               //接收第3位数据   
			idle <= 1'b1;
			dataout[3] <= rx;
			presult <= presult^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd88:begin               //接收第4位数据    
			idle <= 1'b1;
			dataout[4] <= rx;
			presult <= presult^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd104:begin            //接收第5位数据    
			idle <= 1'b1;
			dataout[5] <= rx;
			presult <= presult^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd120:begin            //接收第6位数据    
			idle <= 1'b1;
			dataout[6] <= rx;
			presult <= presult^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b0;
		end
		8'd136:begin            //接收第7位数据   
			idle <= 1'b1;
			dataout[7] <= rx;
			presult <= presult^rx;
			cnt <= cnt + 8'd1;
			rdsig <= 1'b1;
		end
		8'd152:begin
		  idle <= 1'b1;
		  if(1'b1 == rx)
			 frameerror <= 1'b0;
		  else
			 frameerror <= 1'b1;      //如果没有接收到停止位，表示帧出错
		  cnt <= cnt + 8'd1;
		  rdsig <= 1'b1;
		end
		default: begin
			cnt <= cnt + 8'd1;
		end
		endcase
   end	
   else begin
	  cnt <= 8'd0;
	  idle <= 1'b0;
	  rdsig <= 1'b0;	 
	end
end
endmodule
