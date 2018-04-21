library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity alu_exhaustive_tb is

end alu_exhaustive_tb;

architecture TB of alu_exhaustive_tb is

    component alu
        generic (
                  WIDTH : positive := 32
                );
        port (
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
    end component;

    constant WIDTH    : positive := 8;
    signal i_opcode   : std_logic_vector(5 downto 0) := (others => '0');
    signal i_ir_shft  : std_logic_vector(4 downto 0) := (others => '0');
    signal i_A        : std_logic_vector(width-1 downto 0)  := (others => '0');
    signal i_B        : std_logic_vector(WIDTH-1 downto 0)  := (others => '0');

    signal o_result   : std_logic_vector(width-1 downto 0);
    signal o_result_hi: std_logic_vector(width-1 downto 0);
    signal o_branch_taken: std_logic;

    


begin  -- TB

    UUT : alu
        generic map (WIDTH => WIDTH)
        port map (
                    i_opcode       => i_opcode,
                    i_ir_shft      => i_ir_shft,
                    i_A            => i_A,
                    i_B            => i_B,
                    o_result       => o_result,
                    o_result_hi    => o_result_hi,
                    o_branch_taken => o_branch_taken );





    process

variable temp : std_logic_vector(width-1 downto 0);
variable mult : std_logic_vector(2*width-1 downto 0);


    begin

    -- test all input combinations
    for op in 0 to 31 loop 
    for i in 0 to 255 loop
      for j in 0 to 255 loop

        i_opcode  <= std_logic_vector(to_unsigned(op,6));    

        -- Use j loop variable since for Shift opcodes only
        -- A operand of ALU is used.
        i_ir_shft <= std_logic_vector(to_unsigned(j,5)) ;

        i_A <= std_logic_vector(to_unsigned(i,8));
        i_B <= std_logic_vector(to_unsigned(j,8));
        wait for 5 ns;
        -- Checker 
        if ( i_opcode = ALU_OP_ADDU ) then  
	
  		
          assert( o_result = I_A+I_B) report "Error : ADD = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error : ADD BranchTaken != 0" ;

        elsif ( i_opcode = ALU_OP_SUBU ) then  
         
          assert( o_result = I_A-I_B) report "Error : SUB = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error : SUB BranchTaken != 0";

       elsif ( i_opcode = ALU_OP_MULT ) then  
	mult:= std_logic_vector(to_signed(i,width) * to_signed(j,width));
         assert( o_result    = mult(width-1 downto 0) )    report "Error : MULT LSB = " & integer'image(conv_integer(o_result));
          assert( o_result_hi = mult((width*2)-1 downto width)) report "Error : MULT MSB = " & integer'image(conv_integer(o_result_hi));
          assert( o_branch_taken = '0') report "Error : MULT BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_MULTU ) then  
	mult:= std_logic_vector(to_unsigned(i,width) * to_unsigned(j,width));
         assert( o_result    =mult(width-1 downto 0) )    report "Error : MULTU LSB = " & integer'image(conv_integer(o_result));
          assert( o_result_hi = mult((width*2)-1 downto width)) report "Error : MULTU MSB = " & integer'image(conv_integer(o_result_hi));
          assert( o_branch_taken = '0') report "Error : MULTU BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_AND ) then  
	
          assert( o_result = std_logic_vector(I_A and I_B)) report "Error : AND = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error AND : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_OR ) then  
	
          assert( o_result = std_logic_vector(I_A OR I_B)) report "Error : OR = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error OR : BranchTaken != 0" ;

        elsif ( i_opcode = ALU_OP_XOR ) then  
          assert( o_result = std_logic_vector(I_A xor I_B)) report "Error : XOR = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0')report "Error XOR : BranchTaken != 0" ;

      elsif ( i_opcode = ALU_OP_SRL ) then  
         
        assert( o_result = std_logic_vector(shift_right(unsigned(i_A), to_integer(unsigned(i_ir_shft)))))  report "Error : SRL= " & integer'image(conv_integer(o_result));
         assert( o_branch_taken = '0') report "Error SRL : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_SLL ) then  
          assert( o_result = std_logic_vector(shift_left(unsigned(i_A), to_integer(unsigned(i_ir_shft))))) report "Error : SLL= " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error SLL : BranchTaken != 0" ;

        elsif ( i_opcode = ALU_OP_SRA ) then  
                  assert( o_result = std_logic_vector(shift_right(signed(i_A), to_integer(unsigned(i_ir_shft))))) report "Error : SRA= " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error SRA : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_SLT ) then  
          -- Note: ALU A=I and ALU B=J 
          if ( to_signed(i,width) < to_signed(j,width) ) then 
            assert( o_result =X"01") report "Error : SLT = " & integer'image(conv_integer(o_result));
          else
            assert( o_result =X"00") report "Error : SLT = " & integer'image(conv_integer(o_result));
          end if;
          assert( o_branch_taken = '0') report "Error SLT : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_SLTU ) then  
          -- Note: ALU A=I and ALU B=J 
          if ( to_unsigned(i,width) < to_unsigned(j,width) ) then 
            assert( o_result = X"01") report "Error : SLTU = " & integer'image(conv_integer(o_result));
          else
            assert( o_result = X"00") report "Error : SLTU = " & integer'image(conv_integer(o_result));
          end if;
          assert( o_branch_taken = '0') report "Error SLTU : BranchTaken != 0";


        elsif ( i_opcode = ALU_OP_MFHI ) then  
          assert( o_result    = X"00") report "Error : MFHI = " & integer'image(conv_integer(o_result));
          assert( o_result_hi =X"00") report "Error : MFHI = " & integer'image(conv_integer(o_result_hi));
          assert( o_branch_taken = '0') report "Error : MFHI BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_MFLO ) then  
          assert( o_result    = X"00") report "Error : MFLO = " & integer'image(conv_integer(o_result));
          assert( o_result_hi = X"00") report "Error : MFLO = " & integer'image(conv_integer(o_result_hi));
          assert( o_branch_taken = '0') report "Error : MFLO BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_JR  ) then  
          assert( o_result    = std_logic_vector(to_unsigned(i,width))) report "Error : JR = " & integer'image(conv_integer(o_result));
          assert( o_result_hi = X"00") report "Error : JR = " & integer'image(conv_integer(o_result_hi));
          assert( o_branch_taken = '0') report "Error Else : BranchTaken != 0";


        elsif ( i_opcode = ALU_OP_JAL ) then  
          assert( o_result = I_A+I_B) report "Error : JAL = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error : JAL BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_ADDIU ) then  
          temp:=std_logic_vector(to_unsigned(i,width)+to_unsigned(j,width));
          assert( o_result = temp) report "Error : ADDIU = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error : ADDIU BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_SUBIU ) then  
          temp:=std_logic_vector(to_unsigned(i,width)-to_unsigned(j,width));
          assert( o_result = temp) report "Error : SUBIU = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error : SUBIU BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_ANDI ) then  
	temp:= I_A and i_B;
	
          assert( o_result =temp) report "Error : ANDI = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error ANDI : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_ORI ) then
	  
          assert( o_result = std_logic_vector(I_A OR I_B)) report "Error : ORI = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error ORI : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_XORI ) then
	
          assert( o_result = std_logic_vector(I_A xor i_B)) report "Error : XORI = " & integer'image(conv_integer(o_result));
          assert( o_branch_taken = '0') report "Error XORI : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_SLTI ) then  
          -- Note: ALU A=I and ALU B=J 
          if ( to_signed(i,width) < to_signed(j,width) ) then 
            assert( o_result = X"01") report "Error : SLTI = " & integer'image(conv_integer(o_result));
          else
            assert( o_result = X"00") report "Error : SLTI = " & integer'image(conv_integer(o_result));
          end if;
          assert( o_branch_taken = '0') report "Error SLTI : BranchTaken != 0";

        elsif ( i_opcode = ALU_OP_SLTIU ) then  
          -- Note: ALU A=I and ALU B=J 
          if ( to_unsigned(i,width) < to_unsigned(j,width) ) then 
            assert( o_result = X"01") report "Error : SLTIU = " & integer'image(conv_integer(o_result));
          else
            assert( o_result =X"00")report "Error : SLTIU = " & integer'image(conv_integer(o_result));
          end if;
          assert( o_branch_taken = '0') report "Error SLTIU : BranchTaken != 0";


        elsif ( i_opcode = ALU_OP_BEQ ) then  
          if ( to_unsigned(i,width) = to_unsigned(j,width) ) then 
            assert( o_branch_taken = '1') report "Error : BEQ BranchTaken != 0";
          else
            assert( o_branch_taken = '0') report "Error : BEQ BranchTaken != 0";
          end if;
          assert( o_result =X"00") report "Error : BEQ = " & integer'image(conv_integer(o_result));

        elsif ( i_opcode = ALU_OP_BNE ) then  
          if ( to_unsigned(i,width) /= to_unsigned(j,width) ) then 
            assert( o_branch_taken = '1') report "Error : BNE BranchTaken != 0";
          else
            assert( o_branch_taken = '0') report "Error : BNE BranchTaken != 0";
          end if;
          assert( o_result = X"00") report "Error : BNE = " & integer'image(conv_integer(o_result));

        elsif ( i_opcode = ALU_OP_BLEZ ) then  
          if ( to_signed(i,width) <= to_signed(0,width)) then 
            assert( o_branch_taken = '1') report "Error : BLEZ BranchTaken != 0";
          else
            assert( o_branch_taken = '0') report "Error : BLEZ BranchTaken != 0";
          end if;
          assert( o_result = X"00") report "Error : BLEZ = " & integer'image(conv_integer(o_result));

        elsif ( i_opcode = ALU_OP_BGTZ ) then  
          if ( to_signed(i,width) > to_signed(0,width)) then 
            assert( o_branch_taken = '1') report "Error : BGTZ BranchTaken != 0" ;
          else
            assert( o_branch_taken = '0') report "Error : BGTZ BranchTaken != 0";
          end if;
          assert( o_result = X"00") report "Error : BGTZ = " & integer'image(conv_integer(o_result));

        elsif ( i_opcode = ALU_OP_BLTZ ) then  
          if ( to_signed(i,width) < to_signed(0,width)) then 
            assert( o_branch_taken = '1') report "Error : BLTZ BranchTaken != 0";
          else
            assert( o_branch_taken = '0') report "Error : BLTZ BranchTaken != 0";
          end if;
          assert( o_result = X"00") report "Error : BLTZ = " & integer'image(conv_integer(o_result));

        elsif ( i_opcode = ALU_OP_BGEZ ) then  
          if ( to_signed(i,width) >= to_signed(0,width)) then 
            assert( o_branch_taken = '1') report "Error : BLTZ BranchTaken != 0";
          else
            assert( o_branch_taken = '0') report "Error : BLTZ BranchTaken != 0";
          end if;
          assert( o_result = X"00") report "Error : BLTZ = " & integer'image(conv_integer(o_result));


        else 
          assert( o_result    = X"00") report "Error : ELSE = " & integer'image(conv_integer(o_result));
          assert( o_result_hi = X"00") report "Error : ELSE = " & integer'image(conv_integer(o_result_hi));
          assert( o_branch_taken = '0') report "Error Else : BranchTaken != 0";

        end if;
    
        wait for 10 ns;

        end loop;  -- j
      end loop;  -- i
    end loop; -- op
    wait;
   report "SIM DONE!!!!!!!";

    end process;
  


end TB;
