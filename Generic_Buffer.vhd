library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_buffer is
Generic( n :  Integer := 128);
port (
  LeftInput : in std_logic_vector(n-1 downto 0);
  RightOutput : out std_logic_vector (n-1 downto 0);
  clk,rst: in std_logic
 );
end generic_buffer;


architecture BehavioralGeneric_buffer of generic_buffer is
begin
process(clk,rst)
begin
 if(rst = '1') then
   RightOutput<= (others=>'0');
 elsif(rising_edge(clk)) then
	RightOutput<= LeftInput; 
 end if;
end process;
end BehavioralGeneric_buffer;
