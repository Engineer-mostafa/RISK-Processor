
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mux_4x1 is
-- least n could be 1 
GENERIC ( n : integer :=1 );
Port ( 
in1 : in std_logic_vector(n-1 DOWNTO 0); -- mux input1
in2 : in std_logic_vector(n-1 DOWNTO 0); -- mux input2
in3 : in std_logic_vector(n-1 DOWNTO 0); -- mux input3
in4 : in std_logic_vector(n-1 DOWNTO 0); -- mux input4
sel : in std_logic_vector(1 downto 0); -- selection line
dataout : out std_logic_vector(n-1 DOWNTO 0)); -- output data
end mux_4x1 ;

architecture a_mux_4x1 of mux_4x1 is

begin

process (sel, in1, in2, in3, in4)
begin
case SEL is
when "00" => dataout <= in1;
when "01" => dataout <= in2;
when "10" => dataout <= in3;
when "11" => dataout <= in4;
when others => dataout <= (OTHERS=>'Z');
end case;
end process;

end a_mux_4x1 ;