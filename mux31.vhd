
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.mips_lib.all;
entity mux31 is
  generic (
   	width:     positive := 32);
  port (
    input0    : in  std_logic_vector(width-1 downto 0);
    input1    : in  std_logic_vector(width-1 downto 0);
	  input2   : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic_vector(1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end mux31;

architecture BHV of mux31 is
begin
process(input0, input1, input2, sel)
begin
 if (sel = "00") then
			output <= input0;
		elsif (sel = "01") then
			output <= input1;
		else 
			output <= input2;
		end if;
	end process;
end BHV;
