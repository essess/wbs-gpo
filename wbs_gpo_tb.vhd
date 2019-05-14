---
 -- Copyright (c) 2019 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee, vunit_lib;
use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

context vunit_lib.vunit_context;
context vunit_lib.vc_context;     --< pickup wishbone_pkg+

entity wbs_gpo_tb is
  generic( runner_cfg : string;
           tclk : time := 10 ns;
           TPD  : time := 2  ns );
end entity;

architecture dfault of wbs_gpo_tb is

  constant WAITCLK : integer := 2;
  signal   clkcnt  : natural := 0;
  signal   clk     : std_logic;

  signal srst, cyc, stb, we, ack : std_logic;
  signal dat : std_logic_vector(7 downto 0);
  signal gpo : std_logic_vector(7 downto 0);
  signal adr : std_logic_vector(0 downto 0);                          --< unused/stub

  constant wbm : bus_master_t := new_bus( data_length    => dat'length,
                                          address_length => adr'length );

  signal sel : std_logic_vector(byte_enable_length(wbm)-1 downto 0);  --< unused/stub

begin

  dut : entity work.wbs_gpo
    generic map( TPD => TPD )
    port map( wb_clk_i  => clk,
              wb_srst_i => srst,
              wb_cyc_i  => cyc,
              wb_stb_i  => stb,
              wb_we_i   => we,
              wb_dat_i  => dat,
              wb_ack_o  => ack,
              gpo_o     => gpo );

  bm : entity vunit_lib.wishbone_master
    generic map ( bus_handle => wbm )
    port map ( clk   => clk,
               adr   => adr,
               dat_i => x"00",
               dat_o => dat,
               sel   => sel,
               cyc   => cyc,
               stb   => stb,
               we    => we,
               stall => '0',
               ack   => ack );

  test_runner_watchdog(runner, 1 ms);

  tb : process
  begin
    test_runner_setup(runner, runner_cfg);

    ---
     -- runs for every test / 'prolog'
    ---
    wait for 1*tclk;
    srst <= '1';
    wait until clkcnt = 1;
    wait for TPD;
    srst <= '0';
    wait until clkcnt = 3;


    if run("CLASSIC_NON-PIPELINED") then
      write_bus( net, wbm, 0, x"11" );
      wait_until_idle( net, wbm );
      check( gpo = x"11" );
      write_bus( net, wbm, 0, x"22" );
      wait_until_idle( net, wbm );
      check( gpo = x"22" );
      write_bus( net, wbm, 0, x"33" );
      wait_until_idle( net, wbm );
      check( gpo = x"33" );
    elsif run("CLASSIC_PIPELINED") then
      write_bus( net, wbm, 0, x"44" );
      wait until rising_edge(clk); wait for TPD;
      check( gpo = x"44" );
      write_bus( net, wbm, 0, x"55" );
      wait until rising_edge(clk); wait for TPD;
      check( gpo = x"55" );
      write_bus( net, wbm, 0, x"66" );
      wait until rising_edge(clk); wait for TPD;
      check( gpo = x"66" );
      wait_until_idle( net, wbm );
--  elsif run("BURST") then
--    -- burst_write_bus() not supported by vunit_lib.wishbone_master
--    -- classic pipelined is essentially the same thing anyways
    end if;

    ---
     -- runs for every test / 'epilog'
    ---
    wait for 1*tclk;

    test_runner_cleanup(runner);
  end process;

  sysclk : process
  begin
    wait for WAITCLK*tclk;
    loop
      clk <= '0'; wait for tclk/2;
      clk <= '1'; clkcnt <= clkcnt +1;
                  wait for tclk/2;
    end loop;
  end process;

end architecture;
