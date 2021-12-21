
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

use work.all;
ENTITY WriteBackStage IS 
GENERIC ( n : integer :=16 );
Port( 	
	ALUresult 			: in std_logic_vector(15 downto 0);
	In_Data	  			: in std_logic_vector(15 downto 0);
	WBtoReg 			: in std_logic;
	result_WritingOutput		: out std_logic_vector(15 downto 0)
);
end WriteBackStage;




ARCHITECTURE arch_WriteBackStage OF WriteBackStage IS
COMPONENT mux_2x1 IS
GENERIC ( n : integer :=16 );
Port ( 
in1 : in std_logic_vector(n-1 DOWNTO 0); -- mux input1
in2 : in std_logic_vector(n-1 DOWNTO 0); -- mux input2
sel : in std_logic; -- selection line
dataout : out std_logic_vector(n-1 DOWNTO 0)); -- output data
end COMPONENT ;

begin

 mux : mux_2x1 GENERIC MAP(n => 16) PORT MAP(ALUresult, In_Data, WBtoReg, result_WritingOutput); 
	


end arch_WriteBackStage;