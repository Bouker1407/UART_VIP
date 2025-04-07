//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : test_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_TEST_PKG__SV
`define GUARD_UART_TEST_PKG__SV

package test_pkg;
  import uvm_pkg::*;
  import uart_pkg::*;
  import seq_pkg::*;
  import env_pkg::*;

  // Include your file
  `include "uart_base_test.sv"
  //lhs
  `include "uart_lhs_five_bits_data_test.sv"
  `include "uart_lhs_six_bits_data_test.sv"
  `include "uart_lhs_seven_bits_data_test.sv"
  `include "uart_lhs_eight_bits_data_test.sv"
  `include "uart_lhs_nine_bits_data_test.sv"

  `include "uart_lhs_no_parity_test.sv"
  `include "uart_lhs_odd_parity_test.sv"
  `include "uart_lhs_even_parity_test.sv"

  `include "uart_lhs_one_stop_bit_test.sv"
  `include "uart_lhs_two_stop_bit_test.sv"

  `include "uart_lhs_baud_rate_4800_test.sv"
  `include "uart_lhs_baud_rate_9600_test.sv"
  `include "uart_lhs_baud_rate_19200_test.sv"
  `include "uart_lhs_baud_rate_57600_test.sv"
  `include "uart_lhs_baud_rate_115200_test.sv"

  //rhs
  `include "uart_rhs_five_bits_data_test.sv"
  `include "uart_rhs_six_bits_data_test.sv"
  `include "uart_rhs_seven_bits_data_test.sv"
  `include "uart_rhs_eight_bits_data_test.sv"
  `include "uart_rhs_nine_bits_data_test.sv"

  `include "uart_rhs_no_parity_test.sv"
  `include "uart_rhs_odd_parity_test.sv"
  `include "uart_rhs_even_parity_test.sv"

  `include "uart_rhs_one_stop_bit_test.sv"
  `include "uart_rhs_two_stop_bit_test.sv"

  `include "uart_rhs_baud_rate_4800_test.sv"
  `include "uart_rhs_baud_rate_9600_test.sv"
  `include "uart_rhs_baud_rate_19200_test.sv"
  `include "uart_rhs_baud_rate_57600_test.sv"
  `include "uart_rhs_baud_rate_115200_test.sv"

  //both
  `include "uart_both_five_bits_data_test.sv"
  `include "uart_both_six_bits_data_test.sv"
  `include "uart_both_seven_bits_data_test.sv"
  `include "uart_both_eight_bits_data_test.sv"
  `include "uart_both_nine_bits_data_test.sv"

  
  `include "uart_both_no_parity_test.sv"
  `include "uart_both_odd_parity_test.sv"
  `include "uart_both_even_parity_test.sv"

  `include "uart_both_one_stop_bit_test.sv"
  `include "uart_both_two_stop_bit_test.sv"

  `include "uart_both_baud_rate_4800_test.sv"
  `include "uart_both_baud_rate_9600_test.sv"
  `include "uart_both_baud_rate_19200_test.sv"
  `include "uart_both_baud_rate_57600_test.sv"
  `include "uart_both_baud_rate_115200_test.sv"

  //custom baud rate
  `include "uart_lhs_baud_rate_custom_test.sv"
  `include "uart_rhs_baud_rate_custom_test.sv"
  `include "uart_both_baud_rate_custom_test.sv"

  //error test
  `include "uart_data_bits_error_test.sv"
  `include "uart_parity_bit_error_test.sv"
  `include "uart_stop_bit_error_test.sv"
  `include "uart_baud_rate_error_test.sv"
endpackage: test_pkg

`endif


