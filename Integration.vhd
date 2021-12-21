
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY integration IS
GENERIC ( n : integer :=16 ); -- For register size
PORT (
    clk,rst: IN std_logic;
    in_port: IN std_logic_vector(n-1 DOWNTO 0);
    out_port: OUT std_logic_vector(n-1 DOWNTO 0)
);
END integration;

ARCHITECTURE arch1 OF integration IS

    COMPONENT control_unit_VHDL is
        port (
        opcode: in std_logic_vector(4 downto 0);
        reset: in std_logic;
        RegWrite,WB_To_Reg,HLT,SETC,RST,OUT_PORT_SIG,IN_PORT_SIG: out std_logic
        );
    end COMPONENT;

    COMPONENT fetch IS
    GENERIC ( 
        n : integer :=2; --used in mux_4x1 / mux_2x1 
        m : integer :=2 --used in mux_4x1 (OP)
        ); 
        PORT(
            HLT_Signal,Clk,Rst,enable : IN std_logic;
            PCSrc : IN std_logic_vector(1 DOWNTO 0);
            pc_01, pc_10 : IN std_logic_vector(31 DOWNTO 0);
            NewPc : OUT std_logic_vector(31 DOWNTO 0);
            Instruction : OUT std_logic_vector(31 DOWNTO 0));
    END COMPONENT;

    COMPONENT decode_stage IS
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
    END COMPONENT;

    COMPONENT ALU_VHDL is
        port(
         Input1 : in std_logic_vector(15 downto 0); -- Rdst
         opcode : in std_logic_vector(4 downto 0); -- function select
         alu_result: out std_logic_vector(15 downto 0); -- ALU Output Result
         Zero_Flag,Negative_Flag,Carry_Flag: out std_logic             -- Z<0>:=CCR<0> ; zero flag 
                                           -- N<0>:=CCR<1> ; negative flag
                                           -- C<0>:=CCR<2> ; carry flag
        
         );
    end COMPONENT;

    COMPONENT generic_buffer is
        Generic( n :  Integer := 128);
        port (
          LeftInput : in std_logic_vector(n-1 downto 0);
          RightOutput : out std_logic_vector (n-1 downto 0);
          clk,rst: in std_logic
         );
    end COMPONENT;
        
    SIGNAL Instruction,NewPc:  std_logic_vector(31 DOWNTO 0);
    -- SIGNAL InstructionOut,NewPcOut:  std_logic_vector(31 DOWNTO 0);
    SIGNAL RegWrite,WB_To_Reg,HLT,SETC,RST,OUT_PORT_SIG,IN_PORT_SIG: std_logic;
    SIGNAL alwayson: std_logic := '1';
    SIGNAL PCSrc: std_logic_vector(1 DOWNTO 0);
    SIGNAL pc_01, pc_10: std_logic_vector(31 DOWNTO 0);  --> Need to connect this
    SIGNAL ifidin,ifidout: std_logic_vector(127 DOWNTO 0);
    SIGNAL opcode: std_logic_vector(4 downto 0);
    SIGNAL pc_outD: std_logic_vector(31 DOWNTO 0); --> Need to connect this
    SIGNAL rsrc1addrD, rsrc2addrD,rdstaddrD: std_logic_vector(2 DOWNTO 0); --> Need to connect this
    SIGNAL extrabits: std_logic_vector(1 DOWNTO 0); --> Need to connect this
    SIGNAL immmediate_offsetD: std_logic_vector(15 DOWNTO 0); --> Need to connect this
    SIGNAL in_dataD: std_logic_vector(n-1 DOWNTO 0); --> Need to connect this to id/ex buffer as IN
    SIGNAL write_reg: std_logic_vector(2 DOWNTO 0); --> Need to connect this
    SIGNAL write_data: std_logic_vector(n-1 DOWNTO 0); --> Need to connect this
    SIGNAL read_data_1D, read_data_2D, read_data_3D: std_logic_vector(n-1 DOWNTO 0); --> Need to connect this to id/ex buffer as IN
    SIGNAL ccr_inD, ccr_outD: std_logic_vector(3 DOWNTO 0); --> Need to connect this
    SIGNAL sp_inD, sp_outD: std_logic_vector(31 DOWNTO 0);--> Need to connect this
    SIGNAL int_signal, rti_signal: std_logic; --> Need to connect this

    BEGIN

        cu: control_unit_VHDL PORT MAP(opcode, rst, RegWrite, WB_To_Reg, HLT, SETC, RST, OUT_PORT_SIG, IN_PORT_SIG);

        fetchs: fetch PORT MAP(HLT, clk, rst, alwayson, PCSrc, pc_01, pc_10, NewPc,Instruction);

        ifid: generic_buffer GENERIC MAP(64) PORT MAP(ifidin, ifidout, clk, rst);

        ds: decode_stage GENERIC MAP (n) PORT MAP(ifidout(63 DOWNTO 32),ifidout(31 DOWNTO 0), pc_outD, opcode,
        rsrc1addrD, rsrc2addrD,rdstaddrD, extrabits, immmediate_offsetD, clk, rst, RegWrite, IN_PORT_SIG, OUT_PORT_SIG, in_port, in_dataD, out_port,
        write_reg, write_data, read_data_1D, read_data_2D, read_data_3D, ccr_inD, ccr_outD, sp_inD, sp_outD, int_signal, rti_signal);


        ifidin <= Intruction & NewPc;


END arch1;
