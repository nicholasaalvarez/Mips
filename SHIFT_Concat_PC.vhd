library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SHIFT_Concat_PC is

    Port ( input: in  STD_LOGIC_VECTOR (25 downto 0);
				i_pc: in std_logic_vector(3 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
end  SHIFT_Concat_PC;

architecture Behavioral of  SHIFT_Concat_PC is
signal temp: std_logic_vector(27 downto 0);
begin
  process (input, i_pc,temp)
	begin
		temp (27 downto 2) <= (input(25 downto 0));
		temp (1 downto 0) <= "00";
		
		output<= i_pc & temp;
		
		
	end process;
end Behavioral;
