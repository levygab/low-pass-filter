----------------------------------- bench filter-------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



library lib_RTL;
--library lib_SYNTH;
--library lib_PAR;

entity bench_filter_pipeline is
end entity;  -- bench_filter

architecture arch of bench_filter_pipeline is

  component filter_pipeline
   port(filter_in   : in  std_logic_vector(7 downto 0);
       clk         : in  std_logic;
       reset       : in  std_logic;
       adc_eocb    : in  std_logic;
       adc_convstb : out std_logic;
       adc_rdb     : out std_logic;
       adc_csb     : out std_logic;
       dac_wrb     : out std_logic;
       dac_csb     : out std_logic;
       dac_ldacb   : out std_logic;
       dac_clrb    : out std_logic;
       filter_out  : out std_logic_vector(7 downto 0)) ;
  end component;

  signal clk                                   : std_logic                    := '0';
  signal reset                                 : std_logic;
  signal filter_in                             : std_logic_vector(7 downto 0) := "00000000";
  signal filter_out                            : std_logic_vector(7 downto 0);
  signal adc_eocb                              : std_logic;
  signal adc_convstb                           : std_logic;
  signal adc_rdb                               : std_logic;
  signal adc_csb                               : std_logic;
  signal dac_wrb                               : std_logic;
  signal dac_csb                               : std_logic;
  signal dac_ldacb                             : std_logic;
  signal dac_clrb                              : std_logic;
  signal buff_oe                               : std_logic;

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

  dut : filter_pipeline
    port map (
      clk         => clk,
      reset       => reset,
      filter_in   => filter_in,
      filter_out  => filter_out,
      adc_eocb    => adc_eocb,
      adc_convstb => adc_convstb,
      adc_rdb     => adc_rdb,
      adc_csb     => adc_csb,
      dac_wrb     => dac_wrb,
      dac_csb     => dac_csb,
      dac_ldacb   => dac_ldacb,
      dac_clrb    => dac_clrb
      ) ;


  clk   <= not(clk) after 10 ns;
  reset <= '1', '0' after 45 ns;



  p_stim : process
    variable freq : real := 1000.0;
    variable t    : real;
  begin
    t         := real(now/ 1 ns)/1000000000.0;
    wait until adc_eocb = '0';
    filter_in <= std_logic_vector(to_unsigned(integer(127.0*sin(2.0*math_pi*t*freq)+127.0), 8));
    freq      := freq+1.0;
  end process;


  convertisseur_adc : process
  begin
    adc_eocb <= '1';
    wait until adc_convstb'event and adc_convstb = '0';  --detecte le
                                                         --front descendant de
                                                         --conv apres le reset
    wait for 300 ns;
    adc_eocb <= '0';
    wait for 70 ns;
    wait until (adc_rdb'event or adc_csb'event) and adc_rdb = '1' and adc_csb = '1' for 40 ns;
    adc_eocb <= '1';
    
  end process;


  assert_convstb : process              -- a completer pour chaque timing
    variable t1, t2 : time;
  begin  -- process
    wait on adc_convstb until adc_convstb = '0';
    t1 := now;
    wait on adc_convstb until adc_convstb = '1';
    t2 := now-t1;
    assert t2 >= (20 ns) report "demande de conversion trop courte" severity warning;
  end process;


  assert_readb_2convstb : process
    variable t1, t2 : time;
  begin  -- process
    wait on adc_rdb until adc_rdb = '1';
    t1 := now;
    wait on adc_convstb until adc_convstb = '0';
    t2 := now-t1;
    assert t2 >= (30 ns) report "demande de conversion top proche de la lecture" severity warning;
  end process;


  assert_readb_pulse : process
    variable t1, t2 : time;
  begin  -- process
    wait on adc_rdb until adc_rdb = '0';
    t1 := now;
    wait on adc_rdb until adc_rdb = '1';

    t2 := now-t1;
    assert t2 >= (30 ns) report "duree minimum de adc_rdb" severity warning;
  end process;


  assert_eoc_pulse : process
    variable t1, t2 : time;
  begin  -- process
    wait on adc_eocb until adc_eocb = '0';
    t1 := now;
    wait on adc_eocb until adc_eocb = '1';

    t2 := now-t1;
    assert t2 >= (70 ns) and ((110 ns) >= t2) report "duree de eocb" severity warning;
  end process;


  assert_write_pulse : process
    variable t1, t2 : time;
  begin  -- process
    wait on dac_wrb until dac_wrb = '0';
    t1 := now;
    wait on dac_wrb until dac_wrb = '1';

    t2 := now-t1;
    assert t2 >= (20 ns) report "duree minimum de dac_wrb" severity warning;
  end process;
  


end architecture;
