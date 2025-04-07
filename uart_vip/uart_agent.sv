class uart_agent extends uvm_agent;

`uvm_component_utils(uart_agent)

virtual uart_if uart_vif;
uart_config uart_configuration;

uart_sequencer sequencer;
uart_driver driver;
uart_monitor monitor;

function new(string name = "uart_agent", uvm_component parent);
	super.new(name, parent);
endfunction: new

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
		`uvm_fatal(get_type_name(), "Could not get uart_vif from uvm_config_db, please check!")
	if (!uvm_config_db#(uart_config)::get(this, "", "uart_configuration", uart_configuration))
		`uvm_fatal(get_type_name(), "Could not get uart_vif from uvm_config_db, please check!")

	if (is_active == UVM_ACTIVE) begin
		`uvm_info(get_type_name(), $sformatf("Active agent is configured"), UVM_FULL)

		driver = uart_driver::type_id::create("driver", this);
		sequencer = uart_sequencer::type_id::create("sequencer", this);
		monitor = uart_monitor::type_id::create("monitor", this);

		uvm_config_db#(virtual uart_if)::set(this, "driver", "uart_vif", uart_vif);
		uvm_config_db#(virtual uart_if)::set(this, "monitor", "uart_vif", uart_vif);
		
		uvm_config_db#(uart_config)::set(this, "driver", "uart_configuration", uart_configuration);
		uvm_config_db#(uart_config)::set(this, "monitor", "uart_configuration", uart_configuration);

	end
	else begin
		`uvm_info(get_type_name(), $sformatf("Passive agent is configured"), UVM_FULL)

		monitor = uart_monitor::type_id::create("monitor", this);

		uvm_config_db#(virtual uart_if)::set(this, "monitor", "uart_vif", uart_vif);

		uvm_config_db#(uart_config)::set(this, "monitor", "uart_configuration", uart_configuration);
	end	
endfunction: build_phase

virtual function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(get_is_active() == UVM_ACTIVE) begin
		driver.seq_item_port.connect(sequencer.seq_item_export);
	end
endfunction: connect_phase

endclass: uart_agent
