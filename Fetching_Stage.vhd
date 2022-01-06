
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
Library work;

ENTITY fetch IS
GENERIC ( 
	n : integer :=2; --used in mux_4x1 / mux_2x1 
	m : integer :=2 --used in mux_4x1 (OP)
	); 
	PORT(
	      HLT_Signal,Clk,Rst,enable : IN std_logic;
	      --OP : IN std_logic_vector(1 DOWNTO 0); --can't get it from in
	      PCSrc : IN std_logic_vector(1 DOWNTO 0);
	      pc_01, pc_10 : IN std_logic_vector(31 DOWNTO 0);
	      NewPc : OUT std_logic_vector(31 DOWNTO 0);
	      Instruction : OUT std_logic_vector(31 DOWNTO 0));
	END fetch ;

------------------------------------------------------------------

ARCHITECTURE a_fetch  OF fetch IS

component dff IS
	PORT(clk,rst,en : IN std_logic;
	     reset_value: IN std_logic_vector(n - 1 DOWNTO 0); --reem
	     --edge_signal: IN std_logic; --0:rise, 1:fall --reem
	     d : IN std_logic_vector(n - 1 DOWNTO 0);
	     q : OUT std_logic_vector(n - 1 DOWNTO 0));

end component;

component adder is 

PORT(
	      input1 : IN std_logic_vector(n - 1 DOWNTO 0);
	      input2 : IN std_logic_vector(n - 1 DOWNTO 0);
	      output : OUT std_logic_vector(n - 1 DOWNTO 0));

end component;

component mux_4x1 is 
GENERIC ( m : integer);
Port ( 
in1 : in std_logic_vector(m-1 DOWNTO 0); -- mux input1
in2 : in std_logic_vector(m-1 DOWNTO 0); -- mux input2
in3 : in std_logic_vector(m-1 DOWNTO 0); -- mux input3
in4 : in std_logic_vector(m-1 DOWNTO 0); -- mux input4
sel : in std_logic_vector(1 downto 0); -- selection line
dataout : out std_logic_vector(m-1 DOWNTO 0)); -- output data

end component;


component mux_2x1 is 
Port ( 
in1 : in std_logic_vector(n-1 DOWNTO 0); -- mux input1
in2 : in std_logic_vector(n-1 DOWNTO 0); -- mux input2
sel : in std_logic; -- selection line
dataout : out std_logic_vector(n-1 DOWNTO 0)); -- output data

end component;

component memory IS
	PORT(
		address : IN  std_logic_vector(31 DOWNTO 0);--PC is the address 
		instruction : OUT std_logic_vector(31 DOWNTO 0);
		OP : OUT std_logic_vector(1 DOWNTO 0));
end component;

signal empty :  std_logic_vector(31 downto 0);
signal out_pc, out_PC_in, out_PC_mux_in,instruction_out,
out_add_in_extended,newPcSignal,reset_val : std_logic_vector(31 DOWNTO 0);
signal out_add_in,OP,sth1,sth2: std_logic_vector(1 downto 0);

BEGIN

	-----------1
	-- we need to initialize, so begin with reset
	-- reset_val <= (others => '0');
	reset_val <= "00000000000000000000000010100000";
	PC: dff port map(Clk,Rst,enable,reset_val,out_PC_in,out_pc);

	-----------5
	-- out_pc <= to_integer(unsigned(instruction_out))
	-- when Rst='1' 
	-- else out_pc;

	pc_adder: adder port map(out_pc , out_add_in_extended , newPcSignal );
	NewPc <= newPcSignal;

	-----------7
	empty <= (OTHERS=>'0');
	PC_mux_4x1 : mux_4x1 
	generic map(m => 32) 
	port map(out_PC_mux_in , pc_01 , pc_10, empty , PCSrc, out_PC_in);

	-----------6
	PC_hlt_mux_2x1 : mux_2x1 
	generic map(n => 32)
	port map(newPcSignal,out_pc,HLT_Signal,out_PC_mux_in);

	-----------2
	instruction_mem :memory port map(out_pc, instruction_out , OP);
	--if OP == "10" then read from memory twice, but we don't know op!!!
	--so we will waste a cycle to know **in decode** that it needs to go to fetch again
	--or try to give the output to adder

	Instruction <=instruction_out;

	-----------3
	sth1<="01";
	sth2<="10";
	op_mux_4x1 : mux_4x1 
	generic map(m => 2)
	port map(sth1 ,sth1,sth2, sth1 , OP, out_add_in);

	-----------4
	process(Clk,out_add_in)
	begin
		out_add_in_extended <= empty(31 downto 2) & out_add_in ;
	end process;
	

END a_fetch ;




