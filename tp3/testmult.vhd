--Ajout des librairies pour les std-logic  
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test is
end test;

architecture bench of test is
component mult is
port(multiplieur,multiplicande:std_logic_vector(7 downto 0);
	go,clk,rst:std_logic;
	S:out std_logic_vector(15 downto 0);
	fin:out std_logic);
end component;

-- Initialisation des signaux à 0 en binaire
signal multiplieur,multiplicande:std_logic_vector(7 downto 0):="00000000";
signal S:std_logic_vector(15 downto 0):="0000000000000000";
signal go,rst,fin,clk:std_logic:='0';

begin
	UUT:mult port map(multiplieur=>multiplieur,multiplicande=>multiplicande,go=>go,clk=>clk,rst=>rst,S=>S,fin=>fin);
	clk<=not clk after 5 ns;
	rst<='1' after 2 ns;
	go<='1' after 2 ns, '0' after 12 ns;
-- Voici les deux valeurs à multiplier entre elle, via notre algorithme.
	multiplieur<="00010111";	-- Valeur de 23 en décimale
	multiplicande<="00010011";	-- Valeur de 19 en décimale

end bench;
