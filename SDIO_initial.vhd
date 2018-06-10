LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SDIO_initial is
	port(
		--rst : in std_logic;
		SD_clk : in std_logic;
		SD_CMD : inout std_logic;
		SD_data : inout std_logic_vector(3 downto 0);
		initial_done : out std_logic = '0';
		RCA : out std_logic_vector(n downto 0)
	);
end SDIO_initial;

architecture bhv of SDIO_initial is
	type initial_ST is (failed, idle, S_CMD0, S_CMD8, WAIT8, S_ACMD41, WAIT41, S_CMD2, WAIT2, S_CMD3, WAIT3, standby);
	signal CMD0 : std_logic_vector(47 downto 0) := x"400000000095"
	signal CMD8 : std_logic_vector(47 downto 0) := x"48000001aa87";
	signal CMD55 : std_logic_vector(47 downto 0) := x"770000000065";
	signal ACMD41 : std_logic_vector(47 downto 0) := x"694000000077";
	signal ACMD41_tmp : std_logic_vector(47 downto 0);
	signal CMD11 : std_logic_vector(47 downto 0) := x"4b0000000077";
	signal CMD2 : std_logic_vector(47 downto 0) := x"42000000004d";
	signal CMD3 : std_logic_vector(47 downto 0) := x"430000000021";
	--signal CMD_OUT : std_logic_vector(47 downto 0);
	signal CMD_response : std_logic_vector(47 downto 0); 
	signal empty74clock : std_logic := '0';
	signal cnt, cnt0 : integer := 0;
	signal inORout : std_logic := '0';
	signal response_valid : std_logic := '0';
	signal response_cnt : integer := 0;
	signal current_state : initial_ST;
begin
	process(SD_clk)
	begin
		if(SD_clk'event and  SD_clk = '1' and empty74clock = '1')then
			if(SD_CMD = '0' and inORout = '0') then
				CMD_response <= CMD_response(46 downto 0) & SD_CMD;
				inORout <= '1';
				response_cnt <= response_cnt + 1;
			elsif(inORout = '1')
				if(response_cnt < 47) then
					CMD_response <= CMD_response(46 downto 0) & SD_CMD;
					response_cnt <= response_cnt + 1;
					response_valid <= '0';
				else
					response_cnt <= 0;
					inORout <= '0';
					response_valid <= '1';
				end if;
			end if;
		else
			response_valid <= '0';
		end if;
	end process;
	
	process(SD_clk)--放空74个时钟周期
		if(SD_clk'event and SD_clk = '1' and empty74clock = '0') then
			if(cnt < 74) then
				cnt <= cnt + 1;
			else
				empty74clock <= '1';
			end if;
		end if;
	end process;
			
	process(SD_clk)
	begin
		if(SD_clk'event and SD_clk = '1' and empty74clock = '1') then
			if(empty74clock = '0') then
				initial_done <= '0';
				current_state <= idle;
			else
				case current_state is
				when idle =>
					initial_done <= '0';
					current_state <= S_CMD0;
				when S_CMD0 =>
					if(CMD0 /= x"000000000000") then
						SD_CMD <= CMD0(47);
						CMD0 <= CMD(46 downto 0) & '0';
					else
						current_state <= S_CMD8;
					end if;
				when S_CMD8 =>
					if(CMD8 /= x"000000000000") then
						SD_CMD <= CMD8(47);
						CMD8 <= CMD8(46 downto 0) & '0';
					else
						current_state <= WAIT8;
					end if;
				when WAIT8 => 
					if(response_valid = '1' and CMD_response(19 downto 16) = "0001") then
						current_state <= S_CMD55;
					else if(response_valid = '1' and CMD_response(19 downto 16) /= "0001") then
						current_state <= failed;
					end if;
				when S_CMD55 =>
					if(S_CMD55 /= x"000000000000") then
						SD_CMD <= CMD55(47);
						CMD55 <= CMD55(46 downto 0) & '0';
					else
						if(response_valid = '1' and CMD_response(47 dwonto 40) = x"37") then
							current_state <= S_ACMD41;
							ACMD41_tmp <= ACMD41;
						elsif(response_valid = '1' and CMD_response(47 dwonto 40) /= x"37") then
							current_state <= failed;
						end if;
					end if;
				when S_ACMD41 => 
					if(ACMD41_tmp /= x"000000000000") then
						SD_CMD <= ACMD41_tmp(47);
						ACMD41_tmp <= ACMD41_tmp(46 downto 0) & '0';
					else
						current_state <= WAIT41;
					end if;
				when WAIT41 =>
					if(response_valid = '1' and CMD_response(31) = '1') then
						current_state <= S_CMD2;
					elsif(response_valid = '1' and CMD_response(31) = '0') then
						ACMD41_tmp <= ACMD41;
						current_state <= S_ACMD41;
					end if;
				when S_CMD2 =>
					if(S_CMD2 /= x"000000000000") then
						SD_CMD <= CMD2(47);
						CMD2 <= CMD2(46 downto 0) & '0';
					else
						current_state <= WAIT2;
					end if
				when WAIT2 => 
					if(cnt0 < 138) then
						cnt0 <= cnt0 + 1;
					else
						current_state <= S_CMD3;
					end if;
				when S_CMD3 =>
					if(S_CMD3 /= x"000000000000") then
						SD_CMD <= CMD3(47);
						CMD3 <= CMD3(46 downto 0) & '0';
					else
						current_state <= WAIT3;
					end if;
				when WAIT3 =>
					if(response_valid = '1' and CMD_response(45 downto 40) = "000011")then	
						RCA <= CMD_response(31 downto 16);
						current_state <= standby;
						initial_done <= '1';
					elsif(response_valid = '1' and CMD_response(45 downto 40) /= "000011") then
						current_state <= failed;
						initial_done <= '0';
					end if;
				when standby =>
					initial_done <= '1';
				when others => null;
				end case;
			end if;
		end if;
	end process;				
				
end bhv;