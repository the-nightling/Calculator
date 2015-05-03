gui_open_window Wave
gui_sg_create VGA_PLL_group
gui_list_add_group -id Wave.1 {VGA_PLL_group}
gui_sg_addsignal -group VGA_PLL_group {VGA_PLL_tb.test_phase}
gui_set_radix -radix {ascii} -signals {VGA_PLL_tb.test_phase}
gui_sg_addsignal -group VGA_PLL_group {{Input_clocks}} -divider
gui_sg_addsignal -group VGA_PLL_group {VGA_PLL_tb.CLK_IN1}
gui_sg_addsignal -group VGA_PLL_group {{Output_clocks}} -divider
gui_sg_addsignal -group VGA_PLL_group {VGA_PLL_tb.dut.clk}
gui_list_expand -id Wave.1 VGA_PLL_tb.dut.clk
gui_sg_addsignal -group VGA_PLL_group {{Status_control}} -divider
gui_sg_addsignal -group VGA_PLL_group {VGA_PLL_tb.LOCKED}
gui_sg_addsignal -group VGA_PLL_group {{Counters}} -divider
gui_sg_addsignal -group VGA_PLL_group {VGA_PLL_tb.COUNT}
gui_sg_addsignal -group VGA_PLL_group {VGA_PLL_tb.dut.counter}
gui_list_expand -id Wave.1 VGA_PLL_tb.dut.counter
gui_zoom -window Wave.1 -full
