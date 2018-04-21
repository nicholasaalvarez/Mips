library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sign_extend is
	port (
		x: in std_logic_vector(15 downto 0);
		isSigned: in std_logic;
		y: out std_logic_vector(31 downto 0)
	);
end sign_extend;

architecture extend of sign_extend is
	begin
	
	
	process(x,issigned)
	begin
	if(isSigned ='1') then
	y <= std_logic_vector(resize(signed(x), y'length));
	else
	y<= std_logic_vector(to_unsigned(0,16)) & x;
	end if;
	end process;
end extend;