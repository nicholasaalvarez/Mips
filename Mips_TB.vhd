-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mips_Tb is
end Mips_TB;

architecture TB of Mips_tb is
  signal outport  : std_logic_vector(31 downto 0);
  signal i_sw_inport_data  : std_logic_vector(8 downto 0):= "000000000";
  signal clk    : std_logic := '0';
  signal   i_sw_inport_sel  : std_logic := '0';
  signal i_sw_inport_wr: std_logic:= '0';
  signal rst    : std_logic:= '1';
 

begin  -- TB

  UUT : entity work.Mips
    port map (
       -- ++++++++++++ Inputs ++++++++++++++++
        clk  => clk,
        rst   => rst,		 -- Inputs from Switches 
         -- Switches Bits[8:0]
         i_sw_inport_data=>  i_sw_inport_data,  -- Swithc Bit[9]
         i_sw_inport_sel=> i_sw_inport_sel,
         
         i_sw_inport_wr => i_sw_inport_wr,  -- Button (used to write inport data
		  

        -- ++++++++++++ Outputs +++++++++++++++
     outport=> outport
		  
     );   



  -- toggle clock
  clk <= not clk after 10 ns;

  process
  begin


wait until clk'event and clk ='1';
rst<='0';
i_sw_inport_sel<= '0';
i_sw_inport_data<="111111111";
i_sw_inport_wr<= '1';


 
wait;
  end process;
end TB;


