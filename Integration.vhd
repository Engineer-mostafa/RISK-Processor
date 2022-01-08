
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY integration IS
    GENERIC (n : INTEGER := 16); -- For register size
    PORT (
        clk, rst : IN STD_LOGIC;
        in_port : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        out_port : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
    );
END integration;

ARCHITECTURE arch1 OF integration IS

    COMPONENT control_unit_VHDL IS
        PORT (
            opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            reset : IN STD_LOGIC;
            RegWrite, WB_To_Reg, HLT, SETC, RST, OUT_PORT_SIG, IN_PORT_SIG : OUT STD_LOGIC;

            -- Two Operand
            ALUs1, PC_SOURCE : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALUs2, INT : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT fetch IS
        GENERIC (
            n : INTEGER := 2; --used in mux_4x1 / mux_2x1 
            m : INTEGER := 2 --used in mux_4x1 (OP)
        );
        PORT (
            HLT_Signal, Clk, Rst, enable : IN STD_LOGIC;
            PCSrc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_01, pc_10 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            NewPc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            Instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    COMPONENT decode_stage IS
        GENERIC (n : INTEGER := 16); -- For register size
        PORT (
            instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            opfncode : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            rsrc1addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            rsrc2addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            rdstaddr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            extrabits : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            immmediate_offset : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            clk, rst : IN STD_LOGIC;
            RegWrite : IN STD_LOGIC;
            in_signal : IN STD_LOGIC;
            out_signal : IN STD_LOGIC;
            in_port : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            in_data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            out_port : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            -- read_reg1: IN std_logic_vector(2 DOWNTO 0);
            -- read_reg2: IN std_logic_vector(2 DOWNTO 0);
            -- read_reg3: IN std_logic_vector(2 DOWNTO 0); -- For the Rdst read
            write_reg : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_data : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            read_data_1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            read_data_2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            read_data_3 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            ccr_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            ccr_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            aluOP : IN STD_LOGIC;
            sp_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            int_signal : IN STD_LOGIC; -- Used to store the Flags in a special register in case of INT instruction
            rti_signal : IN STD_LOGIC -- Used to restore Flags from the special register in case of RTI instruction
        );
    END COMPONENT;

    COMPONENT EXStage IS
        PORT (
            Input : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Rdst
            Opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- function select
            aluResult : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU Output Result
            oldZero_Flag, oldNegative_Flag, oldCarry_Flag : IN STD_LOGIC;
            zero_Flag, negative_Flag, carry_Flag, aluOP : OUT STD_LOGIC; -- Z<0>:=CCR<0> ; zero flag 
            -- N<0>:=CCR<1> ; negative flag
            -- C<0>:=CCR<2> ; carry flag

            -- Two Operand 
            Rsrc1 , Rsrc2 , Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0) -- Rsrc1 , Rsrc 2 , Imm
            );
    END COMPONENT;

    COMPONENT generic_buffer IS
        GENERIC (n : INTEGER := 128);
        PORT (
            LeftInput : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            RightOutput : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            clk, rst : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT MEM_STAGE IS
        GENERIC (n : INTEGER := 32);
        PORT (
            Left_OUTPUT_BUFFER : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            Right_INPUT_BUFFER : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            clk : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT WriteBackStage IS
        GENERIC (n : INTEGER := 16);
        PORT (
            ALUresult : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            In_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            RdstData : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            WBtoReg : IN STD_LOGIC;
            out_signal : IN STD_LOGIC;
            result_WritingOutput : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL Instruction, NewPc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- SIGNAL InstructionOut,NewPcOut:  std_logic_vector(31 DOWNTO 0);
    SIGNAL RegWrite, WB_To_Reg, HLT, SETC, RSTs, OUT_PORT_SIG, IN_PORT_SIG : STD_LOGIC;
    SIGNAL alwayson : STD_LOGIC := '1';
    SIGNAL PCSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL pc_01, pc_10 : STD_LOGIC_VECTOR(31 DOWNTO 0); --> Need to connect this
    SIGNAL ifidin, ifidout : STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL opcode : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL pc_outD : STD_LOGIC_VECTOR(31 DOWNTO 0); --> Need to connect this
    SIGNAL rsrc1addrD, rsrc2addrD, rdstaddrD : STD_LOGIC_VECTOR(2 DOWNTO 0); --> Need to connect this
    SIGNAL extrabits : STD_LOGIC_VECTOR(1 DOWNTO 0); --> Need to connect this
    SIGNAL immmediate_offsetD : STD_LOGIC_VECTOR(15 DOWNTO 0); --> Need to connect this
    SIGNAL in_dataD : STD_LOGIC_VECTOR(n - 1 DOWNTO 0); --> Need to connect this to id/ex buffer as IN
    SIGNAL write_reg : STD_LOGIC_VECTOR(2 DOWNTO 0); --> Need to connect this
    -- SIGNAL write_data: std_logic_vector(n-1 DOWNTO 0); --> Need to connect this
    SIGNAL read_data_1D, read_data_2D, read_data_3D : STD_LOGIC_VECTOR(n - 1 DOWNTO 0); --> Need to connect this to id/ex buffer as IN
    SIGNAL ccr_inD, ccr_outD : STD_LOGIC_VECTOR(3 DOWNTO 0); --> Need to connect this
    SIGNAL sp_inD, sp_outD : STD_LOGIC_VECTOR(31 DOWNTO 0);--> Need to connect this
    SIGNAL int_signal, rti_signal : STD_LOGIC; --> Need to connect this
    SIGNAL aluResult : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    --aluOP just a to forward flags or not
    SIGNAL ZFlag, NFlag, CFlag, aluOP, oldZero_Flag, oldNegative_Flag, oldCarry_Flag : STD_LOGIC;
    SIGNAL exmemin, exmemout, memwbin, memwbout : STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL idexin, idexout : STD_LOGIC_VECTOR(255 DOWNTO 0);
    SIGNAL OUT_OUTSig_sig, OUT_RegWrite_sig, enable_pc : STD_LOGIC;
    SIGNAL result_WriteBackOutput_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Cycle : INTEGER;

    -- Two Operand
    SIGNAL ALUs1, PC_SOURCE : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ALUs2, INT : STD_LOGIC;


BEGIN

    -- Constants: To be implemeted later:
    rti_signal <= '0'; -- Need to send this from the control unit instead

    -- The Control Unit
    cu : control_unit_VHDL PORT MAP(opcode, rst, RegWrite, WB_To_Reg, HLT, SETC, RSTs, OUT_PORT_SIG, IN_PORT_SIG, ALUs1, PC_SOURCE, ALUs2, INT);
    -- Need to add extrabits to it as input.

    -- The Fetch Stage:
    fetchs : fetch PORT MAP(HLT, clk, RSTs, enable_pc, PCSrc, pc_01, pc_10, NewPc, Instruction);

    -- The Buffer between the Fetch and Decode Stages.
    ifid : generic_buffer GENERIC MAP(64) PORT MAP(ifidin, ifidout, clk, RSTs);
    ifidin(63 DOWNTO 32) <= Instruction; -- Fetched Instruction (32 bits)
    ifidin(31 DOWNTO 0) <= NewPc; -- NewPC from Fetch    (32 bits)

    -- The Decode Stage:
    ds : decode_stage GENERIC MAP(
        n) PORT MAP(ifidout(63 DOWNTO 32), ifidout(31 DOWNTO 0), pc_outD, opcode,
        rsrc1addrD, rsrc2addrD, rdstaddrD, extrabits, immmediate_offsetD, clk, RSTs, memwbout(31), IN_PORT_SIG, memwbout(24), in_port, in_dataD, out_port,
        memwbout(23 DOWNTO 21), result_WriteBackOutput_sig, read_data_1D, read_data_2D, read_data_3D, ccr_inD, ccr_outD, aluOP, sp_inD, sp_outD, int_signal, rti_signal);
    -- The Buffer between the Decode and Execute Stages.
    idex : generic_buffer GENERIC MAP(256) PORT MAP(idexin, idexout, clk, RSTs);
    idexin(255 DOWNTO 166) <= (OTHERS => '0');

    -- Two Operand
    idexin(171) <= INT;         -- inturupt (1 bit)
    idexin(170) <= ALUs2;       -- inturselector of the second input for alu upt (1 bit)
    idexin(169 DOWNTO 168) <= PC_SOURCE; -- pc source for choose the source of pc  (2 bit)
    idexin(167 DOWNTO 166) <= ALUs1; -- selector of the first input for alu (2 bit)

    -- One Operand
    idexin(165) <= OUT_PORT_SIG; -- OUT_PORT_SIG Signal        ( 1 bit )
    idexin(164 DOWNTO 160) <= opcode; -- OpCode                     ( 5 bits)
    idexin(159 DOWNTO 128) <= sp_outD; -- SP From Decode Stage       (32 bits)
    idexin(127 DOWNTO 96) <= pc_outD; -- PC From Decode Stage       (32 bits)
    idexin(95 DOWNTO 93) <= rsrc1addrD; -- Rsrc1 Address From Decode  ( 3 bits)
    idexin(92 DOWNTO 90) <= rsrc2addrD; -- Rsrc2 Address From Decode  ( 3 bits)
    idexin(89 DOWNTO 87) <= rdstaddrD; -- Rdst Address From Decode   ( 3 bits)
    idexin(86 DOWNTO 71) <= immmediate_offsetD; -- Offset/Immediate Data      (16 bits)
    idexin(70 DOWNTO 55) <= in_dataD; -- Data from Input Port       (16 bits)
    idexin(54 DOWNTO 39) <= read_data_1D; -- Value of Rsrc1 [Rsrc1]     (16 bits)
    idexin(38 DOWNTO 23) <= read_data_2D; -- Value of Rsrc2 [Rsrc2]     (16 bits)
    idexin(22 DOWNTO 7) <= read_data_3D; -- Value of Rdst  [Rdst]      (16 bits)
    idexin(6 DOWNTO 3) <= ccr_outD; -- Value of Flags [CCR]       ( 4 bits)
    -- Signals
    -- Execute Signals:
    -- Memory Signals:
    -- Write Back Signals:
    idexin(2) <= RegWrite; -- RegWrite Signal            ( 1 bit )
    idexin(1) <= WB_To_Reg; -- WB_To_Reg Signal           ( 1 bit )
    idexin(0) <= SETC; -- SETC Signal                ( 1 bit )
    -- idexin(2 DOWNTO 0) <= (OTHERS => '0');
    oldZero_Flag <= idexout(3);
    oldNegative_Flag <= idexout(4);
    oldCarry_Flag <= idexout(5);
    -- The Execution Stage
    -- Add a CCR in to the Execution Stage
    ExecutionStage : EXStage PORT MAP(idexout(22 DOWNTO 7), idexout(164 DOWNTO 160), aluResult, oldZero_Flag, oldNegative_Flag, oldCarry_Flag,
                                     ZFlag, NFlag, CFlag, aluOP , idexout(54 DOWNTO 39) , idexout(38 DOWNTO 23) ,  idexout(86 DOWNTO 71));
                                    -- Rdst 16-bits , opcode , alu_result, RSTs , flags , aluOP , Rsrc 1 (16 bit) , Rsrc 2 (16 bit) , Imm (16 bit) 

    -- buffer between execution and memory
    IEX_IMEM : generic_buffer GENERIC MAP(64) PORT MAP(exmemin, exmemout, clk, RSTs);
                            -- input -> aluresult + inData / output -> aluresult + inData
    exmemin(63 DOWNTO 24) <= aluResult & idexout(70 DOWNTO 55) & idexout(2) & idexout(1) & CFlag & NFlag & ZFlag & idexout(0) & RSTs & idexout(165) ;
    exmemin(23 DOWNTO 21) <= idexout(89 DOWNTO 87);
    exmemin(20 DOWNTO 5) <= idexout(22 DOWNTO 7);
    exmemin(4 DOWNTO 0) <= (OTHERS => '0');
    -- 16<63,48> + 16<47,32> + 1<31> +     1<30>   + 1<29> + 1<28> + 1<27> + 1<26> + 1<25> + 1<24> = 40

    ccr_inD <= '0' & CFlag & NFlag & ZFlag;
    MemoryStage : MEM_STAGE GENERIC MAP(64) PORT MAP(exmemout, memwbin, clk);
    -- buffer between memory and writeback
    IMEM_IWB : generic_buffer GENERIC MAP(64) PORT MAP(memwbin, memwbout, clk, RSTs);
    WriteBack_Stage : WriteBackStage PORT MAP(memwbout(63 DOWNTO 48), memwbout(47 DOWNTO 32), memwbout(20 DOWNTO 5), memwbout(30), memwbout(24), result_WriteBackOutput_sig); -- ALUresult , In_Data , WBtoReg /  result_WritingOutput

    PROCESS (clk, rst)
    BEGIN
        IF (rst = '1') THEN
            Cycle <= 0;
        ELSIF (rising_edge(clk)) THEN
            Cycle <= Cycle + 1;
        END IF;
    END PROCESS;
END arch1;