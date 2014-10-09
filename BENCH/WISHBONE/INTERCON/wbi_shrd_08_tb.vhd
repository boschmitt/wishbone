--======================================================================================================================
-- Copyright (c) 2014, Bruno Schmitt <boschmitt [at] inf [dot] ufrgs [dot] br
-- All rights reserved.
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--======================================================================================================================
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

use work.COMMON_TB_pkg.all;

library WISHBONE;
   use WISHBONE.WB_pkg.all;
   use WISHBONE.WBI_pkg.all;
   use WISHBONE.WBS_pkg.all;
   use WISHBONE.WB_TESTBENCH_pkg.all;


entity WBI_SHRD_08_TB is
end entity;

architecture testbench of WBI_SHRD_08_tb is
   --===================================================================================================================
   -- Constants
   --===================================================================================================================
   constant CLK_PERIOD_c   : time := 10 ns;
   constant CLK_PHASE_c    : time := 0 ns;
   constant RST_DELAY_c    : time := 0 ns;
   constant RST_DURATION_c : time := 15 ns;

   -- Wishbone
   constant WB_N_SLAVES_c  : integer      := 3;       -- # of slaves in the bus
   constant WB_CD_AWIDTH_c : integer      := 16;
   constant WB_MEMMAP_c    : WBI_MEMMAP_t := ( (16#0000#, 16#4#),
                                               (16#1000#, 16#4#),
                                               (16#1020#, 16#4#) );
   -- Slaves IDs
   constant CS_REGS0_c : integer := 0;
   constant CS_REGS1_c : integer := 1;
   constant CS_REGS2_c : integer := 2;
   --===================================================================================================================
   -- Signals
   --===================================================================================================================
   signal CLK_s : std_logic;
   signal RST_s  : std_logic;

   signal SEL_s  : std_logic_vector(0 downto 0);  -- Not used for this TB

   -- Master bus
   signal WBM_ADR_s  : WB_ADR_t;
   signal WBM_DATR_s : WB_BYTE_t;
   signal WBM_DATW_s : WB_BYTE_t;
   signal WBM_WE_s   : std_logic;
   signal WBM_STB_s  : std_logic;
   signal WBM_CYC_s  : std_logic;
   signal WBM_ACK_s  : std_logic;
   signal WBM_ERR_s  : std_logic;
   signal WBM_RTY_s  : std_logic;

   -- Slave bus
   signal WBS_ADR_s  : WB_ADR_t;
   signal WBS_DATW_s : WB_BYTE_t;
   signal WBS_DATR_s : WBI_BYTE_BUS_t(0 to WB_N_SLAVES_c - 1);
   signal WBS_WE_s   : std_logic;
   signal WBS_STB_s  : std_logic_vector(0 to WB_N_SLAVES_c - 1);
   signal WBS_ACK_s  : std_logic_vector(0 to WB_N_SLAVES_c - 1);
   signal WBS_CYC_s  : std_logic_vector(0 to WB_N_SLAVES_c - 1);
   signal WBS_ERR_s  : std_logic_vector(0 to WB_N_SLAVES_c - 1);
   signal WBS_RTY_s  : std_logic_vector(0 to WB_N_SLAVES_c - 1);

   signal REGSW0_s : WBS_REGS_BANK_08_t(0 to 3);
   signal REGSR0_s : WBS_REGS_BANK_08_t(0 to 3);
   signal REGSW1_s : WBS_REGS_BANK_08_t(0 to 3);
   signal REGSR1_s : WBS_REGS_BANK_08_t(0 to 3);
   signal REGSW2_s : WBS_REGS_BANK_08_t(0 to 3);
   signal REGSR2_s : WBS_REGS_BANK_08_t(0 to 3);

begin
--======================================================================================================================
-- Clock and Reset
--======================================================================================================================
   p_CLK: GENERATE_CLOCK(
      CLOCK_PERIOD_c => CLK_PERIOD_c,
      CLOCK_PULSE_c  => CLK_PERIOD_c/2,
      CLOCK_PHASE_c  => CLK_PHASE_c,
      CLK_o => CLK_s
   );

   p_SYNC_RST: SYNC_RST(
      DELAY_c    => RST_DELAY_c,
      DURATION_c => RST_DURATION_c,
      CLK_i      => CLK_s,
      RST_o      => RST_s
   );
--======================================================================================================================
-- Master
--======================================================================================================================
   p_MASTER: process
   begin

      WBM_WAIT_RESET( ADR_o => WBM_ADR_s, DAT_o => WBM_DATW_s, WE_o  => WBM_WE_s,  STB_o => WBM_STB_s, SEL_o => SEL_s,
                      ACK_i => WBM_ACK_s, CYC_o => WBM_CYC_s,  ERR_i => WBM_ERR_s, RTY_i => WBM_RTY_s,
                      RST_i => RST_s,     CLK_i => CLK_s );

      WBM_STD_SINGLEWRITE( ADR_c => x"0000",   SEL_c => "0",        DATA_c => x"A4",
                           ADR_o => WBM_ADR_s, DAT_o => WBM_DATW_s, WE_o  => WBM_WE_s,  STB_o => WBM_STB_s, SEL_o => SEL_s,
                           ACK_i => WBM_ACK_s, CYC_o => WBM_CYC_s,  ERR_i => WBM_ERR_s, RTY_i => WBM_RTY_s,
                           CLK_i => CLK_s );

      WBM_STD_SINGLEWRITE( ADR_c => x"1000",   SEL_c => "0",        DATA_c => x"BC",
                           ADR_o => WBM_ADR_s, DAT_o => WBM_DATW_s, WE_o  => WBM_WE_s,  STB_o => WBM_STB_s, SEL_o => SEL_s,
                           ACK_i => WBM_ACK_s, CYC_o => WBM_CYC_s,  ERR_i => WBM_ERR_s, RTY_i => WBM_RTY_s,
                           CLK_i => CLK_s );

      WBM_STD_SINGLEWRITE( ADR_c => x"0001",   SEL_c => "0",        DATA_c => x"CD",
                           ADR_o => WBM_ADR_s, DAT_o => WBM_DATW_s, WE_o  => WBM_WE_s,  STB_o => WBM_STB_s, SEL_o => SEL_s,
                           ACK_i => WBM_ACK_s, CYC_o => WBM_CYC_s,  ERR_i => WBM_ERR_s, RTY_i => WBM_RTY_s,
                           CLK_i => CLK_s );

      WBM_STD_SINGLEWRITE( ADR_c => x"1020",   SEL_c => "0",        DATA_c => x"FF",
                           ADR_o => WBM_ADR_s, DAT_o => WBM_DATW_s, WE_o  => WBM_WE_s,  STB_o => WBM_STB_s, SEL_o => SEL_s,
                           ACK_i => WBM_ACK_s, CYC_o => WBM_CYC_s,  ERR_i => WBM_ERR_s, RTY_i => WBM_RTY_s,
                           CLK_i => CLK_s );

      wait;

   end process;
--======================================================================================================================
-- Wishbone mux
--======================================================================================================================
   u_UTT: entity WISHBONE.WBI_SHRD_08
   generic map(
      WB_CD_AWIDTH_g => 16,
      WB_N_SLAVES_g  => WB_N_SLAVES_c,
      WB_MEMMAP_g    => WB_MEMMAP_c
   )
   port map (
      CLK_i      => CLK_s,
      RST_i      => RST_s,
      CLK_EN_i   => '1',
      WBM_ADR_i  => WBM_ADR_s,
      WBM_DAT_i  => WBM_DATW_s,
      WBM_DAT_o  => WBM_DATR_s,
      WBM_WE_i   => WBM_WE_s,
      WBM_STB_i  => WBM_STB_s,
      WBM_ACK_o  => WBM_ACK_s,
      WBM_CYC_i  => WBM_CYC_s,
      WBM_ERR_o  => WBM_ERR_s,
      WBM_RTY_o  => WBM_RTY_s,
      WBS_ADR_o  => WBS_ADR_s,
      WBS_DAT_i  => WBS_DATR_s,
      WBS_DAT_o  => WBS_DATW_s,
      WBS_WE_o   => WBS_WE_s,
      WBS_STB_o  => WBS_STB_s,
      WBS_ACK_i  => WBS_ACK_s,
      WBS_CYC_o  => WBS_CYC_s,
      WBS_ERR_i  => WBS_ERR_s,
      WBS_RTY_i  => WBS_RTY_s
   );
--======================================================================================================================
-- Slave 0
--======================================================================================================================
   u_REGS0: entity WISHBONE.WBS_REGS_08
   generic map(
      WB_DA_WIDTH_g => 16,
      REGS_RD_g     => 4,
      REGS_WR_g     => 4
   )
   port map(
      ADR_i     => WBS_ADR_s,
      DAT_i     => WBS_DATW_s,
      DAT_o     => WBS_DATR_s(CS_REGS0_c),
      WE_i      => WBS_WE_s,
      STB_i     => WBS_STB_s(CS_REGS0_c),
      ACK_o     => WBS_ACK_s(CS_REGS0_c),
      CYC_i     => WBS_CYC_s(CS_REGS0_c),
      ERR_o     => WBS_ERR_s(CS_REGS0_c),
      RTY_o     => WBS_RTY_s(CS_REGS0_c),
      REG_DAT_i => REGSR0_s,
      REG_DAT_o => REGSW0_s,
      RST_i      => RST_s,
      CLK_i      => CLK_s,
      CLK_EN_i   => '1'
   );

   --WBS_ERR_s(CS_REGS0_c) <= '0';
   --WBS_RTY_s(CS_REGS0_c) <= '0';

   REGSR0_s <= REGSW0_s;
--======================================================================================================================
-- Slave 1
--======================================================================================================================
   u_REGS1: entity WISHBONE.WBS_REGS_08
   generic map(
      WB_DA_WIDTH_g => 16,
      REGS_RD_g     => 4,
      REGS_WR_g     => 4
   )
   port map(
      ADR_i     => WBS_ADR_s,
      DAT_i     => WBS_DATW_s,
      DAT_o     => WBS_DATR_s(CS_REGS1_c),
      WE_i      => WBS_WE_s,
      STB_i     => WBS_STB_s(CS_REGS1_c),
      ACK_o     => WBS_ACK_s(CS_REGS1_c),
      CYC_i     => WBS_CYC_s(CS_REGS1_c),
      ERR_o     => WBS_ERR_s(CS_REGS1_c),
      RTY_o     => WBS_RTY_s(CS_REGS1_c),
      REG_DAT_i => REGSR1_s,
      REG_DAT_o => REGSW1_s,
      RST_i      => RST_s,
      CLK_i      => CLK_s,
      CLK_EN_i   => '1'
   );

  -- WBS_ERR_s(CS_REGS1_c) <= '0';
  -- WBS_RTY_s(CS_REGS1_c) <= '0';

   REGSR1_s <= REGSW1_s;
--======================================================================================================================
-- Slave 2
--======================================================================================================================
   u_REGS2: entity WISHBONE.WBS_REGS_08
   generic map(
      WB_DA_WIDTH_g => 16,
      REGS_RD_g     => 4,
      REGS_WR_g     => 4
   )
   port map(
      ADR_i     => WBS_ADR_s,
      DAT_i     => WBS_DATW_s,
      DAT_o     => WBS_DATR_s(CS_REGS2_c),
      WE_i      => WBS_WE_s,
      STB_i     => WBS_STB_s(CS_REGS2_c),
      ACK_o     => WBS_ACK_s(CS_REGS2_c),
      CYC_i     => WBS_CYC_s(CS_REGS2_c),
      ERR_o     => WBS_ERR_s(CS_REGS2_c),
      RTY_o     => WBS_RTY_s(CS_REGS2_c),
      REG_DAT_i => REGSR2_s,
      REG_DAT_o => REGSW2_s,
      RST_i      => RST_s,
      CLK_i      => CLK_s,
      CLK_EN_i   => '1'
   );

   --WBS_ERR_s(CS_REGS2_c) <= '0';
   --WBS_RTY_s(CS_REGS2_c) <= '0';

   REGSR2_s <= REGSW2_s;

end architecture;
