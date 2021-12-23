
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

    COMPONENT EXStage is
        port(
         Input : in std_logic_vector(15 downto 0); 			-- Rdst
         Opcode : in std_logic_vector(4 downto 0); 			-- function select
         aluResult: out std_logic_vector(15 downto 0); 			-- ALU Output Result
         zero_Flag,negative_Flag,carry_Flag: out std_logic             	-- Z<0>:=CCR<0> ; zero flag 
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
	Right_INPUT_BUFFER 	: out std_logic_vector(n-1 downto 0)
);
    end COMPONENT;
        


 COMPONENT WriteBackStage is
       GENERIC ( n : integer :=16 );
Port( 	
	ALUresult 			: in std_logic_vector(15 downto 0);
	In_Data	  			: in std_logic_vector(15 downto 0);
	WBtoReg 			: in std_logic;
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
    Signal ZFlag,NFlag,CFlag:  std_logic;
    Signal input_buffer_between_IEX_IMEM , out_buffer_between_IEX_IMEM , input_buffer_between_IMEM_IWB,out_buffer_between_IMEM_IWB: std_logic_vector(63 downto 0);
    Signal input_buffer_between_ID_IEX , out_buffer_between_ID_IEX : std_logic_vector(127 downto 0);
    Signal OUT_OUTSig_sig , OUT_RegWrite_sig, enable_pc: std_logic;
    Signal result_WriteBackOutput_sig: std_logic_vector(15 downto 0); 
    BEGIN

        cu: control_unit_VHDL PORT MAP(opcode, rst, RegWrite, WB_To_Reg, HLT, SETC, RSTs, OUT_PORT_SIG, IN_PORT_SIG);

        fetchs: fetch PORT MAP(HLT, clk, RSTs, enable_pc, PCSrc, pc_01, pc_10, NewPc,Instruction);

        ifid: generic_buffer GENERIC MAP(64) PORT MAP(ifidin, ifidout, clk, RSTs);

        ds: decode_stage GENERIC MAP (n) PORT MAP(ifidout(63 DOWNTO 32),ifidout(31 DOWNTO 0), pc_outD, opcode,
        rsrc1addrD, rsrc2addrD,rdstaddrD, extrabits, immmediate_offsetD, clk, RSTs, RegWrite, IN_PORT_SIG, OUT_PORT_SIG, in_port, in_dataD, out_port,
        write_reg, result_WriteBackOutput_sig, read_data_1D, read_data_2D, read_data_3D, ccr_inD, ccr_outD, sp_inD, sp_outD, int_signal, rti_signal);


        ifidin(63 DOWNTO 32) <= Instruction;
        ifidin(31 DOWNTO 0) <= NewPc;
	

   	input_buffer_between_ID_IEX(127 DOWNTO 59) <= read_data_3D & in_dataD & RegWrite & WB_To_Reg & SETC & RSTs & OUT_PORT_SIG & NewPc;
				 		    -- 16<127,112> + 16<111,96>  + 1 + 1 + 1 + 1 + 1 + 32<75,44> = 69
   	input_buffer_between_ID_IEX(58 DOWNTO 0) <= (OTHERS => '0');
	--input_buffer_between_ID_IEX <= (OTHERS => '0');
    -- buffer between decode and execution
	ID_IEX: generic_buffer GENERIC MAP(128) PORT MAP(input_buffer_between_ID_IEX, out_buffer_between_ID_IEX, clk, RSTs);
	
	ExecutionStage: EXStage PORT MAP (read_data_3D , opcode , aluResult , ZFlag , NFlag , CFlag); 
					-- src 16-bits , opcode , alu_result , flags 

    	input_buffer_between_IEX_IMEM(63 DOWNTO 24 ) <= aluResult & in_dataD & RegWrite & WB_To_Reg & ZFlag & NFlag & CFlag & SETC & RSTs & OUT_PORT_SIG;  
	input_buffer_between_IEX_IMEM(23 DOWNTO 0) <= (OTHERS => '0');
                                -- 16<63,48> + 16<47,32> + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 = 40
-- buffer between execution and memory
	IEX_IMEM: generic_buffer GENERIC MAP(64) PORT MAP(input_buffer_between_IEX_IMEM, out_buffer_between_IEX_IMEM, clk, RSTs); -- input -> aluresult + inData / output -> aluresult + inData
	
	MemoryStage:  MEM_STAGE GENERIC MAP(64) PORT MAP(out_buffer_between_IEX_IMEM , input_buffer_between_IMEM_IWB);
-- buffer between memory and writeback
	IMEM_IWB: generic_buffer GENERIC MAP(64) PORT MAP(input_buffer_between_IMEM_IWB, out_buffer_between_IMEM_IWB, clk, RSTs);
	WriteBack_Stage: WriteBackStage PORT MAP ( out_buffer_between_IMEM_IWB(63 downto 48) , out_buffer_between_IMEM_IWB(47 downto 32) , out_buffer_between_IMEM_IWB(30),result_WriteBackOutput_sig); -- ALUresult , In_Data , WBtoReg /  result_WritingOutput
	

END arch1; 