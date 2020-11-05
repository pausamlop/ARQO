--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2020-2021
--
-- Pablo Izaguirre García - pablo.izaguirre@estudiante.uam.es
-- Paula Samper López - paula.samper@estudiante.uam.es
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo en flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion Instr
      IDataIn    : in  std_logic_vector(31 downto 0); -- Instruccion leida
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is

  -- COMPONENTS 

  component alu
    port(
      OpA : in std_logic_vector (31 downto 0);
      OpB : in std_logic_vector (31 downto 0);
      Control : in std_logic_vector (3 downto 0);
      Result : out std_logic_vector (31 downto 0);
      Zflag : out std_logic
    );
  end component;

  component reg_bank
     port (
        Clk   : in std_logic; -- Reloj activo en flanco de subida
        Reset : in std_logic; -- Reset as�ncrono a nivel alto
        A1    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd1
        Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
        A2    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd2
        Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
        A3    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
        Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
        We3   : in std_logic -- Habilitaci�n de la escritura de Wd3
     );
  end component reg_bank;

  component control_unit
     port (
        -- Entrada = codigo de operacion en la instruccion:
        OpCode   : in  std_logic_vector (5 downto 0);
        -- Seniales para el PC
        Branch   : out  std_logic; -- 1 = Ejecutandose instruccion branch
        -- Seniales relativas a la memoria
        MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
        MemWrite : out  std_logic; -- Escribir la memoria
        MemRead  : out  std_logic; -- Leer la memoria
        -- Seniales para la ALU
        ALUSrc   : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
        ALUOp    : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
        -- Seniales para el GPR
        RegWrite : out  std_logic; -- 1=Escribir registro
        RegDst   : out  std_logic; -- 0=Reg. destino es rt, 1=rd
        -- Senial de salto
        Jump     : out  std_logic
     );
  end component;

  component alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
 end component alu_control;


 -- SIGNALS 
 signal Alu_Op1           : std_logic_vector(31 downto 0);
 signal Alu_Op2           : std_logic_vector(31 downto 0);
 signal AluControl        : std_logic_vector(3 downto 0);
 signal reg_RD_data       : std_logic_vector(31 downto 0);
 signal reg_RD_EX         : std_logic_vector(4 downto 0);
 signal reg_RD_MEM        : std_logic_vector(4 downto 0);
 signal reg_RD_WB         : std_logic_vector(4 downto 0);
 signal num_regRs         : std_logic_vector(4 downto 0);
 signal num_regRt         : std_logic_vector(4 downto 0);
 signal mux_rt            : std_logic_vector(31 downto 0);

 signal Alu_Igual_EX      : std_logic;
 signal Alu_Igual_MEM     : std_logic;

 signal Addr_Branch_EX    : std_logic_vector(31 downto 0);
 signal Addr_Branch_MEM   : std_logic_vector(31 downto 0);

 signal Addr_Jump         : std_logic_vector(31 downto 0);
 signal Addr_Jump_dest    : std_logic_vector(31 downto 0);
 signal desition_Jump     : std_logic;

 signal mux1              : std_logic_vector(4 downto 0);
 signal mux2              : std_logic_vector(4 downto 0);

 signal PC_plus4_IF       : std_logic_vector(31 downto 0);
 signal PC_plus4_ID       : std_logic_vector(31 downto 0);
 signal PC_plus4_EX       : std_logic_vector(31 downto 0);
 signal PC_reg            : std_logic_vector(31 downto 0);
 signal PC_next           : std_logic_vector(31 downto 0);

 signal Instruction_IF    : std_logic_vector(31 downto 0); 
 signal Instruction_ID    : std_logic_vector(31 downto 0); 
 signal Inm_ext_EX        : std_logic_vector(31 downto 0); --Lparte baja de la instrucción extendida de signo
 signal Inm_ext_ID        : std_logic_vector(31 downto 0); --Lparte baja de la instrucción extendida de signo
 signal reg_RS_ID         : std_logic_vector(31 downto 0);
 signal reg_RT_ID         : std_logic_vector(31 downto 0);
 signal reg_RS_EX         : std_logic_vector(31 downto 0);
 signal reg_RT_EX         : std_logic_vector(31 downto 0);
 signal reg_RT_MEM        : std_logic_vector(31 downto 0);

 signal Ctrl_Jump_ID         : std_logic;

 signal dataIn_Mem_MEM    : std_logic_vector(31 downto 0); --From Data Memory
 signal dataIn_Mem_WB     : std_logic_vector(31 downto 0); --From Data Memory


 signal Alu_Res_EX        : std_logic_vector(31 downto 0);
 signal Alu_Res_MEM       : std_logic_vector(31 downto 0);
 signal Alu_Res_WB        : std_logic_vector(31 downto 0);

 signal hazard_efective   : std_logic;

 -- CONTROL SIGNALS

 signal Forward_A, Forward_B : std_logic_vector(1 downto 0);

 signal Ctrl_Branch_ID, Ctrl_MemWrite_ID, Ctrl_MemRead_ID, Ctrl_ALUSrc_ID, Ctrl_RegDest_ID, Ctrl_MemToReg_ID, Ctrl_RegWrite_ID : std_logic;
 signal Ctrl_ALUOp_ID     : std_logic_vector(2 downto 0);
 
 signal Ctrl_Branch_EX, Ctrl_MemWrite_EX, Ctrl_MemRead_EX,  Ctrl_ALUSrc_EX, Ctrl_RegDest_EX, Ctrl_MemToReg_EX, Ctrl_RegWrite_EX : std_logic;
 signal Ctrl_ALUOp_EX     : std_logic_vector(2 downto 0);

 signal Ctrl_Branch_MEM, Ctrl_MemWrite_MEM, Ctrl_MemRead_MEM, Ctrl_MemToReg_MEM, Ctrl_RegWrite_MEM : std_logic;

 signal Ctrl_MemToReg_WB, Ctrl_RegWrite_WB : std_logic;


 -- ENABLE SIGNALS
 signal PCWrite                  : std_logic;
 signal enable_IF_ID             : std_logic;
 signal enable_ID_EX             : std_logic;
 signal enable_EX_MEM            : std_logic;
 signal enable_MEM_WB            : std_logic;

