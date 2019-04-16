--------------------------------------------------------------------------------
--
-- LAB #3
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

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

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
begin
	-- insert your code here.
	reg8: bitstorage port map(datain(7), enout, writein, dataout(7));
	reg7: bitstorage port map(datain(6), enout, writein, dataout(6));
	reg6: bitstorage port map(datain(5), enout, writein, dataout(5));
	reg5: bitstorage port map(datain(4), enout, writein, dataout(4));
	reg4: bitstorage port map(datain(3), enout, writein, dataout(3));
	reg3: bitstorage port map(datain(2), enout, writein, dataout(2));
	reg2: bitstorage port map(datain(1), enout, writein, dataout(1));
	reg1: bitstorage port map(datain(0), enout, writein, dataout(0));
end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	-- hint: you'll want to put register8 as a component here 
	-- so you can use it below
	component register8
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
	end component;
	signal enabler: std_logic_vector(2 downto 0);
	signal writer: 	std_logic_vector(2 downto 0);
begin
	-- insert code here.
	enabler(2) <= enout32; --active low
	enabler(1) <= enout16 and enout32;
	enabler(0) <= enout8 and enout16 and enout32;

	writer(2) <= writein32; --active high
	writer(1) <= writein16 or writein32;
	writer(0) <= writein8 or writein16 or writein32;

	reg32: register8 port map(datain(31 downto 24), enabler(2), writer(2), dataout(31 downto 24));
	reg24: register8 port map(datain(23 downto 16), enabler(2), writer(2), dataout(23 downto 16));
	reg16: register8 port map(datain(15 downto 8),  enabler(1), writer(1), dataout(15 downto 8));
	reg08: register8 port map(datain(7 downto 0),   enabler(0), writer(0), dataout(7 downto 0));
end architecture biggermem;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is
	component fulladder
		port (a : in std_logic;
			   b : in std_logic;
			   cin : in std_logic;
			   sum : out std_logic;
			   carry : out std_logic
			     );
	end component;
	
	signal c : std_logic_vector (32 downto 0);
	signal b : std_logic_vector (31 downto 0);
begin
	-- insert code here.
	with add_sub select 
	b <= not (datain_b) when '1',
		   datain_b when others;
	c(0) <= add_sub;
	co <= c(32);
	adder: For i in 0 to 31 generate
		    FA1: fulladder PORT MAP (datain_a(i), b(i), c(i), dataout(i), c(i+1));
		end generate;
		
end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
	COMPONENT shift_register
	PORT(datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
	END COMPONENT;
	
begin
	-- insert code here.
	with shamt & dir select
	dataout <= 	datain(30 downto 0) & '0'  	when "000010", --shift left by 1
		  '0' & datain(31 downto 1)  		when "000011", --shift right by 1
		 	datain(29 downto 0) & "00"	when "000100", --shift left by 2
		 "00" & datain(31 downto 2) 		when "000101", --shift right by 2
			datain(28 downto 0) & "000" 	when "000110", --shift left by 3
		"000" & datain(31 downto 3)		when "000111", --shift right by 3
			datain(31 downto 0) 		when others;
end architecture shifter;
