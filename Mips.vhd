library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity Mips is
port (
        -- ++++++++++++ Inputs ++++++++++++++++
        clk             : in std_logic;
        rst             : in std_logic;
       
		 -- Inputs from Switches 
         -- Switches Bits[8:0]
         i_sw_inport_data : in std_logic_vector(8 downto 0);
         -- Swithc Bit[9]
         i_sw_inport_sel  : in std_logic;
         -- Button (used to write inport data)
         i_sw_inport_wr   : in std_logic;
		  

        -- ++++++++++++ Outputs +++++++++++++++
		  outport: out std_logic_vector(31 downto 0)
		  

     );
end Mips;


architecture logic of Mips is

   signal  o_PcWrite   :   std_logic;
   signal  o_IorD      :   std_logic;
   signal  o_MemWrite  :   std_logic;
   signal o_MemRead    :   std_logic;
   signal o_MemToReg   :   std_logic;
   signal o_IRWrite    :   std_logic;
   signal o_IsSigned   :   std_logic;
   signal o_RegWrite   :   std_logic;
   signal o_JumpAndLink:   std_logic;
   signal  o_RegDst    :   std_logic;
   signal o_AluSrcA    :   std_logic;
   signal o_AluSrcB    :   std_logic_vector(1 downto 0);
   signal o_PCSrc      :   std_logic_vector(1 downto 0);
   signal  o_AluOp     :   std_logic_vector(5 downto 0);
	
	  
  signal branch_taken  :   std_logic;
  signal IR            :   std_logic_vector(31 downto 0);
 



begin
U_Controller: entity work.Controller 
port map(
  clk=>clk,
  rst => rst,    

    i_IR_Opcode  => IR(31 downto 26), -- IR Bits[31:26]
    i_IR_Func   => IR(5 downto 0), -- IR Bits[05:00]
    i_IR_Bit16  => IR(16),                   -- IR Bit [16]
    i_BranchTaken => branch_taken,

    o_PcWrite =>  o_PcWrite,   
    o_IorD   =>    o_IorD , 
    o_MemWrite =>  o_MemWrite ,
    o_MemRead   => o_MemRead ,
    o_MemToReg =>  o_MemToReg,
    o_IRWrite  =>  o_IRWrite,  
    o_IsSigned  =>  o_IsSigned ,
    o_RegWrite   => o_RegWrite,
    o_JumpAndLink => o_JumpAndLink,
    o_RegDst   =>   o_RegDst,
    o_AluSrcA   =>   o_AluSrcA ,
    o_AluSrcB   =>    o_AluSrcB,
    o_PCSrc      =>   o_PCSrc, 
    o_AluOp     =>   o_AluOp
 
 
 
 
 
);



U_Datapath: entity work.datapath
port map(
     -- ++++++++++++ Inputs ++++++++++++++++
        clk=> clk,
        rst=> rst,      
        pc_load=>   o_PcWrite,
		  IorD => o_IorD,
		  Memread=> o_memread,
		  memwrite=> o_memwrite,
		  memtoreg=> o_memtoreg,
		  IRwrite=> o_IRwrite,
		  Regdest=> o_regdst, 
		  Regwrite=> o_regwrite,
		  ALUsrcA => o_ALUsrcA, 
		  ALusrcB=> o_ALUsrcB,
		  ALUOp=> o_ALUop,
		  pcsource=> o_PCSrc ,
		  issigned=> o_issigned,
		  JumpandLink=> o_jumpandlink,
		 -- Inputs from Switches 
         -- Switches Bits[8:0]
         i_sw_inport_data=> i_sw_inport_data,
         -- Swithc Bit[9]
         i_sw_inport_sel=> i_sw_inport_sel,
         -- Button (used to write inport data)
         i_sw_inport_wr=>i_sw_inport_wr,
		  

        -- ++++++++++++ Outputs ++++++++++++++++
		  branch_taken=> branch_taken,
		  IR =>IR,
		  outport=> outport
);

end logic;