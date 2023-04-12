----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/06/2023 01:40:53 PM
-- Design Name: 
-- Module Name: uart_tx_rx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx_rx is
	generic (
	clk_freq	: integer 	:= 100_000_000;
	baud_rate	: integer 	:= 115_200;
	parity_type	: STD_LOGIC := '0'; -- for even parity -> '0', for odd parity -> '1'
	stop_bit	: integer 	:= 2
	);
	
	Port (
	clk_i		: in STD_LOGIC;
	rst_i		: in STD_LOGIC;
	
	data_tx_i	: in STD_LOGIC_VECTOR (7 downto 0);
	tx_start_i	: in STD_LOGIC;
	ready_tx_o	: out STD_LOGIC;
	tx_o		: out STD_LOGIC;
	
	rx_i		: in STD_LOGIC;
	data_rx_o	: out STD_LOGIC_VECTOR (7 downto 0);
	ready_rx_o	: out STD_LOGIC;
	valid_rx_o	: out STD_LOGIC;
	error_rx_o	: out STD_LOGIC
	);
end uart_tx_rx;

architecture Behavioral of uart_tx_rx is

component uart_tx is
	generic (
	clk_freq	: integer 	:= 100_000_000;
	baud_rate	: integer 	:= 115_200;
	parity_type	: STD_LOGIC := '0'; -- for even parity -> '0', for odd parity -> '1'
	stop_bit	: integer 	:= 2
	);
	
	Port (
	clk_i		: in STD_LOGIC;
	rst_i		: in STD_LOGIC;
	data_i		: in STD_LOGIC_VECTOR (7 downto 0);
	tx_start_i	: in STD_LOGIC;
	ready_o		: out STD_LOGIC;
	tx_o		: out STD_LOGIC
	);
end component;

component uart_rx is
	generic (
	clk_freq	: integer 	:= 100_000_000;
	baud_rate	: integer 	:= 115_200;
	parity_type	: STD_LOGIC := '0'; -- for even parity -> '0', for odd parity -> '1'
	stop_bit	: integer 	:= 2
	);
	
	Port (
	clk_i		: in STD_LOGIC;
	rst_i		: in STD_LOGIC;
	rx_i		: in STD_LOGIC;
	data_o		: out STD_LOGIC_VECTOR (7 downto 0);
	ready_o		: out STD_LOGIC;
	valid_o		: out STD_LOGIC;
	error_o		: out STD_LOGIC
	);
end component;

begin

OBJ_UART_TX : uart_tx
	generic map(
	clk_freq 	=> clk_freq		,
	baud_rate 	=> baud_rate	,
	parity_type => parity_type	,
	stop_bit 	=> stop_bit
	)

	Port map(
	data_i 		=> data_tx_i	,
	ready_o 	=> ready_tx_o	,
	tx_start_i 	=> tx_start_i	,
	tx_o 		=> tx_o			,
	clk_i 		=> clk_i		,
	rst_i 		=> rst_i
	);

OBJ_UART_RX : uart_rx
	generic map(
	clk_freq 	=> clk_freq		,
	baud_rate 	=> baud_rate	,
	parity_type => parity_type	,
	stop_bit 	=> stop_bit
	)

	Port map(
	clk_i	=>	clk_i       ,
	rst_i	=>	rst_i       ,
	rx_i	=>	rx_i    	,
	data_o	=>	data_rx_o   ,
	ready_o	=>	ready_rx_o	,
	valid_o	=>	valid_rx_o	,
	error_o	=>	error_rx_o
	);

end Behavioral;
