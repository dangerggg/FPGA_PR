library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity keyboard_top is
port(
datain,clkin,fclk,rst_in: in std_logic;
play: out std_logic;
pause: out std_logic;
time_num: out integer;--time select output
select_num: out integer--vedio select output
);
end keyboard_top;

architecture behave of keyboard_top is

component Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end component ;

signal scancode : std_logic_vector(7 downto 0);
signal rst : std_logic;
signal clk_f: std_logic;
signal input_num : integer := 0;
signal time_flag : std_logic := '0';
signal cut_flag : std_logic := '0';
signal connect_flag : std_logic := '0';
signal select_flag : std_logic := '0';

begin
rst<=not rst_in;

process(scancode,time_flag,cut_flag,connect_flag,select_flag)
begin
	-- 'B' PLAY
	if (scancode(3 downto 0) = "0010")and (scancode(7 downto 4) = "0011") then
			play <= '1';
	else
		play <= '0';
	end if;
	-- 'space' pause
	if (scancode(3 downto 0) = "1001") and (scancode(7 downto 4) = "0010") then 
			pause <= '1';
	else
		pause <= '0';
	end if;
	-- T select play time
	if (scancode(3 downto 0) = "1100")and (scancode(7 downto 4) = "0010") and (time_flag = '0')then
		time_flag <= '1';
	elsif (scancode(3 downto 0) = "1100")and (scancode(7 downto 4) = "0010") and (time_flag = '1')then
		time_num <= input_num;
		input_num <= 0;
		time_flag <= '0';
	end if;
	-- Y cut vedio
	if (scancode(3 downto 0) = "0101")and (scancode(7 downto 4) = "0011") and (cut_flag = '0')then
			cut_flag <= '1';
	end if;
	-- N connect vedio
	if (scancode(3 downto 0) = "0010")and (scancode(7 downto 4) = "0011") and (connect_flag = '0') then
			connect_flag <= '1';
	end if;
	-- S select 
	if (scancode(3 downto 0) = "1011")and (scancode(7 downto 4) = "0001") and (select_flag = '0')then
		select_flag <= '1';
	elsif (scancode(3 downto 0) = "1011")and (scancode(7 downto 4) = "0001") and (select_flag = '1')then
		select_num <= input_num;
		input_num <= 0;
		select_flag <= '0';
	end if;
	--检测输入数字
	if (scancode(3 downto 0) = "0101") and (scancode(7 downto 4) = "0100") then 
			input_num <= input_num * 10;
	end if;
	if (scancode(3 downto 0) = "0110") and (scancode(7 downto 4) = "0001") then 
			input_num <= input_num * 10 + 1;
	end if;
	if (scancode(3 downto 0) = "1110") and (scancode(7 downto 4) = "0001") then 
			input_num <= input_num * 10 + 2;
	end if;
	if (scancode(3 downto 0) = "0110") and (scancode(7 downto 4) = "0010") then 
			input_num <= input_num * 10 + 3;
	end if;
	if (scancode(3 downto 0) = "0101") and (scancode(7 downto 4) = "0010") then 
			input_num <= input_num * 10 + 4;
	end if;
	if (scancode(3 downto 0) = "1110") and (scancode(7 downto 4) = "0010") then 
			input_num <= input_num * 10 + 5;
	end if;
	if (scancode(3 downto 0) = "0110") and (scancode(7 downto 4) = "0011") then 
			input_num <= input_num * 10 + 6;
	end if;
	if (scancode(3 downto 0) = "1101") and (scancode(7 downto 4) = "0011") then 
			input_num <= input_num * 10 + 7;
	end if;
	if (scancode(3 downto 0) = "1110") and (scancode(7 downto 4) = "0011") then 
			input_num <= input_num * 10 + 8;
	end if;
	if (scancode(3 downto 0) = "0110") and (scancode(7 downto 4) = "0100") then 
			input_num <= input_num * 10 + 9;
	end if;
end process;
		
u0: Keyboard port map(datain,clkin,fclk,rst,scancode);
end behave;