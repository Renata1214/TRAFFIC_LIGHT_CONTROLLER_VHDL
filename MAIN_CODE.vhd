library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is PORT (
	in_clk : IN std_logic;
	in_sensor_main : IN std_logic;
	in_main_walk : IN std_logic;
	in_side_walk : IN std_logic;
	out_main_red : OUT std_logic;
	out_main_yellow : OUT std_logic;
	out_main_green : OUT std_logic;
	out_side_red : OUT std_logic;
	out_side_yellow : OUT std_logic;
	out_side_green : OUT std_logic;
	out_main_walk : INOUT std_logic;
	out_side_walk : INOUT std_logic
);
end FSM;

architecture Behavioral of FSM is

--** FSM states
TYPE state_type IS (
	normal, --3sec
	main_red, --10sec (8+2)
	main_green_1st, -- 8sec
	main_green_2nd, --2sec
	main_green_1st_extended, --5sec
	main_yellow, --2sec
	side_red, --10sec (8+2)+(5)
	side_green_1st, --8sec
	side_green_2nd, --2sec
	side_yellow --2sec
);
SIGNAL state, next_state : state_type := main_red;

--** constants, signals for clock dividers
constant sec_05 : integer := 25e6;
constant sec_1 : integer := 2 * sec_05;
constant sec_2 : integer := 2 * sec_1;
constant sec_3 : integer := 3 * sec_1;
constant sec_5 : integer := 5 * sec_1;
constant sec_8 : integer := 8 * sec_1;
signal clk_count_state : integer range 0 to sec_8;
signal clk_count_blink : integer range 0 to sec_05;

--** signals for registers
signal reg_main_walk, reg_side_walk, reg_blink : std_logic := '0';

--signals for normal state decision
signal choice : std_logic :=0;

begin

--** clock divider process for state transitions; sequential
PROCESS (in_clk)
BEGIN
	if (rising_edge(in_clk)) then

		CASE state IS

			-- states with 2 s period
			WHEN main_green_2nd | main_yellow | side_green_2nd | side_yellow =>
				if (clk_count_state = sec_2) then
					state <= next_state;
					clk_count_state <= 0;
				else
					clk_count_state <= clk_count_state + 1;
				end if;
			WHEN normal =>
				if (clk_count_state = sec_3) then
					state <= next_state;
					clk_count_state <= 0;
				else
					clk_count_state <= clk_count_state + 1;
				end if;
			WHEN main_green_1st_extended =>
				if (clk_count_state = sec_5) then
					state <= next_state;
					clk_count_state <= 0;
				else
					clk_count_state <= clk_count_state + 1;
				end if;
			WHEN side_green_1st|main_green_1st =>
				if (clk_count_state = sec_8) then
					state <= next_state;
					clk_count_state <= 0;
				else
					clk_count_state <= clk_count_state + 1;
				end if;

		END CASE;
	end if;
END PROCESS;

--** clock divider process for blinking operation; sequential
-- BONUS revise this process (and possibly other parts) such that the blinking starts properly, with light off and counter at 0, right after relevant state transitions
PROCESS (in_clk)
BEGIN
	if (rising_edge(in_clk)) then
		if (clk_count_blink = sec_05) then
			reg_blink <= not reg_blink;
			clk_count_blink <= 0;
		else
			clk_count_blink <= clk_count_blink + 1;
		end if;
	end if;
END PROCESS;

--** register; reg_side_walk
-- BONUS revise such that any further request that comes in just after the cycle has finished is not ignored
PROCESS (in_clk)
BEGIN

	if (rising_edge(in_clk)) then

		-- cycle of the respective side has finished, reset the request
		if (state = side_red) then
			reg_side_walk <= '0';
		-- for all other states, set the register in case the button is pushed
		elsif (in_side_walk = '1') then
			reg_side_walk <= '1';
		-- note: no final else, to hold request once set (and until reset)
		end if;
	end if;

END PROCESS;

--** register; reg_main_walk
-- BONUS revise such that any further request that comes in just after the cycle has finished is not ignored
PROCESS (in_clk)
BEGIN

	if (rising_edge(in_clk)) then

		-- cycle of the respective side is finished, reset the request
		if (state = main_red) then
			reg_main_walk <= '0';
		-- for all other scenarios, set the register in case the button is pushed
		elsif (in_main_walk = '1') then
			reg_main_walk <= '1';
		-- note: no final else, to hold request once set (and until reset)
		end if;
	end if;

END PROCESS;

--** next state; sequential
PROCESS (state, in_sensor_main, reg_main_walk, reg_side_walk, reg_blink, choice)
BEGIN

