LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fastSram is 
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
end fastSram;	
	
	
architecture bhv of fastSram is
type memory_state is (idle, mem_read, mem_write, mem_end);
signal current_state : memory_state;
signal addrin : std_logic(19 downto 0);
signal datain : std_logic(31 downto 0);
signal clk50, clk25 : std_logic;
signal readOrwrite : std_logic_vector(1 downto 0) := '00';
begin
-------------------------------------------时钟分频
	process(clk, rst)
	begin
		if clk'event and clk = '1' then 
			clk50 <= not clk50;
		end if;
	end process;
	
	process(clk50, rst)
	begin
		if clk50'event and clk50 = '1' then
			clk25 <= not clk25;
		end if;
	end process;
--------------------------------------------	
--	process(rst, clk50)
--	begin
--		if rst = '0' then
--			current_state <= idle;
--			addrin <= (others => '0');
--		elsif clk50'event and clk50 = '1' then 
--			current_state <= mem_read;
--		end if;
--	end process;
	
	process(clk, rst)
	begin
		if rst = '0' then
			Sram_CS <= '1';
			Sram_WE <= '1';
			Sram_OE <= '1';
			readOrwrite <= "00";
		elsif clk50'event and clk50 = '1' then
			case readOrwrite is 
				when "00" =>
					Sram_CS <= '1';
					Sram_WE <= '1';
					Sram_OE <= '1';
					--readOrwrite <= "01";
				when "01" =>
					Sram_CS <= '0';
					Sram_OE <= '1';
					Sram_WE <= '0';
					Sram_addr <= SD_addr;
					Sram_data <= SD_data;
					readOrwrite <= "10";
				when "10" =>
					Sram_CS <= '0';
					Sram_addr <= Vga_addr;
					Sram_OE <= '0';
					Sram_WE <= '1';
					vga_data <= Sram_data;
					readOrwrite <= "01";
				when "11" => null;
			end case;
					
--			case current_state is
--				when idle =>
--					Sram_CS <= '1';
--					Sram_WE <= '1';
--					Sram_OE <= '1';
--					current_state <= mem_read;
--				when mem_read =>
--					Sram_CS <= '0';
--					Sram_addr <= Vga_addr;
--					Sram_OE <= '0';
--					Sram_WE <= '1';
--					datain <= Sram_data
--					current_state <= idle;
--				when mem_write => null;
--			end case;
		end if;
	end process;
		
	process(datain, rst)
	begin
		if rst = '0' then
			Vga_addr <= (others => '0');
		else
			Vga_addr <= datain;
		end if;
	end process;
end bhv;