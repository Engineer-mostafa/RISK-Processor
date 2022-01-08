


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

use work.all;
ENTITY EXStage IS 
  port(
         Input : in std_logic_vector(15 downto 0); 			-- Rdst
         Opcode : in std_logic_vector(4 downto 0); 			-- function select
         aluResult: out std_logic_vector(15 downto 0); 			-- ALU Output Result
         oldZero_Flag, oldNegative_Flag, oldCarry_Flag  : in std_logic;
         zero_Flag,negative_Flag,carry_Flag , aluOP: out std_logic;             	-- Z<0>:=CCR<0> ; zero flag 
                                           				-- N<0>:=CCR<1> ; negative flag
                                   					-- C<0>:=CCR<2> ; carry flag

        -- Two Operand 
        Rsrc1 , Rsrc2 , Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0) -- Rsrc1 , Rsrc 2 , Imm
         );
end EXStage;




ARCHITECTURE arch_EXStage OF EXStage IS
COMPONENT ALU_VHDL is
        port(
         Input1                                         : in std_logic_vector(15 downto 0); 			-- Rdst
         opcode                                         : in std_logic_vector(4 downto 0); 			-- function select
         alu_result                                     : out std_logic_vector(15 downto 0); 		-- ALU Output Result
         oldZero_Flag, oldNegative_Flag, oldCarry_Flag  : in std_logic;
         Zero_Flag,Negative_Flag,Carry_Flag , aluOP     : out std_logic;             	-- Z<0>:=CCR<0> ; zero flag 
                                           				-- N<0>:=CCR<1> ; negative flag
                                         				-- C<0>:=CCR<2> ; carry flag

         -- Two Operand 
         Rsrc1 , Rsrc2 , Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0) -- Rsrc1 , Rsrc 2 , Imm
         );
end COMPONENT;
begin

 
	    alu: ALU_VHDL PORT MAP(Input , Opcode , aluResult,oldZero_Flag, oldNegative_Flag, oldCarry_Flag , zero_Flag , negative_Flag , carry_Flag, aluOP ,   Rsrc1 , Rsrc2 , Imm);

  
end arch_EXStage;