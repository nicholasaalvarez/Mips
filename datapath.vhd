library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity datapath is
port (
        -- ++++++++++++ Inputs ++++++++++++++++
        clk             : in std_logic;
        rst             : in std_logic;
        pc_load   : in std_logic;
		  IorD            : in std_logic;
		  Memread         : in std_logic;
		  memwrite        : in std_logic;
		  memtoreg        : in std_logic;
		  IRwrite         : in std_logic;
		  Regdest         : in std_logic;
		  Regwrite        : in std_logic;
		  ALUsrcA         : in std_logic;
		  ALusrcB         : in std_logic_vector(1 downto 0);
		  ALUOp           : in std_logic_vector(5 downto 0);
		  pcsource        : in std_logic_vector(1 downto 0);
		  issigned        : in std_logic;
		  JumpandLink     : in std_logic;
		 -- Inputs from Switches 
         -- Switches Bits[8:0]
         i_sw_inport_data : in std_logic_vector(8 downto 0);
         -- Swithc Bit[9]
         i_sw_inport_sel  : in std_logic;
         -- Button (used to write inport data)
         i_sw_inport_wr   : in std_logic;
		  

        -- ++++++++++++ Outputs ++++++++++++++++
		  branch_taken: out std_logic;
		  IR : out std_logic_vector(31 downto 0);
		  outport: out std_logic_vector(31 downto 0)
		  

     );
end datapath;
	
architecture logic of datapath is	

   -- Signal Declarations 
signal pc_out : std_logic_vector(31 downto 0);
signal mux21_out: std_logic_vector(31 downto 0);
signal memout: std_logic_vector(31 downto 0);
signal IR25_0: std_logic_vector(25 downto 0);
signal IR31_26: std_logic_vector(5 downto 0);
signal IR25_21: std_logic_vector(4 downto 0);
signal IR20_16: std_logic_vector(4 downto 0);
signal IR15_11: std_logic_vector(4 downto 0);
signal IR15_0: std_logic_vector(15 downto 0);
signal memoryRegOut: std_logic_vector(31 downto 0);
signal writeReg: std_logic_vector(4 downto 0);
signal writedata: std_logic_vector(31 downto 0);
signal InRegA : std_logic_vector( 31 downto 0);
signal InRegB : std_logic_vector( 31 downto 0);
signal Signextend_out : std_logic_vector(31 downto 0);
signal shiftleft2_out: std_logic_vector(31 downto 0);
signal RegA_out : std_logic_vector( 31 downto 0);
signal RegB_out : std_logic_vector( 31 downto 0);
signal Aluinput1 : std_logic_vector( 31 downto 0);
signal Aluinput2 : std_logic_vector( 31 downto 0);
signal Shiftleft_concat: std_logic_vector( 31 downto 0);
signal Alu_out_reg : std_logic_vector(31 downto 0);
signal Alu_result : std_logic_vector(31 downto 0);
signal mux31_out : std_logic_vector(31 downto 0);
signal alu_lo_hi_out : std_logic_vector(31 downto 0);

   --------------------------------------------------------
   --               Component Declarations 
   --------------------------------------------------------

begin

U_PC: entity work.pc port map(
rst => rst,
clk=> clk,
address_to_load=> mux31_out,
cntrl_in=> pc_load,
current_address=> pc_out


);


U_Mux21_1: entity work.mux21 
generic map( width=> 32)
port map(
 input0 =>pc_out,  
 input1=>Alu_out_reg,  
  sel =>  IorD, 
  output=> mux21_out 

);



U_MEMORY: entity work.Memory 
port map(
   -- Clocks and Resets
   clk=>clk,
   rst=>rst,
    
         -- PC (32-bit address)
   i_pc=> mux21_out,

         -- Inputs from Controller 
   i_mem_read=> Memread,  
   i_mem_write=> memwrite,

         -- Inputs from Switches 
         -- Switches Bits[8:0]
   i_sw_inport_data =>i_sw_inport_data,
         -- Swithc Bit[9]
   i_sw_inport_sel=>    i_sw_inport_sel,  
         -- Button (used to write inport data)
   i_sw_inport_wr =>    i_sw_inport_wr, 
     
         -- Input from Register File Register B
         -- Will be used to drive to Outport to LED's
   i_reg_b => RegB_out, 

         -- Memory outputs
    o_memout => memout,
    o_outport => outport

);

