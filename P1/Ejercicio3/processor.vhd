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
 signal reg_RD_data  : std_logic_vector(31 downto 0);
 signal reg_RD_EX       : std_logic_vector(4 downto 0);
 signal reg_RD_MEM       : std_logic_vector(4 downto 0);
 signal reg_RD_WB       : std_logic_vector(4 downto 0);

 signal mux1           : std_logic_vector(4 downto 0);
 signal mux2           : std_logic_vector(4 downto 0);

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

 signal dataIn_Mem_MEM     : std_logic_vector(31 downto 0); --From Data Memory
 signal dataIn_Mem_WB      : std_logic_vector(31 downto 0); --From Data Memory


 signal Alu_Res_EX        : std_logic_vector(31 downto 0);
 signal Alu_Res_MEM       : std_logic_vector(31 downto 0);



begin


  ---------- PORT MAP REGSMIPS ---------- 
  RegsMIPS : reg_bank
  port map (
    Clk   => Clk,
    Reset => Reset,
    A1    => Instruction(25 downto 21),
    Rd1   => reg_RS,
    A2    => Instruction(20 downto 16),
    Rd2   => reg_RT,
    A3    => reg_RD,
    Wd3   => reg_RD_data,
    We3   => Ctrl_RegWrite
  );
  -----------------------------------------

  ---------- PORT MAP UNIDADCONTROL ---------- 
  UnidadControl : control_unit
  port map(
    OpCode   => Instruction(31 downto 26),
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

  ---------- PORT MAP ALU_CONTROL_I ---------- 
  Alu_control_i: alu_control
  port map(
    -- Entradas:
    ALUOp  => Ctrl_ALUOP, -- Codigo de control desde la unidad de control
    Funct  => instruction (5 downto 0), -- Campo "funct" de la instruccion
    -- Salida de control para la ALU:
    ALUControl => AluControl -- Define operacion a ejecutar por la ALU
  );
  -----------------------------------------

   ---------- PORT MAP ALUMIPS---------- 
  Alu_MIPS : alu
  port map (
    OpA     => reg_RS,
    OpB     => Alu_Op2,
    Control => AluControl,
    Result  => Alu_Res,
    Zflag   => ALU_IGUAL
  );
  -----------------------------------------



end architecture;
