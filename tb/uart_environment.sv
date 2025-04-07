class uart_environment extends uvm_env;
`uvm_component_utils(uart_environment)

virtual uart_if lhs_vif;
virtual uart_if rhs_vif;

uart_agent uart_lhs_agent;
uart_agent uart_rhs_agent;
uart_scoreboard scoreboard;

uart_config uart_lhs_config;
uart_config uart_rhs_config;

function new(string name = "uart_environment", uvm_component parent);
	super.new(name, parent);
endfunction: new

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("build_phase", "ENTERED...", UVM_FULL)

	if (!uvm_config_db#(virtual uart_if)::get(this, "", "lhs_vif", lhs_vif))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db!"))

	if (!uvm_config_db#(virtual uart_if)::get(this, "", "rhs_vif", rhs_vif))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db!"))

	if(!uvm_config_db#(uart_config)::get(this, "", "uart_lhs_config", uart_lhs_config))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_lhs_config from uvm_config_db!"))

	if(!uvm_config_db#(uart_config)::get(this, "", "uart_rhs_config", uart_rhs_config))
		`uvm_fatal(get_type_name(), $sformatf("Failed to get uar_rhs_config from uvm_config_db!"))

	if (uart_lhs_config != uart_rhs_config) begin
		`uvm_warning(get_type_name(), $sformatf("Configuration is not matched on uart_lhs_config and uart_rhs_config!\n uart_lhs_config: \n %s \n uart_rhs_config: \n %s", uart_lhs_config.sprint(), uart_rhs_config.sprint()))
	end
	uart_lhs_agent = uart_agent::type_id::create("uart_lhs_agent", this);

	uart_rhs_agent = uart_agent::type_id::create("uart_rhs_agent", this);

	scoreboard = uart_scoreboard::type_id::create("scoreboard", this);

	uvm_config_db#(virtual uart_if)::set(this, "uart_lhs_agent", "uart_vif", lhs_vif);

	uvm_config_db#(virtual uart_if)::set(this, "uart_rhs_agent", "uart_vif", rhs_vif);

	uvm_config_db#(uart_config)::set(this, "uart_lhs_agent", "uart_configuration", uart_lhs_config);

	uvm_config_db#(uart_config)::set(this, "uart_rhs_agent", "uart_configuration", uart_rhs_config);

	uvm_config_db#(uart_config)::set(this, "scoreboard", "uart_lhs_config", uart_lhs_config);

	uvm_config_db#(uart_config)::set(this, "scoreboard", "uart_rhs_config", uart_rhs_config);

	`uvm_info("build_phase", "EXITING...", UVM_FULL)
endfunction: build_phase

virtual function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info("connect_phase", "ENTERED...", UVM_FULL)
	uart_lhs_agent.driver.expected_item_port.connect(scoreboard.lhs_expected_item_collected_port);
	uart_lhs_agent.monitor.data_observed_port.connect(scoreboard.lhs_data_collected_port);
	uart_lhs_agent.monitor.other_bits_data_observed_port.connect(scoreboard.lhs_other_bits_data_collected_port);

	uart_rhs_agent.driver.expected_item_port.connect(scoreboard.rhs_expected_item_collected_port);
	uart_rhs_agent.monitor.data_observed_port.connect(scoreboard.rhs_data_collected_port);
	uart_rhs_agent.monitor.other_bits_data_observed_port.connect(scoreboard.rhs_other_bits_data_collected_port);
	
	`uvm_info("connect_phase", "EXITING...", UVM_FULL)
endfunction: connect_phase



endclass: uart_environment
