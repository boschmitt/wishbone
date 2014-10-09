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

library WISHBONE;
   use WISHBONE.WB_pkg.all;

package WB_TESTBENCH_pkg is
--======================================================================================================================
-- Procedure WAIT RESET
--======================================================================================================================
   procedure WBM_WAIT_RESET(
      -- Wishbone Signals
      signal ADR_o  : out std_ulogic_vector;
      signal DAT_o  : out std_ulogic_vector;
      signal WE_o   : out std_ulogic;
      signal STB_o  : out std_ulogic;
      signal SEL_o  : out std_ulogic_vector;
      signal ACK_i  : in  std_ulogic;
      signal CYC_o  : out std_ulogic;
      signal ERR_i  : in  std_ulogic;
      signal RTY_i  : in  std_ulogic;
      signal RST_i  : in  std_ulogic;
      signal CLK_i  : in  std_ulogic
   );
--======================================================================================================================
-- Procedures SINGLE READ
--======================================================================================================================
   -- Standard
   procedure WBM_STD_SINGLEREAD(
      constant ADR_c   : in std_ulogic_vector;
      constant SEL_c   : in std_ulogic_vector;
      -- Read Data
      signal DATA_o : out std_ulogic_vector;
      -- Wishbone Signals
      signal ADR_o  : out std_ulogic_vector;
      signal DAT_i  : in  std_ulogic_vector;
      signal WE_o   : out std_ulogic;
      signal STB_o  : out std_ulogic;
      signal SEL_o  : out std_ulogic_vector;
      signal ACK_i  : in  std_ulogic;
      signal CYC_o  : out std_ulogic;
      signal ERR_i  : in  std_ulogic;
      signal RTY_i  : in  std_ulogic;
      signal CLK_i  : in  std_ulogic
   );
--======================================================================================================================
-- Procedures SINGLE WRITE
--======================================================================================================================
   -- Standard
   procedure WBM_STD_SINGLEWRITE(
      constant ADR_c   : in std_ulogic_vector;
      constant SEL_c   : in std_ulogic_vector;
      constant DATA_c  : in std_ulogic_vector;
      -- Wishbone Signals
      signal ADR_o  : out std_ulogic_vector;
      signal DAT_o  : out std_ulogic_vector;
      signal WE_o   : out std_ulogic;
      signal STB_o  : out std_ulogic;
      signal SEL_o  : out std_ulogic_vector;
      signal ACK_i  : in  std_ulogic;
      signal CYC_o  : out std_ulogic;
      signal ERR_i  : in  std_ulogic;
      signal RTY_i  : in  std_ulogic;
      signal CLK_i  : in  std_ulogic
   );

end package;

