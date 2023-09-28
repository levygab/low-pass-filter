library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library lib_RTL;

entity bench_dac is
end entity;  -- bench_dac

architecture arch of bench_dac is

-- Time constant declaration
    constant clockcycle : time := 20 ns;
    constant half_clockcycle : time := clockcycle/2;

-- Signal declaration
    signal clk                  : std_logic := '1';
    signal reset                : std_logic;
    signal dac_conv_data        : std_logic;
    signal dac_wrb              : std_logic;
    signal dac_csb              : std_logic;
    signal dac_ldacb            : std_logic;
    signal dac_clrb             : std_logic;

-- Component declaration
    component dac_interface
        port(
            clk           : in  std_logic;
            reset         : in  std_logic;
            dac_conv_data : in  std_logic;
            dac_wrb       : out std_logic;
            dac_csb       : out std_logic;
            dac_ldacb     : out std_logic;
            dac_clrb      : out std_logic
        );
    end component;

begin

-- Port mapping
    dut  :  dac_interface
    port map (
        clk                     => clk,
        reset                   => reset,
        dac_conv_data           => dac_conv_data,
        dac_wrb                 => dac_wrb,
        dac_csb                 => dac_csb,
        dac_ldacb               => dac_ldacb,
        dac_clrb                => dac_clrb
    );

--Generation of Clock cycles and Reset pulse
    clk   <= not(clk) after half_clockcycle;
    reset <= '1', '0' after clockcycle;

-- Processing tests
    test_dac : process
    begin
        dac_conv_data <= '0';
        wait for 5*clockcycle;
        dac_conv_data <= '1';
        wait for clockcycle;
        dac_conv_data <= '0';
        wait for 5*clockcycle;
    end process;

end architecture;

