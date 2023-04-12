
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu is

end tb_alu;

architecture Behavioral of tb_alu is

component alu is
	Port ( 
	op1_i			: in STD_LOGIC_VECTOR (31 downto 0);
	op2_i			: in STD_LOGIC_VECTOR (31 downto 0);
	opr_i			: in STD_LOGIC_VECTOR (7 downto 0);
	op_ready_i		: in STD_LOGIC;
	output_o		: out STD_LOGIC_VECTOR(63 downto 0)
	);
end component;

component alu_in_data is
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
end component;

constant clk_period	: time := 10 ns;

signal data			: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal ready		: STD_LOGIC := '0';
signal clk_i		: STD_LOGIC := '0';
signal rst_i		: STD_LOGIC := '0';
signal op1_o		: STD_LOGIC_VECTOR (31 downto 0);
signal op2_o		: STD_LOGIC_VECTOR (31 downto 0);
signal opr_o		: STD_LOGIC_VECTOR (7 downto 0);
signal op_ready_o	: STD_LOGIC := '0';
signal output_o		: STD_LOGIC_VECTOR(63 downto 0);

begin

OBJ_ALU_DATA: alu_in_data
	Port map(
	clk_i			=>	clk_i	    ,
	rst_i			=>	rst_i       ,
	data_i			=> 	data        ,
	data_ready_i	=>	ready       ,
	op1_o			=>	op1_o       ,
	op2_o			=>	op2_o       ,
	opr_o			=>	opr_o		,
	op_ready_o		=> 	op_ready_o	
	);

OBJ_ALU: alu
	Port map(
	op1_i		=>	op1_o       ,
	op2_i		=>	op2_o       ,
	opr_i		=>	opr_o		,
	op_ready_i	=>	op_ready_o	,
	output_o	=> 	output_o
	);

P_MAIN: process

begin
	wait for 100*clk_period;
	for k in 0 to 3 loop
		wait for 10*clk_period;
		ready	<= '1';
		data	<= "11111111";
		wait for 10*clk_period;
		ready	<= '0';
		data	<= "00000000";
	end loop;
	
	for k in 0 to 3 loop
		wait for 10*clk_period;
		ready	<= '1';
		data	<= "11111111";
		wait for 10*clk_period;
		ready	<= '0';
		data	<= "00000000";
	end loop;
	
	wait for 3*clk_period;
	ready	<= '1';
	data	<= "00000000";
	wait for 2*clk_period;
	ready	<= '0';
	data	<= "00000000";
	
	-- wait for 100*clk_period;
	
	-- assert false
	-- report "SIM DONE"
	-- severity failure;
end process;

P_CLKGEN: process 
begin
	clk_i <= '0';
	wait for clk_period/2;
	clk_i <= '1';
	wait for clk_period/2;
end process;

end Behavioral;
