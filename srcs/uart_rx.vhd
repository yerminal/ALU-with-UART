
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_rx is
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
end uart_rx;

architecture Behavioral of uart_rx is

type states is (S_IDLE, S_START, S_DATA, S_STOP);

constant c_baud_timer_limit	: integer						:= clk_freq/baud_rate;
signal state				: states						:= S_IDLE;
signal sft_register			: STD_LOGIC_VECTOR (7 downto 0)	:= (others => '0');

function ror_lv_1(sft_register: STD_LOGIC_VECTOR (7 downto 0)) return STD_LOGIC_VECTOR is
begin
	return sft_register(0) & sft_register(7 downto 1);
end function;

begin
	
	P_MAIN: process(clk_i)
	
	variable baud_timer		: integer range 0 to c_baud_timer_limit	:= 0;
	variable bit_counter	: integer range 0 to 8 					:= 0;
	variable parity_bit		: STD_LOGIC 							:= parity_type;
	
	begin
	if rst_i = '1' then
		sft_register	<= (others => '0');
		data_o			<= (others => '0');
		state 			<= S_IDLE;
		ready_o			<= '0';
		valid_o 		<= '1';
		error_o			<= '0';
		baud_timer 		:= 0;
		bit_counter		:= 0;
		parity_bit		:= parity_type;
	elsif rising_edge(clk_i) then
		case state is
			when S_IDLE =>
				if (rx_i = '0') then
					state 		<= S_START;
					baud_timer	:= 1;
					ready_o 	<= '0';
					data_o 		<= (others => '0');
				-- elsif (rx_i = '1') then
					-- ready_o <= '1';
				end if;
			when S_START =>
				if (baud_timer = c_baud_timer_limit-1) then
					state		<= S_DATA;
					baud_timer 	:= 0;
				else
					baud_timer := baud_timer + 1;
				end if;
			when S_DATA =>
				if (baud_timer = (c_baud_timer_limit-1)/2) then
					if (bit_counter = 8) then
						if (parity_bit /= rx_i) then
							error_o <= '1';
						else
							error_o <= '0';
						end if;
						data_o 		<= sft_register;
						bit_counter	:= stop_bit;
						state 		<= S_STOP;
					else
						sft_register(0)	<= rx_i;
						parity_bit		:= parity_bit xor rx_i;
						bit_counter 	:= bit_counter + 1;
					end if;
					baud_timer := baud_timer + 1;
				elsif (baud_timer = c_baud_timer_limit-1) then
					sft_register 	<= ror_lv_1(sft_register);
					baud_timer		:= 0;
				else
					baud_timer := baud_timer + 1;
				end if;
			when S_STOP =>
				if (baud_timer = (c_baud_timer_limit-1)/2) then
					if (rx_i /= '1') then
						valid_o 	<= '0';
						state 		<= S_IDLE;
						ready_o		<= '1';
						baud_timer 	:= 0;
						bit_counter	:= 0;
						parity_bit	:= parity_type;
					elsif (bit_counter = 1) then
						valid_o 	<= '1';
						state 		<= S_IDLE;
						ready_o		<= '1';
						baud_timer 	:= 0;
						bit_counter	:= 0;
						parity_bit	:= parity_type;
					else
						baud_timer := baud_timer + 1;
						bit_counter := bit_counter - 1;
					end if;
				elsif (baud_timer = c_baud_timer_limit-1) then
					baud_timer := 0;
				else
					baud_timer := baud_timer + 1;
				end if;
		end case;
	end if;
	end process P_MAIN;

end Behavioral;
