library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity keyboard_top is
port(
datain,clkin,fclk,rst_in: in std_logic;
play: out std_logic;
pause: out std_logic;
--seg0,seg1:out std_logic_vector(6 downto 0)
);
end top;

architecture behave of keyboard_top is

component Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end component ;

--component seg7 is
--port(
--code: in std_logic;
--seg_out : out std_logic_vector(6 downto 0)
--);
--end component;

signal scancode : std_logic_vector(7 downto 0);
signal play: std_logic := '0';
signal pause: std_logic := '0';
signal rst : std_logic;
signal clk_f: std_logic;
begin
rst<=not rst_in;

process(scancode)
begin
	if (scancode(3 downto 0) = "0110")and (scancode(7 downto 4) = "0001") then
			play <= '1';
	else
		play <= '0';
	end if;
	
	if (scancode(3 downto 0) = "1110") and (scancode(7 downto 4) = "0001") then 
			pause <= '1';
	else
		pause <= '0';
	end if;
end process;
		

u0: Keyboard port map(datain,clkin,fclk,rst,scancode);
--u1: seg7 port map(play,seg0);
--u2: seg7 port map(pause,seg1);

end behave;

