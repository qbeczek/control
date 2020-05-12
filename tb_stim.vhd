library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_stim is  
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
	calc_req		: inout	std_logic;
	calc_ack		: in	std_logic;
	calc_value	: in 	integer range 0 to data_width
);
end entity;


architecture arch_tb_stim of tb_stim is

signal lclk : std_logic := '0';
signal num : integer := 0;

begin

lclk <= not lclk after (clk_period/2);
-- process generacji zegara
	clock_process: process (lclk)
	  begin
		clk <= lclk;
		num <= num+1;
	end process;

-- process konczenia symulacji
	finish_process: process 
	variable iter : integer;
	  begin
		wait until num = 2000;
		assert FALSE Report " OK: Koniec symulacji" severity FAILURE;
	--	wait
	end process;

-- glowny process pobudzen
	STIM_PROCESS : process
		
		-- procedura do oczekiwania n number cykli zegara
		procedure wait_cycles(number : in integer) is
			variable iter : integer;
		begin
			wait until clk = '1';
		end wait_cycles;

		-- procedura generacji oczekiwania na wyznaczenie
		-- liczby bitow - procedura czeka az sygnal potwierdzenia
		-- calk_ack bedzie ustawiony na te sama wartosc
		-- bitowa co sygnal calc_req
		procedure calc_request (number : in integer) is

		begin
			calc_req <= '1';
			data_out <= std_logic_vector(to_unsigned(number, data_out'length));
			
			wait until calc_ack = '1';
			calc_req <= '0';			
			wait until calc_ack = '0';
			
		end calc_request;

		variable nn : integer;

	begin
		rst <= '0';
		data_out <= (others => '0');
		calc_req <= '0';
		wait_cycles(1);
		rst <= '1';
		wait_cycles(1);
		nn := 10;
		
		loop
			nn := 12345*nn mod 21269;
			calc_request(nn);
			wait_cycles(1);
		end loop;

	end process;

end architecture;
