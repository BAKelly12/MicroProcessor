--------------------------------------------------------------------------------
--
-- LAB #4
--
--------------------------------------------------------------------------------
-- Developer : Don Dang, Brigid Kelly
-- Project   : Lab 4
-- Filename  : Register.vhd
-- Date      : 5/10/18
-- Class     : Microprocessor Designs
-- Instructor: Ken Rabold
-- Purpose   : 
--             Design and implement Arithmetic Logic Unit
--
-- Notes     : 
-- This excercise is developed using Questa Sim 
			
-- Developer	Date		Activities
-- DD		5/10/18 	Modify ALU.vhd
-- KK		5/12/18		Inserted missing codes for ALU.vhd

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
	begin
  		sum   <= a xor b xor cin; 
  		carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;

--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port( datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is

	component fulladder is    -- FullAdder Component Declaration
		port (a : in std_logic;
                b : in std_logic;
                cin : in std_logic;
                sum : out std_logic;
                carry : out std_logic);
	end component;
 
signal c: std_logic_vector (32 downto 0);
signal sub: std_logic_vector (31 downto 0);

begin
	with add_sub select 
		sub <= not (datain_b) when '1',
		datain_b when others;
 
	c(0) <= add_sub;
	co <= c(32);

FullAdder32: for i in 0 to 31 generate
FAi: FullAdder port map (datain_a(i), sub(i),c(i),dataout(i), c(i + 1));

END GENERATE; 


end calc;

-----------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port( datain: in std_logic_vector(31 downto 0);
    		dir: in std_logic;
		shamt: in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
begin
-- insert code here.
	with dir & shamt select
		dataout <= datain(30 downto 0) & '0' when "000001", 
		datain(29 downto 0) & "00" when "000010", 
		datain(28 downto 0) & "000" when "000011", 
		'0' & datain(31 downto 1) when "100001", 
		"00" & datain(31 downto 2) when "100010", 
		"000" & datain(31 downto 3) when "100011",
		datain(31 downto 0) when others;

end architecture shifter;

-----------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity ALU is
	Port( DataIn1: in std_logic_vector(31 downto 0);
		DataIn2: in std_logic_vector(31 downto 0);
		ALUCtrl: in std_logic_vector(4 downto 0);
		Zero: out std_logic;
		ALUResult: out std_logic_vector(31 downto 0) );
end entity ALU;

architecture ALU_Arch of ALU is
	signal add_sub_ins: std_logic_vector(31 downto 0);
	signal add_sub_co: std_logic;
	signal shift_reg_ins: std_logic_vector(31 downto 0);
	signal and_ins: std_logic_vector(31 downto 0);
	signal or_ins: std_logic_vector(31 downto 0);
	signal result: std_logic_vector(31 downto 0);

-- ALU components
component adder_subtracter
	port( datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end component adder_subtracter;

component shift_register
	port( datain: in std_logic_vector(31 downto 0);
    		dir: in std_logic;
		shamt: in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end component shift_register;

begin
-- Add ALU VHDL implementation here

	addsub: adder_subtracter port map(DataIn1, DataIn2, ALUCtrl(2), add_sub_ins, add_sub_co);
	shift: shift_register port map(DataIn1, ALUCtrl(3), DataIn2(4 downto 0), shift_reg_ins);

	and_ins <= DataIn1 and DataIn2;
	or_ins <= DataIn1 or DataIn2;

with ALUCtrl(1 downto 0) select
	result <= add_sub_ins when "00",
  	shift_reg_ins when "01",
  	and_ins when "10",
  	or_ins when others;

with result select
	Zero <= '1' when "00000000000000000000000000000000",
	'0' when others;

	ALUResult <= result;

end architecture ALU_Arch;

