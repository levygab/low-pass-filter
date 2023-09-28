library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library lib_RTL;

entity bench_fsm_pipeline is
end entity;  -- bench_fsm

architecture arch of bench_fsm_pipeline is

-- Constant declaration
    constant clockcycle        : time     := 20 ns;
    constant half_clockcycle   : time     := clockcycle/2;
    constant N_BENCH           : integer  := 5;

-- Signal declaration
    signal clk                       : std_logic := '1';
    signal reset                     : std_logic;
    signal adc_data_ready            : std_logic;
    signal adc_data_request          : std_logic;
    signal dac_conv_data             : std_logic;
    signal rom_address               : std_logic_vector(N_BENCH-1 downto 0);
    signal delay_line_address        : std_logic_vector(N_BENCH-1 downto 0);
    signal delay_line_sample_shift   : std_logic;
    signal accu_ctrl                 : std_logic;
    signal buff_oe                   : std_logic;

-- Component declaration
    component fsm
        generic( N : integer := 5 );
        port(
            clk                     : in  std_logic;
            reset                   : in  std_logic;
            adc_data_ready          : in  std_logic;
            adc_data_request        : out std_logic;
            dac_conv_data           : out std_logic;
            rom_address             : out std_logic_vector(N-1 downto 0);
            delay_line_address      : out std_logic_vector(N-1 downto 0);
            delay_line_sample_shift : out std_logic;
            accu_ctrl               : out std_logic;
            buff_oe                 : out std_logic
        );
    end component;

begin

-- Port mapping
    dut  :  fsm
    generic map ( N => N_BENCH )
    port map (
        clk                         => clk,
        reset                       => reset,
        adc_data_ready              => adc_data_ready,
        adc_data_request            => adc_data_request,
        dac_conv_data               => dac_conv_data,
        rom_address                 => rom_address,
        delay_line_address          => delay_line_address,
        delay_line_sample_shift     => delay_line_sample_shift,
        accu_ctrl                   =>accu_ctrl,
        buff_oe                     => buff_oe
    );

--Generation of Clock cycles and Reset pulse
    clk   <= not(clk) after half_clockcycle;
    reset <= '1', '0' after clockcycle;

-- Processing tests
    test_fsm : process
    begin
        adc_data_ready   <= '1';
        wait for 2*clockcycle;
        adc_data_ready   <= '0';
        wait for 2*clockcycle;
        adc_data_ready   <= '1';
        wait for 35*clockcycle;
        adc_data_ready   <= '1';
        wait for 2*clockcycle;
        adc_data_ready   <= '0';
    end process;

end architecture;





