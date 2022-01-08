


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

use work.all;
ENTITY MEM_STAGE IS 
GENERIC ( n : integer :=128 );
Port( 	
	Left_OUTPUT_BUFFER 	: in std_logic_vector(n-1 downto 0);
	Right_INPUT_BUFFER 	: out std_logic_vector(n-1 downto 0);
	-- WBranch,
	Clk,Rst,enable: in std_logic;
	Write_data,Address,Rdst,Rscr2: in std_logic_vector(15 downto 0);
	CCR,Rdst_numb		: in std_logic_vector(2 downto 0);
	pc_in				: in std_logic_vector(31 downto 0);
	OP					: in std_logic_vector(4 downto 0);
	PCsrc				: out std_logic_vector(31 downto 0); --branch
	empty_stack			: out std_logic; --in integration call EPC to go to  M[2] and M[3]
	invalid_add			: out std_logic --in integration call EPC to go to  M[4] and M[5]
);
end MEM_STAGE;

-- Left_OUTPUT_BUFFER: 128b
-- Address CCR 
-- Rdst_numb(55-53) Rdst(52-37) Write_data//not done
-- pc_in(110-78) OP(77-73) WBranch(72)//not done 

-- Right_INPUT_BUFFER: 128b 
-- Address Read_data(47-32)  Rdst
-- Rdst_numb

ARCHITECTURE arch_MEM_STAGE OF MEM_STAGE IS

component Dmemory IS
GENERIC ( 
	n : integer :=2
	); 
	PORT(
        -- MemRead, MemWrite,
        Clk,Rst,enable : IN std_logic;
        OP : IN std_logic_vector(4 DOWNTO 0);
		Write_data,Address,Rscr2 : IN std_logic_vector(15 DOWNTO 0);
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

	data_memory: Dmemory port map(Clk,Rst,enable,OP,
	Write_data,Address, Rscr2,Right_INPUT_BUFFER(127 downto 112), empty_stack
	);


end arch_MEM_STAGE;