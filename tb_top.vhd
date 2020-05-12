library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is  
generic( 
		 clk_period			: time    :=1 us;
		 shifter_width 	: integer := 8;
		 counter_width 	: integer := 8;
		 data_width			: integer := 8
		);
end entity;

architecture arch_tb_top of tb_top is

component top is  
generic( 
		 shifter_width 	: integer := 8;
		 counter_width 	: integer := 8;
		 data_width	 	: integer := 8
		);
port(
		rst			: in	std_logic;
		clk			: in 	std_logic;
		data_in 	: in	std_logic_vector (data_width-1 downto 0);
		calc_req	: in	std_logic;
		calc_ack	: out	std_logic;
		calc_value	: out 	integer range 0 to data_width
			
);
end component;

component tb_stim is  
generic( 
		 clk_period		: time    := 1 us;
		 shifter_width 	: integer := 8;
		 counter_width 	: integer := 8;
		 data_width		: integer := 8
		);
port (		
	rst			: inout	std_logic;
	clk			: inout std_logic;
	data_out 	: inout	std_logic_vector (data_width-1 downto 0);
	calc_req	: inout	std_logic;
	calc_ack	: in	std_logic;
	calc_value	: in 	integer range 0 to counter_width
);
end component;

	signal clock 				: std_logic;
	signal reset 				: std_logic;
	signal calc_acknowledge : std_logic;
	signal calc_request		: std_logic;
	signal data_out 		   : std_logic_vector (data_width-1 downto 0);
	signal calc_value 		: integer range 0 to data_width;

begin

	TOP_u : top
	generic map( 
			 shifter_width 	=> shifter_width,
			 counter_width 	=> counter_width,
			 data_width		=> data_width
			)
	port map(		
		rst			=> reset,
		clk			=> clock,
		data_in 	=> data_out,
		calc_req	=> calc_request,
		calc_ack	=> calc_acknowledge,
		calc_value	=> calc_value
	);
			
	
	STIM_u : tb_stim   
	generic map( 
			 clk_period		=> clk_period,
			 shifter_width 	=> shifter_width,
			 counter_width 	=> counter_width,
			 data_width		=> data_width
			)
	port map(		
		rst			=> reset,
		clk			=> clock,
		data_out 	=> data_out,
		calc_req	=> calc_request,
		calc_ack	=> calc_acknowledge,
		calc_value	=> calc_value
	);

end architecture;
