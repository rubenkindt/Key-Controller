-----------------------------------------------------------------
-- Project    : Labo Digitale ELektronica
-- Author     : R.Kindt - campus De Nayer
-- Begin Date : 13/05/2018
-- File       : keyctrl_8_system.vhd
-----------------------------------------------------------------
-- Design: 
-- system file
--
-- Description:
-- combines the clock divider made by ir. J. Meel and the keycontroler made by R. Kindt
-- Design of the clock divider:
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
-----------------------------------------------------------------
--package common is
--	CONSTANT modulo16: positive := 3; -- https://stackoverflow.com/questions/20072851/how-to-use-a-constant-calculated-from-generic-parameter-in-a-port-declaration-in
--	CONSTANT modulo4 : positive := 1;
--END common;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
--USE Work.common.ALL;

ENTITY system_keyctrl IS
PORT (	clk_100M : IN  std_logic;    -- 100 MHz clk input
        clk_sel  : IN  std_logic_vector(1 DOWNTO 0);   -- select input of clk-multiplexer (4 to 1) - active high
        clk_mux_b: OUT std_logic;    -- synchronised output of clk multiplexer - active low (LED display)
------- Ports SYSTEM
	--clk, clk is geen ingang poort wel een signaal declaratie zie rond lijn 109
	reset_b	:IN std_logic:='1';
	up_b		:IN std_logic:='1';	
	enter_b		:IN std_logic:='1';
	pcode_b		:IN std_logic_vector(3 DOWNTO 0):="0000";
	test_b		:IN std_logic:='1';
	ledbar_out	:OUT std_logic_vector(9 DOWNTO 0):=(OTHERS=>'0');
	disc0		:OUT std_logic_vector(7 DOWNTO 0):=x"00";
	disc1		:OUT std_logic_vector(7 DOWNTO 0):=x"00";
	disc2		:OUT std_logic_vector(7 DOWNTO 0):=x"00";
	disc3		:OUT std_logic_vector(7 DOWNTO 0):=x"00"
);
END system_keyctrl;

ARCHITECTURE structural OF system_keyctrl IS
COMPONENT clkdiv
GENERIC(width_1  : natural := 26;    -- width of divider = width_1 + 1
        posclk3  : natural := 5);    -- bit position on clk-divider (width_1 - posclk3)
				     -- for clk selected by multiplexer with control "11"
PORT   (clk_100M : IN  std_logic;    -- 100 MHz clk input
        clk_sel  : IN  std_logic_vector(1 DOWNTO 0);   -- select input of clk-multiplexer (4 to 1) - active high
        clk_mux_b: OUT std_logic;    -- synchronised output of clk multiplexer - active low (LED display)
        clk_buf  : OUT std_logic     -- buffered synchronised output of clk multiplexer
);
END COMPONENT ;

COMPONENT keyctrl
PORT (	clk,reset_b	:IN std_logic:='1';
	up_b		:IN std_logic:='1';
	enter_b		:IN std_logic:='1';
	pcode_b		:IN std_logic_vector(3 DOWNTO 0);
	test_b		:IN std_logic:='1';
	ledbar_out	:OUT std_logic_vector(9 DOWNTO 0):=(OTHERS=>'0');
	disc0		:OUT std_logic_vector(7 DOWNTO 0):=x"00";
	disc1		:OUT std_logic_vector(7 DOWNTO 0):=x"00";
	disc2		:OUT std_logic_vector(7 DOWNTO 0):=x"00";
	disc3		:OUT std_logic_vector(7 DOWNTO 0):=x"00"
);
END COMPONENT ;


-- CONFIGURATION SPECIFICATION
-- ===========================
FOR clkdriver : clkdiv  USE ENTITY work.clkdiv(behavior);
FOR system    : keyctrl USE ENTITY work.keyctrl(behavior);

-- CONSTANT/SIGNAL DECLARATIONS & MAPPING
-- ======================================;
-- Generic Parameters & Signals CLOCK DIVIDER (clkdiv)
  CONSTANT div_width_1 : natural := 26;  -- clk_sel = "00" : frequency = 0.74 Hz
  CONSTANT mux_posclk3 : natural := 5;   -- clk_sel = "11" : frequency = 23.8 Hz

-- Signals SYSTEM	
	CONSTANT period 	: time 	:= 100 ns;
	CONSTANT delay  	: time 	:=  10 ns;
	CONSTANT modulo16: positive := 3; 
	CONSTANT modulo4 : positive := 1; 
	SIGNAL clk		:std_logic;

BEGIN
-- Port Map CLOCK DIVIDER (clkdiv)
clkdriver : clkdiv 
GENERIC MAP(
	width_1 => div_width_1,
	posclk3 => mux_posclk3
)
PORT MAP(clk_100M  => clk_100M,           -- external 100 MHz clock
	clk_sel   => clk_sel,
	clk_mux_b => clk_mux_b,
	clk_buf   => clk
);               -- internal clock for shiftregister driven by clk_buf

-- Port Map SYSTEM    
system : keyctrl    
PORT MAP(
		clk 		=>clk,
		reset_b		=>reset_b,
		up_b		=>up_b,
		enter_b		=>enter_b,
		pcode_b		=>pcode_b,
		test_b		=>test_b,
		ledbar_out	=>ledbar_out,
		disc0		=>disc0,
		disc1		=>disc1,
		disc2		=>disc2,
		disc3		=>disc3		
);
END structural;
