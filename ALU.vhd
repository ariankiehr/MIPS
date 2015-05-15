library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port ( a : in  STD_LOGIC_VECTOR (31 downto 0);
           b : in  STD_LOGIC_VECTOR (31 downto 0);
           control : in  STD_LOGIC_VECTOR (2 downto 0);
           zero : out  STD_LOGIC;
           result : out  STD_LOGIC_VECTOR (31 downto 0));
end ALU;

architecture Behavioral of ALU is
signal result_int : STD_LOGIC_VECTOR (31 downto 0);
begin

process (control, a, b) --Result
begin
	case control is
		when "000" => result_int <=(a AND b) ;
		when "001" => result_int <= a OR b ;
		when "010" => result_int <= a + b ;
		when "110" => result_int <= a - b ;
		when "111" => 	if a < b then
								result_int <= x"00000001" ; 
							else
								result_int <= x"00000000" ;
							end if;
		when "100" => result_int <= b(15 downto 0) & x"0000" ;
		when others => result_int <= x"00000000";
	end case;
end process;

result <= result_int;	

process (result_int) --Zero
 
begin
	if result_int = x"00000000" then
		zero <= '1' ;
	else
		zero <= '0' ;
	end if;
	
end process;
end Behavioral;
