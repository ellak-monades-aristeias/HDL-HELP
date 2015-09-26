
----------------------------------------------------------------------------------------------------------------
-- Part 1
-- Libraries declaration
----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 2
-- Entity declaration
----------------------------------------------------------------------------------------------------------------

entity vga_controller_v1 is    
	port(clk : in std_logic;
		 rst : in std_logic;
		 validData : in std_logic;
		 vgaAddress : in std_logic_vector(18 downto 0);
		 vgaData : in std_logic_vector(3 downto 0);
		 hsync : out std_logic;
		 vsync : out std_logic;
		 vgaCLK : out std_logic;
		 red : out std_logic_vector(7 downto 0);
		 green : out std_logic_vector(7 downto 0);
		 blue : out std_logic_vector(7 downto 0) );
end vga_controller_v1;

----------------------------------------------------------------------------------------------------------------

architecture bhv of vga_controller_v1 is 

----------------------------------------------------------------------------------------------------------------
-- Part 3
-- Components declaration
----------------------------------------------------------------------------------------------------------------

	-- memory buffer // default settings for 640x480 image resolution
	-- for different address/data width use Altera's MegaWizard plug-in manager to edit the vga_buffer.vhd 
	component vgabuffer is
		port(clock : in std_logic;
			 data : in std_logic_vector (3 downto 0);
			 rdaddress : in std_logic_vector (18 downto 0);
			 wraddress : in std_logic_vector (18 downto 0);
			 wren : in std_logic;
			 q : out std_logic_vector (3 downto 0)	);
	end component;
	
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 4
-- Signals declaration
----------------------------------------------------------------------------------------------------------------

	signal enable : std_logic;
	signal hcount : std_logic_vector(9 downto 0);
	signal vcount : std_logic_vector(9 downto 0);
	signal sigVsync : std_logic;
	signal sigHsync : std_logic;
	signal addressPointer : std_logic_vector(2 downto 0);
	signal vgaBuffer_rdaddress : std_logic_vector(18 downto 0);
	signal vgaBuffer_dataOut : std_logic_vector(3 downto 0);
	
	type state_type is (s1, s2);
	signal state : state_type;
	
----------------------------------------------------------------------------------------------------------------
	
begin

----------------------------------------------------------------------------------------------------------------
-- Part 5
-- Components instantiation
----------------------------------------------------------------------------------------------------------------
  
  comp1: vgaBuffer port map(clk, vgaData, vgaBuffer_rdaddress,
              vgaAddress, validData, vgaBuffer_dataOut);

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 6
-- Define the FSM
----------------------------------------------------------------------------------------------------------------
	
	-- 25MHz clock formulation (from 50MHz clock)   
	process(clk, rst)
	begin
		if rst='0' then
			state <= s1;
		elsif rising_edge(clk) then
			case state is
				when s1 =>  
					state <= s2;
				when s2 =>  
					state <= s1;
			end case;
		end if;
	end process;
 
	process(state)
	begin
		case state is
			when s1 => 
				enable <= '1';
			when s2 =>
				enable <= '0';
		end case;
	end process;

----------------------------------------------------------------------------------------------------------------
	
----------------------------------------------------------------------------------------------------------------
-- Part 7
-- Create VGA resolution (640x480, 60Hz) synchronization signals
----------------------------------------------------------------------------------------------------------------
 
	-- Horizontal synchronization signal
	process(clk, rst)
	begin
		if rst='0' then
			hcount <= (others => '0');
			sigHsync <= '1';
		elsif rising_edge(clk) then 
			if enable = '1' then
				hcount <= hcount + 1;
				if hcount>655 and hcount<752 then
					sigHsync <= '0';
				elsif (hcount>639 and hcount<656) or (hcount>751 and hcount<799) then
					sigHsync <= '1';
				elsif hcount=799 then
					hcount <= (others => '0');
					sigHsync <= '1';
				else 
					sigHsync <= '1';
				end if;
			end if; 
		end if; 
	end process;
	
	-- Vertical synchronization signal
	process(clk, rst)
	begin
		if rst='0' then
			vcount <= (others => '0');
			sigVsync <= '1';
		elsif rising_edge(clk) then 
			if enable='1' then
				if hcount=799 then
					vcount <= vcount + 1;
				end if;
				if vcount>490 and vcount<493 then
					sigVsync <= '0';
				elsif (vcount>479 and vcount<491) or (vcount>492 and vcount<523) then
					sigVsync<='1';
				elsif vcount=523 then
					sigVsync <= '1';
					vcount <= (others=>'0');
				else
					sigVsync <= '1';
				end if;
			end if; 
		end if; 
	end process;
	
----------------------------------------------------------------------------------------------------------------
	
----------------------------------------------------------------------------------------------------------------
-- Part 8
-- Set pixel values according to VGA buffer contents
----------------------------------------------------------------------------------------------------------------

	-- Synchronize VGA buffer read address to active pixel per clock
	process(clk, rst)
	begin
		if rst='0' then
			vgaBuffer_rdaddress <= (others => '0');
		elsif rising_edge(clk) then
			if enable='1' then
				if ( (hcount<640) and (vcount<480) ) then
					vgaBuffer_rdaddress <= vgaBuffer_rdaddress + 1;
				end if;
				if ( (hcount=640) and (vcount=480) ) then
					vgaBuffer_rdaddress <= (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	-- Assign vgaBuffer output to RGB channels
	process(hcount, vcount, vgaBuffer_dataOut)
	begin
		if ( (hcount<640) and (vcount<480) ) then
			red <= vgaBuffer_dataOut(7 downto 0);
			green <= vgaBuffer_dataOut(15 downto 8);
			blue <= vgaBuffer_dataOut(23 downto 16);
		else
			red <= (others => '0');
			green <= (others => '0');
			blue <= (others => '0');
		end if;
	end process;

----------------------------------------------------------------------------------------------------------------
	
	vsync <= sigVsync;
	hsync <= sigHsync;
	vgaCLK <= enable;
  
end;