class uart_base_test extends uvm_test;

`uvm_component_utils(uart_base_test)

virtual uart_if lhs_vif;
virtual uart_if rhs_vif;
uart_environment uart_env;
uart_config uart_lhs_config;
uart_config uart_rhs_config;

function new(string name = "uart_base_test", uvm_component parent);
	super.new(name, parent);
	uart_lhs_config = uart_config::type_id::create("uart_lhs_config");
	uart_rhs_config = uart_config::type_id::create("uart_rhs_config");
endfunction: new

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("build_phase", "ENTERED...", UVM_FULL)

	if (!uvm_config_db#(virtual uart_if)::get(this, "", "lhs_vif", lhs_vif))
		`uvm_fatal(get_type_name(), $sformatf("Could not get uart_vif from uvm_config_db, please check!"))

	if (!uvm_config_db#(virtual uart_if)::get(this, "", "rhs_vif", rhs_vif))
		`uvm_fatal(get_type_name(), $sformatf("Could not get uart_vif from uvm_config_db, please check!"))


	uart_env = uart_environment::type_id::create("uart_env", this);

	uvm_config_db#(virtual uart_if)::set(this, "uart_env", "lhs_vif", lhs_vif);
	uvm_config_db#(virtual uart_if)::set(this, "uart_env", "rhs_vif", rhs_vif);

	uvm_config_db#(uart_config)::set(this, "uart_env", "uart_lhs_config", uart_lhs_config);
	uvm_config_db#(uart_config)::set(this, "uart_env", "uart_rhs_config", uart_rhs_config);

	`uvm_info("build_phase", "EXITING...", UVM_FULL)


endfunction: build_phase

virtual function void start_of_simulation_phase(uvm_phase phase);
	uvm_top.print_topology();
endfunction: start_of_simulation_phase

virtual function void final_phase(uvm_phase phase);
	uvm_report_server svr;
	super.final_phase(phase);
	`uvm_info("final_phase", "ENTERED...", UVM_HIGH)
	svr = uvm_report_server::get_server();
	if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
		$display("### Status: TEST FAILED ###");
	end
	else begin
		$display("### Status: TEST PASSED ###");
	end
	`uvm_info("final_phase", "EXITING...", UVM_HIGH)
endfunction: final_phase


endclass: uart_base_test
