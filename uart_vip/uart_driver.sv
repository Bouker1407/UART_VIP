class uart_driver extends uvm_driver #(uart_transaction);

`uvm_component_utils(uart_driver)

virtual uart_if uart_vif;
uart_config uart_configuration;


real transfer_speed;
int  data_bits;
bit parity_bit;
bit no_parity;
int stop_bit;
bit [8:0] data;
int num_1_bits;

uvm_analysis_port #(uart_transaction) expected_item_port;

function new(string name = "uart_driver", uvm_component parent);
	super.new(name, parent);
endfunction: new

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	expected_item_port = new("expected_item_port", this);

	if(!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) begin
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db. Please check!"))
	end

	if(!uvm_config_db#(uart_config)::get(this, "", "uart_configuration", uart_configuration)) begin
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_config from uvm_config_db. Please check!"))
	end

	transfer_speed = 1000000 / uart_configuration.baud_rate; 
	data_bits = uart_configuration.data_bits;
	stop_bit = uart_configuration.stop_bit;
	no_parity = (uart_configuration.parity_bit == uart_config::NO_PARITY) ? 1'b1 : 1'b0;
endfunction: build_phase

virtual task run_phase(uvm_phase phase);
	`uvm_info("run_phase", "ENTERED...", UVM_FULL)
	req = uart_transaction::type_id::create("req");
	forever begin
		num_1_bits = 0;
		seq_item_port.get(req);
		expected_item_port.write(req);
		data = req.data;
		for (int i = 0; i < data_bits; i++) begin
			num_1_bits = num_1_bits + data[i];
		end
		case (uart_configuration.parity_bit)
			uart_config::ODD_PARITY: parity_bit = (num_1_bits % 2 == 0) ?  1'b1 : 1'b0;
		        uart_config::EVEN_PARITY: parity_bit = (num_1_bits % 2 == 0) ? 1'b0 : 1'b1;	
		endcase
		#(transfer_speed);
		//start bit
		uart_vif.TX = 1'b0;
		// data
		repeat(data_bits) begin
			#(transfer_speed);
			uart_vif.TX = data[0];
			data = data >> 1;
		end
		// parity
		if (~no_parity) begin
			#(transfer_speed);
			uart_vif.TX = parity_bit;	
		end
		// stop bit/s
		repeat(stop_bit) begin
			#(transfer_speed);
			uart_vif.TX = 1'b1;
		end
		
		#(transfer_speed);
		$cast(rsp, req.clone());
		rsp.set_id_info(req);
		rsp.end_time = $time;
		seq_item_port.put(rsp);		
	end
endtask: run_phase


endclass: uart_driver
