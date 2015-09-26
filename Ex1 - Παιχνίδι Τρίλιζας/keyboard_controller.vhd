
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

entity keyboard_controller is
   port( clk : in std_logic;
         rst : in std_logic;
         kClk : in std_logic;
         kData : in std_logic;
         keyboard_data : out std_logic_vector(7 downto 0)
       );
end keyboard_controller;

----------------------------------------------------------------------------------------------------------------

architecture bhv of keyboard_controller is

----------------------------------------------------------------------------------------------------------------
-- Part 3
-- Signals declaration
----------------------------------------------------------------------------------------------------------------

   signal kClk_Delay1 : std_logic;
   signal kClk_Delay2 : std_logic;
   signal kData_Delay1 : std_logic;
   signal kData_Delay2 : std_logic;   
   signal counter : std_logic_vector(3 downto 0);
   signal button : std_logic_vector(8 downto 0);
   signal Fclk : std_logic;
   signal enable : std_logic;
   signal full : std_logic;
   
   type state_type is (start,data,ready);
   signal current_state,next_state : state_type;

----------------------------------------------------------------------------------------------------------------

begin

----------------------------------------------------------------------------------------------------------------
-- Part 4
-- Synchronize parts with different clock frequency
----------------------------------------------------------------------------------------------------------------
	
	-- Shift registers to synchronize keyboard data and clock
   process(clk,rst)
   begin
      if rst='0' then
         kClk_Delay1 <= '1';
         kClk_Delay2 <= '1';
      elsif rising_edge(clk) then
         kClk_Delay1 <= kClk;
         kClk_Delay2 <= kClk_Delay1;
         kData_Delay1 <= kData;
         kData_Delay2 <= kData_Delay1;
      end if;
   end process; 

   -- Comparison of registers' outputs to detect transition to '0' 
	Fclk <= kClk_Delay2 and (not kClk_Delay1);
   
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 5
-- Define the FSM
----------------------------------------------------------------------------------------------------------------

   process(clk,rst)
   begin
      if rst='0' then
         current_state <= start;
      elsif rising_edge(clk) then
         current_state <= next_state;
      end if;
   end process;

    -- FSM states sequence
   process(Fclk,counter,current_state)
   begin
      next_state <= current_state;
      case current_state is
         when start => if Fclk='1' then
                          next_state <= data;
                       end if;
         when data => if Fclk='1' then
                         if counter=8 then
                            next_state <= ready;
                         end if;
                      end if;
         when ready => if Fclk='1' then
                          next_state <= start;
                       end if;
      end case;
   end process;


   process(current_state)
   begin
      case current_state is
         when start => enable <= '0';
                       full <= '0';
         when data => enable <= '1';
                      full <= '0';  
         when ready => enable <= '0';
                       full <= '1';
      end case;
   end process;

----------------------------------------------------------------------------------------------------------------
   
----------------------------------------------------------------------------------------------------------------
-- Part 6
-- Shift register to collect keyboard data
----------------------------------------------------------------------------------------------------------------

	-- Shift data to button
   process(clk,rst)
   begin
      if rst='0' then
         counter <= (others => '0');
         button <= (others => '0');
      elsif rising_edge(clk) then
         if Fclk='1' then
            if enable='1' then 
               button(8) <= kData_Delay2;
               button(7 downto 0) <= button(8 downto 1);
               counter <= counter + 1;
            elsif full='1' then
               counter <= (others => '0');
			   end if;
         end if;
      end if;
   end process;
   
    -- When scan code is acquired sent data to keyboard controller output
   process(clk,rst)
   begin
      if rst='0' then
         keyboard_data <= (others => '0');
      elsif rising_edge(clk) then
         if full='1' then
            keyboard_data <= button(7 downto 0); 
		 else
		    keyboard_data <= (others => '0');
         end if;
      end if;
   end process;
   
----------------------------------------------------------------------------------------------------------------
	
end;