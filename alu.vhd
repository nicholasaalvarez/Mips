  library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;
   entity alu is
generic (
           WIDTH : positive := 32
     );
port (
        -- ++++++++++++ Inputss ++++++++++++++++
        -- from Alu Control entity
        i_opcode : in std_logic_vector(5 downto 0);

        -- IR Shift Control Bits[10:6]
        i_ir_shft : in std_logic_vector(4 downto 0);

        -- Inputs to be operated on by ALU
        i_A : in std_logic_vector(width-1 downto 0);
        i_B : in std_logic_vector(width-1 downto 0);

        -- ++++++++++++ Outputs ++++++++++++++++
        -- Alu Result 
        o_result    : out std_logic_vector(width-1 downto 0);
        o_result_hi : out std_logic_vector(width-1 downto 0);

        -- Branch Taken
        o_branch_taken : out std_logic
     );
end alu;
	
architecture logic of alu is	




begin  -- GOOD3



	process(i_opcode,i_A, i_B,i_ir_shft)
	

variable mult : std_logic_vector(2*width-1 downto 0);


	begin
	
	o_result<= std_logic_vector(to_unsigned(0,width));
	o_result_hi<=std_logic_vector(to_unsigned(0,width));
	o_branch_taken <= '0';
	
	
	case i_opcode is
	

when ALU_OP_ADDU =>
 o_result<=std_logic_vector(unsigned(i_A) + unsigned(i_B));

when ALU_OP_ADDIU=>
 o_result<=std_logic_vector(unsigned(i_A) + unsigned(i_B));


when ALU_OP_SUBU=>
 o_result<= std_logic_vector(unsigned(i_A) - unsigned(i_B));


when ALU_OP_SUBIU=>
 o_result<= std_logic_vector(unsigned(i_A) - unsigned(i_B));





when  ALU_OP_MULT =>
mult:=std_logic_vector(signed(i_A) *signed(i_B));

 o_result <= mult(width-1 downto 0); 
o_result_hi <= mult(2*width-1 downto width);



when ALU_OP_MULTU=>
mult:=std_logic_vector(unsigned(i_A) *unsigned(i_B));

 o_result <= mult(width-1 downto 0); 
o_result_hi <= mult(2*width-1 downto width);



when ALU_OP_AND =>
 o_result<= i_A and i_B;

when ALU_OP_ANDI=>
 o_result<= i_A and i_B;





when ALU_OP_OR =>
 o_result<= i_A or i_B;


when ALU_OP_ORI=>
 o_result<= i_A or i_B;



when ALU_OP_XOR =>
 o_result<= i_A xor i_B;

when ALU_OP_XORI=>
 o_result<= i_A xor i_B;



when ALU_OP_SRL=>
 o_result<= std_logic_vector(shift_right(unsigned(i_B), to_integer(unsigned(i_ir_shft))));



when ALU_OP_SLL=>
 o_result<= std_logic_vector(shift_left(unsigned(i_B), to_integer(unsigned(i_ir_shft))));

when ALU_OP_SRA =>
 o_result <= std_logic_vector(shift_right(signed(i_B), to_integer(unsigned(i_ir_shft))));




when ALU_OP_SLT=>

if(signed(i_B) > signed(i_A) ) then
 o_result<= std_logic_vector(to_unsigned(1,width));
else 
 o_result<= std_logic_vector(to_unsigned(0,width));
end if;

when ALU_OP_SLTU=> 
if(unsigned(i_B) > unsigned(i_A))  then
 o_result<= std_logic_vector(to_unsigned(1,width));
else 
 o_result<= std_logic_vector(to_unsigned(0,width));
end if;



when ALU_OP_SLTI=>   
if(signed(i_B) > signed(i_A))  then
 o_result<= std_logic_vector(to_unsigned(1,width));
else 
 o_result<= std_logic_vector(to_unsigned(0,width));
end if;

when ALU_OP_SLTIU=>
if(unsigned(i_B) > unsigned(i_A))  then
 o_result<= std_logic_vector(to_unsigned(1,width));
else 
 o_result<= std_logic_vector(to_unsigned(0,width));
end if;


 

when ALU_OP_BEQ =>
 o_result<=std_logic_vector(to_unsigned(0,width));

if(unsigned(i_A)  = unsigned(i_B) ) then
o_branch_taken <= '1';
else
o_branch_taken<= '0';
end if;



when ALU_OP_BNE=>
 o_result<=std_logic_vector(to_unsigned(0,width));
if( unsigned(i_A) /= unsigned(i_B)) then
o_branch_taken <= '1';
else
o_branch_taken<= '0';
end if;


when ALU_OP_BLEZ=>
 o_result<=std_logic_vector(to_unsigned(0,width));
if(signed(i_A) <= to_signed(0,width)) then 
o_branch_taken <= '1';
else
o_branch_taken<= '0';
end if;



when ALU_OP_BGTZ=> 
 o_result<=std_logic_vector(to_unsigned(0,width));
if(signed(i_A) > to_signed(0,width)) then
o_branch_taken <= '1';
else
o_branch_taken<= '0';
end if;


when ALU_OP_BLTZ => 
 o_result<=std_logic_vector(to_unsigned(0,width));
if(signed(i_A) < to_signed(0,width)) then
o_branch_taken <= '1';
else
o_branch_taken<= '0';
end if;


when ALU_OP_BGEZ=>
 o_result<=std_logic_vector(to_unsigned(0,width));
if(signed(i_A) >= to_signed(0,width)) then
o_branch_taken <= '1';
else
o_branch_taken<= '0';
end if;


when ALU_OP_PASSB=>
o_result<= i_B;

when ALU_OP_PassA=> 
o_result<= i_A;







when others =>
 o_result<=std_logic_vector(to_unsigned(0,width));



end case;





end process;
end logic;