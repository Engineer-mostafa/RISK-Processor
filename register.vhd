LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY dff IS
GENERIC ( n : integer :=32 );
	PORT(clk,rst,en : IN std_logic;
	     --reset_value: IN std_logic_vector(n - 1 DOWNTO 0); --reem
	     --edge_signal: IN std_logic; --0:rise, 1:fall --reem
	     d : IN std_logic_vector(n - 1 DOWNTO 0);
	     q : OUT std_logic_vector(n - 1 DOWNTO 0));
	END dff;


------------------------------------------------------------

ARCHITECTURE a_Dff OF dff IS
BEGIN
	PROCESS(clk,rst,en)
	BEGIN
		IF(rst = '1') THEN
			q <= (others => '0'); --q <= reset_value; 
			--reset_value could be 0 for nomral registers 
			--or default value for pc
		--ELSIF ((rising_edge(clk)) and (en ='1') and (edge_signal='0')) THEN
		ELSIF ((rising_edge(clk)) and (en ='1')) THEN
			q <= d;
		--ELSEIF ((en ='1') and and (edge_signal='1')) --reem
			--q <= d;

		END IF;
	END PROCESS;
END a_Dff;
