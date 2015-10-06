
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

   entity vga_controller is
	  port(clk : in std_logic;
		   rst : in std_logic;
		   keyboard_data : in std_logic_vector(7 downto 0);
		   hsync : out std_logic;
		   vsync : out std_logic;
		   vgaCLK : out std_logic;
		   red : out std_logic_vector(7 downto 0);
		   green : out std_logic_vector(7 downto 0);
		   blue : out std_logic_vector(7 downto 0));
   end vga_controller;

----------------------------------------------------------------------------------------------------------------

architecture bhv of vga_controller is 

----------------------------------------------------------------------------------------------------------------
-- Part 3
-- Components declaration
----------------------------------------------------------------------------------------------------------------

	-- Memory buffer
	-- for different address/data width use Altera's MegaWizard plug-in manager to edit the vga_buffer.vhd 
	component vga_buffer is
		port(clock : in std_logic;
			 data : in std_logic_vector (2 downto 0);
			 rdaddress : in std_logic_vector (14 downto 0);
			 wraddress : in std_logic_vector (14 downto 0);
			 wren : in std_logic;
			 q : out std_logic_vector (2 downto 0) );
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
	signal pointer : std_logic_vector(14 downto 0);
	signal vgaBuffer_rdaddress : std_logic_vector(14 downto 0);
	signal vgaBuffer_dataOut : std_logic_vector(2 downto 0);
	signal vgaBuffer_wraddress : std_logic_vector(14 downto 0);
	signal vgaBuffer_dataIn : std_logic_vector(2 downto 0);
	signal vgaBuffer_wrEnable : std_logic;
	
	type state_type is (s1,s2);
	signal state : state_type;

----------------------------------------------------------------------------------------------------------------
	
begin
  
----------------------------------------------------------------------------------------------------------------
-- Part 5
-- Components instantiation
----------------------------------------------------------------------------------------------------------------

	-- Instantiate VGA buffer
comp1: vga_buffer port map(clk, vgaBuffer_dataIn, vgaBuffer_rdaddress,
              vgaBuffer_wrAddress, vgaBuffer_wrEnable, vgaBuffer_dataOut);
    
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
					enable <= '1';
				when s2 =>  
					state <= s1;
					enable <= '0';
				when others => 
					enable <= '0';
			end case;
		end if;
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
				elsif (vcount>479 and vcount<491) or (vcount>492 and vcount<524) then
					sigVsync<='1';
				elsif vcount=524 then
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

	-- synchronize VGA buffer read address to active pixel space
	process(clk, rst)
	begin
		if rst='0' then
			vgaBuffer_rdaddress <= (others => '0');
		elsif rising_edge(clk) then
			if enable='1' then
				if ( ( hcount>240 and hcount<= 400 ) and ( vcount>180 and vcount<=300 ) ) then
					vgaBuffer_rdaddress <= vgaBuffer_rdaddress + 1;
				elsif hcount=401 and vcount=300 then
					vgaBuffer_rdaddress <= (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	-- Send VGA Buffer values to Red, Green, Blue (RGB) output channels
	process(hcount, vcount, pointer, vgaBuffer_rdaddress, vgaBuffer_dataOut)
	begin
		red <= (others => '0');
		green <= (others => '0');
		blue <= (others => '0');
		if ( ( hcount>240 and hcount<= 400 ) and ( vcount>180 and vcount<=300 ) ) then
			red <= (others => vgaBuffer_dataOut(0));
			green <= (others => vgaBuffer_dataOut(1));
			blue <= (others => vgaBuffer_dataOut(2));
			if (vgaBuffer_rdaddress = pointer) then
				if vgaBuffer_dataOut="111" then
					red <= (others => '0');
					green <= (others => '0');
					blue <= (others => '0');
				else
					red <= (others => vgaBuffer_dataOut(0));
					green <= (others => vgaBuffer_dataOut(1));
					blue <= (others => vgaBuffer_dataOut(2));
				end if;
			end if;
		end if;
	end process;
	
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 9
-- Cursor moves
----------------------------------------------------------------------------------------------------------------
	
	-- Current pixel position (cursor)
	process(clk,rst)
	begin
		if rst='0' then
			pointer <= "000000001100000";
		elsif rising_edge(clk) then
			if keyboard_data="00100011" then 	-- 'D' button check, 23(HEX)
				pointer <= pointer + 1; 		-- move right (current position + 1)
			elsif keyboard_data="00011100" then 	-- 'A' button check, 1C (HEX)
				pointer <= pointer - 1; 			-- move left (current position - 1)
			elsif keyboard_data="00011101" then 	-- 'W' button check, 1D (HEX)
				if pointer <= 160 then				-- move up (from 1st line to last)
					pointer <= pointer + 19040;
				else								-- move up (current position - length of row)
					pointer <= pointer - 160;
				end if;
			elsif keyboard_data="00011011" then 	-- 'S' button check, 1B (HEX)
				if pointer >= 19040 then				-- move down (from last line to 1st)
					pointer <= pointer - 19040; 
				else								-- move down (current position + length of row)
					pointer <= pointer + 160; 
				end if;
			end if;
		end if;
	end process;
	
----------------------------------------------------------------------------------------------------------------
-- Part 10
-- Insert color to pixels
----------------------------------------------------------------------------------------------------------------
	
	-- Insert pixel colour to VGA buffer
	process(keyboard_data, pointer)
	begin
		if keyboard_data="00101101" then 			-- Check for button 'R'
			vgaBuffer_dataIn <= "001"; 				-- Red color stored in bit(0)
			vgaBuffer_wrAddress <= pointer-1;		-- Get current cursor value to store color information
			vgaBuffer_wrEnable <= '1';
		elsif keyboard_data="00110100" then 		-- Check for button 'G'
			vgaBuffer_dataIn <= "010";				-- Green color stored in bit(1)
			vgaBuffer_wrAddress <= pointer-1;		-- Get current cursor value to store color information
			vgaBuffer_wrEnable <= '1';
		elsif keyboard_data="00110010" then 		-- Check for button 'B'
			vgaBuffer_dataIn <= "100";				-- Blue color stored in bit(2) 
			vgaBuffer_wrAddress <= pointer-1;		-- Get current cursor value to store color information
			vgaBuffer_wrEnable <= '1';
		else										-- if no color key pressed do nothing
			vgaBuffer_dataIn <= (others => '0');
			vgaBuffer_wrAddress <= (others => '0');
			vgaBuffer_wrEnable <= '0';
		end if;	
	end process;
	
----------------------------------------------------------------------------------------------------------------

	vsync <= sigVsync;
	hsync <= sigHsync;
	vgaCLK <= enable;
	
end;