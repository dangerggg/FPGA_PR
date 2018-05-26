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
		r, g, b : out std_logic_vector(2 downto 0);
		
		Sram_WE : out std_logic;
		Sram_OE : out std_logic;
		Sram_CS : out std_logic;
		Sram_addr : out std_logic_vector(19 downto 0);
		Sram_data : inout std_logic_vector(31 downto 0)
	);
end top_player;


architecture bhv of top_player is

--component keyboard is
--	port(
--		
--	)
--end component;

component VGA is
	port(
		hs, vs : out std_logic;
		r, g, b : out std_logic_vector(2 downto 0);
		rst : in std_logic;
		clk100 : in std_logic;
		
		--clk25 : out std_logic;
		addr : out std_logic_vector(19 downto 0);
		memory : in std_logic_vector(31 downto 0)
	);
end component;

component fastSram is
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		VGA_addr : in std_logic;
		VGA_data : out std_logic_vector(31 downto 0);
		
		Sram_WE : out std_logic;
		Sram_OE : out std_logic;
		Sram_CS : out std_logic;
		Sram_addr : out std_logic_vector(19 downto 0);
		Sram_data : inout std_logic_vector(31 downto 0)
	);
end component;

signal vga_addr : std_logic_vector(19 downto 0);
signal vga_data : std_logic_vector(31 downto 0);

begin
	u1: VGA port map(
		hs=>hs, vs=>vs,
		r=>r, g=>g, b=>b,
		clk100=>clk100,
		rst=>rst,
		addr=>vga_addr, memory=>vga_data
	);
	
	u2: fastSram port map(
		clk=>clk100, rst=>rst,
		vGA_addr=>vga_addr, VGA_data=>vga_data,
		Sram_WE=>Sram_WE,
		Sram_OE=>Sram_OE,
		Sram_CS=>Sram_CS,
		Sram_addr=>Sram_addr, Sram_data=>Sram_data
	);
end bhv;


