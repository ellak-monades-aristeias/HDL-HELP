library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tictactoe is
	port(clk : in std_logic;
		  rst : in std_logic;
		  kClk : in std_logic;
		  kData : in std_logic;
		  hsync : out std_logic;
		  vsync : out std_logic;
		  --vgaCLK : out std_logic;
		  --blank : out std_logic;
		  --sync : out std_logic;
		  red : out std_logic_vector(7 downto 0);
		  green : out std_logic_vector(7 downto 0);
		  blue : out std_logic_vector(7 downto 0);
		  scoreX : out std_logic_vector(6 downto 0);
		  scoreO : out std_logic_vector(6 downto 0));
end tictactoe;

architecture bhv of tictactoe is

   component keyboard_controller
   port(clk : in std_logic;
        rst : in std_logic;
        kClk : in std_logic;
        kData : in std_logic;
        keyboard_data : out std_logic_vector(7 downto 0));
   end component;

   component vga_controller
   port(clk : in std_logic;
		  rst : in std_logic;
		  board_status : in std_logic_vector(17 downto 0);
		  hsync : out std_logic;
		  vsync : out std_logic;
		  vgaCLK : out std_logic;
		  red : out std_logic_vector(7 downto 0);
		  green : out std_logic_vector(7 downto 0);
		  blue : out std_logic_vector(7 downto 0));
   end component;
	
   component MoveGen
   port(clk : in std_logic;
		  rst : in std_logic;
		  keyboard_data : in std_logic_vector(7 downto 0);
		  scoreX : out std_logic_vector(6 downto 0);
		  scoreO : out std_logic_vector(6 downto 0);
        board_status : out std_logic_vector(17 downto 0));
   end component;
   
   signal sig_scoreX, sig_scoreO : std_logic_vector(6 downto 0);
   signal sig_keyboard_data: std_logic_vector(7 downto 0);
   signal sig_board_status: std_logic_vector(17 downto 0);
   signal sig_hsync, sig_vsync, sig_vgaCLK : std_logic;
   signal sig_red, sig_green, sig_blue : std_logic_vector(7 downto 0);

begin

comp1: keyboard_controller port map( clk, rst, kClk, kData, sig_keyboard_data );
comp2: vga_controller port map( clk, rst, sig_board_status, sig_hsync, sig_vsync, sig_vgaCLK, sig_red, sig_green, sig_blue);
comp3: MoveGen port map( clk, rst, sig_keyboard_data, sig_scoreX, sig_scoreO, sig_board_status);
	
	hsync <= sig_hsync;
	vsync <= sig_vsync;
	--vgaCLK <= sig_vgaCLK;
	--blank <= sig_vsync;
	--sync <= sig_hsync;
	red <= sig_red;
	green <= sig_green;
	blue <= sig_blue;
	scoreX <= sig_scoreX;
	scoreO <= sig_scoreO;

end;
