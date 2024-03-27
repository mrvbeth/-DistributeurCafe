library IEEE;
use IEEE.std_logic_1164.all;

entity DistributeurCafe is
    Port ( 
        bouton_cafe_noir : in std_logic;
        bouton_cafe_lait : in std_logic;
        bouton_espresso      : in  STD_LOGIC; 
        bouton_cappuccino    : in  STD_LOGIC; 
        bouton_sucre : in std_logic_vector(1 downto 0);
        piece_1_dh : in std_logic_vector(3 downto 0); 
        piece_2_dh : in std_logic_vector(2 downto 0); 
        piece_5_dh : in std_logic_vector(1 downto 0); 
        piece_10_dh : in std_logic_vector(1 downto 0); 
        reset    : in  STD_LOGIC; 
        
        cafe_pret : out std_logic;
        monnaie_insuffisante : out std_logic;
        monnaie_exacte : out std_logic;
        monnaie_excedentaire : out std_logic;
        delivrance_cafe : out std_logic;
        reste_monnaie : out integer range 0 to 500
    );
    
    function to_integer( s : std_logic ) return natural is
    begin
        if s = '1' then
            return 1;
        else
            return 0;
        end if;
    end function;
    
	function calculate_total(
		coins : in std_logic_vector;
		dirham_multi : in integer
	) return integer is
		variable total : integer := 0;
	begin
		for i in coins'range loop
			total := total + to_integer(coins(i)) * (2**i);
		end loop;
		return total * dirham_multi;
	end function;

end DistributeurCafe;


architecture Behavioral of DistributeurCafe is
    constant prix_cafe_noir : integer := 8; -- 8dh
    constant prix_cafe_lait : integer := 10; -- 10dh
    constant prix_espresso : integer := 12; -- 12dh
    constant prix_cappuccino : integer := 14; -- 14dh
    constant prix_sucre : integer := 1; -- Prix par morceau de sucre 1dh
    
    signal total_monnaie_inseree : integer range 0 to 500; 
    signal prix_cafe_selectionne : integer := 0;
    signal prix_sucre_selectionne : integer := 0;
    signal total_prix : integer := 0; 
    signal reste_argent : integer range 0 to 500; 
    
begin
    
    process(piece_1_dh, piece_2_dh, piece_5_dh, piece_10_dh)
    begin
		total_monnaie_inseree <=
			calculate_total(piece_1_dh, 1) +
			calculate_total(piece_2_dh, 2) +
			calculate_total(piece_5_dh, 5) +
			calculate_total(piece_10_dh, 10);
    end process;
    
    process(bouton_cafe_noir, bouton_cafe_lait, bouton_espresso, bouton_cappuccino, total_monnaie_inseree)
    begin
    	if reset = '1' and total_monnaie_inseree <= 0 then
			prix_cafe_selectionne <= 0;
			prix_sucre_selectionne <= 0;
			total_prix <= 0;
			cafe_pret <= '0';
            monnaie_insuffisante <= '0';
            monnaie_exacte <= '0';
            monnaie_excedentaire <= '0';
            delivrance_cafe <= '0';
            reste_argent <= 0;
        elsif reset = '1' and total_monnaie_inseree > 0 then
			prix_cafe_selectionne <= 0;
			prix_sucre_selectionne <= 0;
			total_prix <= 0;
			cafe_pret <= '0';
            monnaie_insuffisante <= '0';
            monnaie_exacte <= '0';
            monnaie_excedentaire <= '0';
            delivrance_cafe <= '0';
			reste_argent <= total_monnaie_inseree; 
		else
			if bouton_cafe_noir = '1' then
				prix_cafe_selectionne <= prix_cafe_noir;
			elsif bouton_cafe_lait = '1' then
				prix_cafe_selectionne <= prix_cafe_lait;
			elsif bouton_espresso = '1' then
				prix_cafe_selectionne <= prix_espresso;
			elsif bouton_cappuccino = '1' then
				prix_cafe_selectionne <= prix_cappuccino;        
			end if;
			
			
			if bouton_sucre = "00" then
				prix_sucre_selectionne <= prix_sucre * 0;
			elsif bouton_sucre = "01" then
				prix_sucre_selectionne <= prix_sucre * 1;
			elsif bouton_sucre = "10" then
				prix_sucre_selectionne <= prix_sucre * 2;
			elsif bouton_sucre = "11" then
				prix_sucre_selectionne <= prix_sucre * 3;      
			end if;


			total_prix <= prix_cafe_selectionne + prix_sucre_selectionne;
				
				
			if total_monnaie_inseree < total_prix  then
				cafe_pret <= '0';
				monnaie_insuffisante <= '1';
				monnaie_exacte <= '0';
				monnaie_excedentaire <= '0';
				delivrance_cafe <= '0';
				reste_argent <= total_monnaie_inseree; 
			elsif total_monnaie_inseree = total_prix  then
				cafe_pret <= '1';
				monnaie_insuffisante <= '0';
				monnaie_exacte <= '1';
				monnaie_excedentaire <= '0';
				delivrance_cafe <= '1';
				reste_argent <= total_monnaie_inseree - total_prix ;
			else
				cafe_pret <= '1';
				monnaie_insuffisante <= '0';
				monnaie_exacte <= '0';
				monnaie_excedentaire <= '1';
				delivrance_cafe <= '1';
				reste_argent <= total_monnaie_inseree - total_prix ; 
			end if;
		end if;
		
        reste_monnaie <= reste_argent;
        
    end process;
    
end Behavioral;