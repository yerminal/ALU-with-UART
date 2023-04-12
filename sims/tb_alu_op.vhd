----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2023 08:38:11 AM
-- Design Name: 
-- Module Name: tb_alu_op - Behavioral
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

entity tb_alu_op is

end tb_alu_op;

architecture Behavioral of tb_alu_op is

component alu is
	Port (
	clk_i			: in STD_LOGIC;
	rst_i			: in STD_LOGIC;
	op1_i			: in STD_LOGIC_VECTOR (31 downto 0);
	op2_i			: in STD_LOGIC_VECTOR (31 downto 0);
	opr_i			: in STD_LOGIC_VECTOR (7 downto 0);
	op_ready_i		: in STD_LOGIC;
	output_o		: out STD_LOGIC_VECTOR(63 downto 0)
	);
end component;

constant clk_period	: time := 10 ns;

signal clk_i		: STD_LOGIC := '0';
signal rst_i		: STD_LOGIC := '0';
signal op1_o		: STD_LOGIC_VECTOR (31 downto 0);
signal op2_o		: STD_LOGIC_VECTOR (31 downto 0);
signal opr_o		: STD_LOGIC_VECTOR (7 downto 0);
signal op_ready_o	: STD_LOGIC := '0';
signal output_o		: STD_LOGIC_VECTOR(63 downto 0);

begin

OBJ_ALU: alu
	Port map(
	clk_i		=>	clk_i		,
	rst_i		=>	rst_i		,
	op1_i		=>	op1_o       ,
	op2_i		=>	op2_o       ,
	opr_i		=>	opr_o		,
	op_ready_i	=>	op_ready_o	,
	output_o	=> 	output_o
	);

P_MAIN: process

begin
	wait for 10*clk_period;
	op1_o     	<= x"00000001";
	op2_o     	<= x"FFFFFFFE";
	opr_o		<= x"00";
	wait for clk_period;
	op_ready_o	<= '1';
	wait for clk_period;
	op_ready_o	<= '0';
	-- for k in 0 to 3 loop
		-- wait for 10*clk_period;
		-- ready	<= '1';
		-- data	<= "11111111";
		-- wait for 10*clk_period;
		-- ready	<= '0';
		-- data	<= "00000000";
	-- end loop;
	
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