begin


-- ASIGNACIONES

-- IF STAGE -------------------------------

PC_next <= Addr_Jump_dest when desition_Jump = '1' else PC_plus4_IF;

Addr_Jump      <= PC_plus4_ID(31 downto 28) & Instruction_ID(25 downto 0) & "00";

desition_Jump  <= Ctrl_Jump_ID or (Ctrl_Branch_MEM and ALU_IGUAL_MEM);
Addr_Jump_dest <= Addr_Jump   when Ctrl_Jump_ID='1' else
                  Addr_Branch_MEM when Ctrl_Branch_MEM='1' else
                  (others =>'0');




-- PROCESS ASÍNCRONO
PC_reg_proc: process(Clk, Reset)
begin
  if Reset = '1' then
    PC_reg <= (others => '0');
  elsif rising_edge(Clk) then
    if PCWrite = '1' then
      PC_reg <= PC_next;
    end if;
  end if;
end process;

PC_plus4_IF    <= PC_reg + 4;
IAddr       <= PC_reg;
Instruction_IF <= IDataIn;

-------------------------------------------
enable_IF_ID <= '1';
enable_ID_EX <= '1';
enable_EX_MEM <= '1';
enable_MEM_WB <= '1';

IF_ID_reg_proc: process(Clk, Reset)
begin
  if reset = '1' then
    PC_plus4_ID <= (others => '0');
    Instruction_ID <= (others => '0');
  elsif rising_edge(Clk) then
    if enable_IF_ID = '1' then
      PC_plus4_ID <= PC_plus4_IF;
      Instruction_ID <= Instruction_IF;
    end if;
  end if;
end process;

ID_EX_reg_proc: process(Clk, reset)
begin
  if Reset = '1' then
    mux1 <= (others => '0');
    mux2 <= (others => '0');
    Inm_ext_EX <= (others => '0');
    reg_RT_EX <= (others => '0');
    reg_RS_EX <= (others => '0');
    PC_plus4_EX <= (others => '0');
    num_regRs <= (others => '0');
    num_regRt <= (others => '0');

    -- Unidad de Control
    Ctrl_Branch_EX <= '0';
    Ctrl_MemWrite_EX <= '0';
    Ctrl_MemRead_EX <= '0';
    Ctrl_ALUSrc_EX <= '0';
    Ctrl_RegDest_EX <= '0';
    Ctrl_MemToReg_EX <= '0'; 
    Ctrl_RegWrite_EX <= '0';
    Ctrl_ALUOp_EX <= (others =>'0');

    
  elsif rising_edge(Clk) then
    if enable_ID_EX = '1' then
      mux1 <= Instruction_ID(20 downto 16);
      mux2 <= Instruction_ID(15 downto 11);
      Inm_ext_EX <= Inm_ext_ID;
      reg_RT_EX <= reg_RT_ID;
      reg_RS_EX <= reg_RS_ID;
      PC_plus4_EX <= PC_plus4_ID;
      num_regRs <= Instruction_ID(25 downto 21);
      num_regRt <= Instruction_ID(20 downto 16);

      -- Unidad de Control
      Ctrl_Branch_EX <= Ctrl_Branch_ID;
      Ctrl_MemWrite_EX <= Ctrl_MemWrite_ID;
      Ctrl_MemRead_EX <= Ctrl_MemRead_ID;
      Ctrl_ALUSrc_EX <= Ctrl_ALUSrc_ID;
      Ctrl_RegDest_EX <= Ctrl_RegDest_ID;
      Ctrl_MemToReg_EX <= Ctrl_MemToReg_ID; 
      Ctrl_RegWrite_EX <= Ctrl_RegWrite_ID;
      Ctrl_ALUOp_EX <= Ctrl_ALUOp_ID;
    end if;

  end if;
