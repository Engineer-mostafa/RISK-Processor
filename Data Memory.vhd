
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Dmemory IS
    GENERIC (
        n : INTEGER := 2
    );
    PORT (
        -- MemRead, MemWrite,
        Clk, Rst, enable : IN STD_LOGIC;
        OP : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        Write_data, Address, Rscr2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Read_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        empty_stack : OUT STD_LOGIC
    );
END ENTITY Dmemory;

ARCHITECTURE a_Dmemory OF Dmemory IS

    COMPONENT dff IS
        PORT (
            clk, rst, en : IN STD_LOGIC;
            reset_value : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));

    END COMPONENT;

    TYPE Dmemory_type IS ARRAY(0 TO (2 ** 20) - 1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL data_memory : Dmemory_type;
    -- signal empty,one :  std_logic_vector(31 downto 0);
    SIGNAL out_SP, out_SP_in, reset_val : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    -- begin with reset --> then enable
    -- empty <= (OTHERS=>'0');
    -- one <= (OTHERS=>'1');

    reset_val <= "00000000000100000000000000000000";
    SP : dff PORT MAP(Clk, Rst, enable, reset_val, out_SP_in, out_SP);

    PROCESS (Clk)
    BEGIN
        IF (rising_edge(Clk)) THEN
            -- push
            IF (OP = "01100") THEN
                --dec SP
                out_SP_in <= STD_LOGIC_VECTOR(unsigned(out_SP_in) - 1);

                --put in memory Rdst value
                data_memory(to_integer(unsigned(out_SP_in(19 DOWNTO 0)))) <= Write_data;
                empty_stack <= '0';

                --pop
            ELSIF (OP = "01101") THEN
                --check empty stack
                IF (out_SP = reset_val) THEN
                    empty_stack <= '1';
                ELSE
                    --update read data(R[Rdst])
                    Read_data <= data_memory(to_integer(unsigned(out_SP(19 DOWNTO 0))));
                    --inc SP
                    out_SP_in <= STD_LOGIC_VECTOR(unsigned(out_SP_in) + 1);
                    empty_stack <= '0';
                END IF;

                --LDM
            ELSIF (OP = "10000") THEN
                Read_data <= Write_data;

                --LDD
            ELSIF (OP = "10010") THEN
                --Write_data: R[Rsrc1], Read_data: R[Rdst], Address: aluRes
                --R[ Rdst ] ← M[R[ Rsrc] + offset]; 
                Read_data <= data_memory(to_integer(unsigned(Write_data) + unsigned(Address)));

                --STD
            ELSIF (OP = "10011") THEN
                --Write_data: R[Rsrc1], Address: aluRes, Rscr2: R[ Rsrc2]
                --M[R[ Rsrc2] + offset] ←R[Rsrc1];  
                data_memory(to_integer(unsigned(Rscr2) + unsigned(Address))) <= Write_data;

            END IF;

        END IF;
    END PROCESS;

END a_Dmemory;