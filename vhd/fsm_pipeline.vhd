------------------------------fsm.vhd----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
  generic( 
    N         : integer     := 5;
    MAX_COUNT : integer     := 31
  );
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
end fsm;

-- machine à états contrôlant le filtre numérique.

architecture arch of fsm is
  type state is (reset_sig, req, wait_data, delay, add, buff, write, wait_reg, wait_accu);
  signal current_state, next_state        : state;
  signal count, new_count                 : std_logic_vector(N-1 downto 0);

begin
  p_seq : process(clk, reset)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        current_state     <= reset_sig;
      else
        current_state     <= next_state;
      end if;
    count <= new_count;
    end if;
  end process p_seq;

  p_comb : process(current_state, count, new_count, reset, adc_data_ready)
  begin
    adc_data_request <= '0';
    delay_line_sample_shift <= '0';
    accu_ctrl <= '0';
    buff_oe <= '0';
    dac_conv_data <= '0';
    rom_address <= (others => '0');
    delay_line_address <= (others => '0');

    case current_state is
      when reset_sig =>
        next_state <= req;
        new_count <= (others => '1');

      when req =>
        adc_data_request <= '1';
        next_state <= wait_data;
        new_count <= (others => '0');

      when wait_data =>
        if adc_data_ready = '1' then
          next_state <= delay;
        else
          next_state <= wait_data;
        end if;
        new_count <= (others => '0');

      when delay =>
        delay_line_sample_shift <= '1';
        next_state <= wait_reg;
        new_count <= (others => '0');

      when wait_reg =>
        if unsigned(count) = 0 then
          rom_address <= std_logic_vector(unsigned(count));
          delay_line_address <= std_logic_vector(unsigned(count));
          new_count <= std_logic_vector(unsigned(count)+1);
          next_state <= wait_reg;
        else 
          rom_address <= std_logic_vector(unsigned(count));
          delay_line_address <= std_logic_vector(unsigned(count));
          new_count <= std_logic_vector(unsigned(count)+1);
          next_state <= add;
        end if;

      when add =>
        if unsigned(count) = 2 then
          accu_ctrl <= '1';
          rom_address <= std_logic_vector(unsigned(count));
          delay_line_address <= std_logic_vector(unsigned(count));
          new_count <= std_logic_vector(unsigned(count)+1);
          next_state <= add;
        elsif unsigned(count) = MAX_COUNT then
          next_state <= wait_accu;
          rom_address <= std_logic_vector(unsigned(count));
          delay_line_address <= std_logic_vector(unsigned(count));
          new_count <= (others => '0');
        else
          next_state <= add;
          new_count <= std_logic_vector(unsigned(count)+1);
          rom_address <= std_logic_vector(unsigned(count));
          delay_line_address <= std_logic_vector(unsigned(count));
        end if;

      when wait_accu =>
        if unsigned(count) = 0 then
          new_count <= std_logic_vector(unsigned(count)+1);
          next_state <= wait_accu;
        else
          new_count <= (others => '0');
          next_state <= buff;
        end if;

      when buff =>
        buff_oe <= '1';
        next_state <= write;
        new_count <= (others => '0');

      when write =>
        dac_conv_data <= '1';
        next_state <= req;
        new_count <= (others => '0');

    end case;
  end process p_comb;
end arch;