CASE state IS

	-- TODO fill in the missing cases

	WHEN normal =>

		reg_blink <= '0';

		if (in_side_walk = 1) then 
			reg_side_walk <= '1';
		end if;

		if (in_main_walk = 1 ) then 
			reg_main_walk <= '1';
		end if;
		
		if (choice = '0')then
			next_state <= main_green_1st;
		else
			next_state <= main_side_1st;
		end if;

 -- MAIN CASES

	WHEN main_green_1st =>
		if (in_side_walk = 1) then 
			reg_side_walk <= '1';
			reg_blink <= '1';
		end if;
		if (in_main_walk= 1) then 
			reg_main_walk <= '1';
		end if;
		
		if (in_sensor_main = 1) then
			next_state <= main_green_1st_extended;
		else
			next_state <= main_green_2nd;
		end if;

	WHEN main_green_1st_extended => 
		if (in_side_walk = 1) then 
			reg_side_walk <= '1';
			reg_blink <= '1';
		end if;
		if (in_main_walk= 1) then 
			reg_main_walk <= '1';
		end if;
		next_state <= main_green_2nd;

	WHEN main_green_2nd => 
		
		if (in_side_walk = 1) then 
			reg_side_walk <= '1';
		end if;

		if (out_side_walk = 1){
			reg_side_walk <= '0';
		}

		if (in_main_walk= 1) then 
			reg_main_walk <= '1';   
		end if;

		next_state <= main_yellow;
	
	WHEN main_yellow =>
		if (in_side_walk = 1) then 
			reg_side_walk <= '1';			
		end if;

		if (in_main_walk= 1) then 
			reg_main_walk <= '1';
		end if;

		next_state <= normal;

-- Side Cases

	WHEN side_green_1st =>
		if (in_side_walk = 1) then 
			reg_side_walk <= '1';
		end if;
		if (in_main_walk= 1) then 
			reg_main_walk <= '1';
			reg_blink <= '1';
		end if;

		next_state <= side_green_2nd;

	WHEN side_green_2nd => 
		if (in_side_walk = 1) then 
			reg_side_walk <= '1';
		end if;

		if (out_main_walk = 1){
			reg_main_walk <= '0';
		}

		if (in_main_walk= 1) then 
			reg_main_walk <= '1';   
		end if;

		next_state <= side_yellow;

	WHEN side_yellow =>
		if (in_side_walk = 1) then 
			reg_side_walk <= '1';
		end if;

		if (in_main_walk= 1) then 
			reg_main_walk <= '1';   
		end if;

		next_state <= normal;

END CASE;

END PROCESS;

--** outputs; combinational
PROCESS (state, reg_side_walk, reg_main_walk, reg_blink)
BEGIN

-- default assignments
out_main_red <= '0';
out_main_yellow <= '0';
out_main_green <= '0';
out_side_red <= '0';
out_side_yellow <= '0';
out_side_green <= '0';
out_main_walk <= '0';
out_side_walk <= '0';
	-----------------------
	normal, --3sec
	main_red, --10sec (8+2)
	main_green_1st, -- 8sec
	main_green_2nd, --2sec
	main_green_1st_extended, --5sec
	main_yellow, --2sec
	side_red, --10sec (8+2)+(5)
	side_green_1st, --8sec
	side_green_2nd, --2sec
	side_yellow --2sec
	------------------
CASE state IS
	WHEN normal =>
		out_main_red <= '1';
		out_main_yellow <= '0';
		out_main_green <= '0';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';
	WHEN main_green_1st =>
		out_main_red <= '0';
		out_main_yellow <= '0';
		out_main_green <= '1';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';
		if 
	WHEN main_green_2nd =>
		out_main_red <= '0';
		out_main_yellow <= '0';
		out_main_green <= '1';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';\
		if (reg_blink = 1)then 
		out_side_walk <= '1';
		else
		out_side_walk <= '0';
		end if;
		
	WHEN main_green_1st_extended =>
		out_main_red <= '1';
		out_main_yellow <= '0';
		out_main_green <= '0';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';
	WHEN main_yellow =>
		out_main_red <= '1';
		out_main_yellow <= '0';
		out_main_green <= '0';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';
	WHEN side_green_1st =>
		out_main_red <= '1';
		out_main_yellow <= '0';
		out_main_green <= '0';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';
	WHEN side_green_2nd =>
		out_main_red <= '1';
		out_main_yellow <= '0';
		out_main_green <= '0';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';
	WHEN side_yellow =>
		out_main_red <= '1';
		out_main_yellow <= '0';
		out_main_green <= '0';
		out_side_red <= '1';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';



END CASE;

END PROCESS;

end Behavioral;
