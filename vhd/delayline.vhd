-----------------------------regdec.vhd----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity delay_line is
  port(delay_line_in           : in  std_logic_vector(7 downto 0);
       delay_line_address      : in  std_logic_vector(4 downto 0);
       delay_line_sample_shift : in  std_logic;
       reset                   : in  std_logic;
       clk                     : in  std_logic;
       delay_line_out          : out std_logic_vector(7 downto 0)) ;
end delay_line;

architecture a of delay_line is
  type delay_line is array (0 to 31) of std_logic_vector(7 downto 0);
  signal x : delay_line;

begin
  p_dl : process(clk)
  begin

    if (clk'event and clk = '1') then
      if (reset = '1') then
        for i in x'range loop
          x(i) <= (others => '0');
        end loop;
      elsif (delay_line_sample_shift = '1') then
        x(0) <= delay_line_in;
        for i in x'low to (x'high - 1) loop
          x(i+1) <= x(i);
        end loop;
      end if;
    end if;
  end process p_dl;

  delay_line_out <= x(to_integer(unsigned(delay_line_address)));
end a;
