library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control is
port (
	Instruction	: in std_logic_vector(5 downto 0);
	Dest_reg	: out std_logic ;
	ALU			: out std_logic ;
	Dest_memo	: out std_logic ;
	Reg_wr		: out std_logic ;
	Mem_rd		: out std_logic ;
	Mem_wr      : out std_logic ;
	cond_jump	: out std_logic ;
	jump		: out std_logic ;
	ALU_op1		: out std_logic ;
	ALU_op0		: out std_logic 
);
end control ;

architecture control_arq of control is

begin
		ALU <= '0' when (Instruction="000000" or Instruction="000100"
		or Instruction="000010") else '1'; --FuenteALU
		
		Dest_reg <= '1' when (Instruction="000000") else '0' ; --RegDest
		
		Dest_memo <= '0' when (Instruction="000000" or Instruction="001111") else '1' ; --MemaReg
		
		Reg_wr <= '1' when (Instruction="000000" or Instruction="100011" or Instruction="001111") else '0' ; --EscrReg
		
		Mem_rd <= '1' when (Instruction="100011") else '0' ; --LeerMem
		
		Mem_wr <= '1' when (Instruction="101011") else '0' ; --EscrMem
		
		cond_jump <= '1' when (Instruction="000100") else '0' ;
		
		jump <= '1' when (Instruction="000010") else '0' ;
		
		ALU_op1 <= '1' when (Instruction="000000" or Instruction="001111") else '0' ;
		
		ALU_op0 <= '1' when (Instruction="000100" or Instruction="001111") else '0' ;
end control_arq;