end process;


EX_MEM_reg_proc: process(Clk, reset)
begin
  if Reset = '1' then
    reg_RD_MEM <= (others => '0');
    reg_RT_MEM <= (others => '0');
    Alu_Res_MEM <= (others => '0');
    Alu_Igual_MEM <= '0';
    Addr_Branch_MEM <= (others => '0');

    -- Unidad de Control
    Ctrl_Branch_MEM <= '0';
    Ctrl_MemWrite_MEM <= '0';
    Ctrl_MemRead_MEM <= '0';
    Ctrl_MemToReg_MEM <= '0'; 
    Ctrl_RegWrite_MEM <= '0';
    
  elsif rising_edge(Clk) then
    if enable_EX_MEM = '1' then
      reg_RD_MEM <= reg_RD_EX;
      reg_RT_MEM <= mux_rt;
      Alu_Res_MEM <= Alu_Res_EX;
      Alu_Igual_MEM <= Alu_Igual_EX;
      Addr_Branch_MEM <= Addr_Branch_EX;

      -- Unidad de Control
      Ctrl_Branch_MEM <= Ctrl_Branch_EX;
      Ctrl_MemWrite_MEM <= Ctrl_MemWrite_EX;
      Ctrl_MemRead_MEM <= Ctrl_MemRead_EX;
      Ctrl_MemToReg_MEM <= Ctrl_MemToReg_EX; 
      Ctrl_RegWrite_MEM <= Ctrl_RegWrite_EX;
    end if;

  end if;
end process;

MEM_WB_reg_proc: process(Clk, reset)
begin
  if Reset = '1' then
    reg_RD_WB <= (others => '0');
    Alu_Res_WB <= (others => '0');
    dataIn_Mem_WB <= (others => '0');
    -- Unidad de Control
    Ctrl_MemToReg_WB <= '0'; 
    Ctrl_RegWrite_WB <= '0';
    
  elsif rising_edge(Clk) then
    if enable_MEM_WB = '1' then
      reg_RD_WB <= reg_RD_MEM;
      Alu_Res_WB <= Alu_Res_MEM; -- reg_RT_MEM
      dataIn_Mem_WB <= dataIn_Mem_MEM;

      -- Unidad de Control
      Ctrl_MemToReg_WB <= Ctrl_MemToReg_MEM; 
      Ctrl_RegWrite_WB <= Ctrl_RegWrite_MEM;
    end if;

  end if;
