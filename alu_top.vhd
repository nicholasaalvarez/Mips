library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity alu_top is

  generic (
              WIDTH : positive := 32
          );
port (

		-- Clocks and Resets
         clk: in std_logic;
         rst: in std_logic;

        -- ++++++++++++ Inputs ++++++++++++++++
        i_opcode        : in std_logic_vector(5 downto 0);
        i_ir_shift      : in std_logic_vector(4 downto 0);

        i_operand_A     : in std_logic_vector(width-1 downto 0);
        i_operand_B     : in std_logic_vector(width-1 downto 0);

        -- ++++++++++++ Outputs ++++++++++++++++
        o_alu_result    : out std_logic_vector(width-1 downto 0);
        o_alu_out_reg   : out std_logic_vector(width-1 downto 0);

        -- This Mux selects the following:
        -- 0:ALU OUT   1:LO Register   2:HI Register
        o_alu_lo_hi_reg : out std_logic_vector(width-1 downto 0);

        -- Branch Taken
        o_branch_taken   : out std_logic

     );
end alu_top;
	
architecture logic of alu_top is	

   -- Signal Declarations 
   signal hi_en, lo_en : std_logic;
   signal result_hi    : std_logic_vector(width-1 downto 0);

   signal mux_sel1     : std_logic;
   signal mux_sel0     : std_logic;
   signal mux_sel      : std_logic_vector(1 downto 0);
   signal alu_result   : std_logic_vector(width-1 downto 0);
   signal alu_out_reg  : std_logic_vector(width-1 downto 0);
   signal hi_reg       : std_logic_vector(width-1 downto 0);
   signal lo_reg       : std_logic_vector(width-1 downto 0);

   --------------------------------------------------------
   --               Component Declarations 
   --------------------------------------------------------
   component alu port 
   ( 
      -- ++++++++++++ Inputs +++++++++++++++++
      -- Opcode and IR Shift   
      i_opcode : in std_logic_vector(5 downto 0);
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

begin

   --------------------------------------------------------
   --             Instantiate all Components 
   --------------------------------------------------------
   alu_inst: alu PORT MAP (
                             i_opcode       => i_opcode,
                             i_ir_shft      => i_ir_shift,
                             i_A            => i_operand_A, 
                             i_B            => i_operand_B, 

                             o_result       => alu_result,
                             o_result_hi    => result_hi, 
                             o_branch_taken => o_branch_taken 

                          );


   -- Generate outputs 
   o_alu_out_reg <= alu_out_reg;
   o_alu_result  <= alu_result;

   -- Generate Mux Select
   mux_sel1 <= '1' when (i_opcode = ALU_OP_MFHI) else '0';
   mux_sel0 <= '1' when (i_opcode = ALU_OP_MFLO) else '0';

   -- Concat MuxSel
   mux_sel <= mux_sel1 & mux_sel0;

   -- Generate Write Enables for Hi and Lo Registers
   hi_en <= '1' when ( i_opcode = ALU_OP_MULT) or (i_opcode = ALU_OP_MULTU) else '0';
   lo_en <= '1' when ( i_opcode = ALU_OP_MULT) or (i_opcode = ALU_OP_MULTU) else '0';

   
    -- Store ALU output "ALU_OUT" Register
    process(clk, rst)
    begin
       if (rst = '1') then
          -- Reset Register 
          alu_out_reg <= (others => '0');
       elsif( rising_edge(clk) ) then
          -- Register ALU Output 
          alu_out_reg <= alu_result; 
  	   end if;
    end process;


    -- Store "LO" Register
    process(clk, rst)
    begin
       if (rst = '1') then
          -- Reset Register 
          lo_reg <= (others => '0');
       elsif( rising_edge(clk) ) then
          -- Check if Opcode requires storage of LO Register
          if ( lo_en = '1' ) then
             -- Write LO Register 
             lo_reg <= alu_result; 
          end if;
  	   end if;
    end process;


    -- Store "HI" Register
    process(clk, rst)
    begin
       if (rst = '1') then
          -- Reset Register 
          hi_reg <= (others => '0');
       elsif( rising_edge(clk) ) then
          -- Check if Opcode requires storage of HI Register
          if ( hi_en = '1' ) then
             -- Write HI Register 
             hi_reg <= result_hi; 
          end if;
  	   end if;
    end process;


   -- Output MUX for ALU_OUT_REG, LO_REG or HI_REG
   process(mux_sel,alu_out_reg,lo_reg,hi_reg)
   begin
      case mux_sel is
         when "10" =>
             o_alu_lo_hi_reg  <= hi_reg;   

          when "01" =>
             o_alu_lo_hi_reg  <= lo_reg;   

          when others =>
             o_alu_lo_hi_reg  <= alu_out_reg;   
       end case; 
    end process;


end logic;
