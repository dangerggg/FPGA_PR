library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity SDIO_read is
    port(
        SD_clk : in std_logic;
        RCA : in std_logic_vector(15 downto 0);
        read_add : in std_logic_vector(31 downto 0);
        SD_data : inout std_logic_vector(3 downto 0);
        SD_CMD : inout std_logic;
        read_data : out std_logic_vector(3 downto 0)
    );
end;

architecture bhv of SDIO_read is
    type read_state is (failed,stand_by,WAIT7,transfer_state,WAIT55,ACMD6_state,WAITa6,CMD6_check_state,CMD6_switch_state,WAIT6switch,CMD12_state,WAIT12,CMD18_state,WAIT18,sending_data);
    signal cmd7 : std_logic_vector(47 downto 0);
    signal cmd55 : std_logic_vector(47 downto 0) := x"770000000065";
    signal acmd6 : std_logic_vector(47 downto 0) := x"4600000002cb";--arg:0...0(30)10
    signal cmd6_check : std_logic_vector(47 downto 0) := x"4600fffff11f" --查询命令
    signal cmd6_switch : std_logic_vector(47 downto 0) := x"4680fffff129" --切换命令
    signal cmd12 : std_logic_vector(47 downto 0) := x"4c0000000061"
    signal cmd18 : std_logic_vector(47 downto 0);
    signal cmd_response : std_logic_vector(47 downto 0);
    signal inORout : std_logic := '0';
    signal response_valid : std_logic := '0';
	signal response_cnt : integer := 0;
    signal current_state : read_state;
    signal crc_data : std_logic_vector(39 downto 0);
    signal crc : std_logic_vector(7 downto 0);
    signal crc_temp : integer := 0;
    signal crc_data_len : integer;
begin
    cmd7(47 downto 40) <= "01000111";
    cmd7(39 downto 24) <= RCA;
    cmd7(23 downto 0)  <= "000000000000000000000001";

    crc_data(39 downto 32) <= "01010010";
    crc_data(31 downto 0) <= read_add;

    crc_data_len <= 40;

    process(crc_data_len)
    begin
        loop1: LOOP
            wait until crc_data_len = 0;
            crc_data_len <= (crc_data_len - 1);
            crc_temp <= (crc_temp xor crc_data);
            crc_data <= (crc_data + 1);
            for i in 0 to 7 LOOP 
                if((crc_temp & x"80") = TRUE) then
                    crc_temp <= ((crc_temp << 1) xor x"12");
                else
                    crc_temp <= (crc_temp << 1);
                end if;
            end LOOP;
        end LOOP loop1;
        crc_temp <= (crc_temp >> 1);
        crc <= (conv_std_logic_vector(crc_temp));
    end process;

    cmd18(47 downto 40) <= "01010010";
    cmd18(39 downto 8) <= read_add;
    cmd18(7 downto 1) <= crc;
    cmd18(0) <= "1";

    process(SD_clk)
	begin
		if(SD_clk'event and  SD_clk = '1') then
			if(SD_CMD = '0' and inORout = '0') then
				cmd_response <= cmd_response(46 downto 0) & SD_CMD;
				inORout <= '1';
				response_cnt <= response_cnt + 1;
			elsif(inORout = '1') then
				if(response_cnt < 47) then
					cmd_response <= cmd_response(46 downto 0) & SD_CMD;
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
    
    procsee(SD_clk)
    begin
        case current_state is
            when stand_by =>
            if(cmd7 /= x"000000000000") then
                SD_CMD <= cmd7(47);
                cmd7 <= cmd7(46 downto 0) & '0';
            else
                current_state <= WAIT7;
            end if;

            when WAIT7 =>
            if(response_valid = '1' and cmd_response(47 dwonto 40) = x"07") then
                current_state <= transfer_state;
            elsif(response_valid = '1' and cmd_response(47 dwonto 40) /= x"07") then
                current_state <= failed;
            end if;

            when transfer_state =>
            if(S_CMD55 /= x"000000000000") then
                SD_CMD <= cmd55(47);
                cmd55 <= cmd55(46 downto 0) & '0';
            else
                current_state <= WAIT55;
            end if;

            when WAIT55 =>
            if(response_valid = '1' and cmd_response(47 dwonto 40) = x"37") then
                current_state <= ACMD6_state;
            elsif(response_valid = '1' and cmd_response(47 dwonto 40) /= x"37") then
                current_state <= failed;
            end if;

            when ACMD6_state =>
            if(acmd6 /= x"000000000000") then
                SD_CMD <= acmd6(47);
                acmd6 <= acmd6(46 downto 0) & '0';
            else
                current_state <= WAITa6;
            end if;

            when WAITa6 =>
            if(response_valid = '1' and cmd_response(47 dwonto 40) = x"06") then
                current_state <= CMD6_check_state;
            elsif(response_valid = '1' and cmd_response(47 dwonto 40) /= x"06") then
                current_state <= failed;
            end if;
            
            when CMD6_check_state =>
            if(cmd6_check /= x"000000000000") then
                SD_CMD <= cmd6_check(47);
                acmd6 <= cmd6_check(46 downto 0) & '0';
            else
                current_state <= CMD6_switch_state;
            end if;
            
            when CMD6_switch_state =>
            if(cmd6_switch /= x"000000000000") then
                SD_CMD <= cmd6_switch(47);
                acmd6 <= cmd6_switch(46 downto 0) & '0';
            else
                current_state <= WAIT6switch;
            end if;

            when WAIT6switch =>
            if(response_valid = '1' and cmd_response(47 dwonto 40) = x"06") then
                current_state <= CMD12_state;
            elsif(response_valid = '1' and cmd_response(47 dwonto 40) /= x"06") then
                current_state <= failed;
            end if;

            when CMD12_state =>
            if(cmd12 /= x"000000000000") then
                SD_CMD <= cmd12(47);
                acmd6 <= cmd12(46 downto 0) & '0';
            else
                current_state <= WAIT12;
            end if;
            
            when WAIT12 =>
            if(response_valid = '1' and cmd_response(47 dwonto 40) = x"0c") then
                current_state <= CMD18_state;
            elsif(response_valid = '1' and cmd_response(47 dwonto 40) /= x"0c") then
                current_state <= failed;
            end if;

            when CMD18_state =>
            if(cmd18 /= x"000000000000") then
                SD_CMD <= cmd18(47);
                cmd18 <= cmd18(46 downto 0) & '0';
            else
                current_state <= WAIT18;
            end if;
            
            when WAIT18 =>
            if(response_valid = '1' and cmd_response(47 dwonto 40) = x"12") then
                current_state <= sending_data;
            elsif(response_valid = '1' and cmd_response(47 dwonto 40) /= x"12") then
                current_state <= failed;
            end if;

            when sending_data =>
            read_data <= SD_data;

            when others => null;
        end case;
    end process;
end bhv ;