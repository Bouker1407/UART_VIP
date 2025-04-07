class uart_monitor extends uvm_monitor;

`uvm_component_utils(uart_monitor)

virtual uart_if uart_vif;
uart_config uart_configuration;

real transfer_speed;
int data_bits;
bit no_parity;
int stop_bit;

bit [8:0] data;
bit [3:0] other_bits_data;

uvm_analysis_port #(bit[8:0]) 	data_observed_port;
uvm_analysis_port #(bit[3:0])	other_bits_data_observed_port; // start - parity - stop

bit timing_violate;

function new(string name = "uart_monitor", uvm_component parent);
	super.new(name, parent);
	data_observed_port = new("data_observed_port", this);
	other_bits_data_observed_port = new("other_bits_data_observed_port", this);
endfunction: new

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db. Please check!"))
	if (!uvm_config_db#(uart_config)::get(this, "", "uart_configuration", uart_configuration))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_config from uvm_config_db. Please check!"))
	transfer_speed = 1000000 / uart_configuration.baud_rate;
	data_bits = uart_configuration.data_bits;
	stop_bit = uart_configuration.stop_bit;
	no_parity = (uart_configuration.parity_bit == uart_config::NO_PARITY) ? 1'b1 : 1'b0;

endfunction: build_phase

virtual task run_phase(uvm_phase phase);
	`uvm_info("run_phase", "ENTERED...", UVM_FULL)
	forever begin
		timing_violate = 1'b0;
		data = 0;
		other_bits_data = 0;
		//start bit
		@(negedge uart_vif.RX);
		other_bits_data[0] =  uart_vif.RX;
		//data
		for(int i = 0; i <= data_bits - 1; i++) begin
			fork
				begin
					#(transfer_speed);
				end
				begin
					check_timing_violation(timing_violate);
				end
			join_any
			disable fork;
			if (timing_violate)
				`uvm_error(get_type_name(), "")
			fork
				begin
					#(transfer_speed/2);
					data[i-1] = uart_vif.RX;
				end
			join_none

		end
		//parity
		if (~no_parity) begin
			fork
				begin
					#(transfer_speed);
				end
				begin
					check_timing_violation(timing_violate);
				end
			join_any
			disable fork;
			if (timing_violate)
				`uvm_error(get_type_name(), "")
			other_bits_data = other_bits_data << 1;
			fork
				begin
					#(transfer_speed/2);
					other_bits_data[0] = uart_vif.RX;
				end
			join_none
		end
		//stop bit
		repeat(stop_bit) begin
			fork
				begin
					#(transfer_speed);
				end
				begin
					check_timing_violation(timing_violate);
				end
			join_any
			disable fork;
			if (timing_violate)
				`uvm_error(get_type_name(), "")
			other_bits_data =  other_bits_data << 1;
			fork
				begin
					#(transfer_speed/2);
					other_bits_data[0] = uart_vif.RX;
				end
			join_none
		end

//		fork
//			begin
//				#(transfer_speed);
//			end
//			begin
//				check_timing_violation(timing_violate);
//			end
//		join_any
//		disable fork;
//		if (timing_violate)
//			`uvm_error(get_type_name(), "")

		#(transfer_speed);
		`uvm_info(get_type_name(), $sformatf("Observed data: %b", data), UVM_FULL)
		data_observed_port.write(data);
		other_bits_data_observed_port.write(other_bits_data);
	end

endtask: run_phase

task check_timing_violation(output bit timing_violate);
	#1;
	@(posedge uart_vif.RX or negedge uart_vif.RX)
	
	timing_violate = 1'b1;
endtask

endclass: uart_monitor
