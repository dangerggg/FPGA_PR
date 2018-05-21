library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
    -- scancode : out std_logic_vector(7 downto 0) -- scan code signal output
    play : out std_logic;-- play:B 1;edit:J 0
    cut: out std_logic;
    connect out std_logic;
    pause: out std_logic-- space 1
    --time_data: out std_logic;
);
end Keyboard ;

architecture rtl of Keyboard is
type state_type is (delay, start, d0, d1, d2, d3, d4, d5, d6, d7, parity, stop, finish) ;
signal data, clk, clk1, clk2, odd, fok : std_logic ; -- ë�̴����ڲ��ź�, oddΪ��żУ��
signal scancode: std_logic_vector(7 downto 0);
signal edit_flag: std_logic := '0';
signal play_or_edit: std_logic;
signal cut_or_connect: std_logic;
--signal select_time,time_flag: std_logic := '0';--选择时间
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
            -- 32 B
            when '01001100' =>
                play_or_edit <= '1'
            -- 3B J
            when '11011100' =>
                play_or_edit <= '0'
            -- 2C T
            -- when '00110100' =>
            --     if time_flag = '0' then
            --         select_time <= '1'
            --         time_flag <= '1'
            --     else if time_flag = '1' then
            --         select_time <= '0'
            --         time_flag <= '0'

            -- 29 space
            when '10010100' =>
                pause <= '1';
            -- 35 Y �?
            when '10101100' =>
                cut_or_connect <= '1';
            -- 31 N �?
            when '10001100' =>
                cut_or_connect < ='0';
			end case;
    end process;
    
    process(play_or_edit,cut_or_connect)
    begin
        if play_or_edit = '1' then
            play <= '1';
        elsif play_or_edit = '0' then
            if cut_or_connect = '1' then
                cut <= '1';
            elsif cut_or_connect ='0' then
                connect <= '1';
			end if;
		end if;
    end process;


    -- process(select_time,scancode)
    -- begin
    --     if select_time = '1' then

    -- end process
end rtl ;
			
						
