library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 

signal pc, 
		 mux_out, 
		 mux_jump_out,
		 add_out, 
		 cond_jump ,
		 Jump_addr ,
		 IFID_PC_plus_4, 
		 IFID_data_in : std_logic_vector(31 downto 0);

--signals etapa 2


signal IDEX_Ctrl_Dest_reg, 
		 IDEX_Ctrl_ALU, 
		 IDEX_Ctrl_dest_memo,
		 IDEX_Ctrl_reg_wr,
		 IDEX_Ctrl_mem_rd,
		 IDEX_Ctrl_mem_wr,
		 IDEX_Ctrl_cond_jump,
		 IDEX_Ctrl_jump,		 
		 IDEX_Ctrl_alu_op1,
		 IDEX_Ctrl_alu_op0 : std_logic ;

signal Instruction_control: std_logic_vector(5 downto 0);
		 
signal read_register_1 ,
		 read_register_2 , 
		 lw_wr, 
		 op_wr, 
		 IDEX_lw_wr, 
		 IDEX_op_wr: std_logic_vector(4 downto 0) ;

signal ext_sig : std_logic_vector (15 downto 0);

signal IDEX_PC_plus_4, 
		 IDEX_ext_sig,
		 IDEX_data1,
		 IDEX_data2, 
		 IDEX_data1_in , 
		 IDEX_data2_in,
		 IDEX_ext_sig_in: std_logic_vector (31 downto 0);
		 
signal jump_inst_in,
		 IDEX_jump_inst: std_logic_vector (27 downto 0);

signal IDEX_Ctrl_Dest_reg_in,
		 IDEX_Ctrl_ALU_in,
		 IDEX_Ctrl_dest_memo_in,
		 IDEX_Ctrl_reg_wr_in,
		 IDEX_Ctrl_mem_rd_in,
		 IDEX_Ctrl_mem_wr_in,
		 IDEX_Ctrl_cond_jump_in,
		 IDEX_Ctrl_jump_in,
		 IDEX_Ctrl_alu_op1_in,
		 IDEX_Ctrl_alu_op0_in : std_logic ;

--Signal 3ra etapa
signal EX_mux1 ,
		 EXMEM_ALU_result ,
		 EXMEM_cond_jump ,
		 EXMEM_data2 ,
		 EXMEM_ALU_result_in ,
		 EXMEM_cond_jump_in : std_logic_vector (31 downto 0);

signal EX_Control_ALU_op : std_logic_vector (1 downto 0); 

signal EX_Ctrl_ALU : std_logic_vector(2 downto 0) ;

signal EXMEM_mux2, 
		 EXMEM_mux2_in : std_logic_vector(4 downto 0) ;

signal Ins_in : std_logic_vector(5 downto 0);

signal EXMEM_Ctrl_mem_rd ,     
		 EXMEM_Ctrl_mem_wr ,
		 EXMEM_Ctrl_dest_memo ,
		 EXMEM_Ctrl_reg_wr ,
		 EXMEM_Ctrl_cond_jump ,
		 EXMEM_Ctrl_ALU_zero,
		 EXMEM_Ctrl_ALU_zero_in : std_logic ;

--signals 4ta etapa
signal Ctrl_PCSrc ,
		 MEMWB_Ctrl_dest_memo ,
		 MEMWB_Ctrl_reg_wr : std_logic;

signal MEMWB_mux2 :std_logic_vector (4 downto 0) ;

signal MEMWB_Data ,
		 MEMWB_Data_in ,
		 MEMWB_ALU_result : std_logic_vector (31 downto 0);

		
--signals 5ta etapa
signal Ctrl_reg_write : std_logic ;
signal Reg_Write_mux_out_5 : std_logic_vector (31 downto 0);  

