library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BANCO_DE_REGISTROS is
    Port ( wr : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reg1_rd : in  STD_LOGIC_VECTOR (4 downto 0);
           reg2_rd : in  STD_LOGIC_VECTOR (4 downto 0);
           reg_wr : in  STD_LOGIC_VECTOR (4 downto 0);
           data_wr : in  STD_LOGIC_VECTOR (31 downto 0);
           data1_rd : out  STD_LOGIC_VECTOR (31 downto 0);
           data2_rd : out  STD_LOGIC_VECTOR (31 downto 0));
end BANCO_DE_REGISTROS;

architecture Behavioral of BANCO_DE_REGISTROS is
	type MEM_T is array (0 to 31) of std_logic_vector (31 downto 0); --Declaro un Tipo
	signal regs: MEM_T; --Declaro una señal del tipo "MEM_T" declarada arriba.
begin
	--Cada Proceso "fabrica" UNA señal. A cada señal la fabrica UN proceso. 
	process (reg1_rd,clk) --Lectura 1
	begin
		if reg1_rd = "00000" then
			data1_rd <= x"00000000";
		elsif (falling_edge(clk)) then
			data1_rd <= regs (CONV_INTEGER(reg1_rd));
		end if;
	end process;
	
	process (reg2_rd,clk) --Lectura 2
	begin
		if reg2_rd = "00000" then
			data2_rd <= x"00000000";
		elsif falling_edge(clk) then
			data2_rd <= regs (CONV_INTEGER(reg2_rd));
		end if;
	end process;
	
	process (reset,wr,data_wr,clk) --Escritura
	begin
		--Tengo que mirar el reset.
		if (reset = '1') then
			for i in 0 to 31 loop
				regs(i) <= x"00000000";
			end loop;
		elsif  (wr = '1') then
			regs (CONV_INTEGER(reg_wr)) <= data_wr;
		end if;
	end process;
end Behavioral;
