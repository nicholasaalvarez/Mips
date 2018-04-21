LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity instruction_reg is
generic(
        WIDTH : positive := 32
);
port(
        clk     : in std_logic;
        rst     : in std_logic;
        memdata : in std_logic_vector(WIDTH-1 downto 0);
        IRwrite : in std_logic;

        instr31_26 : out std_logic_vector(5 downto 0);
        instr25_21 : out std_logic_vector(4 downto 0);
        instr20_16 : out std_logic_vector(4 downto 0);
        instr15_11 : out std_logic_vector(4 downto 0);

        instr25_0  : out std_logic_vector(25 downto 0);
        instr15_0  : out std_logic_vector(15 downto 0)
);
end instruction_reg;

architecture bhv of instruction_reg is

begin

process(clk, rst,memdata, IRwrite)
begin

if(rst = '1') then
        instr31_26 <= (others => '0');
        instr25_21 <= (others => '0');
        instr20_16 <= (others => '0');
        instr15_11 <= (others => '0');

        instr25_0  <= (others => '0');
        instr15_0  <= (others => '0');
elsif(rising_edge(clk)) then
        if(IRwrite = '1') then
        instr31_26 <= memdata(31 downto 26);
        instr25_21 <= memdata(25 downto 21);
        instr20_16 <= memdata(20 downto 16);
        instr15_11 <= memdata(15 downto 11);

        instr25_0  <= memdata(25 downto 0);
        instr15_0  <= memdata(15 downto 0);
        end if;
end if;
end process;
end bhv;
