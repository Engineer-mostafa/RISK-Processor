library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- VHDL code for Control Unit of the MIPS Processor

------------------------------
-- One Operand Control_Unit
------------------------------


entity control_unit_VHDL is
port (
  opcode: in std_logic_vector(4 downto 0);
  reset: in std_logic;
  RegWrite,WB_To_Reg,HLT,SETC,RST,OUT_PORT_SIG,IN_PORT_SIG: out std_logic
 );
end control_unit_VHDL;


architecture Behavioral of control_unit_VHDL is

begin
process(reset,opcode)
begin
 if(reset = '1') then
   RegWrite <= '0';
   WB_To_Reg <= '0';
   HLT <= '0';
   SETC <= '0';
   OUT_PORT_SIG <= '0';
   IN_PORT_SIG <= '0';
   RST <= '1';
  
 else 
 case opcode is
  when "00001" => --HLT
   RegWrite <= '0';
   WB_To_Reg <= '0';
   HLT <= '1';
   SETC <= '0';
   OUT_PORT_SIG <= '0';
   IN_PORT_SIG <= '0';
   RST <= '0';

  when "00010" => -- SETC
   RegWrite <= '0';
   WB_To_Reg <= '0';
   HLT <= '0';
   SETC <= '1';
   OUT_PORT_SIG <= '0';
   IN_PORT_SIG <= '0';
   RST <= '0';

  when "00011" => -- NOT Rdst
   RegWrite <= '1';
   WB_To_Reg <= '0';
   HLT <= '0';
   SETC <= '0';
   OUT_PORT_SIG <= '0';
   IN_PORT_SIG <= '0';
   RST <= '0';  

  when "00100" => -- INC Rdst
   RegWrite <= '1';
   WB_To_Reg <= '0';
   HLT <= '0';
   SETC <= '0';
   OUT_PORT_SIG <= '0';
   IN_PORT_SIG <= '0';
   RST <= '0';  

  when "00101" => -- OUT Rdst
   RegWrite <= '0';
   WB_To_Reg <= '0';
   HLT <= '0';
   SETC <= '0';
   OUT_PORT_SIG <= '1';
   IN_PORT_SIG <= '0';
   RST <= '0';

  when "00110" => -- IN Rdst
   RegWrite <= '1';
   WB_To_Reg <= '1';
   HLT <= '0';
   SETC <= '0';
   OUT_PORT_SIG <= '0';
   IN_PORT_SIG <= '1';
   RST <= '0';    

  when others =>   -- Like NOP
   RegWrite <= '0';
   WB_To_Reg <= '0';
   HLT <= '0';
   SETC <= '0';
   OUT_PORT_SIG <= '0';
   IN_PORT_SIG <= '0';
   RST <= '0';    
 end case;
 end if;
end process;

end Behavioral;