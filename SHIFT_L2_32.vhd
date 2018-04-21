library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SHIFT_L2_32 is

    Port ( input: in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
end  SHIFT_L2_32;

architecture Behavioral of  SHIFT_L2_32 is

begin
  process (input)
	begin
		output (31 downto 2) <= (input(29 downto 0));
		output (1 downto 0) <= "00"; 
	end process;
end Behavioral;
