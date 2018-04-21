-- MIPS Project 
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

package MIPS_LIB is

  ---------------------------------------------------------------------------------------------------------------------
  -- VALUES used By controller
  ---------------------------------------------------------------------------------------------------------------------
  ---- R - Instructions 
  constant OPCODE_RTYPE   : std_logic_vector(5 downto 0) := "000000";  -- Opcode=0x00 R-Instrcution (Func Bits[5:0])
  constant OP0_FUNC_ADDU   : std_logic_vector(5 downto 0) := "100001";  --  Func=0x21  R-Inst
  constant OP0_FUNC_SUBU   : std_logic_vector(5 downto 0) := "100011";  --  Func=0x23  R-Inst
  constant OP0_FUNC_MULT  : std_logic_vector(5 downto 0) := "011000";  --  Func=0x18  R-Inst
  constant OP0_FUNC_MULTU : std_logic_vector(5 downto 0) := "011001";  --  Func=0x19  R-Inst
  constant OP0_FUNC_AND   : std_logic_vector(5 downto 0) := "100100";  --  Func=0x24  R-Inst
  constant OP0_FUNC_OR    : std_logic_vector(5 downto 0) := "100101";  --  Func=0x25  R-Inst
  constant OP0_FUNC_XOR   : std_logic_vector(5 downto 0) := "100110";  --  Func=0x26  R-Inst
  constant OP0_FUNC_SRL   : std_logic_vector(5 downto 0) := "000010";  --  Func=0x02  R-Inst
  constant OP0_FUNC_SLL   : std_logic_vector(5 downto 0) := "000000";  --  Func=0x00  R-Inst
  constant OP0_FUNC_SRA   : std_logic_vector(5 downto 0) := "000011";  --  Func=0x03  R-Inst
  constant OP0_FUNC_SLT   : std_logic_vector(5 downto 0) := "101010";  --  Func=0x2A  R-Inst
  constant OP0_FUNC_SLTU  : std_logic_vector(5 downto 0) := "101011";  --  Func=0x2B  R-Ins t
  constant OP0_FUNC_MFHI  : std_logic_vector(5 downto 0) := "010000";  --  Func=0x10  R-Inst
  constant OP0_FUNC_MFLO  : std_logic_vector(5 downto 0) := "010010";  --  Func=0x12  R-Inst
  constant OP0_FUNC_JR    : std_logic_vector(5 downto 0) := "001000";  --  Func=0x08  R-Inst

  ---- Immediate - Instructions 
  constant OPCODE_ADDIU    : std_logic_vector(5 downto 0) := "001001";  -- Opcode=0x09 Func=N/A   I-Inst
  constant OPCODE_SUBIU    : std_logic_vector(5 downto 0) := "010000";  -- Opcode=0x10 Func=N/A   I-Inst (Not a Mips Inst)
  constant OPCODE_ANDI    : std_logic_vector(5 downto 0) := "001100";  -- Opcode=0x0C Func=N/A   I-Inst
  constant OPCODE_ORI     : std_logic_vector(5 downto 0) := "001101";  -- Opcode=0x0D Func=N/A   I-Inst
  constant OPCODE_XORI    : std_logic_vector(5 downto 0) := "001110";  -- Opcode=0x0E Func=N/A   I-Inst
  constant OPCODE_SLTI    : std_logic_vector(5 downto 0) := "001010";  -- Opcode=0x0A Func=N/A   I-Inst
  constant OPCODE_SLTIU   : std_logic_vector(5 downto 0) := "001011";  -- Opcode=0x0B Func=N/A   I-Inst
  constant OPCODE_LW      : std_logic_vector(5 downto 0) := "100011";  -- Opcode=0x23 Func=N/A   I-Inst
  constant OPCODE_SW      : std_logic_vector(5 downto 0) := "101011";  -- Opcode=0x2B Func=N/A   I-Inst
  constant OPCODE_BEQ     : std_logic_vector(5 downto 0) := "000100";  -- Opcode=0x04 Func=N/A   I-Inst
  constant OPCODE_BNE     : std_logic_vector(5 downto 0) := "000101";  -- Opcode=0x05 Func=N/A   I-Inst
  constant OPCODE_BLEZ    : std_logic_vector(5 downto 0) := "000110";  -- Opcode=0x06 Func=N/A   I-Inst
  constant OPCODE_BGTZ    : std_logic_vector(5 downto 0) := "000111";  -- Opcode=0x07 Func=N/A   I-Inst
 
  constant OPCODE_BLTZ_GEZ : std_logic_vector(5 downto 0) := "000001"; -- Opcode=0x01 Func=N/A   I-Inst Bit[16]=0

  ---- Jump - Instructions 
  constant OPCODE_J      : std_logic_vector(5 downto 0) := "000010";  -- Opcode=0x02 Func=N/A   J-Inst
  constant OPCODE_JAL    : std_logic_vector(5 downto 0) := "000011";  -- Opcode=0x03 Func=N/A   J-Inst
  
  
  ---------------------------------------------------------------------------------------------------------------------
