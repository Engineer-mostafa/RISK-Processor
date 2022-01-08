
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY memory IS
	PORT(
		rst: IN std_logic;
		address : IN  std_logic_vector(31 DOWNTO 0);--PC is the address 
		instruction : OUT std_logic_vector(31 DOWNTO 0);
		pcReset : OUT  std_logic_vector(31 DOWNTO 0);
		-- county: OUT std_logic_vector(3 DOWNTO 0);
		OP : OUT std_logic_vector(1 DOWNTO 0));
END ENTITY memory ;

ARCHITECTURE a_memory OF memory IS

	TYPE memory_type IS ARRAY(0 TO (2**20)-1) OF std_logic_vector(15 DOWNTO 0);
	SIGNAL inst_memory : memory_type;
	SIGNAL temp,temp1 : std_logic_vector(31 DOWNTO 0);
	-- SIGNAL  countery : std_logic_vector(3 downto 0) := "0000";

	
	BEGIN 

		temp(31 downto 16) <= inst_memory(to_integer(unsigned(address(19 downto 0))));
		temp(15 downto 0) <= inst_memory(to_integer(unsigned(address(19 downto 0)))+1);

		temp1(31 downto 16) <= inst_memory(to_integer(unsigned(address(19 downto 0)))+1);
		temp1(15 downto 0) <= inst_memory(to_integer(unsigned(address(19 downto 0))));

		
		process (temp)--trigger on instruction value change
		begin
			
			if(rst='1' ) then
				pcReset <= std_logic_vector( unsigned(temp1) -1);
				
				instruction(15 downto 0) <= inst_memory(to_integer(unsigned(temp(31 downto 11)))+1);
				instruction (31 downto 16) <= inst_memory(to_integer(unsigned(temp(31 downto 11))));--take the next 16 bit
				
			else 
				pcReset <=address;
				
				instruction(15 downto 0) <= inst_memory(to_integer(unsigned(address(19 downto 0)))+1);
				instruction (31 downto 16) <= inst_memory(to_integer(unsigned(address(19 downto 0))));--take the next 16 bit
				
			end if;
			
			OP <= temp(31 downto 30);

		end process;
 
END a_memory ;
