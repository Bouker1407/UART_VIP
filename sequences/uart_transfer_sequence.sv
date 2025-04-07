class uart_transfer_sequence extends uvm_sequence #(uart_transaction);

`uvm_object_utils(uart_transfer_sequence)


bit[8:0] data;


function new(string name = "uart_transfer_sequence");
	super.new(name);
	data = 0;
endfunction: new


virtual task body();
	req = uart_transaction::type_id::create("req");
	req.data = data;
	req.start_time = $time;
	start_item(req);
	`uvm_info(get_type_name(), $sformatf("Send request to driver: \n %s", req.sprint()), UVM_HIGH);
	finish_item(req);
	get_response(rsp);
	`uvm_info(get_type_name(), $sformatf("Received response from driver: \n %s", rsp.sprint()), UVM_HIGH);

endtask: body

endclass: uart_transfer_sequence
