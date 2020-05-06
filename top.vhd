library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is  
generic( 
		 shifter_width 	: integer := 8;
		 counter_width 	: integer := 8;
		 data_width	 	: integer := 8
		);
port(
		rst			: in	std_logic;
		clk			: in 	std_logic;
		data_in 		: in	std_logic_vector (data_width-1 downto 0);
		calc_req		: in	std_logic;
		calc_ack		: out	std_logic;
		calc_value	: out 	integer range 0 to data_width
			
);
end entity;

architecture arch_top of top is

component shifter is
generic( width : integer);
port (
		rst 		: in 	std_logic;		
		clk 		: in  	std_logic;
		load		: in	std_logic;
		num			: in	integer range 0 to width;
		shift_left	: in	std_logic;
		shift_right : in	std_logic;
		data_in		: in 	std_logic_vector (width-1 downto 0);
		data_out	: out	std_logic_vector (width-1 downto 0)
		); 
end component;

component counter is
generic( bits_width : integer);
port (
		rst 		: in 	std_logic;		
		clk 		: in  	std_logic;
		num			: in 	integer range 0 to 2**bits_width;
		load	 	: in	std_logic;
		inc : in	std_logic;
		dec : in	std_logic;
		
		val : out	integer range 0 to 2**bits_width
);
end component;

component control is  
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
		calc_value	: out 	integer range 0 to data_width;
	
	-- sterowanie rejestrem przesuwajacym
		shifter_load : out std_logic;
		shifter_data : out std_logic_vector (shifter_width-1 downto 0);
		shifter_in  : in std_logic_vector (shifter_width-1 downto 0) ;
		shifter_num	: out integer range 0 to shifter_width;
		shifter_left : out std_logic;
		shifter_right: out std_logic;

	-- sterowanie licznikiem VALUE
		value_counter_load : out std_logic;
		value_counter_dec : out std_logic;
		value_counter_inc : out std_logic;
		value_counter_val : in integer range 0 to counter_width**2;
		value_counter_num : out integer range 0 to counter_width**2;

	-- sterowanie licznikiem BITS
		bits_counter_load : out std_logic;
		bits_counter_dec : out std_logic;
		bits_counter_inc : out std_logic ;
		bits_counter_val : in integer range 0 to counter_width**2;
		bits_counter_num : out integer range 0 to counter_width**2;
	
	-- sterowanie licznikiem LBS1
		lbs1_counter_load : out std_logic;
		lbs1_counter_dec : out std_logic;
		lbs1_counter_inc : out std_logic ;
		lbs1_counter_val : in integer range 0 to counter_width**2;
		lbs1_counter_num : out integer range 0 to counter_width**2;
			
	-- sterowanie licznikiem LBS2
		lbs2_counter_load : out std_logic;
		lbs2_counter_dec : out std_logic;
		lbs2_counter_inc : out std_logic ;
		lbs2_counter_val : in integer range 0 to counter_width**2;
		lbs2_counter_num : out integer range 0 to counter_width**2	
);
end component;

signal shifter_load 	: std_logic;
signal shifter_data 	: std_logic_vector (shifter_width-1 downto 0);
signal shifter_out 	: std_logic_vector (shifter_width-1 downto 0) ;
signal shifter_num	: integer range 0 to shifter_width;
signal shifter_left 	: std_logic;
signal shifter_right	: std_logic;

signal value_counter_load 	: std_logic;
signal value_counter_dec 	: std_logic;
signal value_counter_inc 	: std_logic;
signal value_counter_val 	: integer range 0 to counter_width**2;
signal value_counter_num 	: integer range 0 to counter_width**2;

signal bits_counter_load 	: std_logic;
signal bits_counter_dec 	: std_logic;
signal bits_counter_inc 	: std_logic ;
signal bits_counter_val 	: integer range 0 to counter_width**2;
signal bits_counter_num 	: integer range 0 to counter_width**2;

signal lbs1_counter_load 	: std_logic;
signal lbs1_counter_dec 	: std_logic;
signal lbs1_counter_inc 	: std_logic ;
signal lbs1_counter_val 	: integer range 0 to counter_width**2;
signal lbs1_counter_num 	: integer range 0 to counter_width**2;

