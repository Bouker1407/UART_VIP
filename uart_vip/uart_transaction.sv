class uart_transaction extends uvm_sequence_item;

bit [8:0] data;

real start_time;
real end_time;

`uvm_object_utils_begin (uart_transaction)
	`uvm_field_int		(data,						UVM_ALL_ON | UVM_BIN)
	`uvm_field_real		(start_time,					UVM_ALL_ON | UVM_TIME)
	`uvm_field_real		(end_time,					UVM_ALL_ON | UVM_TIME)
`uvm_object_utils_end

function new (string name = "uart_transaction");
	super.new(name);
endfunction: new
	
endclass: uart_transaction
