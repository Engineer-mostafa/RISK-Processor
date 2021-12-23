Library ieee;
use ieee.std_logic_1164.all;

ENTITY decoder3x8 IS
PORT(   ren: IN std_logic;			-- Or wen
	sel: IN std_logic_vector (2 DOWNTO 0);
	en: OUT std_logic_vector (7 DOWNTO 0));
END decoder3x8;

ARCHITECTURE arch1 OF decoder3x8 IS
BEGIN
	en <= "00000001" WHEN ren='1' AND sel="000"
	ELSE "00000010" WHEN ren='1' AND sel="001"
	ELSE "00000100" WHEN ren='1' AND sel="010"
	ELSE "00001000" WHEN ren='1' AND sel="011"
    ELSE "00010000" WHEN ren='1' AND sel="100"
	ELSE "00100000" WHEN ren='1' AND sel="101"
	ELSE "01000000" WHEN ren='1' AND sel="110"
	ELSE "10000000" WHEN ren='1' AND sel="111"
	ELSE "00000000";

END arch1;
