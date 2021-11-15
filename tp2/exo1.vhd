entity controleur is
port(H, rst, ready, readwrite:bit; -- On d�finit ici tous les ports d'entr�e de type bit
	oe, we:out bit); -- Et ici tous les ports de sortie de type bit
end controleur;
--------------------------------------------------------------------------------------------------------------------
architecture monoprocess of controleur is
begin
	process(rst, H) -- S'agissant d'une machine synchrone avec reset asynchrone, la liste de sensibilit� ne prend que H et rst
	-- Avec un seul process, on peut d�clarer la variable d'�tat dans le process car elle ne sera utilis�e qu'� l'int�rieur de celui-ci
	type defetat is(idle, decision, rea, writ);
	variable etat:defetat;

	begin
		if rst='0' then -- Le reset doit etre actif � l'�tat bas
			etat:=idle; -- Lors du reset, on revient � l'�tat initial
		elsif H='1' and H'event then
			oe<='0'; -- Avant toute chose, on remet � chaque fois toutes les sorties � 0
			we<='0';

			case etat is -- Puis on fait un case sur l'�tat puis on d�crit le comportement de chacun d'entre eux
				when idle => 
					if ready='1' then 
						etat:=decision; 
					end if;
				when decision => 
					if readwrite='1' then 
						etat:=rea; 
					else 
						etat:=writ; 
					end if;
				when rea => 
					oe<='1'; -- On allume la sortie oe d�s qu'on est sur l'�tat read, c'est une machine de Moore
					if ready='1' then 
						etat:=idle; 
					end if;
				when writ => 
					we<='1'; -- Idem avec la sortie we
					if ready='1' then 
						etat:=idle; 
					end if;
			end case;
		end if;
	end process;
end monoprocess;
--------------------------------------------------------------------------------------------------------------------
architecture biprocess of controleur is

type defetat is(idle, decision, rea, writ);
signal etat,netat:defetat; -- On a maintenant besoin d'un signal n�tat qui va contenir le nouvel �tat

begin
	mem:process(rst, H) -- Dans cette version, il y a un process qui va m�moriser l'�tat et un autre qui va effectuer les op�rations combinatoires
	begin -- Dans le process de m�morisation, la liste de sensibilit� ne prend que H et rst, car les op�rations de m�morisation de l'�tat
		-- doivent etre synchrones, et le reset toujours asynchrone
		if rst='0' then
			etat<=idle;
		elsif H='1' and H'event then
			etat<=netat;
		end if;
	end process;

	comb:process(etat, ready, readwrite) -- Le process combinatoire contient quant � lui dans sa liste de sensibilit� le signal d'�tat,
						-- ainsi que les entr�es car c'est justement ces-derni�res qui doivent modifier le n�tat
	begin
		oe<='0';
		we<='0';
		netat<=etat; -- En plus de remettre les sorties � 0, il faut aussi affecter l'�tat au n�tat car sinon, le syst�me pourra
				-- avoir un comportement non coh�rent
		case etat is
			when idle => -- Le fonctionnement du case est le meme, mis � part que l'on modifie maintenant n�tat et non plus �tat 
				if ready='1' then 
					netat<=decision; 
					end if;
			when decision => 
				if readwrite='1' then 
					netat<=rea; 
				else 
					netat<=writ; 
				end if;
			when rea => 
				oe<='1'; 
				if ready='1' then 
					netat<=idle; 
				end if;
			when writ => 
				we<='1'; 
				if ready='1' then 
					netat<=idle; 
				end if;
		end case;
	end process;
end biprocess;
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
entity controleurburst is
port(H, rst, ready, readwrite, burst:bit; -- Dans l'entit� de la version burst, il faut rajouter l'entr�e burst
	oe, we:out bit;
	adr:out bit_vector(1 downto 0)); -- Ainsi que la sortie adr
end controleurburst;
--------------------------------------------------------------------------------------------------------------------
architecture burst of controleurburst is

type defetat is(idle, decision, writ, read0, read1, read2, read3); -- Il faut ajouter les 3 �tats de lecture constituant le mode burst
signal etat,netat:defetat;

begin
	mem:process(rst, H) -- Le process de m�morisation reste identique
	begin
		if rst='0' then
			etat<=idle;
		elsif H='1' and H'event then
			etat<=netat;
		end if;
	end process;

	comb:process(etat, ready, readwrite, burst) -- Dans la liste de sensibilit� du process combinatoire, il faut ajouter l'entr�e burst
	begin
		oe<='0';
		we<='0';
		adr<="00"; -- Il est aussi n�cessaire de remettre la sortie adr � 00
		netat<=etat;

		case etat is
			when idle => -- Les �tats idle, decision et write sont identiques
				if ready='1' then 
					netat<=decision; 
				end if;
			when decision => 
				if readwrite='1' then 
					netat<=read0; 
				else 
					netat<=writ; 
				end if;
			when writ => 
				we<='1'; 
				if ready='1' then 
					netat<=idle; 
				end if;
			when read0 => 
				oe<='1'; 
				if ready='1' then 
					if burst='1' then -- En revanche il faut ajouter un test sur l'�tat read0 afin de
							-- prendre en compte le mode burst
						netat<=read1; 
					else 
						netat<=idle; 
					end if; 
				end if;
			when read1 => -- Et enfin les 3 autres �tats du mode burst sont assez simples
				oe<='1'; 
				adr<="01"; -- Il faut bien penser � incr�menter la valeur de l'adr � chaque fois
				if ready='1' then 
					netat<=read2; 
				end if;
			when read2 => 
				oe<='1'; 
				adr<="10"; 
				if ready='1' then 
					netat<=read3; 
				end if;
			when read3 => 
				oe<='1'; 
				adr<="11"; 
				if ready='1' then 
					netat<=idle; 
				end if;
		end case;
	end process;
end burst;