package body WB_TESTBENCH_pkg is
--======================================================================================================================
-- Procedure WAIT RESET
--======================================================================================================================
   procedure WBM_WAIT_RESET(
      -- Wishbone Signals
      signal ADR_o  : out std_ulogic_vector;
      signal DAT_o  : out std_ulogic_vector;
      signal WE_o   : out std_ulogic;
      signal STB_o  : out std_ulogic;
      signal SEL_o  : out std_ulogic_vector;
      signal ACK_i  : in  std_ulogic;
      signal CYC_o  : out std_ulogic;
      signal ERR_i  : in  std_ulogic;
      signal RTY_i  : in  std_ulogic;
      signal RST_i  : in  std_ulogic;
      signal CLK_i  : in  std_ulogic
   ) is
   begin

      wait until rising_edge(CLK_i) and RST_i = '1';
      ADR_o <= (ADR_o'range => 'X');
      DAT_o <= (DAT_o'range => 'X');
      WE_o  <= 'X';
      STB_o <= '0';
      SEL_o <= (SEL_o'range => 'X');
      CYC_o <= '0';
      wait until rising_edge(CLK_i) and RST_i = '0';
      WE_o  <= '0';

   end procedure;
--======================================================================================================================
-- Procedure Standard SINGLE READ
--    * 3.2.1 Classic Standard Single READ Cycle
--======================================================================================================================
   procedure WBM_STD_SINGLEREAD(
      constant ADR_c   : in std_ulogic_vector;
      constant SEL_c   : in std_ulogic_vector;
      -- Read Data
      signal DATA_o : out std_ulogic_vector;
      -- Wishbone Signals
      signal ADR_o  : out std_ulogic_vector;
      signal DAT_i  : in  std_ulogic_vector;
      signal WE_o   : out std_ulogic;
      signal STB_o  : out std_ulogic;
      signal SEL_o  : out std_ulogic_vector;
      signal ACK_i  : in  std_ulogic;
      signal CYC_o  : out std_ulogic;
      signal ERR_i  : in  std_ulogic;
      signal RTY_i  : in  std_ulogic;
      signal CLK_i  : in  std_ulogic
   ) is
   begin
      --================================================================================================================
      -- Clock Edge 0
      --================================================================================================================
      wait until rising_edge(CLK_i);
      ADR_o <= ADR_c;    -- Present a valid address.
      WE_o  <= '0';                             -- Indicates a READ CYCLE.
      STB_o <= '1';                             -- Indicate the start of a phase.
      SEL_o <= SEL_c;    -- Indicates where it expects data.
      CYC_o <= '1';                             -- Inficate the start of a cycle.
      --================================================================================================================
      -- Clock Edge 1
      --================================================================================================================
      wait until rising_edge(CLK_i);
      --================================================================================================================
      -- Clock Edge 2
      --================================================================================================================
      wait until rising_edge(CLK_i) and (ACK_i = '1' or ERR_i = '1');
      DATA_o <= DAT_i;                           -- Master latches data on DAT_i()
      ADR_o  <= (ADR_o'range => '0');
      STB_o  <= '0';                             -- Indicate the end of a phase.
      SEL_o  <= (SEL_o'range => '0');
      CYC_o  <= '0';                             -- Inficate the end of a cycle.

   end procedure;
--======================================================================================================================
-- Procedure Standard SINGLE WRITE
--    * 3.2.3 Classic Standard SINGLE WRITE Cycle
--======================================================================================================================
   procedure WBM_STD_SINGLEWRITE(
      constant ADR_c   : in std_ulogic_vector;
      constant SEL_c   : in std_ulogic_vector;
      constant DATA_c  : in std_ulogic_vector;
      -- Wishbone Signals
      signal ADR_o  : out std_ulogic_vector;
      signal DAT_o  : out std_ulogic_vector;
      signal WE_o   : out std_ulogic;
      signal STB_o  : out std_ulogic;
      signal SEL_o  : out std_ulogic_vector;
      signal ACK_i  : in  std_ulogic;
      signal CYC_o  : out std_ulogic;
      signal ERR_i  : in  std_ulogic;
      signal RTY_i  : in  std_ulogic;
      signal CLK_i  : in  std_ulogic
   ) is
   begin
      --================================================================================================================
      -- Clock Edge 0
      --================================================================================================================
      wait until rising_edge(CLK_i);
      ADR_o <= ADR_c;                          -- Present a valid address.
      DAT_o <= DATA_c;                         -- Present a valid data.
      WE_o  <= '1';                            -- Indicates a WRITE CYCLE.
      STB_o <= '1';                            -- Indicate the start of a phase.
      SEL_o <= SEL_c;                          -- Indicates where it expects data.
      CYC_o <= '1';                            -- Inficate the start of a cycle.
      --================================================================================================================
      -- Clock Edge 1
      --================================================================================================================
      wait until rising_edge(CLK_i);
      --================================================================================================================
      -- Clock Edge 2
      --================================================================================================================
      wait until rising_edge(CLK_i) and (ACK_i = '1' or ERR_i = '1');
      ADR_o <= (ADR_o'range => '0');
      DAT_o <= (DAT_o'range => '0');
      WE_o  <= '0';
      STB_o <= '0';                             -- Indicate the end of a phase.
      SEL_o <= (SEL_o'range => '0');
      CYC_o <= '0';                             -- Inficate the end of a cycle.

   end procedure;

end package body;