--ENTIDADES
	--Banco de registros
	COMPONENT BANCO_DE_REGISTROS
	PORT(
		wr : IN std_logic;
		reset : IN std_logic;
		clk : IN std_logic;
		reg1_rd : IN std_logic_vector(4 downto 0);
		reg2_rd : IN std_logic_vector(4 downto 0);
		reg_wr : IN std_logic_vector(4 downto 0);
		data_wr : IN std_logic_vector(31 downto 0);          
		data1_rd : OUT std_logic_vector(31 downto 0);
		data2_rd : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	--UC
		COMPONENT control
	PORT(
		Instruction : IN std_logic_vector(5 downto 0);          
		Dest_reg : OUT std_logic;
		ALU : OUT std_logic;
		Dest_memo : OUT std_logic;
		Reg_wr : OUT std_logic;
		Mem_rd : OUT std_logic;
		Mem_wr : OUT std_logic;
		cond_jump : OUT std_logic;
		jump		: OUT std_logic;
		ALU_op1 : OUT std_logic;
		ALU_op0 : OUT std_logic
		);
	END COMPONENT;

	--ALU
	COMPONENT ALU
	PORT(
		a : IN std_logic_vector(31 downto 0);
		b : IN std_logic_vector(31 downto 0);
		control : IN std_logic_vector(2 downto 0);          
		zero : OUT std_logic;
		result : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;


begin 	
------------------------------------------------------
	               --Etapa 1
------------------------------------------------------	

	mux_out <= add_out when Ctrl_PCSrc = '0' else cond_jump; --mux_in_1 es jump 
	mux_jump_out <= mux_out when IDEX_Ctrl_jump = '0' else Jump_addr;
	add_out <= pc + x"00000004"; --sumador
	
	--pc
	process (Clk, Reset)
	begin
		if Reset = '1' then
			pc <=x"00000000";
		elsif rising_edge(Clk) then
			pc <= mux_jump_out;
		end if;
	end process;
	
	--salida a memoria de instrucciones
	I_Addr <= pc ;
	I_RdStb <= '1' ;
	I_WrStb <= '0' ;

	
	--registro IF/ID
	process (Clk, Reset)
	begin
		if Reset = '1' then
			IFID_PC_plus_4 <= x"00000000";
			IFID_data_in <= x"00000000";
		elsif rising_edge (Clk) then
			IFID_PC_plus_4 <= add_out;
			IFID_data_in <= I_DataIn; --entrada desde memoria de instrucciones 
		end if;
	end process;
	--FIN ETAPA 1 
	
------------------------------------------------------
	               --Etapa 2
------------------------------------------------------
	--signals
	Instruction_control <= IFID_data_in (31 downto 26);
	read_register_1 <= IFID_data_in (25 downto 21);
	read_register_2 <= IFID_data_in (20 downto 16);
	ext_sig <= IFID_data_in (15 downto 0);
	lw_wr <= IFID_data_in (20 downto 16);
	op_wr <= IFID_data_in (15 downto 11);
	jump_inst_in(27 downto 2) <= IFID_data_in (25 downto 0);
	jump_inst_in(1 downto 0) <= "00";
	
	--Banco de registros
	Inst_BANCO_DE_REGISTROS: BANCO_DE_REGISTROS PORT MAP(
		wr => MEMWB_Ctrl_reg_wr,
		reset => Reset,
		clk => Clk,
		reg1_rd => read_register_1,
		reg2_rd => read_register_2,
		reg_wr => MEMWB_mux2 ,
		data_wr => Reg_Write_mux_out_5 ,
		data1_rd => IDEX_data1_in,
		data2_rd => IDEX_data2_in
	);
	
	
	--UC

	Inst_control: control PORT MAP(
		Instruction => Instruction_control,
		Dest_reg => IDEX_Ctrl_Dest_reg_in,
		ALU => IDEX_Ctrl_ALU_in,
		Dest_memo => IDEX_Ctrl_dest_memo_in,
		Reg_wr => IDEX_Ctrl_reg_wr_in,
		Mem_rd => IDEX_Ctrl_mem_rd_in,
		Mem_wr => IDEX_Ctrl_mem_wr_in,
		cond_jump => IDEX_Ctrl_cond_jump_in,
		jump => IDEX_Ctrl_jump_in,
		ALU_op1 => IDEX_Ctrl_alu_op1_in,
		ALU_op0 => IDEX_Ctrl_alu_op0_in
	);
	
	IDEX_ext_sig_in (31 downto 16) <= x"0000" when (ext_sig(15)='0') else x"FFFF" ;
	IDEX_ext_sig_in (15 downto 0) <= ext_sig ;
	
	--inicializar con 0's
	--definir las senales in
	process (Clk,Reset) begin
		if Reset = '1' then
			IDEX_Ctrl_Dest_reg <= '0' ; 
			IDEX_Ctrl_ALU <= '0' ; 
			IDEX_Ctrl_dest_memo <= '0' ; 
			IDEX_Ctrl_reg_wr <= '0' ; 
			IDEX_Ctrl_mem_rd <= '0' ; 
			IDEX_Ctrl_mem_wr <= '0' ; 
			IDEX_Ctrl_cond_jump <='0' ; 
			IDEX_Ctrl_jump <= '0';
			IDEX_Ctrl_alu_op1 <= '0' ; 
			IDEX_Ctrl_alu_op0 <= '0' ; 
			IDEX_ext_sig <= x"00000000" ; 
			IDEX_PC_plus_4 <= x"00000000" ; 
			IDEX_jump_inst <= x"0000000" ;
			IDEX_lw_wr <= "00000" ; 
			IDEX_op_wr <= "00000" ; 
		elsif rising_edge(Clk) then
			IDEX_Ctrl_Dest_reg <= IDEX_Ctrl_Dest_reg_in;  
			IDEX_Ctrl_ALU <= IDEX_Ctrl_ALU_in;  
			IDEX_Ctrl_dest_memo <= IDEX_Ctrl_dest_memo_in;
			IDEX_Ctrl_reg_wr <= IDEX_Ctrl_reg_wr_in;
			IDEX_Ctrl_mem_rd <= IDEX_Ctrl_mem_rd_in;
			IDEX_Ctrl_mem_wr <= IDEX_Ctrl_mem_wr_in;
			IDEX_Ctrl_cond_jump <= IDEX_Ctrl_cond_jump_in;
			IDEX_Ctrl_jump <= IDEX_Ctrl_jump_in; --jump
			IDEX_jump_inst <= jump_inst_in ; --pc de jump
			IDEX_Ctrl_alu_op1 <= IDEX_Ctrl_alu_op1_in;
			IDEX_Ctrl_alu_op0 <= IDEX_Ctrl_alu_op0_in;
			IDEX_ext_sig <= IDEX_ext_sig_in;   --signo extendido
			IDEX_PC_plus_4 <= IFID_PC_plus_4 ;  --PC +4
			IDEX_lw_wr <= lw_wr ; 	--(20 downto 16)  Instruccion
			IDEX_op_wr <= op_wr ;  --(15 downto 11)  Instruccion
			IDEX_data1 <= IDEX_data1_in;  --Salida registros 1
			IDEX_data2 <= IDEX_data2_in;  -- Salida registros 2
		end if;
	end process;
	--FIN ETAPA  2
	
	
------------------------------------------------------
	               --Etapa 3
------------------------------------------------------
	
	EXMEM_cond_jump_in <= IDEX_PC_plus_4 + (IDEX_ext_sig (29 downto 0) & "00");  --Salto condicional
	EX_mux1 <= IDEX_ext_sig when IDEX_Ctrl_ALU = '1' else IDEX_data2 ; --MUX 1
	EXMEM_mux2_in <= IDEX_op_wr when IDEX_Ctrl_Dest_reg='1' else IDEX_lw_wr ;
	
	EX_Control_ALU_op <= IDEX_Ctrl_alu_op1 & IDEX_Ctrl_alu_op0;
	Ins_in <= IDEX_ext_sig (5 downto 0);
	
	Jump_addr <= IDEX_PC_plus_4(31 downto 28) & IDEX_jump_inst ;
 
	EX_Ctrl_ALU <= "010" when EX_Control_ALU_op = "00" else
					   "110" when EX_Control_ALU_op = "01" else
					   "100" when EX_Control_ALU_op = "11"else
					   "010" when (EX_Control_ALU_op = "10" and Ins_in = "100000")else
					   "110" when (EX_Control_ALU_op = "10" and Ins_in = "100010")else
					   "000" when (EX_Control_ALU_op = "10" and Ins_in = "100100")else
					   "001" when (EX_Control_ALU_op = "10" and Ins_in = "100101")else
					   "111" when (EX_Control_ALU_op = "10" and Ins_in = "101010")else
					   "011";

	Inst_ALU: ALU PORT MAP(
		a => IDEX_data1,
		b => EX_mux1,
		control => EX_Ctrl_ALU,
		zero => EXMEM_Ctrl_ALU_zero_in,
		result => EXMEM_ALU_result_in
	);
	

	process (Clk, Reset) begin
		if(Reset= '1') then
			EXMEM_Ctrl_mem_rd <= '0' ;     
			EXMEM_Ctrl_mem_wr <= '0' ;
			EXMEM_Ctrl_dest_memo <= '0' ;
			EXMEM_Ctrl_reg_wr <= '0' ;
			EXMEM_Ctrl_cond_jump <= '0' ;
			EXMEM_ALU_result <= x"00000000" ;
			EXMEM_Ctrl_ALU_zero <= '0' ;
			EXMEM_cond_jump <= x"00000000" ;
			EXMEM_data2 <= x"00000000" ;
			EXMEM_mux2 <= "00000" ;
		elsif (rising_edge(Clk)) then  --5 senales de control de etapa 2
			EXMEM_Ctrl_mem_rd <=IDEX_Ctrl_mem_rd;     
			EXMEM_Ctrl_mem_wr <= IDEX_Ctrl_mem_wr;
			EXMEM_Ctrl_dest_memo <= IDEX_Ctrl_dest_memo;
			EXMEM_Ctrl_reg_wr <= IDEX_Ctrl_reg_wr ;
			EXMEM_Ctrl_cond_jump <= IDEX_Ctrl_cond_jump;
			EXMEM_data2 <= IDEX_data2;
			EXMEM_mux2 <= EXMEM_mux2_in; 
			cond_jump <= EXMEM_cond_jump_in; --Va a etapa 1
			EXMEM_Ctrl_ALU_zero <= EXMEM_Ctrl_ALU_zero_in ; --Flag de cero en ALU
			EXMEM_ALU_result <= EXMEM_ALU_result_in ; --Resultado ALU
		end if;
	end process ;
	--FIN ETAPA 3


------------------------------------------------------
	               --Etapa 4
------------------------------------------------------

	Ctrl_PCSrc <= EXMEM_Ctrl_ALU_zero and EXMEM_Ctrl_cond_jump ;
	
	--senales banco de datos
	D_Addr <= EXMEM_ALU_result ;
	D_RdStb <= EXMEM_Ctrl_mem_rd ;
	D_WrStb <= EXMEM_Ctrl_mem_wr ;
	D_DataOut <= EXMEM_data2 ;
	MEMWB_Data_in <= D_DataIn;
	
	process (Clk, Reset) begin
		if (Reset = '1') then
			MEMWB_Data <= x"00000000";
			MEMWB_ALU_result <= x"00000000";
			MEMWB_mux2 <= "00000";
			MEMWB_Ctrl_dest_memo <= '0' ;
			MEMWB_Ctrl_reg_wr <= '0' ;
		elsif (rising_edge(Clk)) then
			MEMWB_Data <= MEMWB_Data_in;
			MEMWB_ALU_result <= EXMEM_ALU_result;
			MEMWB_mux2 <= EXMEM_mux2;
			MEMWB_Ctrl_dest_memo <= EXMEM_Ctrl_dest_memo ;
			MEMWB_Ctrl_reg_wr <= EXMEM_Ctrl_reg_wr ;
		end if;
	end process;		
--FIN ETAPA 4



------------------------------------------------------
	               --Etapa 5
------------------------------------------------------

		Reg_Write_mux_out_5 <= MEMWB_Data when MEMWB_Ctrl_dest_memo = '1' else MEMWB_ALU_result;

--FIN ETAPA 5
end processor_arq;
