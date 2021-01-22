library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity man_t_tb is
end man_t_tb;


architecture man_t_tb_behav of man_t_tb is

	SIGNAL s_CLK, s_RST, s_ENA, s_WR: std_logic;
	SIGNAL s_DATA: std_logic_vector (7 downto 0);
	SIGNAL s_BUSY, s_O_DATA: std_logic;


begin
	t_module: entity work.man_t 
		generic map( c_speed => 10)
		port map (	p_i_clk => s_CLK,
					p_i_ena => s_ENA,
					p_i_rst => s_RST,
					p_i_data => s_DATA,
					p_i_wr	=> s_WR,
					p_o_busy => s_BUSY,
					p_o_t_data => s_O_DATA );


	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_RST <= '1';
		wait for 10 ns;
		s_RST <= '0';
		wait for 5 ns;
		s_RST <= '1';
		wait;
	end process;

	process begin
		s_ENA <= '1';
		wait for 30 ns;
		s_ENA <= '0';
		wait;
	end process;

	process begin
		s_DATA <= "00110101";
		s_WR <= '0';
		wait for 50 ns;
		s_WR <= '1';
		wait until s_BUSY = '1';
		s_WR <= '0';
		wait;
	end process;

end architecture;
