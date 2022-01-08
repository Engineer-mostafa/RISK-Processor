


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

use work.all;
ENTITY MEM_STAGE IS 
GENERIC ( n : integer :=128 );
Port( 	
	Left_OUTPUT_BUFFER 	: in std_logic_vector(n-1 downto 0);
	Right_INPUT_BUFFER 	: out std_logic_vector(n-1 downto 0);
	Clk,Rst,enable		: in std_logic;
	PCsrc				: out std_logic_vector(31 downto 0); --branch
	empty_stack			: out std_logic; --in integration call EPC to go to  M[2] and M[3]
	invalid_add			: out std_logic --in integration call EPC to go to  M[4] and M[5]
);
end MEM_STAGE;

-- Left_OUTPUT_BUFFER: 128b
-- Address(20-5) CCR(4-2) MemRead(1) MemWrite(0) 
-- Rdst_numb(55-53) Rdst(52-37) Write_data(36-21)
-- PCsrc(110-78) OP(77-73) WBranch(72) in_data(71-56)

-- Right_INPUT_BUFFER: 128b
-- Address(63-48) Read_data(47-32) in_data(31-16) Rdst(15-0)
-- Rdst_numb(66-64)

ARCHITECTURE arch_MEM_STAGE OF MEM_STAGE IS

component Dmemory IS
	PORT(
        -- MemRead, MemWrite,
        Clk,Rst,enable : IN std_logic;
        OP : IN std_logic_vector(4 DOWNTO 0);
		-- Address : IN  std_logic_vector(19 DOWNTO 0);
		Write_data : IN std_logic_vector(15 DOWNTO 0);
		Read_data : OUT  std_logic_vector(15 DOWNTO 0);
        empty_stack	: OUT std_logic
        );
END component;

begin

	-- invalid address, throw exception
	-- address comes in LDD and STD
	invalid_add <= '1' 
	when Left_OUTPUT_BUFFER(20 downto 5) >= "1111111100000000" -- FF00
	else '0';

	data_memory: Dmemory port map(Clk,Rst,enable,
	Left_OUTPUT_BUFFER(93 downto 89),
	Left_OUTPUT_BUFFER(36 downto 21),
	Right_INPUT_BUFFER(47 downto 32),
	empty_stack
	);

end arch_MEM_STAGE;