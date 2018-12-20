-----------------------------------------------------------------------------------------
-- Project    : Labo Digitale ELektronica
-- designer   : ir. J. Meel
-- Begin Date : 16/03/2010
-- Revision   : version 2 - 26/02/2018 - J. Meel
-- USED BY    : Ruben Kindt
-- USED IN    : Keycntroler 8 
-- USED AT    : 17/05/2018
-- File       : clkdiv.vhd
-----------------------------------------------------------------------------------------
-- Design:
-- CLOCK DIVIDER WITH MULTIPLEXED CLOCK OUTPUT
-- ===========================================
-- The input clk is a 100 MHz clock available on the XUP-board (Virtex2P)
-- This clk drives the clock of a divider.
-- The  position of the last bit of the divider can be deterined with the generic width_1
-- With a 4-to-1 multiplexer one out of 4 outputs of the divider can be selected
-- * The control inputs of the multiplexer and the corresponding clock output :
--    clk_sel => multiplexer output
--    "00" => divider(width_1)
--    "01" => divider(width_1-1)
--    "10" => divider(width_1-2)
--    "11" => divider(width_1-posclk3)
-- * generic: With the generic posclk3 the clock output for "11" can be changed.
-- * output: clk_buf output is buffered with BUFG
-----------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;


ENTITY clkdiv IS
GENERIC(width_1  : natural := 26;    -- width of divider = width_1 + 1
        posclk3  : natural := 5);    -- bit position on clk-divider (width_1 - posclk3)
                                     -- for clk selected by multiplexer with control "11"
PORT   (clk_100M : IN  std_logic;    -- 100 MHz clk input
        clk_sel  : IN  std_logic_vector(1 DOWNTO 0);   -- select input of clk-multiplexer (4 to 1) - active high
        clk_mux_b: OUT std_logic;    -- synchronised output of clk multiplexer - active low (LED display)
        clk_buf  : OUT std_logic);   -- buffered synchronised output of clk multiplexer
END clkdiv;

ARCHITECTURE behavior OF clkdiv IS
SIGNAL divider   : std_logic_vector(width_1 DOWNTO 0) := (OTHERS=>'0');
SIGNAL clk_mux_o : std_logic;  -- multiplexer output
SIGNAL clk_mux_q : std_logic;  -- synchronised multiplexer output (internal signal)
-- general clockbuffer (component declaration)
COMPONENT BUFG                 
         PORT (I : IN  std_logic;  
               O : OUT std_logic); 
END COMPONENT; 

BEGIN

-- clock divider
div : PROCESS (clk_100M)
BEGIN
  IF rising_edge(clk_100M)
	THEN divider <= divider + 1;
  END IF;
END PROCESS div;

--clock multiplexer
clkmux : PROCESS (clk_sel, divider(width_1 DOWNTO width_1-2), divider(width_1-posclk3))
BEGIN
  CASE clk_sel IS
    WHEN "00"   => clk_mux_o <= divider(width_1);         -- 100 MHz/2^width_1+1 = 0.74 Hz
    WHEN "01"   => clk_mux_o <= divider(width_1-1);       -- 100 MHz/2^width_1   = 1.49 Hz
    WHEN "10"   => clk_mux_o <= divider(width_1-2);       -- 100 MHz/2^width_1-1 = 2.98 Hz
    WHEN OTHERS => clk_mux_o <= divider(width_1-posclk3); -- 100 MHz/2^width_1-4 = 23.8 Hz
   END CASE;  
END PROCESS clkmux;

-- synchronisation of clock multiplexer output
syncmux : PROCESS (clk_100M)
BEGIN
  IF rising_edge(clk_100M)
	THEN clk_mux_q <= clk_mux_o;
  END IF;
END PROCESS syncmux;

-- synchronised output of clk multiplexer - active low (LED display)
clk_mux_b <= NOT(clk_mux_q); 

-- buffering of clock signal with BUFG
clockbuffer: BUFG 
   PORT MAP (I => clk_mux_q, 
             O => clk_buf); 

END behavior;