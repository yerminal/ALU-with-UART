
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_uart_rx is
	generic (
	clk_freq: integer := 100_000_000;
	baud_rate: integer := 10_000_000;
	parity_type: STD_LOGIC := '0';
	stop_bit: integer := 1
	);
end tb_uart_rx;

architecture Behavioral of tb_uart_rx is

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

constant clk_period	: time := 10 ns;

signal clk_i		: STD_LOGIC := '0';
signal rst_i		: STD_LOGIC := '0';
signal tx_rx_io		: STD_LOGIC := '1';

signal data_o		: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal ready_rx_o	: STD_LOGIC	:= '1';
signal valid_rx_o	: STD_LOGIC	:= '0';
signal error_rx_o	: STD_LOGIC := '0';

signal data_i		: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal ready_tx_o	: STD_LOGIC;
signal tx_start_i	: STD_LOGIC := '0';

begin

OBJ_TX : uart_tx
	generic map(
	clk_freq => clk_freq,
	baud_rate => baud_rate,
	parity_type => parity_type,
	stop_bit => stop_bit
	)

	Port map(
	data_i => data_i,
	ready_o => ready_tx_o,
	tx_start_i => tx_start_i,
	tx_o => tx_rx_io,
	clk_i => clk_i,
	rst_i => rst_i
	);

OBJ_RX : uart_rx
	generic map(
	clk_freq => clk_freq,
	baud_rate => baud_rate,
	parity_type => parity_type,
	stop_bit => stop_bit
	)

	Port map(
	clk_i	=>	clk_i       ,
	rst_i	=>	rst_i       ,
	rx_i	=>	tx_rx_io    ,
	data_o	=>	data_o      ,
	ready_o	=>	ready_rx_o	,
	valid_o	=>	valid_rx_o	,
	error_o	=>	error_rx_o
	);

P_CLKGEN: process 
begin
	clk_i <= '0';
	wait for clk_period/2;
	clk_i <= '1';
	wait for clk_period/2;
end process;

P_MAIN: process

begin
	wait for 10*clk_period;
	data_i <= "10010101";
	tx_start_i <= '1';
	wait for clk_period;
	tx_start_i <= '0';
	wait for 10*clk_period*22; 
end process;


end Behavioral;
