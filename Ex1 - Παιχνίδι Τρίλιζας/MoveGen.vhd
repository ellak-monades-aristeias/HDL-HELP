
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

   entity MoveGen is
      port(clk : in std_logic;
           rst : in std_logic;
           keyboard_data : in std_logic_vector(7 downto 0);
           scoreX : out std_logic_vector(6 downto 0);
           scoreO : out std_logic_vector(6 downto 0);
           board_status : out std_logic_vector(17 downto 0) );
   end MoveGen;

----------------------------------------------------------------------------------------------------------------

architecture bhv of MoveGen is

----------------------------------------------------------------------------------------------------------------
-- Part 3
-- Signals declaration
----------------------------------------------------------------------------------------------------------------

   signal newRound, checkBoard, winner : std_logic;
   signal sig_board_status : std_logic_vector(17 downto 0);
   signal status_changed : std_logic;
   signal newX : std_logic;
   signal newO : std_logic;
   signal sig_winX, sig_winO : std_logic_vector(3 downto 0);
   signal winX, winO : std_logic_vector(6 downto 0);

   type state_type is (playX,playO,none);
   signal current_state,next_state : state_type;

----------------------------------------------------------------------------------------------------------------

begin 

----------------------------------------------------------------------------------------------------------------
-- Part 4
-- Define the FSM
----------------------------------------------------------------------------------------------------------------

   process(clk, rst, newRound)
   begin
      if rst='0' then
         current_state <= playX;
      elsif rising_edge(clk) then
         current_state <= next_state;
      end if;
   end process;
   
   process(status_changed, current_state, winner, newRound)
   begin
      next_state <= current_state;
      case current_state is
         when playX => if winner='1' then
                          next_state <= none;
                       elsif status_changed='1' then
                          next_state <= playO;
                       end if;
         when playO => if winner='1' then
                          next_state <= none;
                       elsif status_changed='1' then
                          next_state <= playX;
                       end if;
         when none => if newRound = '1' then
                         next_state <= playX;
                      end if;
      end case;
   end process;

	-- FSM control signals
   process(current_state)
   begin
      case current_state is
         when playX => newX <= '1';
                       newO <= '0';
                       checkBoard <= '0';
         when playO => newO <= '1';
                       newX <= '0';  
                       checkBoard <= '0';
         when none => newO <= '0';
                      newX <= '0'; 
                      checkBoard <= '1';
      end case;
   end process;
 
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- Part 5
-- Update board status according to key pressure
----------------------------------------------------------------------------------------------------------------

   process(clk, rst)
   begin
      if rst='0' then
         sig_board_status <= (others => '0');
         status_changed <= '0';
         newRound <= '0';
      elsif rising_edge(clk) then
         case keyboard_data is 
             -- Q button
            when "00010101" => if sig_board_status(1 downto 0)="00" then
                                  if newX='1' then
                                     sig_board_status(1 downto 0) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(1 downto 0) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else 
                                   status_changed <= '0';
                               end if;
             -- W button
            when "00011101" => if sig_board_status(3 downto 2)="00" then
                                  if newX='1' then
                                     sig_board_status(3 downto 2) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(3 downto 2) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '0';
                               end if;
             -- E button
            when "00100100" => if sig_board_status(5 downto 4)="00" then
                                  if newX='1' then
                                     sig_board_status(5 downto 4) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(5 downto 4) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '0';
                               end if;
             -- A button
            when "00011100" => if sig_board_status(7 downto 6)="00" then
                                  if newX='1' then
                                     sig_board_status(7 downto 6) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(7 downto 6) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '1';
                               end if;
             -- S button
            when "00011011" => if sig_board_status(9 downto 8)="00" then
                                  if newX='1' then
                                     sig_board_status(9 downto 8) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(9 downto 8) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '0';
                               end if;
             -- D button
            when "00100011" => if sig_board_status(11 downto 10)="00" then
                                  if newX='1' then
                                     sig_board_status(11 downto 10) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(11 downto 10) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '0';
                               end if;
             -- Z button
            when "00011010" => if sig_board_status(13 downto 12)="00" then
                                  if newX='1' then
                                     sig_board_status(13 downto 12) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(13 downto 12) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '0';
                               end if;
             -- X button
            when "00100010" => if sig_board_status(15 downto 14)="00" then
                                  if newX='1' then
                                     sig_board_status(15 downto 14) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(15 downto 14) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '0';
                               end if;
             -- C button
            when "00100001" => if sig_board_status(17 downto 16)="00" then
                                  if newX='1' then
                                     sig_board_status(17 downto 16) <= "01";
                                     status_changed <= '1';
                                  elsif newO='1' then
                                     sig_board_status(17 downto 16) <= "10";
                                     status_changed <= '1';
                                  end if;
                               else
                                  status_changed <= '0';
                               end if;
             -- N button
            when "00110001" => newRound <= '1';
                               status_changed <= '0';
                               sig_board_status <= (others => '0');
             -- Every other button
			when others => status_changed <= '0';
                           newRound <= '0';
         end case;
      end if;
   end process;

