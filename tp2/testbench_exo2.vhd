entity test is
end test;

architecture bench of test is

component compteur is -- Comme toujours, on recopie ici l'entit� du composant
port(clk, rst, E, S:bit;
	cup:out bit);
end component;

signal clk, rst, E, S, cup:bit; -- On d�finit les signaux d'entr�e/sortie

begin
	UUT:compteur port map(clk=>clk, rst=>rst, E=>E, S=>S, cup=>cup);
	-- Dans le port map on fait l'assignation par nom de tous les signaux	

	clk<=not clk after 10 ns; -- On d�crit un sc�nario permettant de 
	-- tester � peu pr�s toutes les possibilit�s du syst�me
	rst<='1', '0' after 235 ns, '1' after 245 ns;
	E<='1' after 35 ns;
	S<='1' after 155 ns;
end bench;
