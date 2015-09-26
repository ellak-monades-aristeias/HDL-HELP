
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
	port(  
		clk : in std_logic;
		rst : in std_logic;
		board_status : in std_logic_vector(17 downto 0);
		hsync : out std_logic;
		vsync : out std_logic;
		vgaCLK : out std_logic;
		red : out std_logic_vector(7 downto 0);
		green : out std_logic_vector(7 downto 0);
		blue : out std_logic_vector(7 downto 0)
		);
end vga_controller;

----------------------------------------------------------------------------------------------------------------

architecture bhv of vga_controller is 

----------------------------------------------------------------------------------------------------------------
-- Part 3
-- Components declaration
----------------------------------------------------------------------------------------------------------------

	-- ROM memory blocks to display X and O symbols 
	component romX
    port(address : in std_logic_vector(5 downto 0);
         data : out std_logic_vector(63 downto 0));
    end component;
	
	component romO
    port(address : in std_logic_vector(5 downto 0);
         data : out std_logic_vector(63 downto 0));
    end component;

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 4
-- Signals declaration
----------------------------------------------------------------------------------------------------------------

	signal enable : std_logic;
	signal hcount : std_logic_vector(9 downto 0);
	signal vcount : std_logic_vector(9 downto 0);
	signal pointer : std_logic_vector(9 downto 0);
	signal sigVsync : std_logic;
	signal sigHsync : std_logic;
	signal dataX, dataO : std_logic_vector(63 downto 0);
	signal addressX, addressO : std_logic_vector(9 downto 0);
	
	type state_type is (s1,s2);
	signal state : state_type;
	
----------------------------------------------------------------------------------------------------------------

begin

