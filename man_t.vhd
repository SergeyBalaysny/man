library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity man_t is
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
end man_t;

architecture man_t_behav of man_t is

	SIGNAL s_BUFFER:		std_logic_vector(9 downto 0);
	SIGNAL s_BUFER_COUNTER:	std_logic_vector(3 downto 0);
	SIGNAL s_COUNT:			integer;

	type t_state is (st_idle, st_get_bit, st_set_first_halfbit, st_set_second_halfbit);
	SIGNAL s_FSM: t_state;

begin

	process(p_i_clk) begin
		if p_i_rst = '0' then
			s_FSM <= st_idle;
			s_BUFFER <= (others => '0');
			s_BUFER_COUNTER <= "0000";
			p_o_busy <= '0';
			p_o_t_data <= 'Z';
		else

			if rising_edge(p_i_clk) and p_i_ena = '0' then

				case s_FSM is

					when st_idle => if p_i_wr = '1' then
										s_BUFFER <="11" & p_i_data;
										s_BUFER_COUNTER <= "1010";
										s_COUNT <= 0;
										p_o_busy <= '1';
										p_o_t_data <= 'Z';
										s_FSM <= st_get_bit;
									else
										s_FSM <= st_idle;
									end if;

					when st_get_bit => 	if s_BUFER_COUNTER = "0000" then
											s_FSM <= st_idle;
											p_o_busy <= '0';
											p_o_t_data <= 'Z';
										else
											s_COUNT <= c_speed;
											s_FSM <= st_set_first_halfbit;

										end if;

					when st_set_first_halfbit =>	if s_COUNT = 0 then
														s_COUNT <= c_speed;
														s_FSM <= st_set_second_halfbit;
													else
														s_COUNT <= s_COUNT - 1;
														p_o_t_data <= s_BUFFER(9);
														s_FSM <= st_set_first_halfbit;
													end if;

					when st_set_second_halfbit => 	if s_COUNT = 0 then
														s_BUFFER <= s_BUFFER(8 downto 0) & '0';
														s_BUFER_COUNTER <= s_BUFER_COUNTER - '1';
														s_FSM <= st_get_bit;
													else
														s_COUNT <= s_COUNT - 1;
														p_o_t_data <= not s_BUFFER(9);
														s_FSM <= st_set_second_halfbit;
													end if;

					when others => s_FSM <= st_idle;

				end case;

			end if;
		end if;
	end process;

end architecture;