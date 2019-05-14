---
 -- Copyright (c) 2019 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in license.txt; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---

library ieee;
use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

---
 -- (W)ish(B)one (GPIO) (SLAVE)
 --
 -- simple slave using standard READ/WRITE cycles over an 8b bus
 -- GPIO width is fixed at 8 bits and is output only -> keepin' it easy for now
 -- this is just a quick attempt to build my first experiences with wishbone
 --
 -- handles pipelined block cycles just fine
---

entity wbs_gpo is
  generic( TPD : time := 0 ns );
  port( wb_clk_i  : in  std_logic;
        wb_srst_i : in  std_logic;
        --
        wb_cyc_i  : in  std_logic;
        wb_stb_i  : in  std_logic;
        wb_we_i   : in  std_logic;
        wb_dat_i  : in  std_logic_vector(7 downto 0);
        wb_ack_o  : out std_logic;
        --
        gpo_o     : out std_logic_vector(7 downto 0) );
end entity;

architecture dfault of wbs_gpo is

  signal gpo : std_logic_vector(gpo_o'range);
  signal ack : std_logic;

begin

  process(wb_clk_i, wb_srst_i)
  begin
    if wb_srst_i then
      gpo <= (others=>'0');
      ack <= '0';
    elsif rising_edge(wb_clk_i) then
      ack <= '0';
      if wb_cyc_i and wb_stb_i and wb_we_i then
        gpo <= wb_dat_i;
        ack <= '1';
      end if;
    end if;
  end process;

  -- output
  gpo_o    <= gpo after TPD;
  wb_ack_o <= ack after TPD;

end architecture;