----------------------------------------------------------------------------------------------------------------
   
----------------------------------------------------------------------------------------------------------------
-- Part 6
-- Check board status for possible winner
----------------------------------------------------------------------------------------------------------------

	-- Every possible way to complete 3 symbols in a row
   process(clk, rst)
   begin
      if rst='0' then
         sig_winX <= (others => '0');
         sig_winO <= (others => '0');
         winner <= '0';
      elsif rising_edge(clk) then
         -- Don't allow score update during 'none' state
         if checkBoard='0' then
            if ( (sig_board_status(5 downto 0)="010101" ) or ( sig_board_status(11 downto 6)="010101" ) or ( sig_board_status(11 downto 6)="010101" ) ) then
               winner <= '1';
               sig_winX <= sig_winX + 1;
            elsif ( ( sig_board_status(5 downto 0)="101010" ) or ( sig_board_status(11 downto 6)="101010" ) or ( sig_board_status(11 downto 6)="101010" ) )then
               sig_winO <= sig_winO + 1;
               winner <= '1';
            elsif ( ( sig_board_status(1 downto 0)&sig_board_status(7 downto 6)&sig_board_status(13 downto 12)="010101" ) or
                    ( sig_board_status(3 downto 2)&sig_board_status(9 downto 8)&sig_board_status(15 downto 14)="010101" ) or
                    ( sig_board_status(5 downto 4)&sig_board_status(11 downto 10)&sig_board_status(17 downto 16)="010101" ) ) then
               sig_winX <= sig_winX + 1;
               winner <= '1';
            elsif ( ( sig_board_status(1 downto 0)&sig_board_status(7 downto 6)&sig_board_status(13 downto 12)="101010" ) or
                    ( sig_board_status(3 downto 2)&sig_board_status(9 downto 8)&sig_board_status(15 downto 14)="101010" ) or
                    ( sig_board_status(5 downto 4)&sig_board_status(11 downto 10)&sig_board_status(17 downto 16)="101010" ) ) then
               sig_winO <= sig_winO + 1;
               winner <= '1';
            elsif ( ( sig_board_status(1 downto 0)&sig_board_status(9 downto 8)&sig_board_status(17 downto 16)="010101" ) or
                    ( sig_board_status(5 downto 4)&sig_board_status(9 downto 8)&sig_board_status(13 downto 12)="010101" ) ) then
               sig_winX <= sig_winX + 1;
               winner <= '1';
            elsif ( ( sig_board_status(1 downto 0)&sig_board_status(9 downto 8)&sig_board_status(17 downto 16)="101010" ) or
                    ( sig_board_status(5 downto 4)&sig_board_status(9 downto 8)&sig_board_status(13 downto 12)="101010" ) ) then
               sig_winO <= sig_winO + 1;
               winner <= '1';
            end if;
         else
            winner <= '0';
         end if;
      end if;
   end process;
 
----------------------------------------------------------------------------------------------------------------
   
----------------------------------------------------------------------------------------------------------------
-- Part 7
-- Shift register to collect keyboard data
----------------------------------------------------------------------------------------------------------------

   process(sig_winX)
   begin
      case sig_winX is
         when "0000" => winX <= "1000000"; 
         when "0001" => winX <= "1111001";
         when "0010" => winX <= "0100100";
         when "0011" => winX <= "0110000";
         when "0100" => winX <= "0011001";
         when "0101" => winX <= "0010010";
         when "0110" => winX <= "0000010";
         when "0111" => winX <= "1111000";
         when "1000" => winX <= "0000000";
         when "1001" => winX <= "0010000";
         when others => winX <= "1111111";
      end case;
   end process;
 
   process(sig_winO)
   begin 
      case sig_winO is
         when "0000" => winO <= "1000000"; 
         when "0001" => winO <= "1111001";
         when "0010" => winO <= "0100100";
         when "0011" => winO <= "0110000";
         when "0100" => winO <= "0011001";
         when "0101" => winO <= "0010010";
         when "0110" => winO <= "0000010";
         when "0111" => winO <= "1111000";
         when "1000" => winO <= "0000000";
         when "1001" => winO <= "0010000";
         when others => winO <= "1111111";
      end case;
   end process;

----------------------------------------------------------------------------------------------------------------

   board_status <= sig_board_status;
   scoreX <= winX;
   scoreO <= winO;
 
end;