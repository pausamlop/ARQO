--------------------------------------------------------------------------------
-- Forwarding Unit. Arq0 2020-2021
--
-- Pablo Izaguirre García - pablo.izaguirre@estudiante.uam.es
-- Paula Samper López - paula.samper@estudiante.uam.es
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity forwarding_unit is
    port (
        ExMem_RegRd     : in std_logic_vector(4 downto 0);
        MemWb_RegRd     : in std_logic_vector(4 downto 0);
        IdEx_RegRs      : in std_logic_vector(4 downto 0);
        IdEx_RegRt      : in std_logic_vector(4 downto 0);
        ForwardA        : in std_logic_vector(4 downto 0);
        ForwardB        : in std_logic_vector(4 downto 0);
        ExMem_RegWrite  : in std_logic;
        MemWb_RegWrite  : in std_logic
    );
end forwarding_unit;



architecture rtl of forwarding_unit is
    
begin
    
    -- EX HAZARD
    ForwardA <= "10" when (ExMem_RegWrite and (ExMem_RegRd != 0) and (ExMem_RegRd = IdEx_RegRs)) else "00";

    ForwardB <= "10" when (ExMem_RegWrite and (ExMem_RegRd != 0) and (ExMem_RegRd = IdEx_RegRt)) else "00";

    -- MEM HAZARD
    ForwardA <= "01" when (MemWb_RegWrite and (MemWb_RegRd != 0)
                            and not (ExMem_RegWrite and (ExMem_RegRd != 0)
                                and (ExMem_RegRd = IdEx_RegRs))
                            and (MemWb_RegRd = IdEx_RegRs)); 
        
    ForwardB <= "01" when (MemWb_RegWrite and (MemWb_RegRd != 0)
                            and not (ExMem_RegWrite and (ExMem_RegRd != 0)
                                and (ExMem_RegRd = IdEx_RegRt ))
                            and (MemWb_RegRd = IdEx_RegRt));
        
end architecture;