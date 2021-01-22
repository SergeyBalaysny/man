library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity man_tb is
end entity ; -- man_tb


architecture man_tb_behav of man_tb is
	component man_r is
	generic (
				c_preamb_len: integer := 1; 				-- колчиество тактов на котором происходит вычисление частоты 
				c_data_len: integer := 8					-- количество бит данных в одном пакете
		);
	port (	p_i_clk:	in std_logic;
			p_i_ena:	in std_logic; 					-- выбор устройства
			p_i_rst:	in std_logic;					-- сброс автомата
			p_i_r_data: in std_logic; 					-- внешняя линия данных
			p_o_rdy:	out std_logic; 					-- сигнал о формировании примятого байта данных
			p_o_data:	out std_logic_vector(7 downto 0)  	-- принятые данные
	);
	end component;


	SIGNAL s_CLK, s_ENA, s_RST, s_RDY: std_logic;
	SIGNAL s_IN_DATA: std_logic;
	SIGNAL s_OUT_DATA: std_logic_vector(7 downto 0);

	constant t1 : TIME := 80 ns; 
begin
	
	reciv_module: man_r 
					generic map ( c_preamb_len => 1,
								  c_data_len => 8
						
					)
					port map (
									p_i_clk => s_CLK,
									p_i_ena => s_ENA,
									p_i_rst => s_RST,
									p_i_r_data => s_IN_DATA,
									p_o_rdy => s_RDY,
									p_o_data => s_OUT_DATA
								);


	s_ENA <= '1';

	process begin
		s_CLK <= '1';
		wait for 1 ns;
		s_CLK <= '0';
		wait for 1 ns;
	end process;

	process begin
		s_RST <= '0';
		wait for 10 ns;
		s_RST <= '1';
		wait;
	end process;

	process begin
	-- preamb
		s_IN_DATA <= 'Z';
		wait for 30 ns;
		s_IN_DATA <= '1';
		wait for t1;
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
		s_IN_DATA <= '0';
		wait for t1;

	-- data
	-- 0 1
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
	-- 1 1
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
	-- 2 1
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
	-- 3 0
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
	-- 4 1
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
	-- 5 0
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
	-- 6 1
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;
	-- 7 0
		s_IN_DATA <= '0';
		wait for t1;
		s_IN_DATA <= '1';
		wait for t1;

		s_IN_DATA <= 'Z';
		wait;
	end process;





end architecture ; -- arch