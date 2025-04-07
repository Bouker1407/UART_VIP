`uvm_analysis_imp_decl(_lhs_expected_item)
`uvm_analysis_imp_decl(_lhs_data)
`uvm_analysis_imp_decl(_lhs_other_bits_data)
`uvm_analysis_imp_decl(_rhs_expected_item)
`uvm_analysis_imp_decl(_rhs_data)
`uvm_analysis_imp_decl(_rhs_other_bits_data)

class uart_scoreboard extends uvm_scoreboard;

`uvm_component_utils(uart_scoreboard)

uvm_analysis_imp_lhs_expected_item #(uart_transaction, uart_scoreboard) lhs_expected_item_collected_port;
uvm_analysis_imp_lhs_data #(bit[8:0], uart_scoreboard) lhs_data_collected_port;
uvm_analysis_imp_lhs_other_bits_data #(bit[3:0], uart_scoreboard) lhs_other_bits_data_collected_port;
uvm_analysis_imp_rhs_expected_item #(uart_transaction, uart_scoreboard) rhs_expected_item_collected_port;
uvm_analysis_imp_rhs_data #(bit[8:0], uart_scoreboard) rhs_data_collected_port;
uvm_analysis_imp_rhs_other_bits_data #(bit[3:0], uart_scoreboard) rhs_other_bits_data_collected_port;

uart_config uart_lhs_config;
uart_config uart_rhs_config;

uvm_tlm_analysis_fifo #(uart_transaction) lhs_expected_item_fifo;
uvm_tlm_analysis_fifo #(bit[8:0]) lhs_actual_data_fifo;
uvm_tlm_analysis_fifo #(bit[3:0]) lhs_other_bits_data_fifo;

uvm_tlm_analysis_fifo #(uart_transaction) rhs_expected_item_fifo;
uvm_tlm_analysis_fifo #(bit[8:0]) rhs_actual_data_fifo;
uvm_tlm_analysis_fifo #(bit[3:0]) rhs_other_bits_data_fifo;

int lhs_data_bits, rhs_data_bits;
int lhs_num_1_bits, rhs_num_1_bits;
bit lhs_no_parity, rhs_no_parity;
bit lhs_parity_bit, rhs_parity_bit;
int lhs_stop_bit, rhs_stop_bit;
int lhs_other_bits, rhs_other_bits;

function new(string name = "uart_scoreboard", uvm_component parent);
	super.new(name, parent);
endfunction: new

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(uart_config)::get(this, "", "uart_lhs_config", uart_lhs_config))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_lhs_config from uvm_config_db!"))

	if(!uvm_config_db#(uart_config)::get(this, "", "uart_rhs_config", uart_rhs_config))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uar_rhs_config from uvm_config_db!"))

	lhs_expected_item_collected_port = new("lhs_expected_item_collected_port", this);
	lhs_data_collected_port = new("lhs_data_collected_port", this);
	lhs_other_bits_data_collected_port = new("lhs_other_bits_data_collected_port", this);
	rhs_expected_item_collected_port = new("rhs_expected_item_collected_port", this);
	rhs_data_collected_port = new("rhs_data_collected_port", this);
	rhs_other_bits_data_collected_port = new("rhs_other_bits_data_collected_port", this);

	lhs_expected_item_fifo = new("lhs_expected_item_fifo", this);
	lhs_actual_data_fifo = new("lhs_actual_data_fifo", this);
	lhs_other_bits_data_fifo = new("lhs_other_bits_data_fifo", this);

	rhs_expected_item_fifo = new("rhs_expected_item_fifo", this);
	rhs_actual_data_fifo = new("rhs_actual_data_fifo", this);
	rhs_other_bits_data_fifo = new("rhs_other_bits_data_fifo", this);

	lhs_data_bits = uart_lhs_config.data_bits;
	lhs_no_parity = (uart_lhs_config.parity_bit == uart_config::NO_PARITY) ? 1'b1 : 1'b0;
	lhs_stop_bit = uart_lhs_config.stop_bit;
	lhs_other_bits = 1 + (lhs_no_parity == 1'b0) + lhs_stop_bit; 

	rhs_data_bits = uart_rhs_config.data_bits;
	rhs_no_parity = (uart_rhs_config.parity_bit == uart_config::NO_PARITY) ? 1'b1 : 1'b0;
	rhs_stop_bit = uart_rhs_config.stop_bit;
	rhs_other_bits = 1 + (rhs_no_parity == 1'b0) + rhs_stop_bit; 
	//$display("############################## [SCOREBOARD] lhs_other_bits: %d, rhs_other_bits: %d", lhs_other_bits, rhs_other_bits);

endfunction: build_phase

virtual task run_phase(uvm_phase phase);
	uart_transaction lhs_exp, rhs_exp;
	bit[8:0] lhs_act_data, rhs_act_data;
	bit[3:0] lhs_other_bits_data, rhs_other_bits_data;

	forever begin
		fork
			begin
				lhs_num_1_bits = 0;
				lhs_expected_item_fifo.get(lhs_exp);
				rhs_actual_data_fifo.get(rhs_act_data);
				rhs_other_bits_data_fifo.get(rhs_other_bits_data);
				for (int i = 0; i < lhs_data_bits; i++) begin
					lhs_num_1_bits = lhs_num_1_bits + lhs_exp.data[i];
				end
				case(uart_lhs_config.parity_bit)
					uart_config::ODD_PARITY: lhs_parity_bit = (lhs_num_1_bits % 2 == 0) ? 1'b1 : 1'b0;
					uart_config::EVEN_PARITY: lhs_parity_bit = (lhs_num_1_bits % 2 == 0) ? 1'b0 : 1'b1;
				endcase
				if (lhs_exp.data != rhs_act_data) begin
					`uvm_error(get_type_name(), $sformatf("Data transfer from lhs to rhs is not matched! expected data is: %b, actual data is: %b, lhs numer of data bits is: %0d, rhs numer of data bits is: %0d", lhs_exp.data, rhs_act_data, lhs_data_bits, rhs_data_bits))
				end
				//start bit
				if (rhs_other_bits_data[rhs_other_bits-1] != 1'b0) begin
					`uvm_error(get_type_name(), $sformatf("Wrong start bit captured when transferring data from lhs to rhs"))
				end
				rhs_other_bits_data = rhs_other_bits_data << 1;
				//parity bit
				if (~lhs_no_parity) begin
					if (lhs_parity_bit != rhs_other_bits_data[rhs_other_bits-1])
						`uvm_error(get_type_name(), $sformatf("Wrong parity bit captured when transferring data from lhs to rhs"))
					rhs_other_bits_data = rhs_other_bits_data << 1;
				end
				//stop bit
				repeat(lhs_stop_bit) begin
					if (rhs_other_bits_data[rhs_other_bits-1] != 1'b1)
						`uvm_error(get_type_name(), $sformatf("Wrong stop bit captured when transferring data from lhs to rhs"))
					rhs_other_bits_data = rhs_other_bits_data << 1;
				end
			end

			begin
				rhs_num_1_bits = 0;
				rhs_expected_item_fifo.get(rhs_exp);
				lhs_actual_data_fifo.get(lhs_act_data);
				lhs_other_bits_data_fifo.get(lhs_other_bits_data);
				for (int i = 0; i < rhs_data_bits; i++) begin
					rhs_num_1_bits = rhs_num_1_bits + rhs_exp.data[i];
				end
				case(uart_rhs_config.parity_bit)
					uart_config::ODD_PARITY: rhs_parity_bit = (rhs_num_1_bits % 2 == 0) ? 1'b1 : 1'b0;
					uart_config::EVEN_PARITY: rhs_parity_bit = (rhs_num_1_bits % 2 == 0) ? 1'b0 : 1'b1;
				endcase
				if (rhs_exp.data != lhs_act_data) begin
					`uvm_error(get_type_name(), $sformatf("Data transfer from rhs to lhs is not matched! expected data is: %b, actual data is: %b, rhs number of data bits is: %0d, lhs number of data bits is: %0d", rhs_exp.data, lhs_act_data, rhs_data_bits, lhs_data_bits))
				end
				//start bit
				if (lhs_other_bits_data[lhs_other_bits-1] != 1'b0) begin
					`uvm_error(get_type_name(), $sformatf("Wrong start bit captured when transferring data from rhs to lhs"))
				end
				lhs_other_bits_data = lhs_other_bits_data << 1;
				//parity bit
				if (~rhs_no_parity) begin
					if (rhs_parity_bit != lhs_other_bits_data[lhs_other_bits-1])
						`uvm_error(get_type_name(), $sformatf("Wrong parity bit captured when transferring data from rhs to lhs"))
					lhs_other_bits_data = lhs_other_bits_data << 1;
				end
				//stop bit
				repeat(rhs_stop_bit) begin
					if (lhs_other_bits_data[lhs_other_bits-1] != 1'b1)
						`uvm_error(get_type_name(), $sformatf("Wrong stop bit captured when transferring data from rhs to lhs"))
					lhs_other_bits_data = lhs_other_bits_data << 1;
				end
			end
		join_any
	end
endtask: run_phase

function void write_lhs_expected_item(uart_transaction expected_item);
	`uvm_info(get_type_name(), $sformatf("Get expected_item from lhs_uart_driver:\n %s", expected_item.sprint()), UVM_FULL)
	lhs_expected_item_fifo.write(expected_item);
endfunction: write_lhs_expected_item

function void write_rhs_expected_item(uart_transaction expected_item);
	`uvm_info(get_type_name(), $sformatf("Get expected_item from rhs_uart_driver:\n %s", expected_item.sprint()), UVM_FULL)
	rhs_expected_item_fifo.write(expected_item);
endfunction: write_rhs_expected_item

function void write_lhs_data(bit [8:0] data);
	`uvm_info(get_type_name(), $sformatf("Get data from lhs_uart_monitor: %b", data), UVM_FULL)
	lhs_actual_data_fifo.write(data);
endfunction: write_lhs_data

function void write_rhs_data(bit [8:0] data);
	`uvm_info(get_type_name(), $sformatf("Get data from rhs_uart_monitor: %b", data), UVM_FULL)
	rhs_actual_data_fifo.write(data);
endfunction: write_rhs_data

function void write_lhs_other_bits_data(bit [3:0] other_bits_data);
	`uvm_info(get_type_name(), $sformatf("Get other_bits_data from lhs_uart_monitor: %b", other_bits_data), UVM_FULL)
	lhs_other_bits_data_fifo.write(other_bits_data);
endfunction: write_lhs_other_bits_data

function void write_rhs_other_bits_data(bit [3:0] other_bits_data);
	`uvm_info(get_type_name(), $sformatf("Get other_bits_data from rhs_uart_monitor: %b", other_bits_data), UVM_FULL)
	rhs_other_bits_data_fifo.write(other_bits_data);
endfunction: write_rhs_other_bits_data

endclass: uart_scoreboard
