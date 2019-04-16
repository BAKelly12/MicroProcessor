-- Developer  : Don Dang, Brigid Kelly
-- Project    : Lab 6
-- ProjectName: Single Cycle Processor
-- Filename   : Processor.vhd
-- Date       : 5/30/18
-- Class      : Microprocessor Designs
-- Instructor : Ken Rabold
-- Purpose    : 
--             Creating the Single Cycle Processor
--
-- Notes      : 
-- This excercise is developed using Questa Sim 
-- The starting files for this project is Processor.vhd and ProcElements.vhd
			
-- Developer	Date		Activities
-- DD		5/30/18 	Download lab 6 from Team DangKelly from Github


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	       clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port( clk : in  STD_LOGIC;
               opcode : in  STD_LOGIC_VECTOR (6 downto 0);
               funct3  : in  STD_LOGIC_VECTOR (2 downto 0);
               funct7  : in  STD_LOGIC_VECTOR (6 downto 0);
               Branch : out  STD_LOGIC_VECTOR(1 downto 0);
               MemRead : out  STD_LOGIC;
               MemtoReg : out  STD_LOGIC;
               ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0);
               MemWrite : out  STD_LOGIC;
               ALUSrc : out  STD_LOGIC;
               RegWrite : out  STD_LOGIC;
               ImmGen : out STD_LOGIC_VECTOR(1 downto 0));
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     ALUCtrl: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component ProgramCounter;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;
	

	------------------------------------
	--     PROGRAM COUNTER SIGNALS    --
	------------------------------------
signal  PCout : std_logic_vector(31 downto 0);  --output of program counter to IM
--signal  PCplusFour : std_logic_vector(31 downto 0):= "00000000000000000000000000000100"; -- Signal for adding 4 to current instruction memory address
signal  PCAdderOut : std_logic_vector(31 downto 0);  --result of PC+4
signal  PCAddco : std_logic;  --Program counter adder carryout
signal  BNEout: std_logic;  --Branch logic output
signal  BranchAddOut: std_logic_vector(31 downto 0);  --  Signal out of add/sub for branch instructions
signal  BranchAddCarry: std_logic;

signal  PcMuxOut : std_logic_vector(31 downto 0);  -- Output from PC Mux

	-----------------------------------
	--   IMMEDIATE GENERATOR SIGNALS --
	-----------------------------------
signal ImmGenOut : std_logic_vector(31 downto 0);  --output of immediate generator
signal IMtoImmGen : std_logic_vector(31 downto 0);  -- Output from instruction memory to immediate generator

	----------------------------------
	--  INSTRUCTION MEMORY SIGNAL  --
	----------------------------------
signal IMOUT : std_logic_vector(31 downto 0);  --Output of instruction memory bank

	----------------------------------
	--         REG32 SIGNALS        --
	----------------------------------
signal RegDat1 : std_logic_vector(31 downto 0); -- Both signals are outputs from registers
signal RegDat2 : std_logic_vector(31 downto 0);  


	----------------------------------
	--          ALU SIGNALS         --
	----------------------------------
signal Mux2ALU : std_logic_vector(31 downto 0); -- Input to ALU
signal ALUOut  : std_logic_vector(31 downto 0); -- Output from ALU
signal ALUzero : std_logic;  -- Output from ALU zero detector

	----------------------------------
	--     DATA MEMORY SIGNALS      --
	----------------------------------
signal MemReadOut : std_logic_vector(31 downto 0);

signal MeMuxOut   : std_logic_vector(31 downto 0);

signal Acct30bit  : std_logic_vector(29 downto 0);  -- This is a special signal to account for proper addressing of memory


	----------------------------------
	--    CONTROL BLOCK SIGNALS     --
	----------------------------------
signal BranchCTRL   : std_logic_vector(1 downto 0);
signal MemReadCTRL  : std_logic;
signal MemToRegCTRL : std_logic;
signal ALUCTRLCTRL  : std_logic_vector(4 downto 0);
signal MemWriteCTRL : std_logic;
signal ALUSrcCTRL   : std_logic;
signal RegWriteCTRL : std_logic;
signal ImmGenCTRL   : std_logic_vector(1 downto 0);

