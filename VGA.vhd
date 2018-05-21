LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
	port(
		VGA_CLK : out std_logic;
		hs, vs : out std_logic;
		r, g, b : out std_logic_vector(2 downto 0);
		rst : in std_logic;
		clk25 : in std_logic
	);
end VGA;

architecture bhv of VGA is

begin

end bhv;
