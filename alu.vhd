LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_signed.ALL;
USE IEEE.numeric_std.ALL;
-- VHDL code for ALU of the MIPS Processor

------------------------------
-- One Operand Control_Unit
------------------------------

ENTITY ALU_VHDL IS
  PORT (
    -- One Operand 
    Input1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); --  Rdst
    opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- function select
    alu_result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU Output Result
    oldZero_Flag, oldNegative_Flag, oldCarry_Flag : IN STD_LOGIC;
    Zero_Flag, Negative_Flag, Carry_Flag, aluOP : OUT STD_LOGIC; -- Z<0>:=CCR<0> ; zero flag 
                                                                -- N<0>:=CCR<1> ; negative flag
                                                                -- C<0>:=CCR<2> ; carry flag
    
    
    -- Two Operand 
    Rsrc1 , Rsrc2 , Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0) -- Rsrc1 , Rsrc 2 , Imm
    );
END ALU_VHDL;

ARCHITECTURE Behavioral OF ALU_VHDL IS
  SIGNAL result : STD_LOGIC_VECTOR(16 DOWNTO 0);
BEGIN

  WITH opcode SELECT Carry_Flag <=
    '1' WHEN "00010", --Set Carry
    oldCarry_Flag WHEN "00011",
    result(16) WHEN OTHERS;

  WITH opcode SELECT aluOP <=
    '1' WHEN "00010", -- Set Carry
    '1' WHEN "00011", -- NOT Rdst
    '1' WHEN "00100", -- INC Rdst
    '1' WHEN "01001", -- ADD Rdst,Rsrc1, Rsrc2
    '1' WHEN "01010", -- SUB Rdst,Rsrc1, Rsrc2
    '1' WHEN "01011", -- AND Rdst, Rsrc1, Rsrc2 
    '1' WHEN "10000", -- IADD Rdst, Rsrc,Imm  
    '0' WHEN OTHERS; -- Others

  Zero_Flag <= '1' WHEN result(15 DOWNTO 0) = x"0000" ELSE
    '0';
  Negative_Flag <= result(15);

  
  WITH opcode SELECT result <=
    -- One Operand 
    '0' & NOT (Input1) WHEN "00011", -- NOT Rdst
    STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(Input1)) + 1, 17)) WHEN "00100", -- INC Rdst

    -- Two Operand 
    '0' & Rsrc1  WHEN "01000", -- MOV Rsrc, Rdst
    STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(Rsrc1)) + to_integer(unsigned(Rsrc2)), 17)) WHEN "01001",  -- ADD Rdst, Rsrc1, Rsrc2
    STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(Rsrc1)) - to_integer(unsigned(Rsrc2)), 17)) WHEN "01010",  -- SUB Rdst,Rsrc1, Rsrc2
    '0' & (Rsrc1 AND Rsrc2) WHEN "01011",                                                                       -- AND Rdst, Rsrc1, Rsrc2     
    STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(Rsrc1)) + to_integer(unsigned(Imm)), 17)) WHEN "10000",    -- IADD Rdst, Rsrc,Imm    
    (OTHERS => '0') WHEN OTHERS; -- Others
  alu_result <= result(15 DOWNTO 0);
END Behavioral;