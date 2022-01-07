library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY register_file IS
GENERIC ( n : integer :=16 ); -- For register size
PORT (
    clk,rst: IN std_logic;
    RegWrite: IN std_logic;
    in_signal: IN std_logic;
    out_signal: IN std_logic;
    in_port: IN std_logic_vector(n-1 DOWNTO 0);
    in_data: OUT std_logic_vector(n-1 DOWNTO 0);
    out_port: OUT std_logic_vector(n-1 DOWNTO 0);
    read_reg1: IN std_logic_vector(2 DOWNTO 0);
    read_reg2: IN std_logic_vector(2 DOWNTO 0);
    read_reg3: IN std_logic_vector(2 DOWNTO 0); -- For the Rdst read
    write_reg: IN std_logic_vector(2 DOWNTO 0);
    write_data: IN std_logic_vector(n-1 DOWNTO 0);
    read_data_1: OUT std_logic_vector(n-1 DOWNTO 0);
    read_data_2: OUT std_logic_vector(n-1 DOWNTO 0);
    read_data_3: OUT std_logic_vector(n-1 DOWNTO 0);
    ccr_in: IN std_logic_vector(3 DOWNTO 0);
    ccr_out: OUT std_logic_vector(3 DOWNTO 0);
    sp_in: IN std_logic_vector(31 DOWNTO 0);
    sp_out: OUT std_logic_vector(31 DOWNTO 0);
    int_signal: IN std_logic; -- Used to store the Flags in a special register in case of INT instruction
    rti_signal: IN std_logic -- Used to restore Flags from the special register in case of RTI instruction
);
END register_file;