end process;



  ---------- PORT MAP REGSMIPS ---------- 
  RegsMIPS : reg_bank
  port map (
    Clk   => Clk,
    Reset => Reset,
    A1    => Instruction_ID(25 downto 21),
    Rd1   => reg_RS_ID,
    A2    => Instruction_ID(20 downto 16),
    Rd2   => reg_RT_ID,
    A3    => reg_RD_WB,
    Wd3   => reg_RD_data,
    We3   => Ctrl_RegWrite_WB 
  );
  -----------------------------------------

  ---------- PORT MAP UNIDADCONTROL ---------- 
  UnidadControl : control_unit
  port map(
    OpCode   => Instruction_ID(31 downto 26),
    -- Señales para el PC
    Jump     => Ctrl_Jump_ID,
    Branch   => Ctrl_Branch_ID,
    -- Señales para la memoria
    MemToReg => Ctrl_MemToReg_ID,
    MemWrite => Ctrl_MemWrite_ID,
    MemRead  => Ctrl_MemRead_ID,
    -- Señales para la ALU
    ALUSrc   => Ctrl_ALUSrc_ID,
    ALUOP    => Ctrl_ALUOp_ID,
    -- Señales para el GPR
    RegWrite => Ctrl_RegWrite_ID,
    RegDst   => Ctrl_RegDest_ID
  );
  -----------------------------------------

  -- ID stage -----------------------------

  Inm_ext_ID        <= x"FFFF" & Instruction_ID(15 downto 0) when Instruction_ID(15)='1' else
                    x"0000" & Instruction_ID(15 downto 0);
  
  --WARNING: igual se puede simplificar lo de abajo
  -- HAZARD UNIT

  -- hazard_efective   <= '1'  when Ctrl_MemRead_ID = '1' and
  --                             	((num_regRt = Instruction_ID(25 downto 21)) or
  --                             	(num_regRt = Instruction_ID(20 downto 16))) 
	-- 						else '0';
    PCWrite <= '1';
            
  -- hazard_process: process(hazard_efective)
  --   begin
  --       if hazard_efective = '1' then
  --         enable_IF_ID <= '0';
  --         PCWrite <= '1';
  --         Ctrl_Branch_EX <= '0';
  --         Ctrl_MemWrite_EX <= '0';
  --         Ctrl_MemRead_EX <= '0';
  --         Ctrl_ALUSrc_EX <= '0';
  --         Ctrl_RegDest_EX <= '0';
  --         Ctrl_MemToReg_EX <= '0';
  --         Ctrl_RegWrite_EX <= '0';
  --         Ctrl_ALUOp_EX <= (others =>'0');
  --       else
  --         enable_IF_ID <= '1';
  --         PCWrite <= '0';       
  --       end if;
  --   end process;


  ---------- PORT MAP ALU_CONTROL_I ----------
  Alu_control_i: alu_control
  port map(
    -- Entradas:
    ALUOp  => Ctrl_ALUOp_EX, -- Codigo de control desde la unidad de control
    Funct  => Inm_ext_EX (5 downto 0), -- Campo "funct" de la instruccion
    -- Salida de control para la ALU:
    ALUControl => AluControl -- Define operacion a ejecutar por la ALU
  );
  -----------------------------------------

   ---------- PORT MAP ALUMIPS---------- 
  Alu_MIPS : alu
  port map (
    OpA     => Alu_Op1,
    OpB     => Alu_Op2,
    Control => AluControl,
    Result  => Alu_Res_EX,
    Zflag   => Alu_Igual_EX
  );
  -----------------------------------------


  -- EX STAGE -----------------------------

  
  Alu_Op1    <= reg_RS_EX when Forward_A = "00" else
                reg_RD_data when Forward_A = "01" else --reg_RD_data
                Alu_res_MEM when Forward_A = "10";    --Alu_Res_MEM

  mux_rt     <= reg_rt_EX when Forward_B = "00" else
                reg_RD_data when Forward_B = "01" else --reg_RD_data
                Alu_res_MEM when Forward_B = "10";    --Alu_Res_MEM

  Alu_Op2    <= mux_rt when Ctrl_ALUSrc_EX = '0' else Inm_ext_EX;
  reg_RD_EX     <= mux1 when Ctrl_RegDest_EX = '0' else mux2;
  Addr_Branch_EX    <= PC_plus4_EX + ( Inm_ext_EX(29 downto 0) & "00");

  
  -- EX HAZARD
  --Forward_A <= "10" when ((Ctrl_RegWrite_MEM = '1' and (reg_RD_MEM /= "00000")) and (reg_RD_MEM = num_regRs)) else "00";

  --Forward_B <= "10" when ((Ctrl_RegWrite_MEM = '1' and (reg_RD_MEM /= "00000")) and (reg_RD_MEM = num_regRt)) else "00";

  -- MEM HAZARD
  Forward_A <= "01" when (Ctrl_RegWrite_WB = '1' and (reg_RD_WB /= "00000")
                          and not (reg_RD_EX = num_regRs) 
                          and (reg_RD_WB = num_regRs))
                          else "10" when ((Ctrl_RegWrite_MEM = '1' and (reg_RD_MEM /= "00000")) and (reg_RD_MEM = num_regRs)) else "00";

  Forward_B <= "01" when (Ctrl_RegWrite_WB = '1' and (reg_RD_WB /= "00000")
                          and not (reg_RD_EX = num_regRt)   
                          and (reg_RD_WB = num_regRt))
                          else "10" when ((Ctrl_RegWrite_MEM = '1' and (reg_RD_MEM /= "00000")) and (reg_RD_MEM = num_regRt)) else "00";            


  -- MEM STAGE ----------------------------
  
  DAddr <= Alu_Res_MEM;
  DDataOut <= reg_RT_MEM;
  DWrEn <= Ctrl_MemWrite_MEM;
  DRdEn <= Ctrl_MemRead_MEM;
  dataIn_Mem_MEM <= DDataIn;

  -- WB STAGE -----------------------------

  reg_RD_data <= dataIn_Mem_WB when Ctrl_MemToReg_WB = '1' else Alu_Res_WB;


end architecture;