----------------------------------------------------------------------------------------------------------------
-- Part 5
-- Components instantiation
----------------------------------------------------------------------------------------------------------------
    
	-- Rom blocks containing X and O symbols figures
	rX: romX port map(addressX(5 downto 0), dataX);
	rO: romO port map(addressO(5 downto 0), dataO);
	
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
  
	-- Screen Display
	process(hcount, vcount, board_status, dataX, dataO, rst)
	begin
		red <= (others => '0');
		green <= (others => '0');
		blue <= (others => '0');
		if rst='0' then
			addressX <= (others => '0');
			addressO <= (others => '0');
		else
			addressX <= (others => '0');
			addressO <= (others => '0');
			-- X and O display
			if ( ( hcount>68 and hcount<=132 ) and ( vcount>50 and vcount<99 ) ) then
				if ( board_status(1 downto 0)="01") then
					addressX <= vcount-51;
					red <= (others => dataX((conv_integer(hcount)-69)));	--  X_|___|__
					green <= (others => dataX((conv_integer(hcount)-69)));	--  __|___|__ 
					blue <= (others => dataX((conv_integer(hcount)-69)));	--    |   |
				elsif ( board_status(1 downto 0)="10") then
					addressO <= vcount-51;
					red <= (others => dataO((conv_integer(hcount)-69)));	--  O_|___|__
					green <= (others => dataO((conv_integer(hcount)-69)));	--  __|___|__ 
					blue <= (others => dataO((conv_integer(hcount)-69)));	--    |   |
				end if;
			elsif ( ( hcount>288 and hcount<=352 ) and ( vcount>50 and vcount<99 ) ) then
				if ( board_status(3 downto 2)="01") then
					addressX <= vcount-51;
					red <= (others => dataX((conv_integer(hcount)-289)));	--  __|_X_|__
					green <= (others => dataX((conv_integer(hcount)-289)));	--  __|___|__ 
					blue <= (others => dataX((conv_integer(hcount)-289)));	--    |   |
				elsif ( board_status(3 downto 2)="10") then
					addressO <= vcount-51;
					red <= (others => dataO((conv_integer(hcount)-289)));	--  __|_O_|__
					green <= (others => dataO((conv_integer(hcount)-289)));	--  __|___|__ 
					blue <= (others => dataO((conv_integer(hcount)-289)));	--    |   |
				end if;
			elsif ( ( hcount>508 and hcount<=572 ) and ( vcount>50 and vcount<99 ) ) then
				if ( board_status(5 downto 4)="01") then
					addressX <= vcount-51;
					red <= (others => dataX((conv_integer(hcount)-509)));	--  __|___|_X
					green <= (others => dataX((conv_integer(hcount)-509)));	--  __|___|__ 
					blue <= (others => dataX((conv_integer(hcount)-509)));	--    |   |
				elsif ( board_status(5 downto 4)="10") then
					addressO <= vcount-51;
					red <= (others => dataO((conv_integer(hcount)-509)));	--  __|___|_O
					green <= (others => dataO((conv_integer(hcount)-509)));	--  __|___|__ 
					blue <= (others => dataO((conv_integer(hcount)-509)));	--    |   |
				end if;
			elsif ( ( hcount>68 and hcount<=132 ) and ( vcount>200 and vcount<249 ) ) then
				if ( board_status(7 downto 6)="01") then
					addressX <= vcount-201;
					red <= (others => dataX((conv_integer(hcount)-69)));	--  __|___|__
					green <= (others => dataX((conv_integer(hcount)-69)));	--  X_|___|__ 
					blue <= (others => dataX((conv_integer(hcount)-69)));	--    |   |
				elsif ( board_status(7 downto 6)="10") then
					addressO <= vcount-201;
					red <= (others => dataO((conv_integer(hcount)-69)));	--  __|___|__
					green <= (others => dataO((conv_integer(hcount)-69)));	--  O_|___|__ 
					blue <= (others => dataO((conv_integer(hcount)-69)));	--    |   |
				end if;
			elsif ( ( hcount>288 and hcount<=352 ) and ( vcount>200 and vcount<249 ) ) then
				if ( board_status(9 downto 8)="01") then
					addressX <= vcount-201;
					red <= (others => dataX((conv_integer(hcount)-289)));	--  __|___|__
					green <= (others => dataX((conv_integer(hcount)-289)));	--  __|_X_|__ 
					blue <= (others => dataX((conv_integer(hcount)-289)));	--    |   |
				elsif ( board_status(9 downto 8)="10") then
					addressO <= vcount-201;
					red <= (others => dataO((conv_integer(hcount)-289)));	--  __|___|__
					green <= (others => dataO((conv_integer(hcount)-289)));	--  __|_O_|__ 
					blue <= (others => dataO((conv_integer(hcount)-289)));	--    |   |
				end if;
			elsif ( ( hcount>508 and hcount<=572 ) and ( vcount>200 and vcount<249 ) ) then
				if ( board_status(11 downto 10)="01") then
					addressX <= vcount-201;
					red <= (others => dataX((conv_integer(hcount)-509)));	--  __|___|__
					green <= (others => dataX((conv_integer(hcount)-509)));	--  __|___|_X 
					blue <= (others => dataX((conv_integer(hcount)-509)));	--    |   |
				elsif ( board_status(11 downto 10)="10") then
					addressO <= vcount-201;
					red <= (others => dataO((conv_integer(hcount)-509)));	--  __|___|__
					green <= (others => dataO((conv_integer(hcount)-509)));	--  __|___|_O 
					blue <= (others => dataO((conv_integer(hcount)-509)));	--    |   |
				end if;
			elsif ( ( hcount>68 and hcount<=132 ) and ( vcount>350 and vcount<399 ) ) then
				if ( board_status(13 downto 12)="01") then
					addressX <= vcount-351;
					red <= (others => dataX((conv_integer(hcount)-69)));	--  __|___|__
					green <= (others => dataX((conv_integer(hcount)-69)));	--  __|___|__ 
					blue <= (others => dataX((conv_integer(hcount)-69)));	--  X |   |
				elsif ( board_status(13 downto 12)="10") then
					addressO <= vcount-351;
					red <= (others => dataO((conv_integer(hcount)-69)));	--  __|___|__
					green <= (others => dataO((conv_integer(hcount)-69)));	--  __|___|__ 
					blue <= (others => dataO((conv_integer(hcount)-69)));	--  O |   |
				end if;
			elsif ( ( hcount>288 and hcount<=352 ) and ( vcount>350 and vcount<399 ) ) then
				if ( board_status(15 downto 14)="01") then
					addressX <= vcount-351;
					red <= (others => dataX((conv_integer(hcount)-289)));	--  __|___|__
					green <= (others => dataX((conv_integer(hcount)-289)));	--  __|___|__ 
					blue <= (others => dataX((conv_integer(hcount)-289)));	--    | X |
				elsif ( board_status(15 downto 14)="10") then
					addressO <= vcount-351;
					red <= (others => dataO((conv_integer(hcount)-289)));	--  __|___|__
					green <= (others => dataO((conv_integer(hcount)-289)));	--  __|___|__ 
					blue <= (others => dataO((conv_integer(hcount)-289)));	--    | O |
				end if;
			elsif ( ( hcount>508 and hcount<=572 ) and ( vcount>350 and vcount<399 ) ) then
				if ( board_status(17 downto 16)="01") then
					addressX <= vcount-351;
					red <= (others => dataX((conv_integer(hcount)-509)));	--  __|___|__
					green <= (others => dataX((conv_integer(hcount)-509)));	--  __|___|__ 
					blue <= (others => dataX((conv_integer(hcount)-509)));	--    |   | X
				elsif ( board_status(17 downto 16)="10") then
					addressO <= vcount-351;
					red <= (others => dataO((conv_integer(hcount)-509)));	--  __|___|__
					green <= (others => dataO((conv_integer(hcount)-509)));	--  __|___|__ 
					blue <= (others => dataO((conv_integer(hcount)-509)));	--    |   | O
				end if;
			end if;
			
			-- board lines
			if ( ( hcount>200 and hcount<220 ) or ( hcount>420 and hcount<440 ) ) then
				red <= (others => '1');										--	 |   |  
				green <= (others => '1');									--	 |   |  
				blue <= (others => '1');									--   |   |
			elsif ( ( vcount>150 and vcount<170 ) or ( vcount>310 and vcount<330) ) then
				red <= (others => '1');										--	_________
				green <= (others => '1');									--  _________
				blue <= (others => '1');									--	         
			end if;
		end if;
	end process;

----------------------------------------------------------------------------------------------------------------

	vsync<=sigVsync;
	hsync<=sigHsync;
	vgaCLK <= enable;

end;