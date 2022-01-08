library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  
use work.all;
ENTITY WriteBackStage IS 
GENERIC ( n : integer :=16 );
Port( 	
	ALUresult 			: in std_logic_vector(15 downto 0);
	In_Data	  			: in std_logic_vector(15 downto 0);
	RdstData	  		: in std_logic_vector(15 downto 0);
	WBtoReg 			: in std_logic;
	out_signal			: in std_logic;
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

COMPONENT mux_4x1 is
	-- least n could be 2 
	GENERIC ( m : integer :=2 );
	Port ( 
	in1 : in std_logic_vector(m-1 DOWNTO 0); -- mux input1
	in2 : in std_logic_vector(m-1 DOWNTO 0); -- mux input2
	in3 : in std_logic_vector(m-1 DOWNTO 0); -- mux input3
	in4 : in std_logic_vector(m-1 DOWNTO 0); -- mux input4
	sel : in std_logic_vector(1 downto 0); -- selection line
	dataout : out std_logic_vector(m-1 DOWNTO 0)); -- output data
end COMPONENT ;

SIGNAL Empty: std_logic_vector(15 downto 0);
SIGNAL MuxSelect: std_logic_vector(1 DOWNTO 0);

begin

	Empty <= (OTHERS => '0');
	MuxSelect <= out_signal & WBtoReg;

 	mux : mux_4x1 GENERIC MAP(m => 16) PORT MAP(ALUresult, In_Data, RdstData, Empty, MuxSelect, result_WritingOutput); 



end arch_WriteBackStage;