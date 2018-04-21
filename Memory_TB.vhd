library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.MIPS_LIB.all;

entity Memory_TB is
end Memory_TB;

architecture TB of Memory_TB is

  -- MODIFY TO MATCH YOUR TOP LEVEL
  component Memory
    port ( -- Clocks and Resets
         clk: in std_logic;
         rst: in std_logic;
    
         -- PC (32-bit address)
         i_pc : in std_logic_vector(31 downto 0);

         -- Inputs from Controller 
         i_mem_read  : in std_logic;
         i_mem_write : in std_logic;

         -- Inputs from Switches 
         -- Switches Bits[8:0]
         i_sw_inport_data : in std_logic_vector(8 downto 0);
         -- Swithc Bit[9]
         i_sw_inport_sel  : in std_logic;
         -- Button (used to write inport data)
         i_sw_inport_wr   : in std_logic;
     
         -- Input from Register File Register B
         -- Will be used to drive to Outport to LED's
         i_reg_b   : in std_logic_vector(31 downto 0);

         -- Memory outputs
         o_memout  : out std_logic_vector(31 downto 0);
         o_outport : out std_logic_vector(31 downto 0)

	);
  end component;

  signal clk             : std_logic := '0';
  signal rst              : std_logic := '1';
  signal  i_mem_read      : std_logic:= '0';
  signal i_mem_write   : std_logic:= '0';
  signal   i_pc :  std_logic_vector(31 downto 0); 
  signal   i_sw_inport_data :  std_logic_vector(8 downto 0);
  signal  i_sw_inport_sel  :  std_logic;
  signal   i_sw_inport_wr   :  std_logic:='0';
  signal i_reg_b   :  std_logic_vector(31 downto 0);
  signal o_memout  :  std_logic_vector(31 downto 0);
  signal o_outport :  std_logic_vector(31 downto 0);
 
begin  -- TB




  -- MODIFY TO MATCH YOUR TOP LEVEL
  UUT : Memory port map (
    clk       => clk,
    rst       => rst,
    i_pc      => i_pc,
   i_mem_read => i_mem_read,
   i_mem_write=> i_mem_write,
  i_sw_inport_data => i_sw_inport_data,
   i_sw_inport_sel=> i_sw_inport_sel,
     i_sw_inport_wr=>  i_sw_inport_wr,
       i_reg_b => i_reg_b,
        -- Memory outputs
       o_memout=> o_memout,
       o_outport=>o_outport

);


  clk <= not clk after 10 ns;

  process
  begin

  wait until clk'event and clk = '1';

 	rst   <= '0';
	 i_reg_b<= X"F0F0F0F0";
	 i_PC<= X"00000004";
	 i_mem_write<= '1';
 	i_mem_read<='0';




wait until clk'event and clk = '1';
	 	 rst   <= '0';
	 i_reg_b<= X"0A0A0A0A";
	 i_PC<= X"00000000";
	 i_mem_write<= '1';
  	 i_mem_read<='0';

	 wait until clk'event and clk = '1';


    	   rst   <= '0';
	i_mem_write<= '0';
	i_mem_read<= '1';
	i_pc<=X"00000000";
      
	

	 
   	
	 wait until clk'event and clk = '1';


	rst   <= '0';
	i_mem_write<= '0';
	i_mem_read<= '1';
	i_pc<=X"00000001";
     wait until clk'event and clk = '1';

	


	rst   <= '0';
	i_mem_write<= '0';
	i_mem_read<= '1';
	i_pc<=X"00000004";


     wait until clk'event and clk = '1';
       
	rst   <= '0';
	i_mem_write<= '0';
	i_mem_read<= '1';
	i_pc<=X"00000005";
 


 wait until clk'event and clk = '1';
	rst   <= '0';
	i_pc<=X"0000FFFC";
	i_mem_read<= '1';
        i_reg_b<= X"00001111";



  wait until clk'event and clk = '1';
	rst   <= '0';
	i_sw_inport_wr<= '1';
	i_sw_inport_sel<='0';
        i_reg_b<= X"00000000";
	i_sw_inport_data<= "100000000";

 wait until clk'event and clk = '1';
	rst   <= '0';
	i_sw_inport_wr<= '1';
	i_sw_inport_sel<='1';
	 i_reg_b<= X"00000000";
	i_sw_inport_data<= "000000001";

 wait until clk'event and clk = '1';
	rst   <= '0';
	i_mem_read <= '1';
	i_sw_inport_wr <= '0';
 	i_reg_b<= X"00000000";
	i_pc <= X"0000FFF8";

wait until clk'event and clk = '1';
	rst   <= '0';
	i_mem_read <= '1';
	i_sw_inport_wr <= '0';
	 i_reg_b<= X"00000000";
	i_pc <= X"0000FFFC";

	
  end process;

end TB;