class uart_config extends uvm_object;

typedef enum int {
	DATA_5BITS = 5,
	DATA_6BITS = 6,
	DATA_7BITS = 7,
	DATA_8BITS = 8,
	DATA_9BITS = 9
} data_bits_enum;

typedef enum bit [1:0] {
	NO_PARITY = 2'h0,
	ODD_PARITY = 2'h1,
	EVEN_PARITY = 2'h2
} parity_bit_enum;

typedef enum int {
	STOP_1BIT = 1,
	STOP_2BIT = 2
} stop_bit_enum;


 data_bits_enum data_bits;
 parity_bit_enum parity_bit;
 stop_bit_enum stop_bit;
 int baud_rate;

`uvm_object_utils_begin (uart_config)
	`uvm_field_enum 	(data_bits_enum, data_bits,	UVM_ALL_ON | UVM_DEC)

	`uvm_field_enum 	(parity_bit_enum, parity_bit,	UVM_ALL_ON | UVM_HEX)

	`uvm_field_enum 	(stop_bit_enum, stop_bit,	UVM_ALL_ON | UVM_DEC)
	
	`uvm_field_int 		(baud_rate,			UVM_ALL_ON | UVM_DEC)
`uvm_object_utils_end

function new (string name = "uart_config");
	super.new(name);
endfunction: new



endclass: uart_config
