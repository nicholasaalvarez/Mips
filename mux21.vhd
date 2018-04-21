-- Greg Stitt
-- University of Florida
-- From the website, I copied this
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.mips_lib.all;
entity mux21 is
  generic (
   	width:     positive := 32);
  port (
    input0    : in  std_logic_vector(width-1 downto 0);
    input1    : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic;
    output : out std_logic_vector(width-1 downto 0));
end mux21;

architecture BHV of mux21 is
begin
  with sel select
    output <=
    input0 when '0',
    input1 when others;
end BHV;
