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

library WISHBONE;
   use WISHBONE.WB_pkg.all;

package WBI_pkg is
   --===================================================================================================================
   -- Intercon bus data types
   --===================================================================================================================
   type WBI_BYTE_BUS_t  is array (natural range <>) of WB_BYTE_t;
   type WBI_WORD_BUS_t  is array (natural range <>) of WB_WORD_t;
   type WBI_DWORD_BUS_t is array (natural range <>) of WB_DWORD_t;
   --===================================================================================================================
   -- Intercon bus address type
   --===================================================================================================================
   type WBI_ADR_BUS_t   is array (natural range <>) of WB_ADR_t;
   --===================================================================================================================
   -- Intercon Memory Map types
   --===================================================================================================================
   -- Salve MAP
   type WBI_SMAP_t is record
      BASEADDR : integer;
      SIZE     : integer;
   end record;
   -- Intercon MEMomry MAP
   type WBI_MEMMAP_t is array (natural range <>) of WBI_SMAP_t;
   --===================================================================================================================
end package;
