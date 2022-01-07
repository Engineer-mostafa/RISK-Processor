


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

use work.all;
ENTITY MEM_STAGE IS 
GENERIC ( n : integer :=32 );
Port( 	
	Left_OUTPUT_BUFFER 	: in std_logic_vector(n-1 downto 0);
	Right_INPUT_BUFFER 	: out std_logic_vector(n-1 downto 0);
	clk					: in std_logic
);
end MEM_STAGE;




ARCHITECTURE arch_MEM_STAGE OF MEM_STAGE IS

begin
	process(clk)
	BEGIN
	IF(rising_edge(clk)) THEN

	Right_INPUT_BUFFER <= Left_OUTPUT_BUFFER;

	end if;
  end process;

end arch_MEM_STAGE;