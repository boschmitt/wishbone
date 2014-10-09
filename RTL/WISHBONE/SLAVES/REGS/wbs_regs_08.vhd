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
-- WISHBONE DATASHEET
--======================================================================================================================
--| VESRION           | REV B.4
--+-------------------+-------------------------------------------------------------------------------------------------
--| DESCRIPTION:      | Wishbone register bank slave.
--+-------------------+-------------------------------------------------------------------------------------------------
--| SUPPORTED CYCLES: | SLAVE, SINGLE STANDARD READ/WRITE
--|                   | SLAVE, BLOCK READ/WRITE
--+-------------------+-------------------------------------------------------------------------------------------------
--| DATA PORT:        | SIZE                 : 8
--|                   | GRANULARITY          : 8
--|                   | MAX.OPER.SIZE        : 8
--|                   | TRANSFER ORDERING    : BIG ENDIAN / LITTLE ENDIAN
--|                   | TRANSFER SEQUENCE    : Undefined
--======================================================================================================================
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.ALL;

library WISHBONE;
   use WISHBONE.WB_pkg.all;
   use WISHBONE.WBS_pkg.all;

entity WBS_REGS_08 is
   generic (
      constant WB_DA_WIDTH_g : integer := 16;   -- Address width that is effectly necessary for decoding
      constant REGS_RD_g     : integer := 2;    -- Number of READ-only registers
      constant REGS_WR_g     : integer := 2     -- Number of WRITE-only registers
   );
   port (
      --================================================================================================================
      -- Syscon Interface
      --================================================================================================================
      CLK_i     : in  std_ulogic;
      RST_i     : in  std_ulogic;
      --================================================================================================================
      CLK_EN_i  : in  std_ulogic;
      --================================================================================================================
      -- Wishbone Interface
      --================================================================================================================
      ADR_i     : in  WB_ADR_t;
      DAT_i     : in  std_ulogic_vector(7 downto 0);
      DAT_o     : out std_ulogic_vector(7 downto 0);
      WE_i      : in  std_ulogic;
      STB_i     : in  std_ulogic;
      ACK_o     : out std_ulogic;
      CYC_i     : in  std_ulogic;
      ERR_o     : out std_ulogic;
      RTY_o     : out std_ulogic;
      --================================================================================================================
      -- Registers Interface
      --================================================================================================================
      REG_DAT_i : in  WBS_REGS_BANK_08_t(0 to REGS_RD_g - 1);
      REG_DAT_o : out WBS_REGS_BANK_08_t(0 to REGS_WR_g - 1)
   );
end entity;

architecture BEHAVORIAL of WBS_REGS_08 is
   --===================================================================================================================
   -- Internal Signals
   --===================================================================================================================
   signal ADR_s  : std_ulogic_vector(WB_DA_WIDTH_g - 1 downto 0);
   signal ACK_s  : std_ulogic;
   signal DATA_s : std_ulogic_vector(7 downto 0);

   signal CE_WR_s : std_ulogic_vector(0 to REGS_WR_g - 1);
   signal CE_RD_s : std_ulogic_vector(0 to REGS_RD_g - 1);

begin
--======================================================================================================================
-- Address decoder
--======================================================================================================================
   ADR_s <= ADR_i(WB_DA_WIDTH_g - 1 downto 0);


   p_DECODER_WR: process(CLK_i)
   begin
      lbl_DECOD: for i in 0 to REGS_WR_g - 1 loop
         if rising_edge(CLK_i) then
            if RST_i = '1' then
               CE_WR_s(i) <= '0';
            else
               if to_integer(unsigned(ADR_s)) = i then
                  CE_WR_s(i) <= '1';
               else
                  CE_WR_s(i) <= '0';
               end if;
            end if;
         end if;
      end loop;
   end process;


   p_DECODER_RD: process(CLK_i)
   begin
      lbl_DECOD_RD: for i in 0 to REGS_RD_g - 1 loop
         if rising_edge(CLK_i) then
            if to_integer(unsigned(ADR_s)) = i then
               CE_RD_s(i) <= '1';
            else
               CE_RD_s(i) <= '0';
            end if;
         end if;
      end loop;
   end process;
--======================================================================================================================
-- Write
--======================================================================================================================
   p_REG_WR: process(CLK_i)
   begin
      lbl_REG_WR: for i in 0 to REGS_WR_g - 1 loop
         if rising_edge(CLK_i) then
            if RST_i = '1' then
               REG_DAT_o(i) <= (others => '0');
            elsif CE_WR_s(i) = '1' and ACK_s = '1' and WE_i = '1' then
               REG_DAT_o(i) <= DAT_i;
            end if;
         end if;
      end loop;
   end process;
--======================================================================================================================
-- Read MUX
--======================================================================================================================
   p_RD_MUX: process(CE_RD_s, REG_DAT_i)
      variable DATA_v : std_ulogic_vector(7 downto 0);
   begin
      DATA_v := (others => '0');
      g_MUX: for i in 0 to REGS_RD_g - 1 loop
         DATA_v := DATA_v or (REG_DAT_i(i) and (REG_DAT_i(i)'range => CE_RD_s(i)));
      end loop;
      DATA_s <= DATA_v;
   end process;

   p_REG_RD: process(CLK_i)
   begin
      if rising_edge(CLK_i) then
         DAT_o <= DATA_s;
      end if;
   end process;
--======================================================================================================================
-- WBS ACK Signal
--======================================================================================================================
   p_ACK: process(CLK_i)
   begin
      if rising_edge(CLK_i) then
         if RST_i = '1' then
            ACK_s <= '0';
         else
            if STB_i = '1' and CYC_i = '1' then
               ACK_s <= '1';
            else
               ACK_s <= '0';
            end if;
         end if;
      end if;
   end process;

   ACK_o <= ACK_s and STB_i;

end architecture;
