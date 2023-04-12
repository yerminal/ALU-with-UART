
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_out_data is
	Port (
	clk_i			: in STD_LOGIC;
	rst_i			: in STD_LOGIC;
	data_i			: in STD_LOGIC_VECTOR (63 downto 0);
	ready_data_i	: in STD_LOGIC;
	ready_to_send_i	: in STD_LOGIC;
	output_o		: out STD_LOGIC_VECTOR (7 downto 0);
	send_o			: out STD_LOGIC
	);
end alu_out_data;

architecture Behavioral of alu_out_data is

type states is (S_IDLE, S_SEND);

signal data				: STD_LOGIC_VECTOR (63 downto 0) 	:= (others => '0');	
signal state			: states 							:= S_IDLE;
signal packet_counter	: integer range 0 to 8 				:= 0;

begin

P_MAIN: process(clk_i)

variable send_before_data	: STD_LOGIC := '0';
variable send_before_packet	: STD_LOGIC := '0';

begin
	if rst_i = '1' then
		send_before_data	:= '0';
		send_before_packet 	:= '0';
		data 				<= (others => '0');
		state 				<= S_IDLE;
		packet_counter 		<= 0;
		output_o			<= (others => '0');
		send_o				<= '0';
	elsif rising_edge(clk_i) then
		case state is
			when S_IDLE =>
				if ready_data_i = '1' AND send_before_data = '0' then
					send_before_data := '1';
					state 			<= S_SEND;
					data 			<= data_i;
					if ready_to_send_i = '1' then
						output_o 		<= data_i(packet_counter*8+7 downto packet_counter*8);
						send_o 			<= '1';
						packet_counter 	<= packet_counter + 1;
						send_before_packet 	:= '1';
					end if;
				elsif ready_data_i = '0' then
					send_before_data := '0';
				end if;
			when S_SEND =>
				if ready_data_i = '0' then
					send_before_data := '0';
				end if;
				
				if ready_to_send_i = '1' AND send_before_packet = '0' then
					output_o 		<= data(packet_counter*8+7 downto packet_counter*8);
					send_o 			<= '1';
					send_before_packet 	:= '1';
					packet_counter 	<= packet_counter + 1;
				elsif ready_to_send_i = '0' then
					send_before_packet 	:= '0';
					send_o 			<= '0';
					if packet_counter = 8 then
						packet_counter 	<= 0;
						state 			<= S_IDLE;
					end if;
				end if;
		end case;
	end if;
end process P_MAIN;


end Behavioral;