begin

	-----------------------------------
	--    PROGRAM COUNTER MAPS       --
	-----------------------------------
	PC :         ProgramCounter   port map(reset, clock, PCMuxOut, PCout);
	PCAdder:     adder_subtracter  port map(PCout,  "00000000000000000000000000000100", '0', PCAdderOut, PCAddco);
	Branchadder: adder_subtracter port map(PCout, ImmGenOut, '0', BranchAddOut, BranchAddCarry);
	PCmux:       BusMux2To1       port map(BNEout, PCAdderOut,  BranchAddOut, PCMuxOut);	
       -- BranchOrNot: branchlogic      port map(BranchCTRL, ALUZero, BNEOut);

	----------------------------------
	--  INSTRUCTION MEMORY MAP      --
	----------------------------------
	IM :         InstructionRAM   port map(reset, clock, PCOut(31 downto 2), IMOUT);


	----------------------------------
	--     CONTROL BLOCK MAP        --
	----------------------------------
	CTRL :       Control          port map(clock, IMOUT(6 downto 0), IMOUT(14 downto 12), IMOUT(31 downto 25), BranchCTRL, MemReadCTRL, MemToRegCTRL,
														 ALUCTRLCTRL, MemWriteCTRL, ALUSrcCTRL, RegWriteCTRL, ImmGenCTRL);

	---------------------------------
	--         REG32 MAPS          --
	---------------------------------
	Reg32 :      Registers        port map(IMOUT(19 downto 15), IMOUT(24 downto 20), IMOUT(11 downto 7), MeMuxOut, RegWriteCTRL, RegDat1, RegDat2);
       
	RegMux:      BusMux2To1       port map(ALUSrcCTRL, RegDat2, ImmGenOut, Mux2ALU);


	

	--------------------------------
	--        ALU MAP             --
	--------------------------------
	TheALU :     ALU              port map(RegDat1, Mux2ALU, ALUCTRLCTRL, ALUZero, ALUOut);

	--------------------------------
	--    DATA MEMORY MAPS        --
	--------------------------------
	Acct30bit <= "0000" & ALUOUT(27 downto 2);
	
	DMEM :       RAM              port map(reset, clock, MemReadCTRL, MemWriteCTRL, Acct30bit, RegDat2, MemReadOut);

	MeMux :      BusMux2To1       port map(MemToRegCTRL, ALUOut, MemReadOut, MeMuxOut);

	---------------------------------
	--        IMMGEN MAP           --
	---------------------------------

--IGEN :       ImmGen           port map(ImmGenCTRL, IMOUT, ImmGenOut);

	with ImmGenCTRL & IMOUT(31) select
	ImmGenOut <=   "111111111111111111111" & IMOUT(30 downto 20) when "001",  --I_type
                       "000000000000000000000" & IMOUT(30 downto 20) when "000",  --I_type
		       "111111111111111111111" & IMOUT(30 downto 25) & IMOUT(11 downto 7) when "011",  --S_type
                       "000000000000000000000" & IMOUT(30 downto 25) & IMOUT(11 downto 7) when "010",  --S_type
		        "11111111111111111111" & IMOUT(7) & IMOUT(30 downto 25) & IMOUT(11 downto 8) & '0' when "101", --B_type
                        "00000000000000000000" & IMOUT(7) & IMOUT(30 downto 25) & IMOUT(11 downto 8) & '0' when "100", --B_type
			                   "1" & IMOUT(30 downto 12) & "000000000000" when "111", --U_type
                                           "0" & IMOUT(30 downto 12) & "000000000000" when "110", --U_type
            "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when others;
	

	-------------------------------------
	--        BRANCH LOGIC             --
	-------------------------------------

	with BranchCTRL & ALUZero select
	BNEOut <=   '1' when "101",
                         '1' when "010",
		         '0' when others;
 

end holistic;



