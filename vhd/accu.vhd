------------------------------accu.vhd-----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accu is
  port(accu_in   : in  std_logic_vector(15 downto 0);
       accu_ctrl : in  std_logic;
       clk       : in  std_logic;
       reset     : in  std_logic;
       accu_out  : out std_logic_vector(20 downto 0)) ;

end accu;

architecture a of accu is
  signal accu : unsigned(20 downto 0);
begin
  
  p_accu : process (clk)
  begin
    if (clk'event and clk = '1') then
      if reset = '1' then
        accu <= (others => '0');
      elsif accu_ctrl = '1' then
        accu <= "00000" & unsigned(accu_in);
      else
        accu <= accu +("00000" & unsigned(accu_in));
      end if;
    end if;
  end process p_accu;

  accu_out <= std_logic_vector(accu);

end a;
