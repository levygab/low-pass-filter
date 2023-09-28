-----------------------------filtre.vhd----------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity filter_pipeline is
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
end filter_pipeline;

architecture a of filter_pipeline is

  component accu
    port(accu_in   : in  std_logic_vector(15 downto 0);
         accu_ctrl : in  std_logic;
         clk       : in  std_logic;
         reset     : in  std_logic;
         accu_out  : out std_logic_vector(20 downto 0)) ;
  end component;


  component buff
    port(buff_in  : in  std_logic_vector(7 downto 0);
         buff_oe  : in  std_logic;
         clk      : in  std_logic;
         reset    : in  std_logic;
         buff_out : out std_logic_vector(7 downto 0)) ;
  end component;


  component fsm_pipeline
    port(clk                     : in  std_logic;
         reset                   : in  std_logic;
         adc_data_ready          : in  std_logic;
         adc_data_request        : out std_logic;
         dac_conv_data           : out std_logic;
         rom_address             : out std_logic_vector(4 downto 0);
         delay_line_address      : out std_logic_vector(4 downto 0);
         delay_line_sample_shift : out std_logic;
         accu_ctrl               : out std_logic;
         buff_oe                 : out std_logic) ;
  end component;


  component mult
    port(mult_in_a : in  std_logic_vector(7 downto 0);
         mult_in_b : in  std_logic_vector(7 downto 0);
         mult_out  : out std_logic_vector(15 downto 0)) ;
  end component;


  component delay_line
    port(delay_line_in           : in  std_logic_vector(7 downto 0);
         delay_line_address      : in  std_logic_vector(4 downto 0);
         delay_line_sample_shift : in  std_logic;
         reset                   : in  std_logic;
         clk                     : in  std_logic;
         delay_line_out          : out std_logic_vector(7 downto 0)) ;
  end component;


  component rom
    port(rom_address : in  std_logic_vector(4 downto 0);
         rom_out     : out std_logic_vector(7 downto 0)) ;
  end component;


  component adc_interface is
    port(clk   : in std_logic;
         reset : in std_logic;

         adc_eocb            : in  std_logic;
         adc_data_request    : in  std_logic;
         adc_data_ready      : out std_logic;
         adc_convstb         : out std_logic;
         adc_rdb             : out std_logic;
         adc_csb             : out std_logic;
         adc_write_conv_data : out std_logic

         );
  end component;


  component dac_interface is
    port(clk           : in  std_logic;
         reset         : in  std_logic;
         dac_conv_data : in  std_logic;
         dac_wrb       : out std_logic;
         dac_csb       : out std_logic;
         dac_ldacb     : out std_logic;
         dac_clrb      : out std_logic
         );
  end component;


  component register_1 is
    port(clk, reset, enable : in  std_logic;
         shift_in           : in  std_logic_vector (7 downto 0);
         shift_out          : out std_logic_vector (7 downto 0)
         );
  end component;


  component register_2 is
    port(clk, reset, enable : in  std_logic;
         shift_in           : in  std_logic_vector (15 downto 0);
         shift_out          : out std_logic_vector (15 downto 0)
         );
  end component;


  signal delay_line_sample_shift                : std_logic;
  signal accu_ctrl                              : std_logic;
  signal buff_oe                                : std_logic;
  signal dac_conv_data                          : std_logic;
  signal adc_data_request                       : std_logic;
  signal adc_data_ready                         : std_logic;
  signal adc_write_conv_data                    : std_logic;
  signal delay_line_out, rom_out, filter_in_mem : std_logic_vector(7 downto 0);
  signal mult_out                               : std_logic_vector(15 downto 0);
  signal accu_out                               : std_logic_vector(20 downto 0);
  signal rom_address                            : std_logic_vector(4 downto 0);
  signal delay_line_address                     : std_logic_vector(4 downto 0);
  signal zero                                   : std_logic;
  signal adc_eocb_sync1                         : std_logic;
  signal adc_eocb_sync2                         : std_logic;
  signal reg_mult_accu_out                      : std_logic_vector(15 downto 0);
  signal reg_dla_mult_out                       : std_logic_vector(7 downto 0);
  signal reg_ra_mult_out                        : std_logic_vector(7 downto 0);

begin

  p_seq : process(clk)
  begin
    if (clk = '1' and clk'event)
    then
      adc_eocb_sync1 <= adc_eocb;
      adc_eocb_sync2 <= adc_eocb_sync1;
    end if;
  end process;


  u1 : rom port map (
    rom_address => rom_address,
    rom_out     => rom_out
    );

  u2 : delay_line port map (
    delay_line_in           => filter_in_mem,
    delay_line_address      => delay_line_address,
    delay_line_sample_shift => delay_line_sample_shift,
    clk                     => clk,
    reset                   => reset,
    delay_line_out          => delay_line_out
    );

  u3 : mult port map (
    mult_in_a => reg_dla_mult_out,
    mult_in_b => reg_ra_mult_out,
    mult_out  => mult_out
    );

  u4 : accu port map (
    accu_in   => reg_mult_accu_out,
    accu_ctrl => accu_ctrl,
    clk       => clk,
    reset     => reset,
    accu_out  => accu_out
    );

  u5 : buff port map (
    buff_in  => accu_out(19 downto 12),
    buff_oe  => buff_oe,
    clk      => clk,
    reset    => reset,
    buff_out => filter_out
    );

  u6 : fsm port map (
    adc_data_request        => adc_data_request,
    adc_data_ready          => adc_data_ready,
    dac_conv_data           => dac_conv_data,
    clk                     => clk,
    reset                   => reset,
    rom_address             => rom_address,
    delay_line_address      => delay_line_address,
    delay_line_sample_shift => delay_line_sample_shift,
    accu_ctrl               => accu_ctrl,
    buff_oe                 => buff_oe
    );

  u7 : adc_interface port map (
    clk                 => clk,
    reset               => reset,
    adc_data_request    => adc_data_request,
    adc_data_ready      => adc_data_ready,
    adc_eocb            => adc_eocb_sync2,
    adc_convstb         => adc_convstb,
    adc_rdb             => adc_rdb,
    adc_csb             => adc_csb,
    adc_write_conv_data => adc_write_conv_data);

  u8 : dac_interface port map (
    clk           => clk,
    reset         => reset,
    dac_conv_data => dac_conv_data,
    dac_wrb       => dac_wrb,
    dac_csb       => dac_csb,
    dac_ldacb     => dac_ldacb,
    dac_clrb      => dac_clrb);

  u9 : register_1 port map (
    clk       => clk,
    reset     => reset,
    enable    => adc_write_conv_data,
    shift_in  => filter_in,
    shift_out => filter_in_mem);

  u10 : register_2 port map (
    clk       => clk,
    reset     => reset,
    enable    => '1',
    shift_in  => mult_out,
    shift_out => reg_mult_accu_out);

  u11 : register_1 port map (
    clk       => clk,
    reset     => reset,
    enable    => '1',
    shift_in  => delay_line_out,
    shift_out => reg_dla_mult_out);

  u12 : register_1 port map (
    clk       => clk,
    reset     => reset,
    enable    => '1',
    shift_in  => rom_out,
    shift_out => reg_ra_mult_out);

end a;

