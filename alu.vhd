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
    Input1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Rdst
    opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- function select
    alu_result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU Output Result
    oldZero_Flag, oldNegative_Flag, oldCarry_Flag  : in std_logic;
    Zero_Flag, Negative_Flag, Carry_Flag ,aluOP : OUT STD_LOGIC -- Z<0>:=CCR<0> ; zero flag 
    -- N<0>:=CCR<1> ; negative flag
    -- C<0>:=CCR<2> ; carry flag

  );
END ALU_VHDL;

ARCHITECTURE Behavioral OF ALU_VHDL IS
  SIGNAL result : STD_LOGIC_VECTOR(16 DOWNTO 0);
BEGIN

  WITH opcode SELECT Carry_Flag <=
    '1' WHEN "00010", --Set Carry
    oldCarry_Flag when "00011",
    result(16) WHEN OTHERS;

    WITH opcode SELECT aluOP <=
    '1' WHEN "00010", --Set Carry
    '1' WHEN "00011",
    '1' WHEN "00100",
    '0' WHEN OTHERS; -- Others
 
    Zero_Flag <= '1' when result(15 downto 0) = x"0000" else '0';
    Negative_Flag <= result(15);

  WITH opcode SELECT result <=
    '0' & NOT (Input1) WHEN "00011", -- NOT Rdst
    STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(Input1)) + 1, 17)) WHEN "00100", -- INC Rdst
    (OTHERS => '0') WHEN OTHERS; -- Others
  alu_result <= result(15 downto 0);
END Behavioral;