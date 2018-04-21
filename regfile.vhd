library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity regfile is
   generic (
              WIDTH : positive := 32
           );
port (

       -- Clocks and Resets
        clk:          in std_logic;
        rst:          in std_logic;

        -- Read Port Address (selects 1 of 32 registers)
        i_rd_adrs1:     in std_logic_vector(4 downto 0);
        i_rd_adrs2:     in std_logic_vector(4 downto 0);

        -- Controller Signals 
        i_cntrl_reg_wr: in std_logic;
        i_cntrl_jal:    in std_logic;

        -- Write Port (writes 1 of 32 registers)
        i_wr_adrs:      in std_logic_vector(4 downto 0);
        i_wr_data:      in std_logic_vector(width-1 downto 0);

        -- ++++++++++++ Outputs ++++++++++++++++
        -- Read Data 
        o_rd_data1:     out std_logic_vector(width-1 downto 0);
        o_rd_data2:     out std_logic_vector(width-1 downto 0)

     );
end regfile;
	

architecture logic of regfile is	

  type   regDataType is array(0 to 31) of std_logic_vector(width-1 downto 0);
  signal regData : regDataType;
  signal adrs : std_logic_vector(4 downto 0);

begin 

  -- Read Ports (Combinatorial)
  o_rd_data1 <= regData(to_integer(unsigned(i_rd_adrs1))); 
  o_rd_data2 <= regData(to_integer(unsigned(i_rd_adrs2))); 

  -- Write 1 of 32-bit Registers
  -- NOTE: When input i_cntrl_jal (Jump-And-Link) is set
  --       this implies that need to update Reg31 which
  --       is the dedicated Return Address ($RA) for MIPS.

  -- Set adrs to 31 when Jump-And-Link Instruction
  adrs <= "11111" when ( i_cntrl_jal = '1' ) else i_wr_adrs; 

  process(clk, rst)
  begin
     if (rst = '1') then
       -- Reset all 32-bit Registers 
       RegData <= (others => X"00000000");
     elsif( rising_edge(clk) ) then
       -- Check if need to write a register
       if ( i_cntrl_reg_wr = '1' ) then
           -- Write Register based on input Write Adrs
          regData(to_integer(unsigned(adrs))) <= i_wr_data;
       end if;
	 end if;
  end process;


end logic;
