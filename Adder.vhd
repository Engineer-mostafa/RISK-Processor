
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY adder IS
GENERIC ( n : integer :=32 );
	PORT(
	      input1 : IN std_logic_vector(n - 1 DOWNTO 0);
	      input2 : IN std_logic_vector(n - 1 DOWNTO 0);
	      output : OUT std_logic_vector(n - 1 DOWNTO 0));
	END adder;

------------------------------------------------------------------

ARCHITECTURE a_Adder OF adder IS
BEGIN

	
	output <= std_logic_vector(unsigned(input1) + unsigned(input2));
		
	
END a_Adder;