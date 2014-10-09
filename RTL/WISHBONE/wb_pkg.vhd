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

package WB_pkg is
   --===================================================================================================================
   -- Data Organization definitions (Section 3.5)
   --===================================================================================================================
   -- Note: This scheme is Little Endian.
   subtype WB_BYTE_t  is std_ulogic_vector( 7 downto 0);
   subtype WB_WORD_t  is std_ulogic_vector(15 downto 0);
   subtype WB_DWORD_t is std_ulogic_vector(31 downto 0);
   subtype WB_QWORD_t is std_ulogic_vector(63 downto 0);
   --===================================================================================================================
   -- Internal address bus definitions
   --===================================================================================================================
   constant WB_AWIDTH_c : integer := 16;

   subtype WB_ADR_t is std_ulogic_vector(WB_AWIDTH_c - 1 downto 0);
   --===================================================================================================================
   -- CTI (Cycle Type Identifiers) Constants
   --===================================================================================================================
   constant WB_CTI_CLASSIC_c  : std_ulogic_vector(2 downto 0) := "000"; -- Classic Wishbone Bus Cycle
   constant WB_CTI_CADR_c     : std_ulogic_vector(2 downto 0) := "001"; -- Constant Address Busrt Cycle
   constant WB_CTI_INCADR_c   : std_ulogic_vector(2 downto 0) := "010"; -- Incremeting Address Burst Cycle
   constant WB_CTI_ENDBURST_c : std_ulogic_vector(2 downto 0) := "111"; -- End of Burst
   --===================================================================================================================
   -- BTE (Burst Types Extensions) Constants (Only relevant to Incrementing burt cycles)
   --===================================================================================================================
   constant WB_BTE_LINEAR_c   : std_ulogic_vector(1 downto 0) := "00";  -- Linear burst
   constant WB_BTE_4WRAP_c    : std_ulogic_vector(1 downto 0) := "00";  -- 4-beat wrap burst
   constant WB_BTE_8WRAP_c    : std_ulogic_vector(1 downto 0) := "00";  -- 8-beat wrap burst
   constant WB_BTE_16WRAP_c   : std_ulogic_vector(1 downto 0) := "00";  -- 16-beat wrap burst
   --===================================================================================================================
end package;
