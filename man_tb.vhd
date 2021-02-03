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


	component  man_t is
	generic(c_speed: integer:= 10);
	port (
			p_i_clk: 	in std_logic;
			p_i_ena: 	in std_logic;				-- сигнал выбора устройства
			p_i_rst:	in std_logic;				-- сигнал сброса
			p_i_data:	in std_logic_vector(7 downto 0); -- байт данных для передачи
			p_i_wr:		in std_logic; 				-- сигнал инициализции передачи данных
			p_o_busy:	out std_logic; 				-- сигнал занятости линии передачи данных
			p_o_t_data:	inout std_logic 				-- выходная линия для передачи данных 
	);
	end component;


	SIGNAL s_CLK, s_ENA_R, s_ENA_T, s_RST, s_RDY: std_logic;
	SIGNAL s_DATA_BUS: std_logic;
	SIGNAL s_OUT_DATA: std_logic_vector(7 downto 0);
	SIGNAL s_INP_DATA:	std_logic_vector(7 downto 0);
	SIGNAL s_BUSY, s_WR: std_logic;

	constant t1 : TIME := 80 ns; 
begin
	
	reciv_module: man_r 
					generic map ( c_preamb_len => 1,
								  c_data_len => 8
						
					)
					port map (
									p_i_clk => s_CLK,
									p_i_ena => s_ENA_R,
									p_i_rst => s_RST,
									p_i_r_data => s_DATA_BUS,
									p_o_rdy => s_RDY,
									p_o_data => s_OUT_DATA
								);


	trans_module: man_t 
					generic map (	c_speed => 80)
					port map (		p_i_clk => s_CLK,
									p_i_ena => s_ENA_T,
									p_i_rst => s_RST,
									p_i_data => s_INP_DATA,
									p_i_wr 	=> s_WR,
									p_o_busy => s_BUSY,
									p_o_t_data => s_DATA_BUS
						);


	s_ENA_R <= '1';
	s_ENA_T <= '0';

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
		s_INP_DATA <= "00110101";
		s_WR <= '0';
		wait for 50 ns;
		s_WR <= '1';

		wait for 10 ns;
		s_INP_DATA <= (others => 'Z');
		wait until s_BUSY = '1';
		s_WR <= '0';
		wait;
	end process;

	



end architecture ; -- arch