library ieee ;
use ieee.std_logic_1164.all;

-- Rejestr przesuwajacy w lewo i w prawo
-- opis sygnalow w komentarzach ponizej
-- W wyniku przesuniecia o num bitow w lewo lub w prawo
-- bity w rejestrze wewnetrznym Q sa ustawiane na '0'

entity shifter is
generic( width : integer);
port (
		-- asynchroniczny reset rejestru
		-- ustawia bity na 0 w rejestrze wewnetrznym Q
		rst 		: in 	std_logic;		
		
		-- zegar, wszystkie sygnaly reaguja na zbocza narastajace zegara
		clk 		: in  	std_logic;
		
		-- synchroniczny wpis do rejestru przy wrtosci sygnalu = '1'
		load		: in	std_logic;
		
		-- liczba okreslajaca o ile bitow ma nastapic przesuniecie 
		-- wartosci wewnetrzneo rejestru Q
		num			: in	integer range 0 to width;
		
		-- gdy sygnal ma wartosc '1' to przesuwana jest 
		-- zawartosc rejestru wewnetrznego Q o num bitow w lewo 
		-- czyli w strone bitow bardziej znaczacych
		shift_left	: in	std_logic;

		-- gdy sygnal ma wartosc '1' to przesuwana jest 
		-- zawartosc rejestru wewnetrznego Q o num bitow w prawo 
		-- czyli w strone bitow mniej znaczacych
		shift_right : in	std_logic;
		
		-- dane do zapisania w rejestrze wewnetrznym Q gdy 
		-- sygnal load='1'
		data_in		: in 	std_logic_vector (width-1 downto 0);
		
		-- wyprowadzenie aktualnej wartosci rejestru Q na zewnatrz
		data_out	: out	std_logic_vector (width-1 downto 0)
		); 
end shifter;

architecture shifter_arch of shifter is

signal Q : std_logic_vector (width-1 downto 0);	-- wewnetrzny sygnal rejestru
												-- w ktorym jest przechowywana aktualna 
												-- dana podlegajaca przesuwaniu
												
begin   

data_out <= Q;

shifter_process: process (clk, rst)
  begin
		if (rst = '0') then
			Q <= (others => '0');
		elsif (rising_edge(clk)) then
			if (load = '1') then
				Q <= data_in;
			elsif (shift_left = '1') then
					Q <=  Q(width-2 downto 0) & '0';
			elsif (shift_right = '1') then
					Q <= '0' & Q(width-1 downto 1);
			end if;
		end if;

  end process;
end shifter_arch;
