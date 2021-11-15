entity compteur is
port(clk, rst, E, S:bit; -- L'entit� du composant est tr�s simple
	cup:out bit);
end compteur;

architecture biprocess of compteur is

type defetat is(q0, q1, q2); -- Comme on utilise deux process, on d�finit toujours �tat et n�tat comme des signaux
signal etat,netat:defetat;

begin
	mem:process(rst, clk) -- Le process de m�morisation est toujours le meme
	begin
		if rst='0' then
			etat<=q0; -- Sur le rst on revient � l'�tat initial Q0
		elsif clk='1' and clk'event then
			etat<=netat;
		end if;
	end process;

	comb:process(etat, E, S) -- Ici en plus de l'�tat, on met les signaux d'entr�e E et S
	begin
		cup<='0'; -- On r�initialise les sorties et on met � jour le n�tat
		netat<=etat;

		case etat is -- Puis enfin on d�crit le fonctionnement de la machine avec un case
			when q0 => 
				if E='1' then 
					if S='1' then 
						netat<=q2; 
						cup<='1'; -- S'agissant d'une machine de Mealy, les sorties d�pendant de l'�tat interne
							-- et des entr�es, contrairement au controleur pr�c�dent.
						-- Dans Q0, on allume la sortie lors du d�comptage car on passe � Q2
					else 
						netat<=q1; 
					end if; 
				end if;
			when q1 => 
				if E='1' then -- A chaque fois, on teste donc en premier E, puis S car si enable est d�sactiv�,
						-- il ne faut rien faire
					if S='1' then 
						netat<=q0; 
					else 
						netat<=q2; 
					end if; 
				end if;
			when q2 => 
				if E='1' then
					if S='1' then 
						netat<=q1; 
					else 
						netat<=q0; 
						cup<='1'; -- Dans Q2, allume la sortie lors du comptage car on passe � Q0
					end if;
				end if;
		end case;
	end process;
end biprocess;
