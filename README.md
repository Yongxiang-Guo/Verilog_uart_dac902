# Verilog_uart_dac902
# My Verilog_Hello_World Code
利用FPGA实现串口通信接收频率、幅度信息，控制DAC902模块输出所给定频率、幅度的正弦信号

代码文件说明：
1、clk_div.v————————串口时钟分频、任意时钟分频模块（用于DA时钟）；
2、uartrx.v————————串口接收模块（不含奇偶校验位）；
3、uart_frame.v————————数据帧解析模块（数据帧长度13位，包含帧头1位、数据10位、帧尾2位）；
4、da_test.v————————DA控制模块（根据接收信息，设置输出正弦信号频率、幅度）；
5、pll.v \ pll_bb.v————————PLL模块（利用quartus自带IP盒实现，产生100MHz时钟）；
6、rom.v \ rom_bb.v————————ROM模块（利用quartus自带IP盒实现，存储正弦波一个周期的1000个点）
