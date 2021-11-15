entity test is
end test;

architecture bench of test is

component controleur is -- Ici on red�clare l'entit� du controleur
port(H, rst, ready, readwrite:bit;
	oe, we:out bit);
end component;

signal H, rst, ready, readwrite, oe, we:bit; -- Puis on cr�e tous les signaux d'entr�e/sortie

for UUT:controleur use entity work.controleur(monoprocess); -- On choisit l'architecture � utiliser

begin
	UUT:controleur port map(H=>H, rst=>rst, ready=>ready, readwrite=>readwrite, oe=>oe, we=>we);
	-- On fait le port map avec une assignation par nom
	H<=not H after 10 ns;
	rst<='1', '0' after 255 ns, '1' after 265 ns; -- Et enfin on d�crit un sc�nario dans
	-- lequel on essaye de tester un peu tous les cas de fonctionnement du syst�me
	ready<='1' after 25 ns, '0' after 115 ns, '1' after 165 ns, '0' after 215 ns, '1' after 275 ns;
	readwrite<='1' after 175 ns;
end bench;
