
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Dmemory IS
	PORT(
        -- MemRead, MemWrite,
        Clk,Rst,enable : IN std_logic;
        OP : IN std_logic_vector(4 DOWNTO 0);
		-- Address : IN  std_logic_vector(19 DOWNTO 0);
		Write_data : IN std_logic_vector(15 DOWNTO 0);
		Read_data : OUT  std_logic_vector(15 DOWNTO 0);
        empty_stack	: OUT std_logic
        );
END ENTITY Dmemory ;

ARCHITECTURE a_Dmemory OF Dmemory IS

    component dff IS
    PORT(clk,rst,en : IN std_logic;
        reset_value: IN std_logic_vector(n - 1 DOWNTO 0);
        d : IN std_logic_vector(n - 1 DOWNTO 0);
        q : OUT std_logic_vector(n - 1 DOWNTO 0));

    end component;

	TYPE Dmemory_type IS ARRAY(0 TO (2**20)-1) OF std_logic_vector(15 DOWNTO 0);
	SIGNAL data_memory : Dmemory_type;
    signal empty,one,ze :  std_logic_vector(31 downto 0);
    signal out_SP, out_SP_in,reset_val : std_logic_vector(31 DOWNTO 0);

	
	BEGIN 

        -- begin with reset --> then enable
        empty <= (OTHERS=>'0');
        one <= (OTHERS=>'1');
        ze <= (OTHERS=>'U');
        reset_val <= empty(11 downto 0) & one(19 downto 0);
        SP: dff port map(Clk,Rst,enable,reset_val,out_SP_in,out_SP);

        process(Clk)
        BEGIN
        IF(rising_edge(Clk)) THEN
            -- push
            IF(OP = "01100")THEN 
                --put in memory Rdst value
                data_memory(to_integer(unsigned(out_SP_in(19 downto 0)))) <= Write_data; 
                --dec SP
                out_SP_in <= std_logic_vector( unsigned(out_SP_in) -1); 
                empty_stack <= '0';

            --pop
            elsif (OP = "01101") then 
                --check empty stack
                if (out_SP = ze) then
                    empty_stack <= '1';
                else
                    --update read data(R[Rdst])
                    Read_data <= data_memory(to_integer(unsigned(out_SP_in(19 downto 0))));
                    --inc SP
                    out_SP_in <= std_logic_vector( unsigned(out_SP_in) +1); 
                    empty_stack <= '0';
                end if ;
            elsif (OP = "10000") then 
                Read_data <= Write_data;
            END IF;

        end if;
        end process;

END a_Dmemory ;
