library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPS_LIB.all;

entity alu_tb is
end alu_tb;

architecture TB of alu_tb is

    component alu

        generic (
            WIDTH : positive := 32
            );
        port (
           i_opcode : in std_logic_vector(5 downto 0);

        -- IR Shift Control Bits[10:6]
        i_ir_shft : in std_logic_vector(4 downto 0);

        -- Inputs to be operated on by ALU
        i_A : in std_logic_vector(width-1 downto 0);
        i_B : in std_logic_vector(width-1 downto 0);

        -- ++++++++++++ Outputs ++++++++++++++++
        -- Alu Result 
        o_result    : out std_logic_vector(width-1 downto 0);
        o_result_hi : out std_logic_vector(width-1 downto 0);

        -- Branch Taken
        o_branch_taken : out std_logic
            );

    end component;

    constant WIDTH  : positive                     := 32;
    signal i_opcode   : std_logic_vector(5 downto 0) := (others => '0');
    signal i_ir_shft   : std_logic_vector(4 downto 0) := (others => '0');
    signal i_A      : std_logic_vector(width-1 downto 0)  := (others => '0');
    signal i_B    : std_logic_vector(WIDTH-1 downto 0)  := (others => '0');

    signal o_result : std_logic_vector(width-1 downto 0);
    signal o_result_hi: std_logic_vector(width-1 downto 0);
    signal o_branch_taken: std_logic;

begin  -- TB

    UUT : alu
        generic map (WIDTH => WIDTH)
        port map (
         i_opcode=> i_opcode,
    	 i_ir_shft=> i_ir_shft,
   	 i_A => i_A,
    	 i_B => i_B,
       o_result=> o_result,
      o_result_hi=> o_result_hi,
      o_branch_taken => o_branch_taken      );

    process
    begin

        -- test 10+15 (no overflow)
        i_opcode    <= ALU_OP_ADDU;
        i_A <= conv_std_logic_vector(10, i_A'length);
        i_B <= conv_std_logic_vector(15, i_B'length);
        wait for 40 ns;
        assert(o_result = conv_std_logic_vector(25, o_result'length)) report "Error : 10+15 = " & integer'image(conv_integer(o_result)) & " instead of 25" severity warning;
      

  -- test 25-10 (no overflow)
        i_opcode    <= ALU_OP_SUBU;
        i_A <= conv_std_logic_vector(25, i_A'length);
        i_B <= conv_std_logic_vector(10, i_B'length);
        wait for 40 ns;
        assert(o_result = conv_std_logic_vector(15, o_result'length)) report "Error : 25-15 = " & integer'image(conv_integer(o_result)) & " instead of 15" severity warning;




-- test 10*-4 (no overflow)
        i_opcode    <= ALU_OP_MULT;
        i_A <= conv_std_logic_vector(10, i_A'length);
        i_B <= conv_std_logic_vector(-4, i_B'length);
        wait for 40 ns;
        assert(o_result = conv_std_logic_vector(-40, o_result'length)) report "Error : 10*-4 = " & integer'image(conv_integer(o_result)) & " instead of -40" severity warning;

-- mult (unsigned) of 65536 * 131072. Make sure to show both the Result and Result Hi
        i_opcode    <= ALU_OP_MULTU;
        i_A <= conv_std_logic_vector(65536, i_A'length);
        i_B <= conv_std_logic_vector(131072, i_B'length);
        wait for 40 ns;
        


--  and of 0x0000FFFF and 0xFFFF1234
        i_opcode    <= ALU_OP_AND;
        i_A <= conv_std_logic_vector(65535, i_A'length);
        i_B <= "11111111111111110001001000110100";
        wait for 40 ns;
     assert(o_result = conv_std_logic_vector(4660, o_result'length)) report "Error : AND = " & integer'image(conv_integer(o_result)) & " instead of 4660" severity warning;


-- shift right logical of 0x0000000F by 4
        i_opcode    <= ALU_OP_SRL;
	i_ir_shft<= "00100";
        i_A <= conv_std_logic_vector(15, i_A'length);
        i_B <= conv_std_logic_vector(0, i_B'length);
        wait for 40 ns;
     assert(o_result = conv_std_logic_vector(0, o_result'length)) report "Error : SRL= " & integer'image(conv_integer(o_result)) & " instead of 0" severity warning;



-- shift right arithmetic of 0xF0000008 by 1
        i_opcode    <= ALU_OP_SRA;
	i_ir_shft<= "00001";
        i_A <= "11110000000000000000000000001000";
        i_B <= conv_std_logic_vector(0, i_B'length);
        wait for 40 ns;
    


--shift right arithmetic of 0x00000008 by 1
        i_opcode    <= ALU_OP_SRA;
	i_ir_shft<= "00001";
        i_A <= "00000000000000000000000000001000";
        i_B <= conv_std_logic_vector(0, i_B'length);
        wait for 40 ns;
    



--   set on less than using 10 and 15
        i_opcode    <= ALU_OP_SLTU;
        i_A <= conv_std_logic_vector(10, i_A'length);
        i_B <= conv_std_logic_vector(15, i_B'length);
        wait for 40 ns;
     assert(o_result = conv_std_logic_vector(1, o_result'length)) report "Error : SLTU = " & integer'image(conv_integer(o_result)) & " instead of 1" severity warning;

--   set on less than using 15 and 10
        i_opcode    <= ALU_OP_SLTU;
        i_A <= conv_std_logic_vector(15, i_A'length);
        i_B <= conv_std_logic_vector(10, i_B'length);
        wait for 40 ns;
     assert(o_result = conv_std_logic_vector(0, o_result'length)) report "Error : SLTU = " & integer'image(conv_integer(o_result)) & " instead of 0" severity warning;

--   Branch Taken output = ?0? for for 5 <= 0
        i_opcode    <= ALU_OP_BLEZ;
        i_A <= conv_std_logic_vector(5, i_A'length);
        i_B <= conv_std_logic_vector(-2, i_B'length);
        wait for 40 ns;
     assert(o_result = conv_std_logic_vector(0, o_result'length)) report "Error : BLEZ = " & integer'image(conv_integer(o_result)) & " instead of 0" severity warning;



 --Branch Taken output = ?1? for for 5 > 0

        i_opcode    <= ALU_OP_BGTZ;
        i_A <= conv_std_logic_vector(5, i_A'length);
        i_B <= conv_std_logic_vector(-2, i_B'length);
        wait for 40 ns;
     assert(o_result = conv_std_logic_vector(1, o_result'length)) report "Error : BGTZ = " & integer'image(conv_integer(o_result)) & " instead of 1" severity warning;








report "SIM DONEEE!";


        wait;

    end process;



end TB;
