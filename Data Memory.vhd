
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Dmemory IS
GENERIC ( 
	n : integer :=2
	); 
	PORT(
        -- MemRead, MemWrite,
        Clk,Rst,enable : IN std_logic;
        OP : IN std_logic_vector(4 DOWNTO 0);
		Write_data,Address,Rscr2 : IN std_logic_vector(15 DOWNTO 0);
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
    -- signal empty,one :  std_logic_vector(31 downto 0);
    signal out_SP, out_SP_in,reset_val : std_logic_vector(31 DOWNTO 0);

	
	BEGIN 

        -- begin with reset --> then enable
        -- empty <= (OTHERS=>'0');
        -- one <= (OTHERS=>'1');
        
        reset_val <= "00000000000100000000000000000000";
        SP: dff port map(Clk,Rst,enable,reset_val,out_SP_in,out_SP);

        process(Clk)
        BEGIN
        IF(rising_edge(Clk)) THEN
            -- push
            IF(OP = "01100")THEN 
                --dec SP
                out_SP_in <= std_logic_vector( unsigned(out_SP_in) -1); 

                --put in memory Rdst value
                data_memory(to_integer(unsigned(out_SP_in(19 downto 0)))) <= Write_data; 
                empty_stack <= '0';

            --pop
            elsif (OP = "01101") then 
                --check empty stack
                if (out_SP = reset_val) then
                    empty_stack <= '1';
                else
                    --update read data(R[Rdst])
                    Read_data <= data_memory(to_integer(unsigned(out_SP(19 downto 0))));
                    --inc SP
                    out_SP_in <= std_logic_vector( unsigned(out_SP_in) +1); 
                    empty_stack <= '0';
                end if ;

            --LDM
            elsif (OP = "10000") then 
                Read_data <= Write_data;

            --LDD
            elsif (OP = "10010") then 
                --Write_data: R[Rsrc1], Read_data: R[Rdst], Address: aluRes
                --R[ Rdst ] ← M[R[ Rsrc] + offset]; 
                Read_data <= data_memory(to_integer(unsigned(Write_data)+unsigned(Address)));
            
            --STD
            elsif (OP = "10011") then 
                --Write_data: R[Rsrc1], Address: aluRes, Rscr2: R[ Rsrc2]
                --M[R[ Rsrc2] + offset] ←R[Rsrc1];  
                data_memory(to_integer(unsigned(Rscr2)+unsigned(Address))) <= Write_data;
            
            END IF;

        end if;
        end process;

END a_Dmemory ;
