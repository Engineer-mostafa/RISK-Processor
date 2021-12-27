


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

use work.all;
ENTITY EXStage IS 
  port(
         Input : in std_logic_vector(15 downto 0); 			-- Rdst
         Opcode : in std_logic_vector(4 downto 0); 			-- function select
         aluResult: out std_logic_vector(15 downto 0); 			-- ALU Output Result
	 RSTs : in std_logic;
         zero_Flag,negative_Flag,carry_Flag: out std_logic             	-- Z<0>:=CCR<0> ; zero flag 
                                           				-- N<0>:=CCR<1> ; negative flag
                                   					-- C<0>:=CCR<2> ; carry flag
         );
end EXStage;




ARCHITECTURE arch_EXStage OF EXStage IS
COMPONENT ALU_VHDL is
        port(
         Input1 : in std_logic_vector(15 downto 0); 			-- Rdst
         opcode : in std_logic_vector(4 downto 0); 			-- function select
         alu_result: out std_logic_vector(15 downto 0); 		-- ALU Output Result
	 RSTs : in std_logic;
         Zero_Flag,Negative_Flag,Carry_Flag: out std_logic             	-- Z<0>:=CCR<0> ; zero flag 
                                           				-- N<0>:=CCR<1> ; negative flag
                                         				-- C<0>:=CCR<2> ; carry flag
         );
end COMPONENT;
begin

	alu: ALU_VHDL PORT MAP(Input , Opcode , aluResult ,  RSTs , zero_Flag , negative_Flag , carry_Flag);

end arch_EXStage;