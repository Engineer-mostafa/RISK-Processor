LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY DataMemory IS
    GENERIC (
        n : INTEGER := 2
    );
    PORT (
        -- MemRead, MemWrite,
        Clk, Rst, enable, MemRead, MemWrite, allowStack : IN STD_LOGIC;
        Address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Read_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        empty_stack : OUT STD_LOGIC
    );
END ENTITY DataMemory;

ARCHITECTURE a_DataMemory OF DataMemory IS
COMPONENT dff IS
GENERIC ( n : integer :=32 );
PORT(clk,rst,en : IN std_logic;
     reset_value: IN std_logic_vector(n - 1 DOWNTO 0); --reem
     --edge_signal: IN std_logic; --0:rise, 1:fall --reem
     d : IN std_logic_vector(n - 1 DOWNTO 0);
     q : OUT std_logic_vector(n - 1 DOWNTO 0));
END COMPONENT;

    TYPE Dmemory_type IS ARRAY(0 TO (2 ** 20)) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL data_memory : Dmemory_type;
    SIGNAL extendedAluResult, actual_mem_Address : STD_LOGIC_VECTOR(19 DOWNTO 0);
    -- signal empty,one :  std_logic_vector(31 downto 0);
    SIGNAL out_SP, out_SP_in, reset_val : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --signal stack_enable std_logic;
BEGIN

    -- begin with reset --> then enable
    -- empty <= (OTHERS=>'0');
    -- one <= (OTHERS=>'1');
    reset_val <= X"000FFFFF";
    extendedAluResult <= X"0" & Address;
    --out_SP_in <= x"aaaaaaaa";
    SP : dff Generic Map(32) PORT MAP(Clk, Rst, enable, reset_val, out_SP_in, out_SP);

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (MemWrite = '1' AND allowStack /= '1') THEN
                data_memory(to_integer(unsigned(extendedAluResult))) <= Write_data(15 DOWNTO 0);
            ELSIF (MemWrite = '1' AND allowStack = '1') THEN
                data_memory(to_integer(unsigned(out_SP(19 DOWNTO 0)))) <= Write_data(15 DOWNTO 0);                                            --push
            END IF;

        END IF;
    END PROCESS;

    
    Read_data <= data_memory(to_integer(unsigned(extendedAluResult))) when(MemRead = '1' and allowStack /= '1')
    ELSE data_memory(to_integer(unsigned(out_SP(19 downto 0)) + 1)) when(MemRead = '1' and allowStack = '1');        --pop



    out_SP_in <= STD_LOGIC_VECTOR(unsigned(out_SP) + 1) when(MemRead = '1' and allowStack = '1')
	else STD_LOGIC_VECTOR(unsigned(out_SP) - 1) when (MemWrite = '1' AND allowStack = '1');

END a_DataMemory;