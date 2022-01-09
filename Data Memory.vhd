
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Dmemory IS
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
END ENTITY Dmemory;

ARCHITECTURE a_Dmemory OF Dmemory IS

    COMPONENT dff IS
    GENERIC ( n : integer :=32 );
	PORT(clk,rst,en : IN std_logic;
	     reset_value: IN std_logic_vector(n - 1 DOWNTO 0); --reem
	     --edge_signal: IN std_logic; --0:rise, 1:fall --reem
	     d : IN std_logic_vector(n - 1 DOWNTO 0);
	     q : OUT std_logic_vector(n - 1 DOWNTO 0));
    END COMPONENT;

    TYPE Dmemory_type IS ARRAY(0 TO (2 ** 20) - 1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL data_memory : Dmemory_type;
    SIGNAL extendedAluResult, actual_mem_Address : STD_LOGIC_VECTOR(19 DOWNTO 0);
    -- signal empty,one :  std_logic_vector(31 downto 0);
    SIGNAL out_SP, out_SP_in, reset_val : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    -- begin with reset --> then enable
    -- empty <= (OTHERS=>'0');
    -- one <= (OTHERS=>'1');

    reset_val <= "00000000000100000000000000000000";
    extendedAluResult <= "0000" & Address;

    SP : dff Generic Map(32) PORT MAP(Clk, Rst, enable, reset_val, out_SP_in, out_SP);

    PROCESS (Clk)
    BEGIN

        -- write on rising edge omly
        -- reading on every time (rising and falling)
        IF (allowStack = '1') THEN
            IF (MemWrite = '1') THEN
                out_SP_in <= STD_LOGIC_VECTOR(unsigned(out_SP_in) - 1);
            ELSIF (MemRead = '1') THEN
                out_SP_in <= STD_LOGIC_VECTOR(unsigned(out_SP_in) + 1);
            END IF;
        END IF;

        IF (rising_edge(Clk)) THEN
            -- push   --pop
            IF (allowStack = '1') THEN
                --dec SP
                IF (MemWrite = '1') THEN
                    --put in memory Rdst value
                    data_memory(to_integer(unsigned(out_SP(19 DOWNTO 0)))) <= Write_data(15 DOWNTO 0);
                    empty_stack <= '0';
                END IF;
            ELSE
                IF (MemWrite = '1') THEN

                    --STD
                    --Write_data: R[Rsrc1], Address: aluRes, Rscr2: R[ Rsrc2]
                    --M[R[ Rsrc2] + offset] ←R[Rsrc1];  
                    data_memory(to_integer(unsigned(Address))) <= Write_data(15 DOWNTO 0);
                END IF;

            END IF;
        END IF;

        IF (allowStack = '1') THEN
            IF (MemRead = '1') THEN
                --check empty stack
                IF (out_SP = reset_val) THEN
                    empty_stack <= '1';
                ELSE
                    --update read data(R[Rdst])
                    Read_data <= data_memory(to_integer(unsigned(out_SP(19 DOWNTO 0))));
                    --inc SP
                    empty_stack <= '0';
                END IF;
            END IF;
        ELSIF (MemRead = '1') THEN

            -- Read_data <= Write_data;
            --     --LDM                                        ----------------------- Don't Forget To update alu
            -- ELSIF (OP = "10000") THEN

            Read_data <= data_memory(to_integer(unsigned(Address)));

        END IF;
    END PROCESS;

END a_Dmemory;