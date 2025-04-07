module testbench;  
  import uvm_pkg::*;
  import uart_pkg::*;
  import test_pkg::*;

  /** Instantiate UART Interface */
  uart_if lhs_if();
  uart_if rhs_if();

  /** Interconnect */
  uart_dut dut(.tx_lhs(lhs_if.RX),
               .rx_lhs(lhs_if.TX),
               .tx_rhs(rhs_if.RX),
               .rx_rhs(rhs_if.TX)
              );

  /** Set the VIP interface on the environment */
  initial begin
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","lhs_vif",lhs_if);
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","rhs_vif",rhs_if);

    /** Start the UVM test */
    run_test();
  end

endmodule


