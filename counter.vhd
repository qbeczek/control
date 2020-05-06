library ieee ;
use ieee.std_logic_1164.all;

-- Licznik z mozliwoscia liczenia w gore i w dol
-- o okreslona wartosc na wejsciu num
-- wszystkie wejscia sterujace so synchroniczne 
-- wzgledem zbocza narastajacego zegara clk

entity counter is
generic( bits_width : integer);
port (
		-- asynchroniczny reset rejestru
		-- ustawia bity na 0 w rejestrze wewnetrznym Q
		rst 		: in 	std_logic;		
		
		-- zegar, wszystkie sygnaly reaguja na zbocza narastajace zegara
		clk 		: in  	std_logic;
		
		-- wartosc o ktora nalezy zmienic licznik
		num			: in 	integer range 0 to 2**bits_width;
		
		-- jesli 1 to traktowanie num jako warotsci poczatkowej licznika
		-- i wpisanie jej do niej
		load	 	: in	std_logic;
		
		-- jesli 1 to ziwekszenie wartosci licznika
		-- o num
		inc : in	std_logic;

		-- jesli 1 to zmniejszenie wartosci licznika
		-- o num
		dec : in	std_logic;
		
		-- aktualna wartosc licznika
		val : out	integer range 0 to 2**bits_width
);
end counter;

architecture counter_arch of counter is

signal Q : integer range 0 to 2**bits_width;	-- wewnetrzny sygnal licznika
												-- w ktorym jest przechowywana aktualna 
												-- liczba podlegajaca zwiekszaniu 
												-- lub zmniejszaniu
												
begin   

val <= Q;

counter_process : process (clk, rst)

begin
	
	if (rst = '0') then
		Q <= 0;
	elsif (rising_edge(clk)) then
		if (load = '1') then
			Q <= (num) mod 2**bits_width;
		elsif (inc = '1') then
			Q <=(Q + num) mod 2**bits_width;
		elsif (dec = '1') then
			Q <= (Q - num) mod 2**bits_width;
		end if;
	end if;

end process;


end counter_arch;
