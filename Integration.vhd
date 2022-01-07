
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
        aluOP : in std_logic;
        sp_in: IN std_logic_vector(31 DOWNTO 0);
        sp_out: OUT std_logic_vector(31 DOWNTO 0);
        int_signal: IN std_logic; -- Used to store the Flags in a special register in case of INT instruction
        rti_signal: IN std_logic -- Used to restore Flags from the special register in case of RTI instruction
    );
    END COMPONENT;

    COMPONENT EXStage is
        port(
         Input : in std_logic_vector(15 downto 0); 			-- Rdst
         Opcode : in std_logic_vector(4 downto 0); 			-- function select
         aluResult: out std_logic_vector(15 downto 0); 			-- ALU Output Result
         oldZero_Flag, oldNegative_Flag, oldCarry_Flag  : in std_logic;
         zero_Flag,negative_Flag,carry_Flag,aluOP : out std_logic            	-- Z<0>:=CCR<0> ; zero flag 
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

COMPONENT MEM_STAGE is
       GENERIC ( n : integer :=32 );
Port( 	
	Left_OUTPUT_BUFFER 	: in std_logic_vector(n-1 downto 0);
	Right_INPUT_BUFFER 	: out std_logic_vector(n-1 downto 0);
    clk                 : in std_logic
);
    end COMPONENT;
        


    COMPONENT WriteBackStage IS 
    GENERIC ( n : integer :=16 );
    Port( 	
        ALUresult 			: in std_logic_vector(15 downto 0);
        In_Data	  			: in std_logic_vector(15 downto 0);
        RdstData	  		: in std_logic_vector(15 downto 0);
        WBtoReg 			: in std_logic;
        out_signal			: in std_logic;
        result_WritingOutput		: out std_logic_vector(15 downto 0)
    );
    end COMPONENT;
    SIGNAL Instruction,NewPc:  std_logic_vector(31 DOWNTO 0);
    -- SIGNAL InstructionOut,NewPcOut:  std_logic_vector(31 DOWNTO 0);
    SIGNAL RegWrite,WB_To_Reg,HLT,SETC,RSTs,OUT_PORT_SIG,IN_PORT_SIG: std_logic;
    SIGNAL alwayson: std_logic := '1';
    SIGNAL PCSrc: std_logic_vector(1 DOWNTO 0);
    SIGNAL pc_01, pc_10: std_logic_vector(31 DOWNTO 0);  --> Need to connect this
    SIGNAL ifidin,ifidout: std_logic_vector(63 DOWNTO 0);
    SIGNAL opcode: std_logic_vector(4 downto 0);
    SIGNAL pc_outD: std_logic_vector(31 DOWNTO 0); --> Need to connect this
    SIGNAL rsrc1addrD, rsrc2addrD,rdstaddrD: std_logic_vector(2 DOWNTO 0); --> Need to connect this
    SIGNAL extrabits: std_logic_vector(1 DOWNTO 0); --> Need to connect this
    SIGNAL immmediate_offsetD: std_logic_vector(15 DOWNTO 0); --> Need to connect this
    SIGNAL in_dataD: std_logic_vector(n-1 DOWNTO 0); --> Need to connect this to id/ex buffer as IN
    SIGNAL write_reg: std_logic_vector(2 DOWNTO 0); --> Need to connect this
    -- SIGNAL write_data: std_logic_vector(n-1 DOWNTO 0); --> Need to connect this
    SIGNAL read_data_1D, read_data_2D, read_data_3D: std_logic_vector(n-1 DOWNTO 0); --> Need to connect this to id/ex buffer as IN
    SIGNAL ccr_inD, ccr_outD: std_logic_vector(3 DOWNTO 0); --> Need to connect this
    SIGNAL sp_inD, sp_outD: std_logic_vector(31 DOWNTO 0);--> Need to connect this
    SIGNAL int_signal, rti_signal: std_logic; --> Need to connect this
    Signal aluResult : std_logic_vector(n - 1 downto 0);
    Signal ZFlag,NFlag,CFlag , aluOP , oldZero_Flag, oldNegative_Flag, oldCarry_Flag : std_logic;
    Signal exmemin , exmemout , memwbin,memwbout: std_logic_vector(63 downto 0);
    Signal idexin , idexout : std_logic_vector(255 downto 0);
    Signal OUT_OUTSig_sig , OUT_RegWrite_sig, enable_pc: std_logic;
    Signal result_WriteBackOutput_sig: std_logic_vector(15 downto 0); 
    Signal Cycle : integer;
     
    BEGIN
    
    -- Constants: To be implemeted later:
    rti_signal <= '0'; -- Need to send this from the control unit instead
    
        -- The Control Unit
        cu: control_unit_VHDL PORT MAP(opcode, rst, RegWrite, WB_To_Reg, HLT, SETC, RSTs, OUT_PORT_SIG, IN_PORT_SIG);
        -- Need to add extrabits to it as input.

        -- The Fetch Stage:
        fetchs: fetch PORT MAP(HLT, clk, RSTs, enable_pc, PCSrc, pc_01, pc_10, NewPc,Instruction);

        -- The Buffer between the Fetch and Decode Stages.
        ifid: generic_buffer GENERIC MAP(64) PORT MAP(ifidin, ifidout, clk, RSTs);
        ifidin(63 DOWNTO 32) <= Instruction; -- Fetched Instruction (32 bits)
        ifidin(31 DOWNTO 0) <= NewPc;        -- NewPC from Fetch    (32 bits)

        -- The Decode Stage:
        ds: decode_stage GENERIC MAP (n) PORT MAP(ifidout(63 DOWNTO 32),ifidout(31 DOWNTO 0), pc_outD, opcode,
        rsrc1addrD, rsrc2addrD,rdstaddrD, extrabits, immmediate_offsetD, clk, RSTs, memwbout(31), IN_PORT_SIG, memwbout(24), in_port, in_dataD, out_port,
        memwbout(23 DOWNTO 21), result_WriteBackOutput_sig, read_data_1D, read_data_2D, read_data_3D, ccr_inD, ccr_outD, aluOP, sp_inD, sp_outD, int_signal, rti_signal);


        -- The Buffer between the Decode and Execute Stages.
        idex: generic_buffer GENERIC MAP(256) PORT MAP(idexin, idexout, clk, RSTs);
        idexin(255 DOWNTO 166) <= (OTHERS => '0');
        idexin(165) <= OUT_PORT_SIG;                -- OUT_PORT_SIG Signal        ( 1 bit )
        idexin(164 DOWNTO 160) <= opcode;           -- OpCode                     ( 5 bits)
        idexin(159 DOWNTO 128) <= sp_outD;          -- SP From Decode Stage       (32 bits)
        idexin(127 DOWNTO 96) <= pc_outD;           -- PC From Decode Stage       (32 bits)
        idexin(95 DOWNTO 93) <= rsrc1addrD;         -- Rsrc1 Address From Decode  ( 3 bits)
        idexin(92 DOWNTO 90) <= rsrc2addrD;         -- Rsrc2 Address From Decode  ( 3 bits)
        idexin(89 DOWNTO 87) <= rdstaddrD;          -- Rdst Address From Decode   ( 3 bits)
        idexin(86 DOWNTO 71) <= immmediate_offsetD; -- Offset/Immediate Data      (16 bits)
        idexin(70 DOWNTO 55) <= in_dataD;           -- Data from Input Port       (16 bits)
        idexin(54 DOWNTO 39) <= read_data_1D;       -- Value of Rsrc1 [Rsrc1]     (16 bits)
        idexin(38 DOWNTO 23) <= read_data_2D;       -- Value of Rsrc2 [Rsrc2]     (16 bits)
        idexin(22 DOWNTO 7) <= read_data_3D;        -- Value of Rdst  [Rdst]      (16 bits)
        idexin(6 DOWNTO 3) <= ccr_outD;             -- Value of Flags [CCR]       ( 4 bits)
        -- Signals
        -- Execute Signals:
        -- Memory Signals:
        -- Write Back Signals:
        idexin(2) <= RegWrite;                      -- RegWrite Signal            ( 1 bit )
        idexin(1) <= WB_To_Reg;                     -- WB_To_Reg Signal           ( 1 bit )
        idexin(0) <= SETC;                          -- SETC Signal                ( 1 bit )
        -- idexin(2 DOWNTO 0) <= (OTHERS => '0');
        oldZero_Flag <= idexout(3) ;
        oldNegative_Flag <= idexout(4); 
        oldCarry_Flag <= idexout(5);
        -- The Execution Stage
        -- Add a CCR in to the Execution Stage
	    ExecutionStage: EXStage PORT MAP (idexout(22 DOWNTO 7), idexout(164 DOWNTO 160), aluResult , oldZero_Flag, oldNegative_Flag, oldCarry_Flag , ZFlag , NFlag , CFlag , aluOP); 
					                            -- src 16-bits , opcode , alu_result, RSTs , flags
        
        -- buffer between execution and memory
        IEX_IMEM: generic_buffer GENERIC MAP(64) PORT MAP(exmemin, exmemout, clk, RSTs); 
                                -- input -> aluresult + inData / output -> aluresult + inData
        
     
        exmemin(63 DOWNTO 24 ) <= aluResult & idexout(70 DOWNTO 55) & idexout(2) & idexout(1) & CFlag & NFlag & ZFlag & idexout(0) & RSTs & idexout(165);  
	    exmemin(23 DOWNTO 21)  <= idexout(89 DOWNTO 87);
	    exmemin(20 DOWNTO 5)  <= idexout(22 DOWNTO 7);
	    exmemin(4 DOWNTO 0)   <= (OTHERS => '0');
                           			             -- 16<63,48> + 16<47,32> + 1<31> +     1<30>   + 1<29> + 1<28> + 1<27> + 1<26> + 1<25> + 1<24> = 40
	
        ccr_inD <=  '0' & CFlag & NFlag & ZFlag ;
	

        MemoryStage:  MEM_STAGE GENERIC MAP(64) PORT MAP(exmemout , memwbin , clk);
        -- buffer between memory and writeback
	    IMEM_IWB: generic_buffer GENERIC MAP(64) PORT MAP(memwbin, memwbout, clk, RSTs);
	    WriteBack_Stage: WriteBackStage PORT MAP ( memwbout(63 downto 48) , memwbout(47 downto 32) ,memwbout(20 DOWNTO 5) ,memwbout(30),memwbout(24),result_WriteBackOutput_sig); -- ALUresult , In_Data , WBtoReg /  result_WritingOutput
	
        PROCESS(clk,rst)
        BEGIN
            IF(rst = '1') THEN
                Cycle <= 0; 
            ELSIF (rising_edge(clk)) THEN
                Cycle <= Cycle + 1;
            END IF;
        END PROCESS;


    END arch1; 