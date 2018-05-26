library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
    play : out std_logic;
	pause: out std_logic;
	play_time : out std_logic;
    cut_file: out std_logic;
    cut_time:out std_logic;
    connect_file: out std_logic_vector(1 downto 0)
) ;
end Keyboard ;

architecture rtl of Keyboard is
type state_type is (delay, start, d0, d1, d2, d3, d4, d5, d6, d7, parity, stop, finish) ;
signal data, clk, clk1, clk2, odd, fok : std_logic ; -- ë�̴����ڲ��ź�, oddΪ��żУ��
signal scancode: std_logic_vector(7 downto 0);
signal cut_or_connect: std_logic := '0';
signal time_flag: std_logic := '0';--选择时间
signal input_num: integer := 0;
signal time_num: integer := 0;
signal select_flag: std_logic := '0';
signal code : std_logic_vector(7 downto 0) ; 
signal state : state_type ;
begin
	clk1 <= clkin when rising_edge(fclk) ;
	clk2 <= clk1 when rising_edge(fclk) ;
	clk <= (not clk1) and clk2 ;
	
	data <= datain when rising_edge(fclk) ;
	
	odd <= code(0) xor code(1) xor code(2) xor code(3) 
		xor code(4) xor code(5) xor code(6) xor code(7) ;
	
	scancode <= code when fok = '1' ;
	
	process(rst, fclk)
	begin
		if rst = '1' then
			state <= delay ;
			code <= (others => '0') ;
			fok <= '0' ;
		elsif rising_edge(fclk) then
			fok <= '0' ;
			case state is 
				when delay =>
					state <= start ;
				when start =>
					if clk = '1' then
						if data = '0' then
							state <= d0 ;
						else
							state <= delay ;
						end if ;
					end if ;
				when d0 =>
					if clk = '1' then
						code(0) <= data ;
						state <= d1 ;
					end if ;
				when d1 =>
					if clk = '1' then
						code(1) <= data ;
						state <= d2 ;
					end if ;
				when d2 =>
					if clk = '1' then
						code(2) <= data ;
						state <= d3 ;
					end if ;
				when d3 =>
					if clk = '1' then
						code(3) <= data ;
						state <= d4 ;
					end if ;
				when d4 =>
					if clk = '1' then
						code(4) <= data ;
						state <= d5 ;
					end if ;
				when d5 =>
					if clk = '1' then
						code(5) <= data ;
						state <= d6 ;
					end if ;
				when d6 =>
					if clk = '1' then
						code(6) <= data ;
						state <= d7 ;
					end if ;
				when d7 =>
					if clk = '1' then
						code(7) <= data ;
						state <= parity ;
					end if ;
				WHEN parity =>
					IF clk = '1' then
						if (data xor odd) = '1' then
							state <= stop ;
						else
							state <= delay ;
						end if;
					END IF;

				WHEN stop =>
					IF clk = '1' then
						if data = '1' then
							state <= finish;
						else
							state <= delay;
						end if;
					END IF;

				WHEN finish =>
					state <= delay ;
					fok <= '1' ;
				when others =>
					state <= delay ;
			end case ; 
		end if ;
    end process ;
    
    process(scancode)
    begin
        case scancode is
            -- 32 B 播放
            when "01001100" =>
                play <= '1';
            -- 3B J 剪辑
            when "11011100" =>
                play <= '0';
            -- 29 space 暂停
            when "10010100" =>
                pause <= '1';
            -- 35 Y 剪
            when "10101100" =>
                cut_or_connect <= '1';
            -- 31 N 接
            when "10001100" =>
				cut_or_connect < ='0';
			-- 2C T 选择时间
			when "00110100" =>
				if time_flag = '1' then
					time_flag  <= '0';
				elsif time_flag = '0' then
					time_flag <= '1';
				end if;
			-- 1B S 选择视频
			when "11011000" =>
				if select_flag = '1' then
					select_flag <= '0';
				elsif select_flag = '0' then
					select_flag <= '1';
				end if;
			-- 45 0
			when "10100010" =>
				input_num <= 0;
			-- 16 1
			when "01101000" =>
				input_num <= 1;
			-- 1E 2
			when "01111000" =>
				input_num <= 2;
			-- 26 3
			when "01100100" =>
				input_num <= 3;
			-- 25 4
			when "10100100" =>
				input_num <= 4;
			-- 2E 5
			when "01110100" =>
				input_num <= 5;
			-- 36 6
			when "01101100" =>
				input_num <= 6;
			-- 3D 7
			when "10111100" =>
				input_num <= 7;
			-- 3E 8
			when "01111100" =>
				input_num <= 8;
			-- 46 9
			when "01100010" =>
				input_num <= 9;
		end case;
	end process;
	
    process(input_num,time_flag)
	begin
		if time_flag = '1' then -- 输入时间
			time_num <= time_num*10 + input_num; 
		elsif time_flag = '0' then
			if cut_or_connect = '1' then --剪时间
				cut_time <= time_num;
			elsif cut_or_connect = '0' then--播放时间
				play_time <= time_num;
			end if;
		end if;
	end process;
	
	process(input_num,select_flag,cut_or_connect)
	begin
		if select_flag = '1' then -- 选择视频
			if cut_or_connect = '1' then
				cut_file <= input_num; --剪的视频
			elsif cut_or_connect = '0 'then
				connect_file <= input_num;--接的视频，数组是不是默认一个一个输入？不确定。
			end if;
		end if;
	end process;
end rtl ;
			
						