ARCHITECTURE arch1 OF register_file IS

    COMPONENT dff_fedge IS
    GENERIC ( n : integer :=16 );
    PORT(   clk,rst,en : IN std_logic;
            --reset_value: IN std_logic_vector(n - 1 DOWNTO 0); --reem
            --edge_signal: IN std_logic; --0:rise, 1:fall --reem
            d : IN std_logic_vector(n - 1 DOWNTO 0);
            q : OUT std_logic_vector(n - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT mux_8x1 IS
    GENERIC ( n : integer :=16 );
    Port ( 
        in1 : in std_logic_vector(n-1 DOWNTO 0); -- mux input1
        in2 : in std_logic_vector(n-1 DOWNTO 0); -- mux input2
        in3 : in std_logic_vector(n-1 DOWNTO 0); -- mux input3
        in4 : in std_logic_vector(n-1 DOWNTO 0); -- mux input4
        in5 : in std_logic_vector(n-1 DOWNTO 0); -- mux input5
        in6 : in std_logic_vector(n-1 DOWNTO 0); -- mux input6
        in7 : in std_logic_vector(n-1 DOWNTO 0); -- mux input7
        in8 : in std_logic_vector(n-1 DOWNTO 0); -- mux input8
        sel : in std_logic_vector(2 downto 0); -- selection line
        dataout : out std_logic_vector(n-1 DOWNTO 0)); -- output data
    END COMPONENT;

    COMPONENT tristate_buffer IS
    GENERIC (n : integer:= 16);
    PORT(   en: IN std_logic;
        p: IN std_logic_vector (n-1 DOWNTO 0);
        q: OUT std_logic_vector (n-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT decoder3x8 IS
    PORT(   ren: IN std_logic;			-- Or wen
        sel: IN std_logic_vector (2 DOWNTO 0);
        en: OUT std_logic_vector (7 DOWNTO 0));
    END COMPONENT;

    SIGNAL read_ens1, read_ens2, read_ens3, write_ens: std_logic_vector(7 DOWNTO 0);
    SIGNAL p0,p1,p2,p3,p4,p5,p6,p7: std_logic_vector(n-1 DOWNTO 0); -- 
    SIGNAL q0,q1,q2,q3,q4,q5,q6,q7: std_logic_vector(n-1 DOWNTO 0); -- The Current Value of The Registers
    SIGNAL q: std_logic_vector(n-1 DOWNTO 0);
    SIGNAL alwayson: std_logic := '1';
    SIGNAL andeden0,andeden1,andeden2,andeden3,andeden4,andeden5,andeden6,andeden7: std_logic; -- Used to write data to the correct register
    SIGNAL ccr_rti,ccr_inner: std_logic_vector(3 DOWNTO 0);
    SIGNAL not_rti_signal: std_logic;

    BEGIN
    
        ccr: dff_fedge GENERIC MAP(4) PORT MAP(clk, rst, alwayson, ccr_in, ccr_inner);
        ccrsaved: dff_fedge GENERIC MAP(4) PORT MAP(clk, rst, int_signal, ccr_in, ccr_rti);
        sp: dff_fedge GENERIC MAP(32) PORT MAP(clk, rst, alwayson, sp_in, sp_out);
        

        reg0: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden0, q, q0);
        reg1: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden1, q, q1);
        reg2: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden2, q, q2);
        reg3: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden3, q, q3);
        reg4: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden4, q, q4);
        reg5: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden5, q, q5);
        reg6: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden6, q, q6);
        reg7: dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden7, q, q7);

        
        read_decoder_1: decoder3x8 PORT MAP(alwayson,read_reg1,read_ens1);
        read_decoder_2: decoder3x8 PORT MAP(alwayson,read_reg2,read_ens2);
        read_decoder_3: decoder3x8 PORT MAP(alwayson,read_reg3,read_ens3);
        write_decoder: decoder3x8 PORT MAP(alwayson,write_reg,write_ens);
        
        -- For CCR Register
        triCCRrti: tristate_buffer GENERIC MAP(4) PORT MAP(rti_signal, ccr_rti, ccr_out);
        triCCR: tristate_buffer GENERIC MAP(4) PORT MAP(not_rti_signal, ccr_inner, ccr_out);
        
        -- For Register Read 1 (Rsrc1)
        tri01: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(0), p0, read_data_1);
        tri11: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(1), p1, read_data_1);
        tri21: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(2), p2, read_data_1);
        tri31: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(3), p3, read_data_1);
        tri41: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(4), p4, read_data_1);
        tri51: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(5), p5, read_data_1);
        tri61: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(6), p6, read_data_1);
        tri71: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(7), p7, read_data_1);

        -- For Register Read 2 (Rsrc2)
        tri02: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(0), p0, read_data_2);
        tri12: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(1), p1, read_data_2);
        tri22: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(2), p2, read_data_2);
        tri32: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(3), p3, read_data_2);
        tri42: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(4), p4, read_data_2);
        tri52: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(5), p5, read_data_2);
        tri62: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(6), p6, read_data_2);
        tri72: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(7), p7, read_data_2);

        -- For Register Read 3 (Rdst)
        tri03: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(0), p0, read_data_3);
        tri13: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(1), p1, read_data_3);
        tri23: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(2), p2, read_data_3);
        tri33: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(3), p3, read_data_3);
        tri43: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(4), p4, read_data_3);
        tri53: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(5), p5, read_data_3);
        tri63: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(6), p6, read_data_3);
        tri73: tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(7), p7, read_data_3);

        PROCESS(clk) 
        BEGIN
            -- IF(falling_edge(clk) AND RegWrite='1') THEN
            --     reglist(to_integer(unsigned(reg_write_dest))) <= write_data;
            -- END IF;
            -- IF(rising_edge(clk)) THEN
            --     p0 <= q0;
            --     p1 <= q1;
            --     p2 <= q2;
            --     p3 <= q3;
            --     p4 <= q4;
            --     p5 <= q5;
            --     p6 <= q6;
            --     p7 <= q7;
            -- END IF;
            IF(falling_edge(clk) AND out_signal='1') THEN
                out_port <= write_data;
            END IF;
            IF(rising_edge(clk) AND in_signal='1') THEN
                in_data <= in_port;
            END IF;
        END PROCESS;

    --read_data_1 <= reglist(to_integer(unsigned(reg_read_addr_1)));
    --read_data_2 <= reglist(to_integer(unsigned(reg_read_addr_2)));

    p0 <= q0;
    p1 <= q1;
    p2 <= q2;
    p3 <= q3;
    p4 <= q4;
    p5 <= q5;
    p6 <= q6;
    p7 <= q7;

    andeden0 <= (write_ens(0) and RegWrite);
    andeden1 <= (write_ens(1) and RegWrite);
    andeden2 <= (write_ens(2) and RegWrite);
    andeden3 <= (write_ens(3) and RegWrite);
    andeden4 <= (write_ens(4) and RegWrite);
    andeden5 <= (write_ens(5) and RegWrite);
    andeden6 <= (write_ens(6) and RegWrite);
    andeden7 <= (write_ens(7) and RegWrite);
    not_rti_signal <= not(rti_signal);
    q <= write_data;

END arch1;
