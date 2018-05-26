LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
	port(
		hs, vs : out std_logic;
		r, g, b : out std_logic_vector(2 downto 0);
		rst : in std_logic;
		clk100, clk_play : in std_logic;
		
		clk25 : out std_logic;
		addr : out std_logic_vector(19 downto 0);
		memory : in std_logic_vector(31 downto 0)
	);
end VGA;

architecture bhv of VGA is
	signal r1,g1,b1   : std_logic_vector(2 downto 0);					
	signal hs1,vs1    : std_logic;				
	signal vector_x : std_logic_vector(9 downto 0);		--X坐标
	signal vector_y : std_logic_vector(8 downto 0);		--Y坐标
	signal cnt : integer := 0;
	signal clk : std_logic;
	signal x,y : integer := 0;
begin
	
	clk25 <= clk;
	process(clk100) --分频
	begin
		if(clk100'event and clk100 = '1') then
			if(cnt = 2) then
				clk <= not clk;
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	--限制二进制数范围
	process(clk, rst)
	begin
		if(rst = '0') then
			vector_x <= (others => '0');
		elsif(clk'event and clk = '1') then
			if(vector_x = 799) then
				vector_x <= (others => '0');
			else
				vector_x <= vector_x + 1;
			end if;
		end if;
	end process;
	
	process(clk, rst)
	begin
		if(rst = '0') then
			vector_y <= (others => '0');
		elsif(clk'event and clk = '1') then
			if(vector_x = 799) then
				if(vector_y = 524) then
					vector_y <= (others => '0');
				else
					vector_y <= vector_y + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(clk,rst) --行同步信号产生（同步宽度96，前沿16）
	begin
		if(rst = '0') then
			hs1 <= '1';
		elsif(clk'event and clk = '1') then
			if(vector_x >= 656 and vector_x < 752) then
				hs1 <= '0';
			else
				hs1 <= '1';
			end if;
		end if;
	end process;
	
	process(clk, rst) --vs
	begin
		if(rst = '0') then
			vs1 <= '1';
		elsif(clk'event and clk = '1') then
			if vector_y >= 490 and vector_y < 492) then
				vs1 <= '0';
			else
				vs1 <= '1';
			end if;
		end if;
	end process;
	
	process(clk, rst)
	begin 
		if(rst = '0') then 
			hs <= '0';
		elsif(clk'event and clk = '1') then
			hs <= hs1;
		end if;
	end process;
	
	process(clk, rst)
	begin
		if(rst = '0') then
			vs <= '0';
		else
			vs <= vs1;
		end if;
	end process;
	
	process(rst, clk, vector_x, vector_y)
	begin
		if(rst = '0') then 
			r1 <= "000";
			g1 <= "000";
			b1 <= "000";
		elsif(clk'event and clk = '1') then 
			x <= CONV_INTEGER(vector_x);
			y <= CONV_INTEGER(vector_y);
			if(x < 340 and y < 191) then
				addr <= CONV_STD_LOGIC_VECTOR(y * 340 + x, 16);
				r1 <= q(23 downto 21);
				g1 <= q(15 downto 13);
				b1 <= q(7 downto 5);
--				case q is
--				when "100" =>
--					r1 <= "111";
--					g1 <= "000";
--					b1 <= "000";
--				when "010" =>
--					r1 <= "000";
--					g1 <= "111";
--					b1 <= "000";
--				when "001" =>
--					r1 <= "000";
--					g1 <= "000";
--					b1 <= "111";
--				when "110" =>
--					r1 <= "111";
--					g1 <= "111";
--					b1 <= "000";
--				when "101" =>
--					r1 <= "111";
--					g1 <= "000";
--					b1 <= "111";
--				when "011" =>
--					r1 <= "000";
--					g1 <= "111";
--					b1 <= "111";
--				when "111" =>
--					r1 <= "111";
--					g1 <= "111";
--					b1 <= "111";
--				when others => 
--					r1 <= "000";
--					g1 <= "000";
--					b1 <= "000";
--				end case;
--			else
--				r1 <= "000";
--				g1 <= "000";
--				b1 <= "000";
			end if;
			r1 <= q(23 downto 21);
			g1 <= q(15 downto 13);
			b1 <= q(7 downto 5);
		end if;
	end process;
	
	process(hs1, vs1, r1, g1, b1) then
	begin
		if(hs1 = '1' and vs1 = '1') then
			r <= r1;
			g <= g1;
			b <= b1;
		else
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '0');
		end if;
	end process;
	
end bhv;