-- HALT Instruction
constant   OPCODE_HALT : std_logic_vector(5 downto 0) := "111111"; -- opcode = 3F



  ---------------------------------------------------------------------------------------------------------------------
  -- VALUES FOR ALU OP Codes
  ---------------------------------------------------------------------------------------------------------------------
  ---- R - Instructions   
  constant ALU_OP_ADDU   : std_logic_vector(5 downto 0) := "000000";  -- Opcode=0x00 Func=0x21  R-Inst
  constant ALU_OP_SUBU   : std_logic_vector(5 downto 0) := "000001";  -- Opcode=0x00 Func=0x22  R-Inst
  constant ALU_OP_MULT   : std_logic_vector(5 downto 0) := "000010";  -- Opcode=0x00 Func=0x18  R-Inst
  constant ALU_OP_MULTU  : std_logic_vector(5 downto 0) := "000011";  -- Opcode=0x00 Func=0x19  R-Inst
  constant ALU_OP_AND    : std_logic_vector(5 downto 0) := "000100";  -- Opcode=0x00 Func=0x24  R-Inst
  constant ALU_OP_OR     : std_logic_vector(5 downto 0) := "000101";  -- Opcode=0x00 Func=0x25  R-Inst
  constant ALU_OP_XOR    : std_logic_vector(5 downto 0) := "000110";  -- Opcode=0x00 Func=0x26  R-Inst
  constant ALU_OP_SRL    : std_logic_vector(5 downto 0) := "000111";  -- Opcode=0x00 Func=0x02  R-Inst
  constant ALU_OP_SLL    : std_logic_vector(5 downto 0) := "001000";  -- Opcode=0x00 Func=0x00  R-Inst
  constant ALU_OP_SRA    : std_logic_vector(5 downto 0) := "001001";  -- Opcode=0x00 Func=0x03  R-Inst
  constant ALU_OP_SLT    : std_logic_vector(5 downto 0) := "001010";  -- Opcode=0x00 Func=0x2A  R-Inst
  constant ALU_OP_SLTU   : std_logic_vector(5 downto 0) := "001011";  -- Opcode=0x00 Func=0x2B  R-Inst
  constant ALU_OP_MFHI   : std_logic_vector(5 downto 0) := "001100";  -- Opcode=0x00 Func=0x10  R-Inst
  constant ALU_OP_MFLO   : std_logic_vector(5 downto 0) := "001101";  -- Opcode=0x00 Func=0x12  R-Inst
 
  ---- Immediate - Instructions 
  constant ALU_OP_ADDIU  : std_logic_vector(5 downto 0) := "001111";  -- Opcode=0x09 Func=N/A   I-Inst
  constant ALU_OP_SUBIU  : std_logic_vector(5 downto 0) := "010000";  -- Opcode=0x10 Func=N/A   I-Inst (Not a Mips Inst)
  constant ALU_OP_ANDI   : std_logic_vector(5 downto 0) := "010001";  -- Opcode=0x0C Func=N/A   I-Inst
  constant ALU_OP_ORI    : std_logic_vector(5 downto 0) := "010010";  -- Opcode=0x0D Func=N/A   I-Inst
  constant ALU_OP_XORI   : std_logic_vector(5 downto 0) := "010011";  -- Opcode=0x0E Func=N/A   I-Inst
  constant ALU_OP_SLTI   : std_logic_vector(5 downto 0) := "010100";  -- Opcode=0x0A Func=N/A   I-Inst
  constant ALU_OP_SLTIU  : std_logic_vector(5 downto 0) := "010101";  -- Opcode=0x0B Func=N/A   I-Inst
  constant ALU_OP_LW     : std_logic_vector(5 downto 0) := "010110";  -- Opcode=0x23 Func=N/A   I-Inst
  constant ALU_OP_SW     : std_logic_vector(5 downto 0) := "010111";  -- Opcode=0x2B Func=N/A   I-Inst
  constant ALU_OP_BEQ    : std_logic_vector(5 downto 0) := "011000";  -- Opcode=0x04 Func=N/A   I-Inst
  constant ALU_OP_BNE    : std_logic_vector(5 downto 0) := "011001";  -- Opcode=0x05 Func=N/A   I-Inst
  constant ALU_OP_BLEZ   : std_logic_vector(5 downto 0) := "011010";  -- Opcode=0x06 Func=N/A   I-Inst
  constant ALU_OP_BGTZ   : std_logic_vector(5 downto 0) := "011011";  -- Opcode=0x07 Func=N/A   I-Inst
  constant ALU_OP_BLTZ   : std_logic_vector(5 downto 0) := "011100";  -- Opcode=0x01 Func=N/A   I-Inst Bit[16]=0
  constant ALU_OP_BGEZ   : std_logic_vector(5 downto 0) := "011101";  -- Opcode=0x01 Func=N/A   I-Inst Bit[16]=1

  ---- Jump - Instructions 
  constant ALU_OP_J      : std_logic_vector(5 downto 0) := "011110";  -- Opcode=0x02 Func=N/A   J-Inst
  constant ALU_OP_JAL    : std_logic_vector(5 downto 0) := "011111";  -- Opcode=0x03 Func=N/A   J-Inst
  constant ALU_OP_PASSB   : std_logic_vector(5 downto 0) := "100000";  -- Opcode=0x02 Func=N/A   J-Inst
  constant ALU_OP_PASSA   : std_logic_vector(5 downto 0) := "001110";  -- Opcode=0x00 Func=0x08  R-Inst
  ---------------------------------------------------------------------------------------------------------------------

end MIPS_LIB;
