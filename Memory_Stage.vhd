


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

use work.all;
ENTITY MEM_STAGE IS 
GENERIC ( n : integer :=128 );
Port( 	
	Left_INPUT_BUFFER 	: in std_logic_vector(n-1 downto 0);
	Right_OUTPUT_BUFFER 	: out std_logic_vector(n-1 downto 0)
);
end MEM_STAGE;




ARCHITECTURE arch_MEM_STAGE OF MEM_STAGE IS

begin

	Right_OUTPUT_BUFFER <= Left_INPUT_BUFFER;



end arch_MEM_STAGE;