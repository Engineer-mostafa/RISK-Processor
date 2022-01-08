LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY register_file IS
    GENERIC (n : INTEGER := 16); -- For register size
    PORT (
        clk, rst : IN STD_LOGIC;
        RegWrite : IN STD_LOGIC;
        in_signal : IN STD_LOGIC;
        out_signal : IN STD_LOGIC;
        in_port : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        in_data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        out_port : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        read_reg1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_reg2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_reg3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- For the Rdst read
        write_reg : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        read_data_1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        read_data_2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        read_data_3 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        ccr_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        ccr_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        aluOP : in STD_LOGIC;
        sp_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        int_signal : IN STD_LOGIC; -- Used to store the Flags in a special register in case of INT instruction
        rti_signal : IN STD_LOGIC -- Used to restore Flags from the special register in case of RTI instruction
    );
END register_file;

ARCHITECTURE arch1 OF register_file IS

    COMPONENT dff_fedge IS
        GENERIC (n : INTEGER := 16);
        PORT (
            clk, rst, en : IN STD_LOGIC;
            --reset_value: IN std_logic_vector(n - 1 DOWNTO 0); --reem
            --edge_signal: IN std_logic; --0:rise, 1:fall --reem
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT mux_8x1 IS
        GENERIC (n : INTEGER := 16);
        PORT (
            in1 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input1
            in2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input2
            in3 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input3
            in4 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input4
            in5 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input5
            in6 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input6
            in7 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input7
            in8 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- mux input8
            sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- selection line
            dataout : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)); -- output data
    END COMPONENT;

    COMPONENT tristate_buffer IS
        GENERIC (n : INTEGER := 16);
        PORT (
            en : IN STD_LOGIC;
            p : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT decoder3x8 IS
        PORT (
            ren : IN STD_LOGIC; -- Or wen
            sel : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            en : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
    END COMPONENT;

    SIGNAL read_ens1, read_ens2, read_ens3, write_ens : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL p0, p1, p2, p3, p4, p5, p6, p7 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- 
    SIGNAL q0, q1, q2, q3, q4, q5, q6, q7 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- The Current Value of The Registers
    SIGNAL q : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL alwayson : STD_LOGIC := '1';
    SIGNAL andeden0, andeden1, andeden2, andeden3, andeden4, andeden5, andeden6, andeden7 : STD_LOGIC; -- Used to write data to the correct register
    SIGNAL ccr_rti, ccr_inner : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL not_rti_signal : STD_LOGIC;

BEGIN

    ccr : dff_fedge GENERIC MAP(4) PORT MAP(clk, rst, aluOP, ccr_in, ccr_inner);
    ccrsaved : dff_fedge GENERIC MAP(4) PORT MAP(clk, rst, int_signal, ccr_in, ccr_rti);
    sp : dff_fedge GENERIC MAP(32) PORT MAP(clk, rst, alwayson, sp_in, sp_out);
    reg0 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden0, q, q0);
    reg1 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden1, q, q1);
    reg2 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden2, q, q2);
    reg3 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden3, q, q3);
    reg4 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden4, q, q4);
    reg5 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden5, q, q5);
    reg6 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden6, q, q6);
    reg7 : dff_fedge GENERIC MAP(n) PORT MAP(clk, rst, andeden7, q, q7);
    read_decoder_1 : decoder3x8 PORT MAP(alwayson, read_reg1, read_ens1);
    read_decoder_2 : decoder3x8 PORT MAP(alwayson, read_reg2, read_ens2);
    read_decoder_3 : decoder3x8 PORT MAP(alwayson, read_reg3, read_ens3);
    write_decoder : decoder3x8 PORT MAP(alwayson, write_reg, write_ens);

    -- For CCR Register
    triCCRrti : tristate_buffer GENERIC MAP(4) PORT MAP(rti_signal, ccr_rti, ccr_out);
    triCCR : tristate_buffer GENERIC MAP(4) PORT MAP(not_rti_signal, ccr_inner, ccr_out);

    -- For Register Read 1 (Rsrc1)
    tri01 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(0), p0, read_data_1);
    tri11 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(1), p1, read_data_1);
    tri21 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(2), p2, read_data_1);
    tri31 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(3), p3, read_data_1);
    tri41 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(4), p4, read_data_1);
    tri51 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(5), p5, read_data_1);
    tri61 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(6), p6, read_data_1);
    tri71 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens1(7), p7, read_data_1);

    -- For Register Read 2 (Rsrc2)
    tri02 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(0), p0, read_data_2);
    tri12 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(1), p1, read_data_2);
    tri22 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(2), p2, read_data_2);
    tri32 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(3), p3, read_data_2);
    tri42 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(4), p4, read_data_2);
    tri52 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(5), p5, read_data_2);
    tri62 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(6), p6, read_data_2);
    tri72 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens2(7), p7, read_data_2);

    -- For Register Read 3 (Rdst)
    tri03 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(0), p0, read_data_3);
    tri13 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(1), p1, read_data_3);
    tri23 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(2), p2, read_data_3);
    tri33 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(3), p3, read_data_3);
    tri43 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(4), p4, read_data_3);
    tri53 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(5), p5, read_data_3);
    tri63 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(6), p6, read_data_3);
    tri73 : tristate_buffer GENERIC MAP(n) PORT MAP(read_ens3(7), p7, read_data_3);

    PROCESS (clk)
    BEGIN


        IF(out_signal='1') THEN
                out_port <= write_data;
           END IF;
        IF (in_signal = '1') THEN
            in_data <= in_port;
        END IF;
      
    END PROCESS;


    andeden0 <= (write_ens(0) AND RegWrite);
    andeden1 <= (write_ens(1) AND RegWrite);
    andeden2 <= (write_ens(2) AND RegWrite);
    andeden3 <= (write_ens(3) AND RegWrite);
    andeden4 <= (write_ens(4) AND RegWrite);
    andeden5 <= (write_ens(5) AND RegWrite);
    andeden6 <= (write_ens(6) AND RegWrite);
    andeden7 <= (write_ens(7) AND RegWrite);
    not_rti_signal <= NOT(rti_signal);
    q <= write_data;
    p0 <= q0;
    p1 <= q1;
    p2 <= q2;
    p3 <= q3;
    p4 <= q4;
    p5 <= q5;
    p6 <= q6;
    p7 <= q7;

END arch1;

