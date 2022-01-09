LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-- VHDL code for Control Unit of the MIPS Processor

------------------------------
-- One Operand Control_Unit
------------------------------
ENTITY control_unit_VHDL IS
  PORT (
    opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    reset : IN STD_LOGIC;

    -- One Operand 
    RegWrite, HLT, SETC, RST, OUT_PORT_SIG, IN_PORT_SIG : OUT STD_LOGIC;
    -- Two Operand
    ALUs1, PC_SOURCE, WB_To_Reg : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALUs2, INT, MemRead, MemWrite , allowStack : OUT STD_LOGIC
  );
END control_unit_VHDL;
ARCHITECTURE Behavioral OF control_unit_VHDL IS

BEGIN
  PROCESS (reset, opcode)
  BEGIN
    IF (reset = '1') THEN
      RegWrite <= '0';
      WB_To_Reg <= "00";
      HLT <= '0';
      SETC <= '0';
      OUT_PORT_SIG <= '0';
      IN_PORT_SIG <= '0';
      RST <= '1';
      PC_SOURCE <= "00";
      ALUs1 <= "00";
      ALUs2 <= '0';
      INT <= '0';
      MemRead <= '0';
      MemWrite <= '0';
      allowStack <= '0';
    ELSE
      CASE opcode IS

          ------------------------------
          -- One Operand 
          ------------------------------
        WHEN "00001" => --HLT
          RegWrite <= '0';
          WB_To_Reg <= "00";
          HLT <= '1';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
                allowStack <= '0';

        WHEN "00010" => -- SETC
          RegWrite <= '0';
          WB_To_Reg <= "00";
          HLT <= '0';
          SETC <= '1';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
      allowStack <= '0';

        WHEN "00011" => -- NOT Rdst
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "01";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "00100" => -- INC Rdst
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "01";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "00101" => -- OUT Rdst
          RegWrite <= '0';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '1';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "01";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "00110" => -- IN Rdst
          RegWrite <= '1';
          WB_To_Reg <= "10";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '1';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

          ------------------------------
          -- Two Operand 
          ------------------------------

        WHEN "01000" => -- MOV Rsrc, Rdst
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "01001" => -- ADD Rdst, Rsrc1, Rsrc2
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "01010" => -- SUB Rdst,Rsrc1, Rsrc2
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "01011" => -- AND Rdst, Rsrc1, Rsrc2
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "10000" => -- IADD Rdst, Rsrc,Imm
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '1';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

          -- Block 3 Memory 

        WHEN "01100" => -- PUSH Rdst
          RegWrite <= '0';
          WB_To_Reg <= "00";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '1';
          allowStack <= '1';

        WHEN "01101" => -- POP Rdst
          RegWrite <= '1';
          WB_To_Reg <= "00";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '1';
          MemWrite <= '0';
          allowStack <= '1';

        WHEN "10001" => -- LDM Rdst, Imm
          RegWrite <= '1';
          WB_To_Reg <= "01";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '1';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "10010" => -- LDD Rdst,offset(Rsrc)
          RegWrite <= '1';
          WB_To_Reg <= "00";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '1';
          INT <= '0';
          MemRead <= '1';
          MemWrite <= '0';
          allowStack <= '0';

        WHEN "10011" => -- STD Rsrc1,offset(Rsrc2)
          RegWrite <= '0';
          WB_To_Reg <= "00";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "10";
          ALUs2 <= '1';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '1';
          allowStack <= '0';

        WHEN OTHERS => -- Like NOP
          RegWrite <= '0';
          WB_To_Reg <= "00";
          HLT <= '0';
          SETC <= '0';
          OUT_PORT_SIG <= '0';
          IN_PORT_SIG <= '0';
          RST <= '0';
          PC_SOURCE <= "00";
          ALUs1 <= "00";
          ALUs2 <= '0';
          INT <= '0';
          MemRead <= '0';
          MemWrite <= '0';
          allowStack <= '0';

      END CASE;
    END IF;
  END PROCESS;

END Behavioral;