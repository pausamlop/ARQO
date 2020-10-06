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
 signal Alu_Op2           : std_logic_vector(31 downto 0);
 signal reg_RD_data       : std_logic_vector(31 downto 0);
 signal reg_RD_EX         : std_logic_vector(4 downto 0);
 signal reg_RD_MEM        : std_logic_vector(4 downto 0);
 signal reg_RD_WB         : std_logic_vector(4 downto 0);

 signal ALU_Igual_EX      : std_logic;
 signal ALU_Igual_MEM     : std_logic;

 signal Addr_Branch_EX    : std_logic_vector(31 downto 0);
 signal Addr_Branch_MEM   : std_logic_vector(31 downto 0);

 signal mux1              : std_logic_vector(4 downto 0);
 signal mux2              : std_logic_vector(4 downto 0);

 signal PC_plus4_IF       : std_logic_vector(31 downto 0);
 signal PC_plus4_ID       : std_logic_vector(31 downto 0);
 signal PC_plus4_EX       : std_logic_vector(31 downto 0);
 signal PC_reg            : std_logic_vector(31 downto 0);
 signal PC_next           : std_logic_vector(31 downto 0);

 signal Instruction_IF    : std_logic_vector(31 downto 0); 
 signal Instruction_ID    : std_logic_vector(31 downto 0); 
 signal Inm_ext           : std_logic_vector(31 downto 0); --Lparte baja de la instrucción extendida de signo
 signal reg_RS_ID         : std_logic_vector(31 downto 0);
 signal reg_RT_ID         : std_logic_vector(31 downto 0);
 signal reg_RS_EX         : std_logic_vector(31 downto 0);
 signal reg_RT_EX         : std_logic_vector(31 downto 0);
 signal reg_RT_MEM        : std_logic_vector(31 downto 0);
 signal reg_RT_WB         : std_logic_vector(31 downto 0);

 signal dataIn_Mem_MEM    : std_logic_vector(31 downto 0); --From Data Memory
 signal dataIn_Mem_WB     : std_logic_vector(31 downto 0); --From Data Memory


 signal Alu_Res_EX        : std_logic_vector(31 downto 0);
 signal Alu_Res_MEM       : std_logic_vector(31 downto 0);

 -- SIGNALS

 signal Ctrl_Branch_ID, Ctrl_MemWrite_ID, Ctrl_MemRead_ID, Ctrl_ALUSrc_ID, Ctrl_RegDest_ID, Ctrl_MemToReg_ID, Ctrl_RegWrite_ID : std_logic;
 signal Ctrl_ALUOP_ID     : std_logic_vector(2 downto 0);
 
 signal Ctrl_Branch_EX, Ctrl_MemWrite_EX, Ctrl_MemRead_EX,  Ctrl_ALUSrc_EX, Ctrl_RegDest_EX, Ctrl_MemToReg_EX, Ctrl_RegWrite_EX : std_logic;
 signal Ctrl_ALUOP_EX     : std_logic_vector(2 downto 0);

 signal Ctrl_Branch_MEM, Ctrl_MemWrite_MEM, Ctrl_MemRead_MEM, Ctrl_MemToReg_MEM, Ctrl_RegWrite_MEM : std_logic;

 signal Ctrl_MemToReg_WB, Ctrl_RegWrite_WB : std_logic;


 -- ENABLE SIGNALS
 signal enable_IF_ID             : std_logic;
 signal enable_ID_EX             : std_logic;
 signal enable_EX_MEM            : std_logic;
 signal enable_MEM_WB            : std_logic;

begin


-- ASIGNACIONES

PC_next <= Addr_Jump_dest when desition_Jump = '1' else PC_plus4;

-- PROCESS ASÍNCRONO
PC_reg_proc: process(Clk, Reset)
begin
  if Reset = '1' then
    PC_reg <= (others => '0');
  elsif rising_edge(Clk) then
    PC_reg <= PC_next;
  end if;
end process;

PC_plus4    <= PC_reg + 4;
IAddr       <= PC_reg;
Instruction <= IDataIn;

-------------------------------------------
enable_IF_ID <= '1';
enable_ID_EX <= '1';
enable_EX_MEM <= '1';
enable_MEM_WB <= '1';

IF_ID_reg_proc: process(Clk, Reset)
begin
  if reset = '1' then
    PC_plus4_ID <= (others => '0');
    Instruccion_ID <= (others => '0');
  elsif rising_edge(Clk) and enable_IF_ID = '1' then
    PC_plus4_ID <= PC_plus4_IF;
    Instruccion_ID <= Instruccion_IF;
  end if;
end process;

