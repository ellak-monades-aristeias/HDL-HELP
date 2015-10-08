
----------------------------------------------------------------------------------------------------------------
-- Part 1
-- Libraries declaration
----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 2
-- Entity declaration
----------------------------------------------------------------------------------------------------------------

   entity color_pixels is
	  port(clk : in std_logic;
           rst : in std_logic;
		   kClk : in std_logic;
           kData : in std_logic;
		   hsync : out std_logic;
		   vsync : out std_logic;
		   vgaCLK : out std_logic;
		   blank : out std_logic;
		   sync : out std_logic;
		   red : out std_logic_vector(7 downto 0);
		   green : out std_logic_vector(7 downto 0);
		   blue : out std_logic_vector(7 downto 0) );
   end color_pixels;

----------------------------------------------------------------------------------------------------------------

architecture bhv of color_pixels is

----------------------------------------------------------------------------------------------------------------
-- Part 3
-- Components declaration
----------------------------------------------------------------------------------------------------------------

   component keyboard_controller
   port(clk : in std_logic;
        rst : in std_logic;
        kClk : in std_logic;
        kData : in std_logic;
        keyboard_data : out std_logic_vector(7 downto 0) );
   end component;

   component vga_controller
   port(clk : in std_logic;
		rst : in std_logic;
		keyboard_data : in std_logic_vector(7 downto 0);
		hsync : out std_logic;
		vsync : out std_logic;
		vgaCLK : out std_logic;
		red : out std_logic_vector(7 downto 0);
		green : out std_logic_vector(7 downto 0);
		blue : out std_logic_vector(7 downto 0) );
   end component;

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 4
-- Signals declaration
----------------------------------------------------------------------------------------------------------------

   signal sig_keyboard_data, sig_keyboard_data1, sig_keyboard_data2 : std_logic_vector(7 downto 0);
   signal sig_hsync, sig_vsync, sig_vgaCLK : std_logic;
   signal sig_red, sig_green, sig_blue : std_logic_vector(7 downto 0);
   signal key_press, key_release, enable : std_logic;
   
   type state_type is (s1,s2,s3,s4);
   signal state : state_type;

----------------------------------------------------------------------------------------------------------------

begin

----------------------------------------------------------------------------------------------------------------
-- Part 5
-- Components instantiation
----------------------------------------------------------------------------------------------------------------

   comp1: keyboard_controller port map( clk, rst, kClk, kData, sig_keyboard_data );
   comp2: vga_controller port map( clk, rst, sig_keyboard_data2, sig_hsync, sig_vsync, sig_vgaCLK, sig_red, sig_green, sig_blue);

----------------------------------------------------------------------------------------------------------------
-- Part 6
-- FSM declaration
----------------------------------------------------------------------------------------------------------------

	process(clk, rst)
	begin
		if rst='0' then
			state <= s1;
		elsif rising_edge(clk) then
			case state is
				when s1 =>  if sig_keyboard_data/=sig_keyboard_data1 then
								state <= s2;
							end if;
				when s2 =>  
					state <= s3;
				when s3 => 	if sig_keyboard_data="00000000" then
								state <= s4;
							end if;
				when s4 =>  if sig_keyboard_data=sig_keyboard_data1 then
								state <= s1;
							end if;
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when s1 => 
				enable <= '0';
			when s2 => 
				enable <= '1';
			when s3 =>
				enable <= '0';
			when s4 =>
				enable <= '0';
		end case;
	end process;

----------------------------------------------------------------------------------------------------------------
-- Part 7
-- Process keyboard scan codes
----------------------------------------------------------------------------------------------------------------
	
	 -- Store scan code value at 'S2' to detect key release at 'S4'
	process(clk, rst)
	begin
		if rst='0' then
			sig_keyboard_data1 <= (others => '0');
		elsif rising_edge(clk) then
			if enable='1' then
				sig_keyboard_data1 <= sig_keyboard_data;
			end if;
		end if;			
	end process;
	
	 -- Send scan code to vga_controller at 'S2'
	process(rst, sig_keyboard_data, enable)
	begin
		if rst='0' then
			sig_keyboard_data2 <= (others => '0');
		else
			if enable='1' then
				sig_keyboard_data2 <= sig_keyboard_data;
			else
				sig_keyboard_data2 <= (others => '0');
			end if;
		end if;
	end process;

----------------------------------------------------------------------------------------------------------------
	
	hsync <= sig_hsync;
	vsync <= sig_vsync;
	vgaCLK <= sig_vgaCLK;
	blank <= sig_vsync;
	sync <= sig_hsync;
	red <= sig_red;
	green <= sig_green;
	blue <= sig_blue;
	
end;
