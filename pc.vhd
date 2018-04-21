library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity pc is
	port(
		rst: in std_logic;
		clk: in std_logic;
		address_to_load: in std_logic_vector(31 downto 0);
		cntrl_in :in std_logic;
		current_address: out std_logic_vector(31 downto 0)
	);
end pc;

architecture logic of pc is


	begin

	 process(clk, rst)
  begin
    if (rst = '1') then
    current_address <= (others => '0');
    elsif (rising_edge(clk)) then
	 if(cntrl_in ='1') then
      current_address <= address_to_load;
      end if;
		end if;
 
  end process;

end logic;