
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY mux_8x1 IS
GENERIC ( n : integer :=16 );
Port ( 
    in0 : in std_logic_vector(n-1 DOWNTO 0); -- mux input1
    in1 : in std_logic_vector(n-1 DOWNTO 0); -- mux input2
    in2 : in std_logic_vector(n-1 DOWNTO 0); -- mux input3
    in3 : in std_logic_vector(n-1 DOWNTO 0); -- mux input4
    in4 : in std_logic_vector(n-1 DOWNTO 0); -- mux input5
    in5 : in std_logic_vector(n-1 DOWNTO 0); -- mux input6
    in6 : in std_logic_vector(n-1 DOWNTO 0); -- mux input7
    in7 : in std_logic_vector(n-1 DOWNTO 0); -- mux input8
    sel : in std_logic_vector(2 downto 0); -- selection line
    dataout : out std_logic_vector(n-1 DOWNTO 0)); -- output data
END mux_8x1 ;

ARCHITECTURE a_mux_8x1 OF mux_8x1 IS

BEGIN

PROCESS (sel, in0, in1, in2, in3 ,in4, in5,in6 ,in7)
BEGIN
    CASE SEL IS
    WHEN "000" => dataout <= in0;
    WHEN "001" => dataout <= in1;
    WHEN "010" => dataout <= in2;
    WHEN "011" => dataout <= in3;
    WHEN "100" => dataout <= in4;
    WHEN "101" => dataout <= in5;
    WHEN "110" => dataout <= in6;
    WHEN "111" => dataout <= in7;
    WHEN others => dataout <= (OTHERS=>'Z');
    END CASE;
    END PROCESS;

END a_mux_8x1 ;