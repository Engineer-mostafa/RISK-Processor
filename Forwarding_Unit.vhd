
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY forwarding_unit IS
PORT (
    Rsrc1: IN std_logic_vector(2 DOWNTO 0);
    Rsrc2: IN std_logic_vector(2 DOWNTO 0);
    Rdst:  IN std_logic_vector(2 DOWNTO 0);
    RdstExMem: IN std_logic_vector(2 DOWNTO 0);
    RdstMemWB: IN std_logic_vector(2 DOWNTO 0);
    MemtoForwarding: IN std_logic;
    WBtoForwarding: IN std_logic;
    ForwardToMux8: OUT std_logic_vector(1 DOWNTO 0);
    ForwardToMux4: OUT std_logic_vector(1 DOWNTO 0)
);
END forwarding_unit;

ARCHITECTURE arch1 OF forwarding_unit IS

    BEGIN
    PROCESS(Rsrc1, Rsrc2, RdstExMem, RdstMemWB, MemtoForwarding, WBtoForwarding, Rdst) IS
        BEGIN    
        IF(MemtoForwarding = '1' AND (RdstExMem /= "000") AND (RdstExMem = Rsrc1 XOR RdstExMem = Rdst)) THEN -- OR RdstExMem = Rdst
            ForwardToMux8 <= "10";
        ELSIF(WBtoForwarding = '1' AND (RdstMemWB /= "000") AND (RdstMemWB = Rsrc1 XOR RdstMemWB = Rdst)
            AND NOT (MemtoForwarding = '1' AND (RdstExMem /= "000") AND (RdstExMem = Rsrc1 OR RdstExMem = Rdst))) THEN -- OR RdstMemWB = Rdst
            ForwardToMux8 <= "11";
        ELSE
            ForwardToMux8 <= "00";
        END IF;

        IF(MemtoForwarding = '1'  AND (RdstExMem /= "000")  AND RdstExMem = Rsrc2) THEN
            ForwardToMux4 <= "10";
        ELSIF(WBtoForwarding = '1' AND (RdstMemWB /= "000") AND RdstMemWB = Rsrc2
        AND NOT(MemtoForwarding = '1'  AND (RdstExMem /= "000")  AND RdstExMem = Rsrc2) ) THEN
            ForwardToMux4<= "11";
        ELSE
            ForwardToMux4 <= "00";
        END IF;
    END PROCESS;
END arch1;
