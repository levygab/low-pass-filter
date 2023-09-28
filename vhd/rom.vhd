------------------------------rom.vhd-------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
  port(rom_address : in  std_logic_vector(4 downto 0);
       rom_out     : out std_logic_vector(7 downto 0)) ;
end rom;

architecture a of rom is
  type tab_rom is array (0 to 31) of std_logic_vector(7 downto 0);
  constant filter_rom : tab_rom :=
    (0  => "00001101", 1 => "00010101", 2 => "00011111", 3 => "00101100",
     --  0x0d               0x15               0x1f               0x2c
     4  => "00111100", 5 => "01001101", 6 => "01100001", 7 => "01110101",
     --  0x3c               0x4d               0x61               0x75
     8  => "10001010", 9 => "10011111", 10 => "10110011", 11 => "11000101",
     --  0x8a               0x9f               0xb3               0xc5
     12 => "11010100", 13 => "11100001", 14 => "11101001", 15 => "11101110",
     --  0xd4               0xe1               0xe9               0xee
     16 => "11101110", 17 => "11101001", 18 => "11100001", 19 => "11010100",
     --  0xee               0xe9               0xe1               0xd4
     20 => "11000101", 21 => "10110011", 22 => "10011111", 23 => "10001010",
     --  0xc5               0xb3               0x9f               0x8a
     24 => "01110101", 25 => "01100001", 26 => "01001101", 27 => "00111100",
     --  0x75               0x61               0x4d               0x3c
     28 => "00101100", 29 => "00011111", 30 => "00010101", 31 => "00001101") ;
     --  0x2c               0x1f               0x15               0xd

begin

  rom_out <= filter_rom(to_integer(unsigned(rom_address)));

end a;

