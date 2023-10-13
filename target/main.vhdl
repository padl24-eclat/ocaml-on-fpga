library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.runtime.all;


entity main is
  
  port(signal clk    : in std_logic;
       signal reset  : in std_logic;
       signal run    : in std_logic;
       signal rdy    : out value(0 to 0);
       signal argument : in value(0 to 0);
       signal result : out value(0 to 31));
       
end entity;
architecture rtl of main is

  type t_state is (compute13);
  signal state: t_state;
  
  begin
    process(clk)
      variable \$v7_init\, \$v14\, \$v9\, rdy12
               : value(0 to 0) := (others => '0');
      variable \$v7\, compute13_id, result11
               : value(0 to 31) := (others => '0');
      
    begin
      
      if rising_edge(clk) then
        if (reset = '1') then
          default_zero(rdy12); default_zero(\$v9\); default_zero(\$v14\); 
          default_zero(result11); default_zero(compute13_id); 
          default_zero(\$v7_init\); default_zero(\$v7\); 
          rdy <= "1";
          rdy12 := "0";
          state <= compute13;
          
        else if run = '1' then
          case state is
          when compute13 =>
            rdy12 := eclat_false;
            \$v14\ := eclat_not(\$v7_init\);
            if \$v14\(0) = '1' then
              \$v7\ := X"0000000" & X"0";
              \$v7_init\ := eclat_true;
            end if;
            \$v7\ := eclat_if(argument & X"0000000" & X"0" & eclat_add(\$v7\ & X"0000000" & X"1"));
            \$v9\ := eclat_unit;
            result11 := \$v7\;
            rdy12 := eclat_true;
            case compute13_id is
            when others =>
              
            end case;
          end case;
          
          result <= result11;
          rdy <= rdy12;
          
        end if;
      end if;
    end if;
  end process;
end architecture;
