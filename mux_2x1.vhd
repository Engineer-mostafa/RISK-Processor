
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mux_2x1 is
GENERIC ( n : integer :=1 );
Port ( 
in1 : in std_logic_vector(n-1 DOWNTO 0); -- mux input1
in2 : in std_logic_vector(n-1 DOWNTO 0); -- mux input2
sel : in std_logic; -- selection line
dataout : out std_logic_vector(n-1 DOWNTO 0)); -- output data
end mux_2x1 ;

architecture a_mux_2x1 of mux_2x1 is

begin

process (sel, in1, in2)
begin
case sel is
when '0' => dataout <= in1;
when '1' => dataout <= in2;
when others => dataout <= (OTHERS=>'Z');
end case;
end process;

end a_mux_2x1 ;