library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_1 is
  port(clk, reset, enable : in  std_logic;
       shift_in           : in  std_logic_vector (7 downto 0);
       shift_out          : out std_logic_vector (7 downto 0)
       );
end register_1;

architecture a of register_1 is
  signal reg : std_logic_vector(7 downto 0);

begin
  p_register : process (clk)
  begin
    if (clk'event and clk = '1') then
      if reset = '1' then
        reg <= (others => '0');
      elsif (enable = '1') then
        reg <= shift_in;
      end if;
    end if;
  end process p_register;

  shift_out <= reg;
end a;
