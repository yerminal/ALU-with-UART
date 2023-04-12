
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_in_data is
	Port (
	clk_i			: in STD_LOGIC;
	rst_i			: in STD_LOGIC;
	data_i			: in STD_LOGIC_VECTOR (7 downto 0);
	data_ready_i	: in STD_LOGIC;
	op1_o			: out STD_LOGIC_VECTOR (31 downto 0);
	op2_o			: out STD_LOGIC_VECTOR (31 downto 0);
	opr_o			: out STD_LOGIC_VECTOR (7 downto 0);
	op_ready_o		: out STD_LOGIC
	);
end alu_in_data;

architecture Behavioral of alu_in_data is

type states is (S_OP1, S_OP2, S_OPR);

signal state	: states	:= S_OP1;

signal data32_temp	: STD_LOGIC_VECTOR (31 downto 0)	:= (others => '0');
signal packet_counter	: integer range 0 to 4 				:= 0;
begin

P_MAIN: process(clk_i)

-- variable packet_counter	: integer range 0 to 4 				:= 0;
variable is_same_data	: STD_LOGIC 						:= '0';
-- variable data32_temp	: STD_LOGIC_VECTOR (31 downto 0)	:= (others => '0');

begin
	if rst_i = '1' then
		is_same_data 	:= '0';
		data32_temp 	<= (others => '0');
		packet_counter 	<= 0;
		state 			<= S_OP1;
		op1_o			<= (others => '0');
		op2_o			<= (others => '0');
		opr_o 			<= (others => '0');
		op_ready_o 		<= '0';
	elsif rising_edge(clk_i) then
		case state is
			when S_OP1 =>
				if packet_counter = 4 then
					op1_o 			<= data32_temp;
					state 			<= S_OP2;
					packet_counter 	<= 0;
				elsif data_ready_i = '1' AND is_same_data = '0' then
					op_ready_o 												<= '0';
					data32_temp(packet_counter*8+7 downto packet_counter*8)	<= data_i;
					packet_counter											<= packet_counter + 1;
					is_same_data											:= '1';
				elsif data_ready_i = '0' then
					is_same_data	:= '0';
				end if;
			when S_OP2 =>
				if packet_counter = 4 then
					op2_o 			<= data32_temp;
					state 			<= S_OPR;
					packet_counter 	<= 0;
				elsif data_ready_i = '1' AND is_same_data = '0' then
					data32_temp(packet_counter*8+7 downto packet_counter*8)	<= data_i;
					packet_counter											<= packet_counter + 1;
					is_same_data											:= '1';
				elsif data_ready_i = '0' then
					is_same_data	:= '0';
				end if;
			when S_OPR =>
				if data_ready_i = '1' AND is_same_data = '0' then
					op_ready_o 		<= '1';
					opr_o			<= data_i;
					is_same_data	:= '1';
					state 			<= S_OP1;
				elsif data_ready_i = '0' then
					is_same_data	:= '0';
				end if;
		end case;
	end if;
end process P_MAIN;


end Behavioral;
