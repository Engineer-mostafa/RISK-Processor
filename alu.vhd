library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_signed.all;
use IEEE.numeric_std.all;
-- VHDL code for ALU of the MIPS Processor

------------------------------
-- One Operand Control_Unit
------------------------------

entity ALU_VHDL is
port(
 Input1 : in std_logic_vector(15 downto 0); -- Rdst
 opcode : in std_logic_vector(4 downto 0); -- function select
 alu_result: out std_logic_vector(15 downto 0); -- ALU Output Result
 RSTs : in std_logic;
 Zero_Flag,Negative_Flag,Carry_Flag : out std_logic             -- Z<0>:=CCR<0> ; zero flag 
							       -- N<0>:=CCR<1> ; negative flag
							       -- C<0>:=CCR<2> ; carry flag

 );
end ALU_VHDL;



architecture Behavioral of ALU_VHDL is
signal result: std_logic_vector(15 downto 0);
begin
process(opcode,Input1)
begin
 case opcode is
 when "00010" => --Set Carry
  Carry_Flag <= '1';
 when "00011" =>
  result <= not (Input1); -- NOT Rdst
 when "00100" => 
  result <= std_logic_vector(to_unsigned(to_integer(unsigned( Input1 )) + 1, 16));  -- INC Rdst
 when others => 
	result <= x"0000"; -- Others
 end case;

if RSTs = '1' then
		Carry_Flag <= '0'; 
end if;
end process;
  Zero_Flag <= '1' when result=x"0000" else '0';
  Negative_Flag <= '1' when signed(result) < 0 else '0';
  alu_result <= result;
end Behavioral;