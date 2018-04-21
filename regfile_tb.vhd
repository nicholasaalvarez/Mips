LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY regfile_tb IS
END regfile_tb;
ARCHITECTURE behavior OF regfile_tb IS

 component regfile

        generic (
            WIDTH : positive := 32
            );
        port (
           -- Clocks and Resets
        clk:          in std_logic;
        rst:          in std_logic;

        -- Read Port Address (selects 1 of 32 registers)
        i_rd_adrs1:     in std_logic_vector(4 downto 0);
        i_rd_adrs2:     in std_logic_vector(4 downto 0);

        -- Controller Signals 
        i_cntrl_reg_wr: in std_logic;
        i_cntrl_jal:    in std_logic;

        -- Write Port (writes 1 of 32 registers)
        i_wr_adrs:      in std_logic_vector(4 downto 0);
        i_wr_data:      in std_logic_vector(width-1 downto 0);

        -- ++++++++++++ Outputs ++++++++++++++++
        -- Read Data 
        o_rd_data1:     out std_logic_vector(width-1 downto 0);
        o_rd_data2:     out std_logic_vector(width-1 downto 0)

     );

    end component;

	constant WIDTH   : positive := 32;
	--Inputs
	 signal clk           : std_logic := '0';
 	 signal rst           : std_logic := '1';
	SIGNAL   i_rd_adrs1  : std_logic_vector(4 DOWNTO 0);
	SIGNAL i_rd_adrs2 : std_logic_vector(4 DOWNTO 0);
	SIGNAL   i_wr_adrs  : std_logic_vector(4 DOWNTO 0);
	SIGNAL  i_wr_data    : std_logic_vector(31 DOWNTO 0);
	SIGNAL i_cntrl_reg_wr : std_logic := '0';
	SIGNAL  i_cntrl_jal:  std_logic := '0';
	--Outputs
	SIGNAL  o_rd_data1: std_logic_vector(31 DOWNTO 0);
	SIGNAL o_rd_data2:  std_logic_vector(31 DOWNTO 0);
BEGIN
	--
	U1_Reg : regfile
 generic map (
            	WIDTH => WIDTH)
   PORT MAP(
 		clk=> clk,
        	rst=> rst,
        -- Read Port Address (selects 1 of 32 registers)
        i_rd_adrs1=> i_rd_adrs1,
        i_rd_adrs2=> i_rd_adrs2,
        -- Controller Signals 
        i_cntrl_reg_wr=> i_cntrl_reg_wr,
        i_cntrl_jal=> i_cntrl_jal,
        -- Write Port (writes 1 of 32 registers)
        i_wr_adrs=> i_wr_adrs,
        i_wr_data=> i_wr_data,
        -- ++++++++++++ Outputs ++++++++++++++++
        -- Read Data 
        o_rd_data1=> o_rd_data1,
        o_rd_data2=> o_rd_data2
		);
		-- Stimulus process
clk <= not clk after 20 ns;
 process
  begin

 
wait until clk'event and clk = '1';

 	rst   <= '0';
	 i_rd_adrs1<= "11111";
	 i_rd_adrs2<= "11111";
	 i_cntrl_jal<='1';
	 i_cntrl_reg_wr<='1';
	
	i_wr_data<= X"10000000";

wait for 20ns;

wait;
	
end process;
END behavior;