U_InstructionReg: entity work.instruction_reg
port map(
    clk=> clk,
    rst => rst,    
    memdata => memout,
    IRwrite=> IRwrite ,

    instr31_26=> IR31_26, 
    instr25_21 => IR25_21,
    instr20_16=> IR20_16,
    instr15_11 => IR15_11,
    instr25_0 => IR25_0,
    instr15_0 => IR15_0

);

U_MemoryDataReg: entity work.reg
generic map( width=> 32)
port map(
 clk=> clk,
 rst => rst,   
 input=> memout,  
 output=>memoryRegOut

);


U_Mux21_2: entity work.mux21 
generic map( width=> 5)
port map(
 input0=> IR20_16,  
 input1=> IR15_11,
  sel=>  Regdest,   
  output =>writeReg

);



U_Mux21_3: entity work.mux21 
generic map( width=> 32)
port map(
 input0 => alu_lo_hi_out, 
 input1=>memoryRegOut,  
  sel => memtoreg,   
  output=> writedata 

);


U_Registerfile: entity work.regfile
generic map( width=> 32)
port map(
  -- Clocks and Resets
        clk=>clk,
        rst=>rst,

        -- Read Port Address (selects 1 of 32 registers)
        i_rd_adrs1=> IR25_21,
        i_rd_adrs2=> IR20_16,

        -- Controller Signals 
        i_cntrl_reg_wr=> Regwrite,
        i_cntrl_jal=>JumpandLink,

        -- Write Port (writes 1 of 32 registers)
        i_wr_adrs=>writeReg,
        i_wr_data=>writedata,

        -- ++++++++++++ Outputs ++++++++++++++++
        -- Read Data 
        o_rd_data1=>InRegA,
        o_rd_data2=> InRegB


);

U_SignExtend: entity work.sign_extend
port map(
x=> IR15_0,
isSigned=> issigned,
y=>Signextend_out

);

U_REGA: entity work.reg
generic map( width=> 32)
port map(
 clk=> clk,   
 rst => rst,    
 input=> InRegA,  
 output=> RegA_out

);



U_REGB: entity work.reg
generic map( width=> 32)
port map(
 clk=> clk,   
 rst=> rst,    
 input=> inRegB,  
 output=> RegB_out

);

U_Shiftleft2: entity work.SHIFT_L2_32
port map(
input=>Signextend_out,
output=> shiftleft2_out

);

U_Mux21_4: entity work.mux21 
generic map( width=> 32)
port map(
 input0=> pc_out,   
 input1=> RegA_out, 
  sel => ALUsrcA,   
  output => Aluinput1

);


U_Mux41: entity work.mux41 
generic map( width=> 32)
port map(
 input0 => RegB_out, 
 input1 =>  std_logic_vector(to_unsigned(4,32)), 
input2=> Signextend_out, 
input3 => shiftleft2_out, 
   sel => ALUsrcB,   
   output =>Aluinput2

);

U_Shiftleft2Concat: entity work.SHIFT_Concat_PC
port map(
input=> IR25_0,
i_pc=>pc_out(3 downto 0),
output=>Shiftleft_concat
);

U_ALUTOP: entity work.alu_top
generic map(width=>32)
port map(
-- Clocks and Resets
         clk=> clk,
         rst=> rst,

        -- ++++++++++++ Inputs ++++++++++++++++
        i_opcode =>  ALUOp,     
        i_ir_shift=> IR15_0(10 downto 6),   

        i_operand_A=> Aluinput1,     
        i_operand_B => Aluinput2 , 

        -- ++++++++++++ Outputs ++++++++++++++++
        o_alu_result=> alu_result,    
        o_alu_out_reg=> Alu_out_reg,  

        -- This Mux selects the following:
        -- 0:ALU OUT   1:LO Register   2:HI Register
        o_alu_lo_hi_reg=> alu_lo_hi_out,

        -- Branch Taken
        o_branch_taken =>  branch_taken  

);
U_Mux31: entity work.mux31 
generic map( width=> 32)
port map(
 input0=>   alu_result, 
 input1 => Alu_out_reg,   
 input2 => Shiftleft_concat,  
  sel => Pcsource,   
  output =>mux31_out
);


 IR<= IR31_26 & IR25_21 & IR20_16 & IR15_0;


end logic;
