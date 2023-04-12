
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
	generic (
	clk_freq	: integer 	:= 100_000_000;
	baud_rate	: integer 	:= 115_200;
	parity_type	: STD_LOGIC := '0'; -- for even parity -> '0', for odd parity -> '1'
	stop_bit	: integer 	:= 1
	);
	
	Port (
	clk			: in STD_LOGIC;
	-- btnR		: in STD_LOGIC;
	btnC		: in STD_LOGIC;
	-- sw			: in STD_LOGIC_VECTOR (7 downto 0);
	led			: out STD_LOGIC_VECTOR (7 downto 0);
	RsRx		: in STD_LOGIC;
	RsTx		: out STD_LOGIC;
	
	valid_led 	: out STD_LOGIC;
	error_led 	: out STD_LOGIC
	);
end top;

architecture Behavioral of top is

component uart_tx_rx is
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
end component;

component alu is
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

component alu_out_data is
	Port (
	clk_i			: in STD_LOGIC;
	rst_i			: in STD_LOGIC;
	data_i			: in STD_LOGIC_VECTOR (63 downto 0);
	ready_data_i	: in STD_LOGIC;
	ready_to_send_i	: in STD_LOGIC;
	output_o		: out STD_LOGIC_VECTOR (7 downto 0);
	send_o			: out STD_LOGIC
	);
end component;

-- component seven_display is
	-- generic (
	-- clk_freq				: integer := 100_000_000; 	-- reference_clock: 100 MHz
	-- digit_refresh_period	: integer := 1000 			-- 1000 us
	-- );
	
	-- Port (
	-- clk_i	: in STD_LOGIC;
	-- rst_i   : in STD_LOGIC;
	-- number  : in integer range 0 to 9999;
	-- -- dp_o		: out STD_LOGIC;
	-- an_o 	: out STD_LOGIC_VECTOR (3 downto 0);
	-- seg_o	: out STD_LOGIC_VECTOR (6 downto 0));
-- end component;

signal data_tx_i	: STD_LOGIC_VECTOR (7 downto 0);
signal ready_tx_o	: STD_LOGIC;
signal ready_rx_o	: STD_LOGIC;
signal data_rx_o	: STD_LOGIC_VECTOR (7 downto 0);
signal valid_rx_o	: STD_LOGIC;
signal error_rx_o   : STD_LOGIC;

signal tx_start_i	: STD_LOGIC;

signal op1			: STD_LOGIC_VECTOR (31 downto 0);
signal op2			: STD_LOGIC_VECTOR (31 downto 0);	
signal opr			: STD_LOGIC_VECTOR (7 downto 0);	
signal op_ready		: STD_LOGIC;

signal number_o		: STD_LOGIC_VECTOR (63 downto 0);
signal ready_number : STD_LOGIC;

begin               

OBJ_UART: uart_tx_rx
	generic map(
	clk_freq	=>  clk_freq	,
	baud_rate	=>  baud_rate	,
	parity_type	=>  parity_type	,
	stop_bit	=>  stop_bit	
	)
	
	Port map(
	clk_i		=>	clk         ,
	rst_i		=> 	btnC        ,
								
	data_tx_i	=>	data_tx_i   ,
	tx_start_i	=>	tx_start_i  ,
	ready_tx_o	=>	ready_tx_o  ,
	tx_o		=> 	RsTx        ,
								
	rx_i		=>	RsRx        ,
	data_rx_o	=>	data_rx_o   ,
	ready_rx_o	=>	ready_rx_o	,
	valid_rx_o	=>	valid_rx_o	,
	error_rx_o	=>	error_rx_o
	);

OBJ_ALU_IN_DATA : alu_in_data
	Port map(
	clk_i			=>	clk			,
	rst_i			=>	btnC		,
	data_i			=>	data_rx_o	,
	data_ready_i	=>	ready_rx_o	,
	op1_o			=>	op1			,
	op2_o			=>	op2			,
	opr_o			=>	opr			,
	op_ready_o		=>	op_ready
	);
	
OBJ_ALU : alu
	Port map( 
	clk_i			=> clk			,	
	rst_i			=> btnC			,	
	op1_i			=> op1			,	
	op2_i			=> op2			,	
	opr_i			=> opr			,	
	op_ready_i		=> op_ready		,	
	output_o		=> number_o		,	
	ready_output_o	=> ready_number
	);

OBJ_ALU_OUT_DATA : alu_out_data
	Port map(
	clk_i		    =>  clk				,
	rst_i		    =>  btnC			,
	data_i		    =>  number_o		,
	ready_data_i    =>  ready_number	,
	ready_to_send_i	=>	ready_tx_o		,
	output_o	    =>	data_tx_i		,
	send_o		    =>	tx_start_i
	);

P_MAIN : process(clk)

variable pressed : STD_LOGIC := '0';

begin
	if btnC = '1' then
		pressed 	:= '0';
		led 		<= (others => '0');
		valid_led 	<= '0';
		error_led 	<= '0';
	elsif rising_edge(clk) then
		-- if (btnR = '1' AND pressed = '0') then
			-- tx_start_i <= '1';
			-- pressed := '1';
		-- elsif (btnR = '0') then
			-- pressed := '0';
			-- tx_start_i <= '0';
		-- else
			-- tx_start_i <= '0';
		-- end if;
		
		if (ready_rx_o = '1') then
			led <= data_rx_o;
			
			if (valid_rx_o /= '1') then
				valid_led <= '1';
			else
				valid_led <= '0';
			end if;
			
			if (error_rx_o = '1') then
				error_led <= '1';
			else
				error_led <= '0';
			end if;
		end if;
	end if;
end process P_MAIN;

-- P_DIGIT : process(clk, data)
-- variable pressed : STD_LOGIC := '0';

-- begin
	-- if rising_edge(clk) then
		
	-- end if;
-- end process P_DIGIT;

end Behavioral;
