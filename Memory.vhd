library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.mips_lib.all;

entity memory is
  port (
         -- Clocks and Resets
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
end memory;

architecture behavorial of memory is 


component bubblesort is
port (
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		we		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

signal inport0    : std_logic_vector(8 downto 0);
signal inport1    : std_logic_vector(8 downto 0);

signal ram_dout   : std_logic_vector(31 downto 0);
signal mem_io     : std_logic;
signal wr_outport : std_logic;
signal Ram_Write : std_logic;




begin


 


  
  
  
  
  
  


  

  
  RAMPORT: bubblesort port map(
  address=>i_pc(9 downto 2),
   data=>i_reg_b,
	we	=>  Ram_write,
	q=> ram_dout

);






  -- Write INPORT 0 and 1 Registers from Switches
  -- NOTE: These registers are not reset on purpose cause
  --       cause input button (reset) will be used to re-load  
  --       a new program after the INPORT registers are written.
  process( clk, i_sw_inport_wr,i_sw_inport_sel, i_sw_inport_data)
  begin
    
     if(clk'event and clk = '1' and i_sw_inport_wr = '1') then

       -- These are only 9-bits registers 
       -- Need to Concat wth 23 MSB's
       if ( i_sw_inport_sel='1' ) then 
	     inport1<= i_sw_inport_data;
	   else
	     inport0<= i_sw_inport_data;
	   end if;

	 end if;

  end process;


  -- Memory Mapped I/O when PC address equals 0xFFFC or 0xFFF8
  -- NOTE: IF address 0xFFFC then Output is driven when MEM READ 
  mem_io     <= '1' when (i_pc=X"0000FFFC") or (i_pc=X"0000FFF8") else '0';
 wr_outport <=  '1' when (i_pc =X"0000FFFC") and (i_mem_write ='1') else '0';

  -- Store Outport (PC=0xFFFC and MemWrite)
  process( clk, rst, wr_outport )
  begin
     
     if ( rst = '1' ) then 
       o_outport <= X"00000000";
     elsif(clk'event and clk = '1') then

       if ( wr_outport='1' ) then 
         o_outport <= i_reg_b; 
		
	   end if;

	 end if;

  end process;

  
  
  
  ram_write<= '1' when (i_pc <= X"000003FF") and (i_mem_write='1') else '0';

  -- Mux either RAM Data Out or Memory Mapped I/O
  -- Memory Mapped I/O are INPORT 0 and 1 Registers
  process( i_pc, i_mem_read,inport0, inport1,ram_dout)
  begin

    if ( i_mem_read = '1') then  

      if ( i_pc = X"0000FFF8" )  then
        -- Select INPORT0 Register (from switches)
        o_memout <= "000" & "00000000000000000000" & inport0;
      elsif ( i_pc = X"0000FFFC" )  then
        -- Select INPORT1 Register (from switches)
        o_memout <= "000" &   X"00000" & inport1;
      else
        -- Select RAM Data Out  
        o_memout <= ram_dout;
   end if;
	
    else 
       o_memout <= X"00000000";

    end if;
	 
	 

	 
	 

  end process;
end behavorial;
