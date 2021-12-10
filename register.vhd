LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY dff IS
GENERIC ( n : integer :=32 );
	PORT(clk,rst,en : IN std_logic;
	     d : IN std_logic_vector(n - 1 DOWNTO 0);
	     q : OUT std_logic_vector(n - 1 DOWNTO 0));
	END dff;


------------------------------------------------------------

ARCHITECTURE a_Dff OF dff IS
BEGIN
	PROCESS(clk,rst,en)
	BEGIN
		IF(rst = '1') THEN
			q <= (others => '0');
		ELSIF ((rising_edge(clk)) and (en ='1')) THEN
			q <= d;

		END IF;
	END PROCESS;
END a_Dff;
