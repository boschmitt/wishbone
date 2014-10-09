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

package COMMON_TB_pkg is
   --===================================================================================================================
   -- Clock
   --===================================================================================================================
   procedure GENERATE_CLOCK (
      constant CLOCK_PERIOD_c : in time;
      constant CLOCK_PULSE_c  : in time;
      constant CLOCK_PHASE_c  : in time;
      signal CLK_o : out std_logic
   );
   --===================================================================================================================
   -- Reset
   --===================================================================================================================
   procedure SYNC_RST (
      constant DELAY_c    : in time;
      constant DURATION_c : in time;
      signal CLK_i : in  std_ulogic;
      signal RST_o : out std_ulogic
   );

end package;

package body COMMON_TB_pkg is
   --===================================================================================================================
   -- Generate Clock
   --===================================================================================================================
   procedure GENERATE_CLOCK (
      constant CLOCK_PERIOD_c : in time;
      constant CLOCK_PULSE_c  : in time;
      constant CLOCK_PHASE_c  : in time;
      signal CLK_o : out std_logic
   ) is
   begin
         wait for CLOCK_PHASE_c;

         loop
            CLK_o <= '1', '0' after CLOCK_PULSE_c;
            wait for CLOCK_PERIOD_c;
         end loop;

   end procedure;
   --===================================================================================================================
   -- Synchronous Reset
   --===================================================================================================================
   procedure SYNC_RST (
      constant DELAY_c    : in time;
      constant DURATION_c : in time;
      signal CLK_i : in  std_ulogic;
      signal RST_o : out std_ulogic
   ) is
   begin

      wait for DELAY_c;
      wait until rising_edge(CLK_i);
      RST_o <= '1';
      wait for DURATION_c;
      wait until rising_edge(CLK_i);
      RST_o <= '0';

      wait;

   end procedure;

end package body;
