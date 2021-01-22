library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity man_r is
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
end man_r;

architecture man_r_behav of man_r is

	SIGNAL s_BUFFER: std_logic_vector(7 downto 0);			-- регистр для хранения принятого байта
	SIGNAL s_BIT_BUFER: std_logic_vector(1 downto 0);
	SIGNAL s_FULL_LEN: integer; 							-- длительность текущего полного бита преамбулы
	SIGNAL s_CURR_BYTE_COUNT: integer;						-- количество принятых байт данных

	SIGNAL s_MED_FULL_LEN: integer; 						-- средняя длительность полного бита в передаче


	SIGNAL s_FIRST_DELAY, s_SECOND_DELAY: integer;			-- задержки для попадания в середину первой и второй части бита данных (3/4 и 1/2 длительности бита) отсичтанных от последнего фронта преамбулы

	SIGNAL s_COUNT: integer;								-- количество фактически принятых бит

	SIGNAL s_INP_FILTER: std_logic_vector(9 downto 0);		-- фильтр принимаемых данных на линии	

	type t_state is (st_idle, st_reciev_preamb, st_delay, st_reciev_data, st_add_bit);
	SIGNAL s_FSM: t_state;

begin

	process(p_i_clk) begin
		if p_i_rst =  '0' then
			s_FSM <= st_idle;
			s_FULL_LEN <= 1;
			s_MED_FULL_LEN <= 0;
			s_COUNT <= 0;
			p_o_rdy <= '0';
			p_o_data <= X"00";
			s_BUFFER <= (others => '0');
			s_BIT_BUFER <= "00";
			s_INP_FILTER <= (others => '0');
		else

			if rising_edge(p_i_clk) and p_i_ena = '1' then

				s_INP_FILTER <= s_INP_FILTER(8 downto 0) & p_i_r_data;

				
				case s_FSM is 				

					-- на линии зафиксирован первый переход с 1 на 0 -> начало приема преамбулы
					when st_idle => if s_INP_FILTER = "1111100000" and s_COUNT < c_preamb_len then   	-- прием первого перехода преамбулы -> начало приема преамбулы
										s_MED_FULL_LEN <= 0;
										
										s_FULL_LEN <= 0;
									
										s_FSM <= st_reciev_preamb;
									else
										s_FSM <= st_idle;
									end if;

					-- прием преамбулы и вычисление частоты принимаемых данных
					when st_reciev_preamb =>	if s_COUNT >= c_preamb_len then
													s_COUNT <= 0; 
												
													s_FIRST_DELAY <= (( 3 * s_MED_FULL_LEN ) / 4) - 10;
													s_SECOND_DELAY <= (s_MED_FULL_LEN / 2);

													--s_FSM <= st_reciev_data;
													s_FSM <= st_delay;

												else
													-- на линии обнаружен очередной переход с 1 на 0 (прошел полный период байта преамбулы)
													if s_INP_FILTER = "1111100000" then 

														-- вычисление длинны полного бита
														-- если принят первый бит -> средняя длительность = длительности первого бита	
														if s_MED_FULL_LEN = 0 then
															s_MED_FULL_LEN <= s_FULL_LEN;

														-- если принят очередной бит -> корректировка средней длительности бита
														else
															s_MED_FULL_LEN <= (s_MED_FULL_LEN + s_FULL_LEN) / s_COUNT;
														end if;

														s_FULL_LEN <= 0;
														s_COUNT <= s_COUNT + 1;			-- отметка об очередном принятом полном бите данных

													else

														s_FULL_LEN <= s_FULL_LEN + 1;
													end if;
														
													s_FSM <= st_reciev_preamb;
												end if;

					when st_delay =>	if s_COUNT = s_FIRST_DELAY then
											s_COUNT <= 0;
											s_CURR_BYTE_COUNT <= 0;

											s_FSM <= st_reciev_data;
										else
											s_COUNT <= s_COUNT + 1;
											s_FSM <= st_delay;
										end if;

						-- прием байта даных
				
					when st_reciev_data => 	if s_CURR_BYTE_COUNT >= c_data_len then
												p_o_data <= s_BUFFER;
												p_o_rdy <= '1';
												s_FSM <= st_idle;

											elsif s_COUNT = 0 then
												s_BIT_BUFER(1) <= p_i_r_data;
												s_COUNT <= s_COUNT + 1;
												s_FSM <= st_reciev_data;
											elsif s_COUNT = s_SECOND_DELAY then
												s_BIT_BUFER(0) <= p_i_r_data;
												s_COUNT <= 0;
												s_FSM <= st_add_bit;
											else
												s_COUNT <= s_COUNT + 1;
											end if;

					when st_add_bit =>	if s_COUNT = s_SECOND_DELAY then

											if s_BIT_BUFER = "01" then
												s_BUFFER <= s_BUFFER(6 downto 0) & '1';
												
											else
												s_BUFFER <= s_BUFFER(6 downto 0) & '0';

											end if;
											s_COUNT <= 0;
											s_BIT_BUFER <= "00";
											s_CURR_BYTE_COUNT <= s_CURR_BYTE_COUNT + 1;
											s_FSM <= st_reciev_data;
										else 
											s_COUNT <= s_COUNT + 1;
											s_FSM <= st_add_bit;
										end if;




					when others => s_FSM <= st_idle;




				end case;


			end if;

	end if;

	end process;


end architecture;
