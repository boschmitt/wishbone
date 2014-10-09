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
--| DESCRIPTION:      | Wishbone shared bus intercon
--|                   |  * Based on multiplexers.
--|                   |  * 1 to N multiplexing (1 Masters, N Slaves)
--|                   |  * Partial address decoding.
--+-------------------+-------------------------------------------------------------------------------------------------
--| SUPPORTED CYCLES: | MASTER/SLAVE, SINGLE STANDARD READ/WRITE
--|                   | MASTER/SLAVE, BLOCK READ/WRITE
--+-------------------+-------------------------------------------------------------------------------------------------
--| DATA PORT:        | SIZE                 : 8
--|                   | GRANULARITY          : 8
--|                   | MAX.OPER.SIZE        : 8
--|                   | TRANSFER ORDERING    : BIG ENDIAN / LITTLE ENDIAN
--|                   | TRANSFER SEQUENCE    : Undefined
--======================================================================================================================
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library WISHBONE;
   use WISHBONE.WB_pkg.all;
   use WISHBONE.WBI_pkg.all;

entity WBI_SHRD_08 is
   generic (
      constant WB_CD_AWIDTH_g : integer      := 16;                          -- Corase Decoder Address WIDTH
      constant WB_N_SLAVES_g  : integer      := 4;                           -- Number of slaves
      constant WB_MEMMAP_g    : WBI_MEMMAP_t := (                            -- Memory map
                                               ( 16#0000#, 16#0F# ),
                                               ( 16#0010#, 16#0F# ),
                                               ( 16#0020#, 16#0F# ),
                                               ( 16#0030#, 16#0F# ))
   );
   port (
      CLK_i      : in  std_ulogic;
      RST_i      : in  std_ulogic;
      CLK_EN_i   : in  std_ulogic;
      --================================================================================================================
      -- Wishbone Master Interface - (Slave interface as seen by the master)
      --================================================================================================================
      WBM_ADR_i  : in  WB_ADR_t;
      WBM_DAT_i  : in  WB_BYTE_t;
      WBM_DAT_o  : out WB_BYTE_t;
      WBM_WE_i   : in  std_ulogic;
      WBM_STB_i  : in  std_ulogic;
      WBM_ACK_o  : out std_ulogic;
      WBM_CYC_i  : in  std_ulogic;
      WBM_ERR_o  : out std_ulogic;
      WBM_RTY_o  : out std_ulogic;
      --================================================================================================================
      -- Wishbone Slaves Interface (Master interface as seen by the slaves)
      --================================================================================================================
      WBS_ADR_o  : out WB_ADR_t;
      WBS_DAT_i  : in  WBI_BYTE_BUS_t(0 to WB_N_SLAVES_g - 1);
      WBS_DAT_o  : out WB_BYTE_t;
      WBS_WE_o   : out std_ulogic;
      WBS_STB_o  : out std_ulogic_vector(0 to WB_N_SLAVES_g - 1);
      WBS_ACK_i  : in  std_ulogic_vector(0 to WB_N_SLAVES_g - 1);
      WBS_CYC_o  : out std_ulogic_vector(0 to WB_N_SLAVES_g - 1);
      WBS_ERR_i  : in  std_ulogic_vector(0 to WB_N_SLAVES_g - 1);
      WBS_RTY_i  : in  std_ulogic_vector(0 to WB_N_SLAVES_g - 1)
   );
end entity;

architecture behavorial of WBI_SHRD_08 is
   --===================================================================================================================
   -- Type
   --===================================================================================================================
   type WBI_ADR_DEC_BUS_t is array (natural range <>) of std_ulogic_vector(WB_CD_AWIDTH_g - 1 downto 0);
   --===================================================================================================================
   -- Internal Signals
   --===================================================================================================================
   signal ADR_s      : std_ulogic_vector(WB_CD_AWIDTH_g - 1 downto 0);
   signal OFFSET_s   : WB_ADR_t;
   signal BASEADDR_s : WBI_ADR_DEC_BUS_t(0 to WB_N_SLAVES_g - 1);

   signal SSTB_s     : std_ulogic_vector(0 to WB_N_SLAVES_g - 1);
   signal SCYC_s     : std_ulogic_vector(0 to WB_N_SLAVES_g - 1);
   signal CS_s       : std_ulogic_vector(0 to WB_N_SLAVES_g - 1);

begin
--======================================================================================================================
-- Sanity chekc with Asserts
--======================================================================================================================
   assert WB_N_SLAVES_g = WB_MEMMAP_g'length
      report "[WISHBONE-IP]: [WBI_SHRD_08.vhd] " &
             " [ERROR]: The number of slaves must be equal to the memory map number of entries"
      severity ERROR;

   assert WB_CD_AWIDTH_g <= WB_ADR_t'length
      report "[WISHBONE-IP]: [WBI_SHRD_08.vhd] " &
             "[ERROR]: The number of address bits to decode cannot be greater than the wishbone address width"
      severity ERROR;
--======================================================================================================================
-- Coarse Address decoder
--======================================================================================================================
   ADR_s <= WBM_ADR_i(WB_CD_AWIDTH_g - 1 downto 0);

   -- Verify which slave has the same base address of the given address.
   lbl: for i in 0 to WB_N_SLAVES_g - 1 generate

      -- Mask out SIZE bits to get the base address.
      BASEADDR_s(i) <= ADR_s and not(std_ulogic_vector(to_unsigned(WB_MEMMAP_g(i).SIZE - 1, WB_CD_AWIDTH_g)));
      -- Compare both slave and given address base address to select the correct slave.
      CS_s(i) <= '1' when std_ulogic_vector(to_unsigned(WB_MEMMAP_g(i).BASEADDR, WB_CD_AWIDTH_g)) = BASEADDR_s(i) else
                 '0';

   end generate;
--======================================================================================================================
-- From Master to slave MUX
--======================================================================================================================
   -- ADR MUX (TYPE: AND-OR)
   -- Select the offset mask of the selected slave.
   p_ADR_MUX: process(CS_s)
      variable OFFSET_v     : WB_ADR_t;
      variable OFFSET_TMP_v : WB_ADR_t;
   begin

      OFFSET_v     := (others => '0');
      OFFSET_TMP_v := (others => '0');

      for i in 0 to WB_N_SLAVES_g - 1 loop
         OFFSET_v     := std_ulogic_vector(to_unsigned(WB_MEMMAP_g(i).SIZE - 1, WB_AWIDTH_c));
         OFFSET_TMP_v := OFFSET_TMP_v or (OFFSET_v and (OFFSET_v'range => CS_s(i)));
      end loop;

      OFFSET_s <= OFFSET_TMP_v;

   end process;

   -- Mask out the base address
   WBS_ADR_o <= WBM_ADR_i and OFFSET_s;
--======================================================================================================================
-- From Master to Slaves Unmuxed Signals
--======================================================================================================================
   -- STB and CYC
   lbl_STB_CYC: for i in 0 to WB_N_SLAVES_g - 1 generate

      SSTB_s(i) <= '1' when CS_s(i) = '1' and WBM_STB_i = '1' else '0';
      SCYC_s(i) <= '1' when CS_s(i) = '1' and WBM_CYC_i = '1' else '0';

   end generate;

   WBS_STB_o  <= SSTB_s;
   WBS_CYC_o  <= SCYC_s;
   WBS_DAT_o  <= WBM_DAT_i;
   WBS_WE_o   <= WBM_WE_i;
--======================================================================================================================
-- From Slave to Master MUX (TYPE: AND-OR)
--======================================================================================================================
   p_DAT_MUX: process(WBS_DAT_i, CS_s)
      variable SDAT_v : WB_BYTE_t;
   begin
      SDAT_v := (others => '0');
      for i in 0 to WB_N_SLAVES_g - 1 loop
         SDAT_v := SDAT_v or (WBS_DAT_i(i) and (SDAT_v'range => CS_s(i)));
      end loop;
      WBM_DAT_o <= SDAT_v;
   end process;

   p_ACK_MUX: process(WBS_ACK_i, CS_s)
      variable SACK_v : std_ulogic;
   begin
      SACK_v := '0';
      for i in 0 to WB_N_SLAVES_g - 1 loop
         SACK_v := SACK_v or (WBS_ACK_i(i) and CS_s(i));
      end loop;
      WBM_ACK_o <= SACK_v;
   end process;

   p_ERR_MUX: process(WBS_ERR_i, CS_s)
      variable SERR_v : std_ulogic;
   begin
      SERR_v := '0';
      for i in 0 to WB_N_SLAVES_g - 1 loop
         SERR_v := SERR_v or (WBS_ERR_i(i) and CS_s(i));
      end loop;
      WBM_ERR_o <= SERR_v;
   end process;

   p_RTY_MUX: process(WBS_RTY_i, CS_s)
      variable SRTY_v : std_ulogic;
   begin
      SRTY_v := '0';
      for i in 0 to WB_N_SLAVES_g - 1 loop
         SRTY_v := SRTY_v or (WBS_RTY_i(i) and CS_s(i));
      end loop;
      WBM_RTY_o <= SRTY_v;
   end process;

end architecture;