ID_EX_reg_proc: process(Clk, reset)
begin
  if Reset = '1' then
    
  elsif rising_edge(Clk) and enable_ID_EX = '1' then

    mux1 <= Instruccion_ID(20 downto 16);
    mux2 <= Instruccion_ID(15 downto 11);
    Inm_ext_EX <= Inm_ext_ID;
    reg_RT_EX <= reg_RT_ID;
    reg_RS_EX <= reg_RS_ID;
    PC_plus4_EX <= PC_plus4_ID;

    -- Unidad de Control
    Ctrl_Branch_EX <= Ctrl_Branch_ID;
    Ctrl_MemWrite_EX <= Ctrl_MemWrite_ID;
    Ctr_MemRead_EX <= Ctrl_MemRead_ID;
    Ctrl_ALUSrc_EX <= Ctrl_ALUSrc_ID;
    trl_RegDest_EX <= Ctrl_RegDest_ID;
    Ctrl_MemToReg_EX <= Ctrl_MemToReg_ID; 
    Ctrl_RegWrite_EX <= Ctrl_RegWrite_ID;
    Ctrl_ALUOP_EX <= Ctrl_ALUOP_ID;

  end if;
end process;


EX_MEM_reg_proc: process(Clk, reset)
begin
  if Reset = '1' then
    
  elsif rising_edge(Clk) and enable_EX_MEM = '1' then


    -- Unidad de Control
    Ctrl_Branch_MEM <= Ctrl_Branch_EX;
    Ctrl_MemWrite_MEM <= Ctrl_MemWrite_EX;
    Ctrl_MemRead_MEM <= Ctrl_MemRead_EX;
    Ctrl_MemToReg_MEM <= Ctrl_MemToReg_EX; 
    Ctrl_RegWrite_MEM <= Ctrl_RegWrite_EX;

  end if;
end process;

MEM_WB_reg_proc: process(Clk, reset)
begin
  if Reset = '1' then
    
  elsif rising_edge(Clk) and enable_MEM_WB = '1' then

    -- Unidad de Control
    Ctrl_MemToReg_WB <= Ctrl_MemToReg_MEM; 
    Ctrl_RegWrite_WB <= Ctrl_RegWrite_MEM;


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
    We3   => Ctrl_RegWrite --  // SIN CAMBIAR
  );
  -----------------------------------------

  ---------- PORT MAP UNIDADCONTROL ----------  // SIN CAMBIAR
  UnidadControl : control_unit
  port map(
    OpCode   => Instruction_ID(31 downto 26),
    -- Señales para el PC
    Jump     => Ctrl_Jump,
    Branch   => Ctrl_Branch,
    -- Señales para la memoria
    MemToReg => Ctrl_MemToReg,
    MemWrite => Ctrl_MemWrite,
    MemRead  => Ctrl_MemRead,
    -- Señales para la ALU
    ALUSrc   => Ctrl_ALUSrc,
    ALUOP    => Ctrl_ALUOP,
    -- Señales para el GPR
    RegWrite => Ctrl_RegWrite,
    RegDst   => Ctrl_RegDest
  );
  -----------------------------------------


  Inm_ext        <= x"FFFF" & Instruction(15 downto 0) when Instruction(15)='1' else
                    x"0000" & Instruction(15 downto 0);
  Addr_Jump      <= PC_plus4(31 downto 28) & Instruction(25 downto 0) & "00";
  Addr_Branch    <= PC_plus4 + ( Inm_ext(29 downto 0) & "00");

  Regs_eq_branch <= '1' when (reg_RS = reg_RT) else '0';
  desition_Jump  <= Ctrl_Jump or (Ctrl_Branch and Regs_eq_branch);
  Addr_Jump_dest <= Addr_Jump   when Ctrl_Jump='1' else
                    Addr_Branch when Ctrl_Branch='1' else
                    (others =>'0');

  ---------- PORT MAP ALU_CONTROL_I ---------- // SIN CAMBIAR
  Alu_control_i: alu_control
  port map(
    -- Entradas:
    ALUOp  => Ctrl_ALUOP, -- Codigo de control desde la unidad de control
    Funct  => Inm_ext_EX (5 downto 0), -- Campo "funct" de la instruccion
    -- Salida de control para la ALU:
    ALUControl => AluControl -- Define operacion a ejecutar por la ALU
  );
  -----------------------------------------

   ---------- PORT MAP ALUMIPS---------- 
  Alu_MIPS : alu
  port map (
    OpA     => reg_RS_EX,
    OpB     => Alu_Op2,
    Control => AluControl, --  // SIN CAMBIAR
    Result  => Alu_Res_EX,
    Zflag   => ALU_Igual_EX
  );
  -----------------------------------------

  -- MAS ASIGNACIONES

  Alu_Op2    <= reg_RT when Ctrl_ALUSrc = '0' else Inm_ext;
  reg_RD     <= Instruction(20 downto 16) when Ctrl_RegDest = '0' else Instruction(15 downto 11);

  DAddr      <= Alu_Res;
  DDataOut   <= reg_RT;
  DWrEn      <= Ctrl_MemWrite;
  dRdEn      <= Ctrl_MemRead;
  dataIn_Mem <= DDataIn;

  reg_RD_data <= dataIn_Mem when Ctrl_MemToReg = '1' else Alu_Res;


end architecture;
