------------------------------mult.vhd-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult is
  port(mult_in_a : in  std_logic_vector(7 downto 0);
       mult_in_b : in  std_logic_vector(7 downto 0);
       mult_out  : out std_logic_vector(15 downto 0)) ;
end mult;


architecture a of mult is
begin
  p_mult : process(mult_in_a, mult_in_b)
  begin
    mult_out <= std_logic_vector(unsigned(mult_in_a) * unsigned(mult_in_b));
  end process p_mult;
end a;
