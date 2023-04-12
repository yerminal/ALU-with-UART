
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
	Port (
	clk_i			: in STD_LOGIC;
	rst_i			: in STD_LOGIC;
	op1_i			: in STD_LOGIC_VECTOR (31 downto 0);
	op2_i			: in STD_LOGIC_VECTOR (31 downto 0);
	opr_i			: in STD_LOGIC_VECTOR (7 downto 0);
	op_ready_i		: in STD_LOGIC;
	output_o		: out STD_LOGIC_VECTOR(63 downto 0);
	ready_output_o	: out STD_LOGIC
	);
end alu;

architecture Behavioral of alu is

subtype return_64_lv is STD_LOGIC_VECTOR(63 downto 0);

-- signal data_tmp	: return_64_lv := (others => '0');
-- signal output	: return_64_lv := (others => '0');
-- when you make addition make op1 op2 to 64 bits
-- when you make multiplication just use numeric STD
function f_arithmetic(	op1	: STD_LOGIC_VECTOR (31 downto 0);
						op2	: STD_LOGIC_VECTOR (31 downto 0);
						opr	: STD_LOGIC_VECTOR (7 downto 0)	) return return_64_lv is
begin
	case opr is
		when x"00" => -- ADDITION (UNSIGNED)
			return return_64_lv(unsigned((63 downto op1'length => '0') & op1) 
								+ unsigned((63 downto op2'length => '0') & op2));
								
		when x"01" => -- ADDITION (SIGNED)
			return return_64_lv(signed((63 downto op1'length => op1(op1'high)) & op1) 
								+ signed((63 downto op2'length => op2(op2'high)) & op2));
		
		when x"02" => -- SUBTRACTION (SIGNED) (OP1 - OP2)
			return return_64_lv(signed((63 downto op1'length => op1(op1'high)) & op1) 
								- signed((63 downto op2'length => op2(op2'high)) & op2));
		
		when x"03" => -- SUBTRACTION (SIGNED) (OP2 - OP1)
			return return_64_lv(signed((63 downto op2'length => op2(op2'high)) & op2) 
								- signed((63 downto op1'length => op1(op1'high)) & op1));
		
		when x"04" => -- MULTIPLICATION (UNSIGNED)
			return return_64_lv(unsigned(op1) 
								* unsigned(op2));
		
		when x"05" => -- MULTIPLICATION (SIGNED)
			return return_64_lv(signed(op1) 
								* signed(op2));
		
		when x"06" => -- DIVISION (UNSIGNED)
			return return_64_lv(unsigned((63 downto op1'length => '0') & op1) 
								/ unsigned(op2));
			
		when x"07" => -- DIVISION (SIGNED)
			return return_64_lv(signed((63 downto op1'length => op1(op1'high)) & op1) 
								/ signed(op2));
								
		when x"08" => -- AND
			return return_64_lv((63 downto op1'length => '0') & op1 AND 
								(63 downto op2'length => '0') & op2);
														  
		when x"09" => -- OR                               
			return return_64_lv((63 downto op1'length => '0') & op1 OR 
								(63 downto op2'length => '0') & op2);
														  
		when x"0A" => -- NAND                              
			return return_64_lv((63 downto op1'length => '0') & op1 NAND 
								(63 downto op2'length => '0') & op2);
		
		when x"0B" => -- NOR
			return return_64_lv((63 downto op1'length => '0') & op1 NOR 
								(63 downto op2'length => '0') & op2);
														  
		when x"0C" => -- XOR                               
			return return_64_lv((63 downto op1'length => '0') & op1 XOR 
								(63 downto op2'length => '0') & op2);
														  
		when x"0D" => -- XNOR                              
			return return_64_lv((63 downto op1'length => '0') & op1 XNOR 
								(63 downto op2'length => '0') & op2);		
		
		when others =>
			return x"0000000000000000";

	end case;
end function;

begin

P_MAIN: process(clk_i)

variable ready_before : STD_LOGIC := '0';

begin
	if rst_i = '1' then
		ready_before 	:= '0';
		output_o 		<= (others => '0');
		ready_output_o 	<= '0';
	elsif rising_edge(clk_i) then
		if op_ready_i = '1' AND ready_before = '0' then
			output_o 		<= f_arithmetic(op1_i,op2_i,opr_i);
			ready_output_o 	<= '1';
			ready_before 	:= '1';
		elsif op_ready_i = '0' then
			ready_before 	:= '0';
			ready_output_o 	<= '0';
		end if;
	end if;
end process P_MAIN;

end Behavioral;
