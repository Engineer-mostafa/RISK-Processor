
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY decode_stage IS
GENERIC ( n : integer :=16 ); -- For register size
PORT (
    instruction: IN std_logic_vector(31 DOWNTO 0);
    pc_in: IN std_logic_vector(31 DOWNTO 0);
    pc_out: OUT std_logic_vector(31 DOWNTO 0);
    opfncode: OUT std_logic_vector(4 DOWNTO 0);
    rsrc1addr: OUT std_logic_vector(2 DOWNTO 0);
    rsrc2addr: OUT std_logic_vector(2 DOWNTO 0);
    rdstaddr: OUT std_logic_vector(2 DOWNTO 0);
    extrabits: OUT std_logic_vector(1 DOWNTO 0);
    immmediate_offset: OUT std_logic_vector(15 DOWNTO 0);
    clk,rst: IN std_logic;
    RegWrite: IN std_logic;
    in_signal: IN std_logic;
    out_signal: IN std_logic;
    in_port: IN std_logic_vector(n-1 DOWNTO 0);
    in_data: OUT std_logic_vector(n-1 DOWNTO 0);
    out_port: OUT std_logic_vector(n-1 DOWNTO 0);
    -- read_reg1: IN std_logic_vector(2 DOWNTO 0);
    -- read_reg2: IN std_logic_vector(2 DOWNTO 0);
    -- read_reg3: IN std_logic_vector(2 DOWNTO 0); -- For the Rdst read
    write_reg: IN std_logic_vector(2 DOWNTO 0);
    write_data: IN std_logic_vector(n-1 DOWNTO 0);
    read_data_1: OUT std_logic_vector(n-1 DOWNTO 0);
    read_data_2: OUT std_logic_vector(n-1 DOWNTO 0);
    read_data_3: OUT std_logic_vector(n-1 DOWNTO 0);
    ccr_in: IN std_logic_vector(3 DOWNTO 0);
    ccr_out: OUT std_logic_vector(3 DOWNTO 0);
    sp_in: IN std_logic_vector(31 DOWNTO 0);
    sp_out: OUT std_logic_vector(31 DOWNTO 0);
    int_signal: IN std_logic; -- Used to store the Flags in a special register in case of INT instruction
    rti_signal: IN std_logic -- Used to restore Flags from the special register in case of RTI instruction
);
END decode_stage;

ARCHITECTURE arch1 OF decode_stage IS

    COMPONENT  register_file  IS
    GENERIC ( n : integer :=16 ); -- For register size
    PORT (
        clk,rst: IN std_logic;
        RegWrite: IN std_logic;
        in_signal: IN std_logic;
        out_signal: IN std_logic;
        in_port: IN std_logic_vector(n-1 DOWNTO 0);
        in_data: OUT std_logic_vector(n-1 DOWNTO 0);
        out_port: OUT std_logic_vector(n-1 DOWNTO 0);
        read_reg1: IN std_logic_vector(2 DOWNTO 0);
        read_reg2: IN std_logic_vector(2 DOWNTO 0);
        read_reg3: IN std_logic_vector(2 DOWNTO 0); -- For the Rdst read
        write_reg: IN std_logic_vector(2 DOWNTO 0);
        write_data: IN std_logic_vector(n-1 DOWNTO 0);
        read_data_1: OUT std_logic_vector(n-1 DOWNTO 0);
        read_data_2: OUT std_logic_vector(n-1 DOWNTO 0);
        read_data_3: OUT std_logic_vector(n-1 DOWNTO 0);
        ccr_in: IN std_logic_vector(3 DOWNTO 0);
        ccr_out: OUT std_logic_vector(3 DOWNTO 0);
        sp_in: IN std_logic_vector(31 DOWNTO 0);
        sp_out: OUT std_logic_vector(31 DOWNTO 0);
        int_signal: IN std_logic; -- Used to store the Flags in a special register in case of INT instruction
        rti_signal: IN std_logic -- Used to restore Flags from the special register in case of RTI instruction
    );
    END COMPONENT;

    BEGIN

    regfile: register_file GENERIC MAP(n) PORT MAP(clk,rst,RegWrite,in_signal,out_signal,in_port,in_data,out_port,instruction(26 DOWNTO 24),instruction(23 DOWNTO 21),instruction(20 DOWNTO 18),write_reg,write_data,read_data_1,read_data_2,read_data_3,ccr_in,ccr_out,sp_in,sp_out,int_signal,rti_signal);
    pc_out <= pc_in;
    opfncode <= instruction(31 DOWNTO 27);
    rsrc1addr <= instruction(26 DOWNTO 24);
    rsrc2addr <= instruction(23 DOWNTO 21);
    rdstaddr <= instruction(20 DOWNTO 18);
    extrabits <= instruction(17 DOWNTO 16);
    immmediate_offset <= instruction(15 DOWNTO 0);

END arch1;