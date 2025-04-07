class uart_both_one_stop_bit_test extends uart_base_test;

`uvm_component_utils(uart_both_one_stop_bit_test)

uart_transfer_sequence lhs_seq, rhs_seq;

int data_limit;

function new(string name = "uart_both_one_stop_bit_test", uvm_component parent);
	super.new(name, parent);
endfunction: new

virtual function void build_phase(uvm_phase phase);
	if (!std::randomize(uart_lhs_config.data_bits, uart_lhs_config.parity_bit, uart_lhs_config.stop_bit, uart_lhs_config.baud_rate) with{
	uart_lhs_config.stop_bit == uart_config::STOP_1BIT;
	uart_lhs_config.baud_rate inside {4800, 9600, 19200, 57600, 115200};
	(uart_lhs_config.data_bits == uart_config::DATA_9BITS) -> (uart_lhs_config.parity_bit == uart_config::NO_PARITY);}) begin
		`uvm_fatal(get_type_name(), $sformatf("Randomization config for uart_lhs and uart_rhs failed!"))
		$finish;
	end
	else begin
		data_limit = 2**uart_lhs_config.data_bits - 1;
		`uvm_info(get_type_name(), $sformatf("uart_lhs_config information:\n %s", uart_lhs_config.sprint()), UVM_HIGH)
		$cast(uart_rhs_config, uart_lhs_config);
		super.build_phase(phase);
	end
endfunction: build_phase

virtual task run_phase(uvm_phase phase);
	phase.raise_objection(this);
	
	lhs_seq = uart_transfer_sequence::type_id::create("lhs_seq");
	rhs_seq = uart_transfer_sequence::type_id::create("rhs_seq");

	repeat(3) begin
		if (!std::randomize(lhs_seq.data) with {lhs_seq.data < data_limit;} || !std::randomize(rhs_seq.data) with {rhs_seq.data < data_limit;})
			`uvm_fatal(get_type_name(), $sformatf("Data randomization failed!"))
		else begin
			fork
				lhs_seq.start(uart_env.uart_lhs_agent.sequencer);
				rhs_seq.start(uart_env.uart_rhs_agent.sequencer);
			join_any
		end
	end

	phase.drop_objection(this);
endtask: run_phase

endclass: uart_both_one_stop_bit_test
