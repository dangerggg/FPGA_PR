library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package signals is
    constant WORD_WIDTH: integer := 32;
    constant ADDR_WIDTH: integer := 20;

    type RAM_REQ is record
        DOUT: std_logic_vector(31 downto 0);
        DEN: std_logic;
        ADDR: std_logic_vector(19 downto 0);
        WE_n: std_logic;
        OE_n: std_logic;
    end record;

    type RAM_RES is record
        DIN: std_logic_vector(31 downto 0);
        DONE: std_logic;
    end record;
end package;