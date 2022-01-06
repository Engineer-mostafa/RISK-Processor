
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY memory IS
	PORT(
		address : IN  std_logic_vector(31 DOWNTO 0);--PC is the address 
		instruction : OUT std_logic_vector(31 DOWNTO 0);
		-- county: OUT std_logic_vector(3 DOWNTO 0);
		OP : OUT std_logic_vector(1 DOWNTO 0));
END ENTITY memory ;

ARCHITECTURE a_memory OF memory IS

	TYPE memory_type IS ARRAY(0 TO (2**20)) OF std_logic_vector(15 DOWNTO 0);
	SIGNAL inst_memory : memory_type;
	SIGNAL temp : std_logic_vector(31 DOWNTO 0);
	-- SIGNAL  countery : std_logic_vector(3 downto 0) := "0000";

	
	BEGIN 

		instruction(31 downto 16) <= inst_memory(to_integer(unsigned(address(19 downto 0))));
		instruction (15 downto 0) <= inst_memory(to_integer(unsigned(address(19 downto 0))+1));--take the next 16 bit
		
		temp(31 downto 16) <= inst_memory(to_integer(unsigned(address(19 downto 0))));

		-- process (temp)--trigger on instruction value change
		-- begin
			
		-- 	-- countery <= std_logic_vector(unsigned(countery) + 1) ;
		-- 	-- county <= countery;

		-- 	if temp(31 downto 30) = "10" then 
		-- 		instruction (15 downto 0) <= inst_memory(to_integer(unsigned(address(19 downto 0))+1));--take the next 16 bit
				
		-- 	else 
		-- 		instruction(15 downto 0) <= (OTHERS=>'Z');
			
		-- 	end if;

			OP <= temp(31 downto 30);

		-- end process;
 
END a_memory ;
