Library ieee;
use ieee.std_logic_1164.all;

ENTITY tristate_buffer IS
GENERIC (n : integer:= 16);
PORT(   en: IN std_logic;
	p: IN std_logic_vector (n-1 DOWNTO 0);
	q: OUT std_logic_vector (n-1 DOWNTO 0));
END tristate_buffer;

ARCHITECTURE arch1 OF tristate_buffer IS
BEGIN

	q <= p WHEN (en = '1')
	ELSE (OTHERS=>'Z');

END arch1;