signal lbs2_counter_load 	: std_logic;
signal lbs2_counter_dec 	: std_logic;
signal lbs2_counter_inc 	: std_logic ;
signal lbs2_counter_val 	: integer range 0 to counter_width**2;
signal lbs2_counter_num 	: integer range 0 to counter_width**2;

begin

SHIFT_uk: shifter
	generic map 
		(width => shifter_width)
	port map
		(rst => rst,
		 clk => clk,
		 load => 		shifter_load,
		 num => 		shifter_num,
		 shift_left =>  shifter_left,
		 shift_right => shifter_right,
		 data_in => 	shifter_data,
		 data_out => 	shifter_out
		);


VALUE_COUNTER_uk : counter
	generic map
		(bits_width => counter_width)
	port map
		(rst => rst,
		 clk => clk,
		 load => value_counter_load,
		 num => value_counter_num,		 
		 inc => value_counter_inc,
		 dec => value_counter_dec,
		 val => value_counter_val
		);


BITS_COUNTER_uk : counter
	generic map
		(bits_width => counter_width)
	port map
		(rst => rst,
		 clk => clk,
		 load => bits_counter_load,
		 num => bits_counter_num,		 
		 inc => bits_counter_inc,
		 dec => bits_counter_dec,
		 val => bits_counter_val
		);
		
LBS1_COUNTER_uk	:	counter
	generic map
		(bits_width => counter_width)
	port map(
		rst => rst,
		clk => clk,
		load => lbs1_counter_load,
		num => lbs1_counter_num,		 
		inc => lbs1_counter_inc,
		dec => lbs1_counter_dec,
		val => lbs1_counter_val
		);

LBS2_COUNTER_uk	:	counter
	generic map
		(bits_width => counter_width)
	port map(
		rst => rst,
		clk => clk,
		load => lbs2_counter_load,
		num => lbs2_counter_num,		 
		inc => lbs2_counter_inc,
		dec => lbs2_counter_dec,
		val => lbs2_counter_val
		);


CONTROL_uk : control
	generic map ( 
		 shifter_width 	=> shifter_width,
		 counter_width 	=> counter_width,
		 data_width	 	=> data_width
		)
	port map(
		rst			=> rst,
		clk			=> clk, 
		data_in 	=> data_in,
		calc_req	=> calc_req,
		calc_ack	=> calc_ack,
		calc_value	=> calc_value,
	
	-- sterowanie rejestrem przesuwajacym
		shifter_load 	=> shifter_load,
		shifter_data 	=> shifter_data,
		shifter_in  	=> shifter_out,
		shifter_num		=> shifter_num,
		shifter_left 	=> shifter_left,
		shifter_right	=> shifter_right,

	-- sterowanie licznikiem VALUE
		value_counter_load => value_counter_load,
		value_counter_dec => value_counter_dec,
		value_counter_inc => value_counter_inc,
		value_counter_val => value_counter_val,
		value_counter_num => value_counter_num,

	-- sterowanie licznikiem BITS
		bits_counter_load => bits_counter_load,
		bits_counter_dec => bits_counter_dec,
		bits_counter_inc => bits_counter_inc,
		bits_counter_val => bits_counter_val,
		bits_counter_num => bits_counter_num,
	
	-- sterowanie licznikiem LBS1
		lbs1_counter_load => lbs1_counter_load,
		lbs1_counter_dec => lbs1_counter_dec,
		lbs1_counter_inc => lbs1_counter_inc,
		lbs1_counter_val => lbs1_counter_val,
		lbs1_counter_num => lbs1_counter_num,
		
	-- sterowanie licznikiem LBS2
		lbs2_counter_load => lbs2_counter_load,
		lbs2_counter_dec => lbs2_counter_dec,
		lbs2_counter_inc => lbs2_counter_inc,
		lbs2_counter_val => lbs2_counter_val,
		lbs2_counter_num => lbs2_counter_num
	);



end architecture;
