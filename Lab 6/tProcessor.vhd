
-- Developer  : Don Dang, Brigid Kelly
-- Project    : Lab 6
-- ProjectName: Single Cycle Processor
-- Filename   : tProcessor.vhd
-- Date       : 5/30/18
-- Class      : Microprocessor Designs
-- Instructor : Ken Rabold
-- Purpose    : 
--             Creating the Single Cycle Processor
--
-- Notes      : 
-- This excercise is developed using Questa Sim 
-- tProcessor.vhd will be used as a testbench for testing the Single Cycle Processor design
			
-- Developer	Date		Activities
-- DD		5/30/18 	Download lab 6 from Team DangKelly from Github


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY tProcessor_vhd IS
END tProcessor_vhd;


---UNIT TESTS MUST STILL BE COMPLETED ---- BRi
ARCHITECTURE behavior OF tProcessor_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT Processor
	PORT(	reset : in  std_logic;
		clock : IN std_logic
		);
	END COMPONENT;

	SIGNAL reset : std_logic := '0';
	SIGNAL clock : std_logic := '0';

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: Processor PORT MAP(
		clock => clock,
		reset => reset);

	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 80 ns;

		-- Reset the processor
		reset <= '1';
		wait for 5 ns;
		reset <= '0';
		wait for 5 ns;

		-- Start processor clock
		for i in 1 to 10000 loop
                    -- clock period = 10 ns
		    clock <= not clock;
                    wait for 5 ns;
    		    clock <= not clock;
                    wait for 5 ns;
                end loop;
  
                wait;  -- simulation stops here

	END PROCESS;

END;
