-----------------------------------------------------------------
-- Project    : Labo Digitale ELektronica
-- Author     : R.Kindt - campus De Nayer
-- Begin Date : 13/04/2018
-- Revision   : version 2  -  22/04/2018 - R.Kindt
--	      : Final version 24/05/2018 - R.Kindt --all comments are rechecked and correct
-- File       : keyctrl_8.vhd
-----------------------------------------------------------------
-- Design: 
-- key controler
--
-- Description:
-- This entity/architecture pair is a combinatorial and sequential of a key-controler
-- * inputs: active-low inputs (push buttons)
-- * output: active low output (LED and LEDBAR)
-----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
--USE Work.common.ALL;

ENTITY keyctrl IS
PORT (	clk,reset_b	:IN std_logic:='1';
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
END;

ARCHITECTURE behavior OF keyctrl IS
CONSTANT toegangcode1		:std_logic_vector(3 DOWNTO 0):=x"4";-- moet 4 zijn
CONSTANT toegangcode3		:std_logic_vector(3 DOWNTO 0):=x"f";-- moet F zijn
CONSTANT m			:positive :=5;
CONSTANT n			:positive :=2;
SIGNAL rst			:std_logic:='0';
SIGNAL up			:std_logic:='0';
SIGNAL enter			:std_logic:='0';
SIGNAL pcode			:std_logic_vector(3 DOWNTO 0);
SIGNAL test			:std_logic:='0';
SIGNAL rst_soft			:std_logic:='0';	--software reset nodig voor meerdere inputs binnen de 60 sec
SIGNAL count_enter		:std_logic_vector(1 DOWNTO 0):="00";
SIGNAL en_count0		:std_logic:='0';	--count enable teller 0
SIGNAL en_count1		:std_logic:='0';
SIGNAL en_count2		:std_logic:='0';
SIGNAL en_count3		:std_logic:='0';
SIGNAL count_up0		:std_logic_vector(3 DOWNTO 0):="0000"; --state van teller0
SIGNAL count_up1		:std_logic_vector(3 DOWNTO 0):="0000";
SIGNAL count_up2		:std_logic_vector(3 DOWNTO 0):="0000";
SIGNAL count_up3		:std_logic_vector(3 DOWNTO 0):="0000";

SIGNAL part_disc0		:std_logic_vector(6 DOWNTO 0):=(OTHERS=>'1'); --display led 0 het deel zonder het puntje
SIGNAL part_disc1		:std_logic_vector(6 DOWNTO 0):=(OTHERS=>'1');
SIGNAL part_disc2		:std_logic_vector(6 DOWNTO 0):=(OTHERS=>'1');
SIGNAL part_disc3		:std_logic_vector(6 DOWNTO 0):=(OTHERS=>'1');
SIGNAL punt_disc0		:std_logic:='1';		--display led 0 enkel het puntje
SIGNAL punt_disc1		:std_logic:='1';
SIGNAL punt_disc2		:std_logic:='1';
SIGNAL punt_disc3		:std_logic:='1';
SIGNAL count_toegangstijd	:std_logic_vector(10 DOWNTO 0):=(OTHERS=>'0');	--de extra opdracht

SIGNAL up_Pflank_alive		:std_logic:='0';		--om de eerste up te negeren
SIGNAL up_Pflank		:std_logic:='0';
SIGNAL enter_Pflank		:std_logic:='0';
SIGNAL count_animatie_clk	:std_logic_vector(2 DOWNTO 0):="000";
SIGNAL count_anim		:std_logic_vector(3 DOWNTO 0):="0000";
SIGNAL animatie_ce		:std_logic:='0';
SIGNAL code_correct		:std_logic:='0';

CONSTANT w1			:std_logic_vector(1 DOWNTO 0):="00"; --up flank
CONSTANT p1			:std_logic_vector(1 DOWNTO 0):="01";
CONSTANT w0			:std_logic_vector(1 DOWNTO 0):="11";
CONSTANT p0			:std_logic_vector(1 DOWNTO 0):="10";
SIGNAL present_state		:std_logic_vector(1 DOWNTO 0):="10";
SIGNAL next_state		:std_logic_vector(1 DOWNTO 0):="00";

CONSTANT w1_enter		:std_logic_vector(1 DOWNTO 0):="00"; --enter flank
CONSTANT p1_enter		:std_logic_vector(1 DOWNTO 0):="01";
CONSTANT w0_enter		:std_logic_vector(1 DOWNTO 0):="11";
CONSTANT p0_enter		:std_logic_vector(1 DOWNTO 0):="10";
SIGNAL present_state_enter	:std_logic_vector(1 DOWNTO 0):="10";
SIGNAL next_state_enter		:std_logic_vector(1 DOWNTO 0):="00";

BEGIN											-- BEGIN
rst	<=not(reset_b);
up	<=not(up_b);
enter	<=not(enter_b);
pcode	<=not(pcode_b);
test	<=not(test_b);

disc0 <= part_disc0 & punt_disc0;
disc1 <= part_disc1 & punt_disc1;
disc2 <= part_disc2 & punt_disc2;
disc3 <= part_disc3 & punt_disc3;

extra:PROCESS (clk)									-- EXTRA
BEGIN
IF rising_edge(clk)
	THEN --1428 is het aantal keer de clk (23,8hz) moet klokken voor 60 seconden
	IF rst ='0'
		THEN	
		IF code_correct='1'
			THEN count_toegangstijd <= (OTHERS=>'1');
			punt_disc0 <= '1';
			punt_disc1 <= '1';
			punt_disc2 <= '1';
			punt_disc3 <= '1';
		ELSE
			IF count_toegangstijd <(1428-1) and up_Pflank_alive='1'
				THEN
				IF (count_toegangstijd >=357) THEN		--1/4 van de tijd weg
					punt_disc0 <= '0';
				ELSE	punt_disc0 <= '1';
				END IF;
				IF count_toegangstijd >=714 THEN		--1/2 van de tijd weg
					punt_disc1 <= '0';
				ELSE	punt_disc1 <= '1';
				END IF;	
				IF (count_toegangstijd >=1071) THEN		--3/4 van de tijd weg
					punt_disc2 <= '0';
				ELSE	punt_disc2 <= '1';
				END IF;
				IF (count_toegangstijd >=(1428-1)) THEN		--4/4 van de tijd weg
					punt_disc3 <= '0';			--gebeurt nooit
				ELSE	punt_disc3 <= '1';		--maar dit wel
				END IF;
				count_toegangstijd <= count_toegangstijd +1;
			ELSE	
			punt_disc0 <= '1';
			punt_disc1 <= '1';
			punt_disc2 <= '1';
			punt_disc3 <= '1';
			END IF;
		END IF;
	ELSE count_toegangstijd<=(OTHERS=>'0');
	END IF;
ELSE
END IF;
END PROCESS extra;

syn_pos_flank_detector_up: Process(clk)							-- flank UP
BEGIN
If rising_edge(clk)
	THEN
	IF (rst = '1' or rst_soft ='1')
		THEN
		present_state <= w0;
	ELSE present_state <= next_state;
	END IF;
ELSE
END IF;
END PROCESS syn_pos_flank_detector_up;

pos_flank_detector_up:PROCESS(present_state,up)						-- flank UP
BEGIN
CASE present_state IS
	WHEN w1=>	up_Pflank<='0';
		IF (up='1')
			THEN next_state <=p1;
			ELSE next_state <=w1;
		END IF;	
	WHEN p1=>	up_Pflank<='1';
		next_state <= w0;
	WHEN w0=>	up_Pflank<='0';
		IF (up='0')
			THEN
			next_state <=p0;
		ELSE	next_state <=w0;
		END IF;
	WHEN p0 =>	up_Pflank<='0';
		next_state <= w1;
	WHEN OTHERS=>	up_Pflank<='0';
END CASE;
END PROCESS pos_flank_detector_up;

alive: PROCESS(clk)		--om de eerste up te negeren				--ALIVE maken van enter_Pflank
BEGIN
IF rising_edge(clk)
	THEN
	IF rst='0' and rst_soft ='0'
		THEN
		IF up_Pflank_alive='0' and up_Pflank='1'
			THEN
			up_Pflank_alive	<='1';
		ELSE 
		END IF;
	ELSE up_Pflank_alive	<='0';
	END if;
ELSE
END IF;
END PROCESS alive;

syn_pos_flank_detector_enter: Process(clk)						--FLANK ENTER
BEGIN
If rising_edge(clk)
	THEN
	IF (rst = '1' or rst_soft='1')
		THEN
		present_state_enter <= w0_enter;
	ELSE present_state_enter <= next_state_enter;
	END IF;
ELSE
END IF;
END PROCESS syn_pos_flank_detector_enter;

pos_flank_detector_enter:PROCESS(present_state_enter,enter)				--FLANK ENTER
BEGIN
CASE present_state_enter IS
	WHEN w1_enter=>	enter_Pflank<='0';
		IF (enter='1')
			THEN next_state_enter <=p1_enter;
			ELSE next_state_enter <=w1_enter;
		END IF;	
	WHEN p1_enter=>	enter_Pflank<='1';
		next_state_enter <= w0_enter;
	WHEN w0_enter=>	enter_Pflank<='0';
		IF (enter='0')
			THEN
			next_state_enter <=p0_enter;
		ELSE	next_state_enter <=w0_enter;
		END IF;
	WHEN p0_enter =>enter_Pflank<='0';
		next_state_enter <= w1_enter;
	WHEN OTHERS=>	enter_Pflank<='0';
END CASE;
END PROCESS pos_flank_detector_enter;

enter_teller: PROCESS (clk)								-- ENTER_teller
BEGIN
IF rising_edge(clk) 
	THEN
	IF (rst='1') or rst_soft='1' 
		THEN count_enter<=(OTHERS=>'0');
	ELSE		-- wanneer 60sec zijn gepasseerd zet de cout_enter vast
		IF count_toegangstijd >= (1428-1)
			THEN count_enter<="11";
		ELSIF enter_Pflank='1'
			THEN count_enter<=count_enter+1;
		ELSE
		END IF;
	END IF;
ELSE
END IF;
END PROCESS enter_teller;

demux:PROCESS(count_enter,up_Pflank_alive)						-- DEMUX
BEGIN
IF up_Pflank_alive = '1'
	THEN
	CASE count_enter IS
		WHEN "00" =>	en_count0<='1'; en_count1<='0'; en_count2<='0'; en_count3<='0';
		WHEN "01" =>	en_count0<='0'; en_count1<='1'; en_count2<='0'; en_count3<='0';
		WHEN "10" =>	en_count0<='0'; en_count1<='0'; en_count2<='1'; en_count3<='0';
		WHEN "11" =>	en_count0<='0'; en_count1<='0'; en_count2<='0'; en_count3<='1';
		WHEN OTHERS =>	en_count0<='0'; en_count1<='0'; en_count2<='0'; en_count3<='0';
	END CASE;
ELSE en_count0<='0'; en_count1<='0'; en_count2<='0'; en_count3<='0';
END IF;
END PROCESS demux;

up_teller0: PROCESS (clk)								-- UP_teller0
BEGIN
IF rising_edge(clk) 
	THEN
	IF (rst='0') and up_Pflank_alive ='1' and rst_soft ='0'
		THEN 
		IF up_Pflank='1' and en_count0='1'
			THEN count_up0<=count_up0+1;
		ELSE
		END IF;
	ELSE count_up0	<=(OTHERS=>'0');
	END IF;
ELSE
END IF;
END PROCESS up_teller0;

up_teller1: PROCESS (clk)								-- UP_teller1
BEGIN
IF rising_edge(clk) 
	THEN
	IF (rst='0') and up_Pflank_alive ='1' and rst_soft ='0'
		THEN 
		IF up_Pflank='1' and en_count1='1'
			THEN count_up1<=count_up1+1;
		ELSE
		END IF;
	ELSE count_up1	<=(OTHERS=>'0');
	END IF;
ELSE
END IF;
END PROCESS up_teller1;

up_teller2: PROCESS (clk)								-- UP_teller2
BEGIN
IF rising_edge(clk)
	THEN
	IF (rst='0') and up_Pflank_alive ='1' and rst_soft ='0'
		THEN 
		IF up_Pflank='1' and en_count2='1'
			THEN count_up2<=count_up2+1;
		ELSE
		END IF;
	ELSE count_up2	<=(OTHERS=>'0');
	END IF;
ELSE
END IF;
END PROCESS up_teller2;

up_teller3: PROCESS (clk)								-- UP_teller3
BEGIN
IF rising_edge(clk)
	THEN
	IF (rst='0') and up_Pflank_alive ='1' and rst_soft ='0'
		THEN 
		IF up_Pflank='1' and en_count3='1'
			THEN count_up3<=count_up3+1;
		ELSE
		END IF;
	ELSE count_up3	<=(OTHERS=>'0');
	END IF;
ELSE
END IF;
END PROCESS up_teller3;

controle_comparator:PROCESS(clk)							--controle_comparator
BEGIN --de oprdacht extra heeft een soft_rst nodig van 1 clk periode, dus synchroon
IF rising_edge(clk) 
	THEN
	IF rst='0'
	 THEN
	IF  rst_soft='0'
		THEN 
		IF count_enter="11"  and count_toegangstijd < (1428-1)-- dan tijd voor controle
			THEN
			IF count_up0 & count_up1 & count_up2 = toegangcode1 & pcode & toegangcode3
				THEN code_correct	<='1';
			ELSE	rst_soft	<='1';
				code_correct	<='0';
			END IF;
		ELSE
		END IF;
	ELSE code_correct<='0';
	  rst_soft	<='0';
	END IF;
	ELSE code_correct	<='0';
	  rst_soft	<='0';
	END IF;
ELSE 
END IF;
END PROCESS controle_comparator;

animatie_clock_teller:PROCESS (clk)							-- animatie clock 
BEGIN
IF rising_edge(clk)
	THEN
	IF rst='0' and rst_soft ='0'
		THEN
		IF code_correct='1'
			THEN
			IF(count_animatie_clk >= m-1) --delen door (m=5)-1
				THEN
				count_animatie_clk	<=(OTHERS => '0');
				animatie_ce		<='1';
			ELSE
				count_animatie_clk	<=count_animatie_clk + 1;
				animatie_ce		<='0';
			END IF;
		ELSE animatie_ce<='0';
		END IF;
	ELSE count_animatie_clk	<=(OTHERS => '0');
	END IF;
ELSE 
END IF;
END PROCESS animatie_clock_teller;

animatie_teller:PROCESS (clk)								--ANIMATIE teller
BEGIN
IF rising_edge(clk)
	THEN
	IF rst='0' and rst_soft ='0' 
		THEN
		IF animatie_ce ='1' 
			THEN
			IF count_anim >= 8
				THEN	count_anim <="0000";
			ELSE	count_anim <= count_anim + '1';
			END IF;
		ELSE
		END IF;
	ELSE  count_anim<=(OTHERS=>'0');
END IF;
ELSE
END IF;
END PROCESS animatie_teller;

led_decoder: PROCESS(count_anim, code_correct)--animatie C met n=2			--ANIMATIE zelf
variable temp_ledbar	:std_logic_vector(9 DOWNTO 0):=(OTHERS=>'0');
BEGIN
IF code_correct ='1'
	THEN
	CASE count_anim IS				    -- indien little endian
		WHEN "0000" => temp_ledbar := "1111111100"; --	"0011111111";
		WHEN "0001" => temp_ledbar := "1111111001"; --	"1001111111";
		WHEN "0010" => temp_ledbar := "1111110011"; --	"1100111111";
		WHEN "0011" => temp_ledbar := "1111100111"; --	"1110011111";
		WHEN "0100" => temp_ledbar := "1111001111"; --	"1111001111";
		WHEN "0101" => temp_ledbar := "1110011111"; --	"1111100111";
		WHEN "0110" => temp_ledbar := "1100111111"; --	"1111110011";
		WHEN "0111" => temp_ledbar := "1001111111"; --	"1111111001";
		WHEN "1000" => temp_ledbar := "0011111111"; --	"1111111100";
		WHEN OTHERS => temp_ledbar := "1111111111"; --	"1111111111";
	END CASE;
ELSE	temp_ledbar := "1111111111";
END IF;
ledbar_out <= temp_ledbar;	--actief hoog insert not()
END PROCESS led_decoder;

hex_to_7seg0:PROCESS (count_up0,test,count_enter,up_pflank_alive)			--hex/7-seg 0
VARIABLE temp_led :std_logic_vector(6 DOWNTO 0):=(OTHERS=>'0');
BEGIN
IF count_enter <3	--indien true dan is code nog niet gecontrolleerd door comparator
	THEN
	IF test='1' and up_pflank_alive='1'
		THEN
		IF count_enter >= 0 --altijd
			THEN
			CASE count_up0 IS
				WHEN "0000" =>
					temp_led :="0000001"; -- '0'
				WHEN "0001" =>
					temp_led :="1001111"; -- '1'
				WHEN "0010" =>
					temp_led :="0010010"; -- '2'
				WHEN "0011" =>
					temp_led :="0000110"; -- '3'
				WHEN "0100" =>
					temp_led :="1001100"; -- '4'
				WHEN "0101" =>
			       		temp_led :="0100100"; -- '5'
				WHEN "0110" =>
			       		temp_led :="0100000"; -- '6'
				WHEN "0111" =>
			       		temp_led :="0001111"; -- '7'
				WHEN "1000" =>
			       		temp_led :="0000000"; -- '8'
			   	WHEN "1001" =>
			       		temp_led :="0000100"; -- '9'
				WHEN "1010" =>
			       		temp_led :="0001000"; -- 'a'
				WHEN "1011" =>
			       		temp_led :="1100000"; -- 'b'
				WHEN "1100" =>
			       		temp_led :="0110001"; -- 'c'
				WHEN "1101" =>
			       		temp_led :="1000010"; -- 'd'
				WHEN "1110" =>
			       		temp_led :="0110000"; -- 'e'
				WHEN "1111" =>
					temp_led :="0111000"; -- 'f'
				WHEN OTHERS =>
			      		temp_led :="1111110"; -- '-'
			END CASE;
		ELSE temp_led := "1111110"; --count_enter < iets dus '-' op de led
		END IF;	--count_enter-if
	ELSE temp_led := "1111110"; -- test =0 output op -
	END IF; --test-if
ELSE	--nog niet genoeg op enter geduwt dus blanko
	temp_led :="1111111";
END IF;	--code bekeken-if
part_disc0 <= temp_led;
END PROCESS hex_to_7seg0;

hex_to_7seg1:PROCESS (count_up1,test,count_enter,up_pflank_alive)			--hex/7-seg 1
variable temp_led :std_logic_vector(6 DOWNTO 0):=(OTHERS=>'0');
BEGIN
IF count_enter <3 	--indien true dan is code nog niet gecontrolleerd door comparator
	THEN
	IF test='1' and up_pflank_alive='1'
		THEN
		IF count_enter >= 1
			THEN
			CASE count_up1 IS
				WHEN "0000" =>
					temp_led :="0000001"; -- '0'
				WHEN "0001" =>
					temp_led :="1001111"; -- '1'
				WHEN "0010" =>
					temp_led :="0010010"; -- '2'
				WHEN "0011" =>
					temp_led :="0000110"; -- '3'
				WHEN "0100" =>
					temp_led :="1001100"; -- '4'
				WHEN "0101" =>
			       		temp_led :="0100100"; -- '5'
				WHEN "0110" =>
			       		temp_led :="0100000"; -- '6'
				WHEN "0111" =>
			       		temp_led :="0001111"; -- '7'
				WHEN "1000" =>
			       		temp_led :="0000000"; -- '8'
			   	WHEN "1001" =>
			       		temp_led :="0000100"; -- '9'
				WHEN "1010" =>
			       		temp_led :="0001000"; -- 'a'
				WHEN "1011" =>
			       		temp_led :="1100000"; -- 'b'
				WHEN "1100" =>
			       		temp_led :="0110001"; -- 'c'
				WHEN "1101" =>
			       		temp_led :="1000010"; -- 'd'
				WHEN "1110" =>
			       		temp_led :="0110000"; -- 'e'
				WHEN "1111" =>
					temp_led :="0111000"; -- 'f'
				WHEN OTHERS =>
			      		temp_led :="1111110"; -- '-'
			END CASE;
		ELSE temp_led := "1111110"; --count_enter < iets dus - op de led
		END IF;	--count_enter-if
	ELSE temp_led := "1111110"; -- test =0 output op -
	END IF; --test-if
ELSE	--nog niet genoeg op enter geduwt dan blanko
	temp_led :="1111111";
END IF;	--code bekeken-if
part_disc1	<= temp_led;
END PROCESS hex_to_7seg1;

hex_to_7seg2:PROCESS (count_up2,test,count_enter,up_pflank_alive)			--hex/7-seg 2
variable temp_led :std_logic_vector(6 DOWNTO 0):=(OTHERS=>'0');
BEGIN
IF count_enter <3 	--indien true dan is code nog niet gecontrolleerd door comparator
	THEN
	IF test='1' and up_pflank_alive='1'
		THEN
		IF count_enter >= 2	
			THEN
			CASE count_up2 IS
				WHEN "0000" =>
					temp_led :="0000001"; -- '0'
				WHEN "0001" =>
					temp_led :="1001111"; -- '1'
				WHEN "0010" =>
					temp_led :="0010010"; -- '2'
				WHEN "0011" =>
					temp_led :="0000110"; -- '3'
				WHEN "0100" =>
					temp_led :="1001100"; -- '4'
				WHEN "0101" =>
			       		temp_led :="0100100"; -- '5'
				WHEN "0110" =>
			       		temp_led :="0100000"; -- '6'
				WHEN "0111" =>
			       		temp_led :="0001111"; -- '7'
				WHEN "1000" =>
			       		temp_led :="0000000"; -- '8'
			   	WHEN "1001" =>
			       		temp_led :="0000100"; -- '9'
				WHEN "1010" =>
			       		temp_led :="0001000"; -- 'a'
				WHEN "1011" =>
			       		temp_led :="1100000"; -- 'b'
				WHEN "1100" =>
			       		temp_led :="0110001"; -- 'c'
				WHEN "1101" =>
			       		temp_led :="1000010"; -- 'd'
				WHEN "1110" =>
			       		temp_led :="0110000"; -- 'e'
				WHEN "1111" =>
					temp_led :="0111000"; -- 'f'
				WHEN OTHERS =>
			      		temp_led :="1111110"; -- '-'
			END CASE;
		ELSE temp_led := "1111110"; --count_enter < iets dus - op de led
		END IF;	--count_enter-if
	ELSE temp_led := "1111110"; -- test =0 output op -
	END IF; --test-if
ELSE	--nog niet genoeg op enter geduwt dan blanko
	temp_led :="1111111";
END IF;	--code bekeken-if
part_disc2	<= temp_led;
END PROCESS hex_to_7seg2;

hex_to_7seg3:PROCESS (count_up3,test,count_enter,up_pflank_alive)			--hex/7-seg 3
variable temp_led :std_logic_vector(6 DOWNTO 0):=(OTHERS=>'0');
BEGIN
IF count_enter <3 	--indien true dan is code nog niet gecontrolleerd door comparator
	THEN
	IF test='1' and up_pflank_alive='1'
		THEN
		IF count_enter >= 3	
			THEN
			CASE count_up3 IS
				WHEN "0000" =>
					temp_led :="0000001"; -- '0'
				WHEN "0001" =>
					temp_led :="1001111"; -- '1'
				WHEN "0010" =>
					temp_led :="0010010"; -- '2'
				WHEN "0011" =>
					temp_led :="0000110"; -- '3'
				WHEN "0100" =>
					temp_led :="1001100"; -- '4'
				WHEN "0101" =>
			       		temp_led :="0100100"; -- '5'
				WHEN "0110" =>
			       		temp_led :="0100000"; -- '6'
				WHEN "0111" =>
			       		temp_led :="0001111"; -- '7'
				WHEN "1000" =>
			       		temp_led :="0000000"; -- '8'
			   	WHEN "1001" =>
			       		temp_led :="0000100"; -- '9'
				WHEN "1010" =>
			       		temp_led :="0001000"; -- 'a'
				WHEN "1011" =>
			       		temp_led :="1100000"; -- 'b'
				WHEN "1100" =>
			       		temp_led :="0110001"; -- 'c'
				WHEN "1101" =>
			       		temp_led :="1000010"; -- 'd'
				WHEN "1110" =>
			       		temp_led :="0110000"; -- 'e'
				WHEN "1111" =>
					temp_led :="0111000"; -- 'f'
				WHEN OTHERS =>
			      		temp_led :="1111110"; -- '-'
			END CASE;
		ELSE temp_led := "1111110"; --count_enter < iets dus - op de led
		END IF;	--count_enter-if
	ELSE temp_led := "1111110"; -- test =0 output op -
	END IF; --test-if
ELSE	--nog niet genoeg op enter geduwt dan blanko
	temp_led :="1111111";
END IF;	--code bekeken-if
part_disc3	<= temp_led;
END PROCESS hex_to_7seg3;
END behavior;
