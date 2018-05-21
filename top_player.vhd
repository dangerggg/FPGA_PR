LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_player is
	port(
		clk100 : in std_logic; --100M
		clk : in std_logic; --11M
		datain, clkPS2 : in std_logic;
		rst : in std_logic; --reset signal
		hs, vs : out std_logic; --行场同步信号
		r, g, b : out std_logic_vector(2 downto 0)
	);
end top_player;


architecture bhv of top_player is

component keyboard is
	port(
		
	)
end component;

component VGA is
	port(
	
	)
end component;
begin
