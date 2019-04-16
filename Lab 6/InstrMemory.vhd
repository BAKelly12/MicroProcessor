--------------------------------------------------------------------------------
--
-- LAB #6 - Instruction Memory
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity InstructionRAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity InstructionRAM;

architecture instrucRAM of InstructionRAM is

   type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;
   signal i_address : std_logic_vector(4 downto 0);

begin

  RamProc: process(Clock, Reset) is
  begin
    if Reset = '1' then
       i_ram <= (
			 0 => B"00000000000000000000010100110011",		--  	add  a0, zero, zero	
			 1 => B"00010000000000000000100010110111",		-- 	lui  a7, 0x10000
			 2 => B"01000100010000000000011000010011",		-- 	addi a2, zero, 0x0444
			 3 => B"00000000001001010001010110010011",		-- 	slli a1, a0, 2     # this is line2:
			 4 => B"00000000001001011001010110010011",		-- 	slli a1, a1, 2  
			 5 => B"00000001000101011000010110110011",		-- 	add  a1, a1, a7       
			 6 => B"00000000000101100001011000010011",		-- 	slli a2, a2, 1       
			 7 => B"00000000101001011010000000100011",		-- 	sw   a0, 0(a1)
			 8 => B"00000000110001011010001000100011",		-- 	sw   a2, 4(a1)
			 9 => B"00000000001001100001011010010011",		-- 	slli a3, a2, 2   
			10 => B"00000000110101011010010000100011",		-- 	sw   a3, 8(a1)
			11 => B"01000000110001101000011100110011",		-- 	sub  a4, a3, a2
			12 => B"00000000111001011010011000100011",		-- 	sw   a4, 12(a1)
			13 => B"00000000000101010000010100010011",		-- 	addi a0, a0, 1
			14 => B"00000000010100000000011110010011",		-- 	addi a5, zero, 5 
			15 => B"01000000101001111000100000110011",		-- 	sub  a6, a5, a0   
			16 => B"11111100000010000001011011100011",		-- 	bne  a6, zero, line2
			17 => B"00000000100001011010100010000011",		-- 	lw   a7, 8(a1)
			18 => B"00000000000000000000000001100011",		-- 	beq  zero, zero, stop 
		others => X"00000000");             
    end if;
  end process RamProc;

  -- Decode address and return instruction to execute
  i_address <= Address(4 downto 0);
  DataOut   <= i_ram(to_integer(unsigned(i_address)));
 
end instrucRAM;	

----------------------------------------------------------------------------------------------------------------------------------------------------------------
