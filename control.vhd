library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is  
generic( 
		 shifter_width 	: integer := 8;
		 counter_width 	: integer := 8;
		 data_width	 		: integer := 8
		);
port(
		rst			: in	std_logic;
		clk			: in 	std_logic;
	-- wejscie danych z ktorego nalezy obliczyc zadane
	-- liczby sekwencji bitow
		data_in 	: in	std_logic_vector (data_width-1 downto 0);
	
	-- zadanie wyznaczenia liczby wzorcow bitowych
	-- dla danych w data_in
		calc_req	: in	std_logic;
	
	-- potwierdzenie wykonani aobliczen
	-- sygnal po wykonaniu obliczen musi zostac ustawiony
	-- na aktualna wartosc calc_req aby nastepna dana
	-- zostala podana
		calc_ack	: out	std_logic;
	
	-- wyznaczona liczba sekwencji
		calc_value	: out 	integer range 0 to data_width;
	
	-- sterowanie rejestrem przesuwajacym
		shifter_load : out std_logic;
		shifter_data : out std_logic_vector (shifter_width-1 downto 0);
		shifter_in   : in std_logic_vector (shifter_width-1 downto 0) ;
		shifter_num	 : out integer range 0 to shifter_width;
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
		bits_counter_dec  : out std_logic;
		bits_counter_inc  : out std_logic ;
		bits_counter_val  : in integer range 0 to counter_width**2;
		bits_counter_num  : out integer range 0 to counter_width**2;
		
	-- sterowanie licznikiem BITS
		lbs1_counter_load : out std_logic;
		lbs1_counter_dec  : out std_logic;
		lbs1_counter_inc  : out std_logic ;
		lbs1_counter_val  : in integer range 0 to counter_width**2;
		lbs1_counter_num  : out integer range 0 to counter_width**2;	
	
	-- sterowanie licznikiem BITS
		lbs2_counter_load : out std_logic;
		lbs2_counter_dec  : out std_logic;
		lbs2_counter_inc  : out std_logic ;
		lbs2_counter_val  : in integer range 0 to counter_width**2;
		lbs2_counter_num  : out integer range 0 to counter_width**2
);
end entity;

architecture arch_control of control is
	
	type STATE_TYPE is (s0, s1, s2, s3); --stany automatu
	signal state_reg, state_next : STATE_TYPE; --stany do synchronicznego działania
begin

proc_next_state:
process(clk, rst)
begin	
	if rst = '1' then
			state_reg <= s0; --reset asynchroniczny
	elsif rising_edge(clk) then
			state_reg <= state_next; --synchroniczna zmiana stanu
	end if;
end process proc_next_state;
--schemat: jezeli na wejsciu jest 1 to przesuwamy rejestr i przechodzimy do nastepnego stanu
--dla zera przesuwamy rejestr i wracamy do s1
--jezeli skonczy sie data_in w shifterze to wracamy do stanu s0 zeby nowe dane załadować
--przy znalezieniu sekwencji inkrementujemy licznik value i przechodzimy do s1
proc_aut:
process(state_reg, data_in)
begin
	case state_reg is
			when s0 =>
				shifter_load <= '1';
				shifter_data <= data_in; --załadowanie danych do shiftera
				
				bits_counter_load <= '1';
				bits_counter_num <= 0; --załadowanie danych do licznika bitów i ustawienie na 0
				
				value_counter_load <= '1';
				value_counter_num <= 0; --załadowanie danych do licznika wartosci i ustawienie na 0
				
				state_next <= s1;
				
			when s1 => 
				if (bits_counter_val < data_width) then
						if (shifter_in(0) = '1') then
						
								bits_counter_inc <= '1';   --inkrementacja w liczniku bitow
                        lbs1_counter_inc <= '1';
								shifter_right <= '1'; 		--przesuniecie w prawo w shifterze, analogicznie w kazdym kolejnym stanie
								
								state_next <= s2; 
								
                  elsif (shifter_in(0) = '0') then
						
								bits_counter_inc <= '1';
								
								shifter_right <= '1';
								state_next <= s1;
                  end if;
					else
						state_next <= s0;
					end if;
					
			when s2 =>
					if (bits_counter_val < data_width) then
						if (shifter_in(0) = '1') then
						
								bits_counter_inc <= '1';
								lbs1_counter_dec <= '1';
								lbs2_counter_inc <= '1';
								shifter_right <= '1';
								
								state_next <= s3;
                  elsif (shifter_in(0) = '0') then
						
								bits_counter_inc <= '1';					  
								shifter_right <= '1';
								
								state_next <= s1;							
                  end if;
					else
						state_next <= s0;
					end if;
				
			when s3 =>
					if (bits_counter_val < data_width) then
						if (shifter_in(0) = '1') then
				
								bits_counter_inc <= '1';
								shifter_right <= '1';
								
								value_counter_inc <= '1';
								state_next <= s1; 
								--znalezienie sekwencji i inkrementacja wartosci licznika znalezionych sekwencji
                  elsif (shifter_in(0) = '0') then
						
								bits_counter_inc <= '1';
								shifter_right <= '1';
								
								state_next <= s1;							
                  end if;
					else
						state_next <= s0;
					end if;
	 end case;
end process proc_aut;

--
--ONLY_FOR_SIM: process (calc_req, data_in, shifter_in, bits_counter_val, value_counter_val)
--begin
--	calc_ack <= calc_req;
--	calc_value <= 0;
--	
--	shifter_load <= '0';
--	shifter_data <= (others => '0');
--	shifter_num <= 0;
--	shifter_left <= '0';
--	shifter_right <= '0';
--	
--	value_counter_load <= '0';
--	value_counter_dec <= '0';
--	value_counter_inc <= '0';
--	value_counter_num <= 0;
--	
--	bits_counter_load <= '0';
--	bits_counter_dec <= '0';
--	bits_counter_inc <= '0';
--	bits_counter_num <= 0;
--	
--end process;

end architecture;
