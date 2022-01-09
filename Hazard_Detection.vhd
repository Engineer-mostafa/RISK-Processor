
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY hazard_detection_unit IS
GENERIC ( n : integer :=16 ); -- For register size
PORT (
    OpCodeFn: IN std_logic_vector(4 DOWNTO 0);
    Rsrc2: IN std_logic_vector(2 DOWNTO 0); -- Not sure why we chose this though
    MemRead: IN std_logic;
    
    IFIDWrite: OUT std_logic;
    IDFlushHazard: OUT std_logic;
    PCWrite: OUT std_logic
);
END hazard_detection_unit;

ARCHITECTURE arch1 OF hazard_detection_unit IS

    BEGIN

    

END arch1;