
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_uart_tx is
	generic (
	clk_freq: integer := 100_000_000;
	baud_rate: integer := 115_200;
	parity_type: STD_LOGIC := '1';
	stop_bit: integer := 2
	);
end tb_uart_tx;

architecture Behavioral of tb_uart_tx is

component uart_tx is
	generic (
	clk_freq: integer := 100_000_000;
	baud_rate: integer := 115_200;
	parity_type: STD_LOGIC := '0';
	stop_bit: integer := 2
	);
	
	Port (
	data_i: in STD_LOGIC_VECTOR (7 downto 0);
	-- valid_i: in STD_LOGIC;
	ready_o: out STD_LOGIC;
	tx_start_i: in STD_LOGIC;
	tx_o: out STD_LOGIC;
	clk_i: in STD_LOGIC;
	rst_i: in STD_LOGIC
	);
end component;

constant clk_period	: time := 10 ns;

signal data_i		: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal ready_o		: STD_LOGIC;
signal tx_o			: STD_LOGIC;
signal tx_start_i	: STD_LOGIC := '0';
signal clk_i		: STD_LOGIC := '0';
signal rst_i		: STD_LOGIC := '0';

begin

OBJ : uart_tx
	generic map(
	clk_freq => clk_freq,
	baud_rate => baud_rate,
	parity_type => parity_type,
	stop_bit => stop_bit
	)

	Port map(
	data_i => data_i,
	ready_o => ready_o,
	tx_start_i => tx_start_i,
	tx_o => tx_o,
	clk_i => clk_i,
	rst_i => rst_i
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
	data_i <= "00010101";
	tx_start_i <= '1';
	wait for clk_period;
	tx_start_i <= '0';
	wait for 10*clk_period*22; 
end process;


end Behavioral;
