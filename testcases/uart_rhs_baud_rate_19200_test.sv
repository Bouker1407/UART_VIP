class uart_rhs_baud_rate_19200_test extends uart_base_test;

`uvm_component_utils(uart_rhs_baud_rate_19200_test)

uart_transfer_sequence seq;

int data_limit;

function new(string name = "uart_rhs_baud_rate_19200_test", uvm_component parent);
	super.new(name, parent);
endfunction: new

virtual function void build_phase(uvm_phase phase);
	if (!std::randomize(uart_rhs_config.data_bits, uart_rhs_config.parity_bit, uart_rhs_config.stop_bit, uart_rhs_config.baud_rate) with{ 
	(uart_rhs_config.data_bits == uart_config::DATA_9BITS) -> (uart_rhs_config.parity_bit == uart_config::NO_PARITY);
	uart_rhs_config.baud_rate inside {19200};}) begin
		`uvm_fatal(get_type_name(), $sformatf("Randomization config for uart_rhs and uart_rhs failed!"))
		$finish;
	end
	else begin
		data_limit = 2**uart_rhs_config.data_bits - 1;
		`uvm_info(get_type_name(), $sformatf("uart_rhs_config information:\n %s", uart_rhs_config.sprint()), UVM_HIGH)
		$cast(uart_lhs_config, uart_rhs_config);
		super.build_phase(phase);
	end
endfunction: build_phase

virtual task run_phase(uvm_phase phase);
	phase.raise_objection(this);
	
	seq = uart_transfer_sequence::type_id::create("seq");

	repeat(3) begin
		if (!std::randomize(seq.data) with {seq.data < data_limit;})
			`uvm_fatal(get_type_name(), $sformatf("Data randomization failed!"))
		else
			seq.start(uart_env.uart_rhs_agent.sequencer);
	end

	phase.drop_objection(this);
endtask: run_phase

endclass: uart_rhs_baud_rate_19200_test
