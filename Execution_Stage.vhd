
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.ALL;
ENTITY EXStage IS
  PORT (
    Input : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Rdst
    Opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- function select
    aluResult : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU Output Result
    indata1,indata2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Input Port Value
    oldZero_Flag, oldNegative_Flag, oldCarry_Flag : IN STD_LOGIC;
    zero_Flag, negative_Flag, carry_Flag, aluOP : OUT STD_LOGIC; -- Z<0>:=CCR<0> ; zero flag 
    -- N<0>:=CCR<1> ; negative flag
    -- C<0>:=CCR<2> ; carry flag

    -- Two Operand 
    Rsrc1, Rsrc2, Imm , From_ALU_Result , From_WB_MUX : IN STD_LOGIC_VECTOR(15 DOWNTO 0);-- Rsrc1 , Rsrc 2 , Imm
    ALUs1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALUs2 : IN STD_LOGIC; 
    ForwardtoMUX8, ForwardToMUX4 : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END EXStage;
ARCHITECTURE arch_EXStage OF EXStage IS
  COMPONENT ALU_VHDL IS
    PORT (
      -- One Operand 
      opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- function select
      alu_result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- ALU Output Result
      oldZero_Flag, oldNegative_Flag, oldCarry_Flag : IN STD_LOGIC;
      Zero_Flag, Negative_Flag, Carry_Flag, aluOP : OUT STD_LOGIC; -- Z<0>:=CCR<0> ; zero flag 
      -- N<0>:=CCR<1> ; negative flag
      -- C<0>:=CCR<2> ; carry flag
      -- Two Operand 
      Rsrc1, Rsrc2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0) -- Rsrc1 , Rsrc 2 , Rdst , Imm
    );

    
  END COMPONENT;

  -- Two Operand
  SIGNAL s_Rsrc1, s_Rsrc2, s_Imm, s_Input, s_OUT_mux_8x1, s_OUT_mux_4x1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL mux_8x1_Selector : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL mux_4x1_Selector : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL mux_2x1_Selector1 : STD_LOGIC;
  SIGNAL mux_2x1_Selector2 : STD_LOGIC;
  SIGNAL mux_2x1_Selector3 : STD_LOGIC;
  SIGNAL mux2_out1, mux2_out2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL indata : STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- replace them with forwarding unit
  -- SIGNAL empty1, empry2, empry3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN

  mux_8x1_Selector <= (ForwardtoMUX8(1) & ALUs1);
  mux_8x1 : ENTITY work.mux_8x1 PORT MAP(Rsrc1, Input, Rsrc2, indata, mux2_out1, mux2_out1, mux2_out1, mux2_out1, mux_8x1_Selector, s_OUT_mux_8x1);
  mux_4x1_Selector <= (ForwardToMUX4(1) & ALUs2);
  mux_4x1 : ENTITY work.mux_4x1 GENERIC MAP(16) PORT MAP (Rsrc2, Imm, mux2_out2, mux2_out2, mux_4x1_Selector, s_OUT_mux_4x1);
  
  mux_2x1_Selector1 <= ForwardToMUX8(0);
  mux_2x11 : ENTITY work.mux_2x1 GENERIC MAP(16) PORT MAP (From_ALU_Result, From_WB_MUX, mux_2x1_Selector1, mux2_out1);
  mux_2x1_Selector2 <= ForwardToMUX4(0);
  mux_2x12 : ENTITY work.mux_2x1 GENERIC MAP(16) PORT MAP (From_ALU_Result, From_WB_MUX, mux_2x1_Selector2, mux2_out2);
  
  -- mux_2x1_Selector3 <= ForwardToMUX4(0);
  mux_2x13 : ENTITY work.mux_2x1 GENERIC MAP(16) PORT MAP (indata1, indata2, mux_2x1_Selector2, indata);
  
  alu : ALU_VHDL PORT MAP(
    Opcode, aluResult, oldZero_Flag, oldNegative_Flag, oldCarry_Flag,
    zero_Flag, negative_Flag, carry_Flag, aluOP, s_OUT_mux_8x1, s_OUT_mux_4x1);
END arch_EXStage;