-----------------------------------------------------------------
-- Project    : Labo Digitale ELektronica
-- Author     : R.Kindt - campus De Nayer
-- Begin Date : 13/04/2018
-- Revision   : version 2 - 03/05/2018 - R.Kindt
--	      : Final version 21/05/2018 - R.Kindt --all comments are rechecked and correct
-- File       : keyctrl_8_test.vhd
-----------------------------------------------------------------
-- TEST BENCH for design: 
-- Test bench for a key controler
--
-- Description:
--
-- This entity/architecture pair generates testvectors
-- (all input combinations)to test the functionality 
-- of a combinatorial and sequential key controler with
-- * inputs: active-low inputs (push buttons)
-- * output: active low output (LED and LEDBAR)
-- 
-----------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY keyctrl_test IS
END keyctrl_test;

ARCHITECTURE structural OF keyctrl_test IS 
CONSTANT modulo16  : positive  := 3;
CONSTANT modulo4   : positive  := 1;
-- Unit Under Test: uut
	COMPONENT keyctrl
PORT (	clk,reset_b	:IN std_logic:='1';
	up_b		:IN std_logic:='1';
	enter_b		:IN std_logic:='1';
	pcode_b		:IN std_logic_vector(3 DOWNTO 0);
	test_b		:IN std_logic:='1'

);
	END COMPONENT;

  FOR uut : keyctrl USE ENTITY work.keyctrl(behavior);
 
	CONSTANT period 	: time 	:= 100 ns;
	CONSTANT delay  	: time 	:=  10 ns;
	SIGNAL   end_of_sim 	: boolean := false;

-- Interconnection (signals - ports)
	SIGNAL clk     	 	: std_logic;
	SIGNAL reset_b		: std_logic;
	SIGNAL up_b		: std_logic;
 	SIGNAL enter_b		: std_logic;
	SIGNAL pcode_b		: std_logic_vector(3 DOWNTO 0);
	SIGNAL test_b		: std_logic:='0';
 
BEGIN
	uut: keyctrl PORT MAP(
		clk 		=>clk,
		reset_b		=>reset_b,
		up_b		=>up_b,
		enter_b		=>enter_b,
		pcode_b		=>pcode_b,
		test_b		=>test_b
);
		
-- Test Bench: clock-generaTOr
clock : PROCESS
BEGIN 
LOOP
	clk <= '1';
	WAIT FOR period/2;
	clk <= '0';
	WAIT FOR period/2;
	EXIT WHEN end_of_sim;
END LOOP;
WAIT;
END PROCESS clock;

-- Test Bench: TVI-generator
tb_gen : PROCESS
BEGIN
reset_b		<=not('0');
up_b		<=not('0');
enter_b		<=not('0');
pcode_b		<=not("0001");		--pcode = te kiezen
test_b		<=not('1');
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
up_b	<=not('1');			--disc0 van - naar 0 zetten
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
up_b	<=not('0');
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;

FOR J IN 0 TO 3 loop 			--led 1 op 4 zetten
	up_b	<=not('1');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	up_b	<=not('0');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;

END LOOP;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
enter_b	<=not('1');			--naar led 2 gaan (disc1)
WAIT FOR period;
enter_b	<=not('0');
WAIT FOR period;

FOR J IN 0 TO 0 loop 			---pcode = 0001
	up_b	<=not('1');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	up_b	<=not('0');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
END LOOP;		
			
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
enter_b	<=not('1');			--naar led 3 gaan (disc2)
WAIT FOR period;
enter_b	<=not('0');
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;

FOR J IN 0 TO 14 loop 			--led 3 op F zetten
	up_b	<=not('1');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	up_b	<=not('0');
	WAIT FOR period;
	WAIT FOR period;WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
END LOOP;

WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
enter_b	<=not('1');			--naar led 4 gaan (disc3) = controle uitvoeren
WAIT FOR period;
enter_b	<=not('0');
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;

FOR J IN 0 TO 80 loop 			--animatie even zijn werk laten doen
	WAIT FOR period;
END LOOP;

reset_b	<=not('1');		--rst
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
reset_b	<=not('0');

WAIT FOR period;
WAIT FOR period;

WAIT FOR period;
up_b	<=not('1');			--disc0 van - naar 0 zetten
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
up_b	<=not('0');
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;

FOR J IN 0 TO 3 loop 			--led 1 op 4 zetten
	up_b	<=not('1');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	up_b	<=not('0');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
END LOOP;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
enter_b	<=not('1');			--naar led 2 gaan (disc1)
WAIT FOR period;
enter_b	<=not('0');
WAIT FOR period;

FOR J IN 0 TO 0 loop 			---pcode = 0001
	up_b	<=not('1');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
	up_b	<=not('0');
	WAIT FOR period;
	WAIT FOR period;
	WAIT FOR period;
END LOOP;		
			
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
enter_b	<=not('1');			--naar led 3 gaan (disc2)
WAIT FOR period;
enter_b	<=not('0');
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;

FOR J IN 0 TO 14 loop 			--led 3 op F zetten
	up_b	<=not('1');
	WAIT FOR period;
	WAIT FOR period;
	up_b	<=not('0');
	WAIT FOR period;
	WAIT FOR period;
END LOOP;

WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
enter_b	<=not('1');			--naar led 4 gaan (disc3) = controle uitvoeren
WAIT FOR period;
enter_b	<=not('0');
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
WAIT FOR period;
	up_b	<=not('1');		--testen of en extra up nog iets doet
	WAIT FOR period;
	WAIT FOR period;
	up_b	<=not('0');
	WAIT FOR period;
	WAIT FOR period;

FOR J IN 0 TO 80 loop 			--animatie even zijn werk laten doen
	WAIT FOR period;
END LOOP;

FOR J IN 0 TO 1500 loop 		--extra testen
	WAIT FOR period;
END LOOP;

end_of_sim <= true;
WAIT;
END PROCESS tb_gen;
END structural;