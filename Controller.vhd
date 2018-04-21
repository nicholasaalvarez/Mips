library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

-- MAIN Mips Controller SM and logic 
entity controller is
  port (

    clk, rst     : in  std_logic;

    i_IR_Opcode  : in  std_logic_vector(5 downto 0); -- IR Bits[31:26]
    i_IR_Func    : in  std_logic_vector(5 downto 0); -- IR Bits[05:00]
    i_IR_Bit16   : in  std_logic;                    -- IR Bit [16]
    i_BranchTaken: in  std_logic;

    o_PcWrite    : out std_logic;
    o_IorD       : out std_logic;
    o_MemWrite   : out std_logic;
    o_MemRead    : out std_logic;
    o_MemToReg   : out std_logic;
    o_IRWrite    : out std_logic;
    o_IsSigned   : out std_logic;
    o_RegWrite   : out std_logic;
    o_JumpAndLink: out std_logic;
    o_RegDst     : out std_logic;
    o_AluSrcA    : out std_logic;
    o_AluSrcB    : out std_logic_vector(1 downto 0);
    o_PCSrc      : out std_logic_vector(1 downto 0);
    o_AluOp      : out std_logic_vector(5 downto 0)
);
end controller;


-------------------------------------------------------------------------------
-- Controller will be using the 2-process State-Machine model 
-------------------------------------------------------------------------------

architecture logic of controller is

  -- State declarations 
  type STATE_TYPE is ( IR_FETCH,   IR_DECODE,  
                       RTYPE_EXEC, ITYPE_EXEC, REGFILE_WR,
                       LOAD_PC_JUMP_BRANCH, MEM_READ,MEM_WRITE, State_OPCODE_HALT  );

  signal state, next_state : STATE_TYPE;

begin

  -- Update State Register with Next State 
  process(clk, rst)
  begin
    if (rst = '1') then
      state <= IR_FETCH;                
    elsif(clk'event and clk = '1') then
      state <= next_state;
    end if;
  end process;

  -- -----------------------------------------------------------------
  --            State Macine Outputs and Next State Logic 
  -- -----------------------------------------------------------------
  process(state, i_IR_Opcode, i_IR_Func, i_IR_Bit16, i_BranchTaken )
  begin

    case state is

      -- -----------------------------------------------------------------
      --       Instruction Fetch / Update Program Counter (PC)
      -- -----------------------------------------------------------------
      -- When in this state have will be increment / loading PC 
      -- to next address, and will have signals asserted to load IR.
      when IR_FETCH =>
         -- Defaults
         o_PcWrite     <= '1';   -- Update PC (PC<-PC+4)
         o_IorD        <= '0';
         o_MemWrite    <= '0';
         o_MemRead     <= '1';   -- Read Mem (Next Instruction)
         o_MemToReg    <= '0';
         o_IRWrite     <= '1';   -- Load Next Instruction IR<-MEM[PC]
         o_IsSigned    <= '0';
         o_RegWrite    <= '0';
         o_JumpAndLink <= '0';
         o_RegDst      <= '0';
         o_AluSrcA     <= '0';         -- Select ALU-A = PC
         o_AluSrcB     <= "01";        -- Select ALU-B = 4 (Used to Inc PC by 1)
         o_AluOp       <= ALU_OP_ADDU; -- Result = PC + 4 
         o_PCSrc       <= "00";        -- Seelct ALU RESULT

         -- Proceed to Load IR / PC <- NextPc (PC<-PC+4)
         -- At rising edge of clock will upate IR and PC with new values.
         next_state    <= IR_DECODE;


      -- -----------------------------------------------------------------
      --                  Instruction Decode State 
      -- -----------------------------------------------------------------
      -- When this state is entered, the PC has been loaded to the next 
      -- address and the Instructin Register has been loaded.
      -- The two Read ports are set to their proper address and the 
      -- Read Data should be on the Regfile output ports.
      when IR_DECODE =>
         -- Defaults
         o_PcWrite     <= '0';
         o_IorD        <= '0';
         o_MemWrite    <= '0';
         o_MemRead     <= '0';
         o_MemToReg    <= '0';
         o_IRWrite     <= '0';
         o_IsSigned    <= '0';
         o_RegWrite    <= '0';
         o_JumpAndLink <= '0';
         o_RegDst      <= '0';
         o_AluSrcA     <= '1';   -- Select RegFile-A
         o_AluSrcB     <= "00";  -- Select RegFile-B
         o_AluOp       <= ALU_OP_ADDU;
         o_PCSrc       <= "00";  -- N/A

         -- ------------------------------------
         --    Process Instruction Register 
         -- ------------------------------------
         if ( i_IR_Opcode  = OPCODE_RTYPE ) then   
           -- Exec R-Type Instruction
           next_state  <= RTYPE_EXEC;

         elsif ( i_IR_Opcode  =  OPCODE_HALT ) then   
           -- Fake Instruction HALT
           next_state  <= State_OPCODE_HALT;
			  
			  
			  --Need to load pc with 25-0
			elsif( I_IR_Opcode = OPCODE_J ) then 
         next_state<=LOAD_PC_JUMP_BRANCH;
			 
			 

         else 
           -- Exec I-Type Instruction
           next_state  <= ITYPE_EXEC;

         end if;



      -- -----------------------------------------------------------------
      --                 Execute R-Type Instructions 
      -- -----------------------------------------------------------------
      -- When Entering this state both RegA and RegB registers have been
      -- loaded and ALU will execute the Opcode provided by this state. 
      when RTYPE_EXEC =>
         -- Default values for state
         o_PcWrite     <= '0';
         o_IorD        <= '0';
         o_MemWrite    <= '0';
         o_MemRead     <= '0';
         o_MemToReg    <= '0';
         o_IRWrite     <= '0';
         o_IsSigned    <= '0';
         o_RegWrite    <= '0';
         o_JumpAndLink <= '0';
         o_RegDst      <= '0';
         o_AluSrcA     <= '1';   -- Select RegFile-A
         o_AluSrcB     <= "00";  -- Select RegFile-B
         o_PCSrc       <= "00";  -- N/A

         -- Proceed to Write Register File (Default)
         -- Can be overwritten if instruction (ie. MULT)
         -- does not require regfile write to take place.
         next_state <= REGFILE_WR;

         -- Select the proper ALU Opcode and determine 
         -- next_state based on opcode being processed
         if ( i_IR_Func = OP0_FUNC_ADDU ) then 
           o_AluOp    <= ALU_OP_ADDU;

         elsif ( i_IR_Func = OP0_FUNC_SUBU ) then 
           o_AluOp    <= ALU_OP_SUBU;

         elsif ( i_IR_Func = OP0_FUNC_MULT ) then 
            o_AluOp    <= ALU_OP_MULT;
            next_state <= IR_FETCH; -- Note: No RegFile Write needed

         elsif ( i_IR_Func = OP0_FUNC_MULTU ) then 
            o_AluOp    <= ALU_OP_MULTU;
            next_state <= IR_FETCH; -- Note: No RegFile Write needed

         elsif ( i_IR_Func = OP0_FUNC_AND ) then 
            o_AluOp    <= ALU_OP_AND;

         elsif ( i_IR_Func = OP0_FUNC_OR  ) then 
            o_AluOp    <= ALU_OP_OR;

         elsif ( i_IR_Func = OP0_FUNC_XOR ) then 
            o_AluOp    <= ALU_OP_XOR;

         elsif ( i_IR_Func = OP0_FUNC_SRL ) then 
            o_AluOp    <= ALU_OP_SRL;

         elsif ( i_IR_Func = OP0_FUNC_SLL ) then 
            o_AluOp    <= ALU_OP_SLL;

         elsif ( i_IR_Func = OP0_FUNC_SRA ) then 
            o_AluOp    <= ALU_OP_SRA;

         elsif ( i_IR_Func = OP0_FUNC_SLT ) then 
            o_AluOp    <= ALU_OP_SLT;

         elsif ( i_IR_Func = OP0_FUNC_SLTU ) then 
            o_AluOp    <= ALU_OP_SLTU;

         elsif ( i_IR_Func = OP0_FUNC_SRA ) then 
            o_AluOp    <= ALU_OP_SRA;

         elsif ( i_IR_Func = OP0_FUNC_MFHI ) then 
            o_AluOp    <= ALU_OP_MFHI;

         elsif ( i_IR_Func = OP0_FUNC_MFLO ) then 
            o_AluOp    <= ALU_OP_MFLO;

         elsif ( i_IR_Func = OP0_FUNC_JR ) then 
            -- RegA needs to be loaded to PC 
            o_AluOp    <= ALU_OP_PASSA;           -- RESULT = RegA Bits[25:21]
            next_state <= LOAD_PC_JUMP_BRANCH; -- Note: No RregFile Write Needed
				


         else
            o_AluOp  <= ALU_OP_ADDU;

         end if;


      -- -----------------------------------------------------------------
      --      Execute I-Type Instructions 
      -- -----------------------------------------------------------------
      -- When Entering this state both RegA and RegB registers have been
      -- loaded and ALU will execute the Opcode provided by this state.
      when ITYPE_EXEC =>


          -- Defaults for State
          o_PcWrite     <= '0';
          o_IorD        <= '0';
          o_MemWrite    <= '0';
          o_MemRead     <= '0';
          o_MemToReg    <= '0';
          o_IRWrite     <= '0';
          o_IsSigned    <= '0';   -- Default is Immediate = Unsigned 
          o_RegWrite    <= '0';
          o_JumpAndLink <= '0';
          o_RegDst      <= '0';
          o_AluSrcA     <= '1';   -- Select RegFile-A ($s)
          o_AluSrcB     <= "10";  -- Select Offset IR Bits[15:0] = Immediate 
          o_PCSrc       <= "00";  -- N/A
          -- Proceed to Write Register File (Default)
          next_state <= REGFILE_WR;

          -- Select the proper ALU Opcode and determine 
          -- next_state based on opcode being processed
          if ( i_IR_Opcode = OPCODE_ADDIU ) then 
             o_AluOp    <= ALU_OP_ADDIU;
             o_IsSigned <= '1';   -- Set Offset is a Signed

          elsif ( i_IR_Opcode = OPCODE_SUBIU ) then 
             o_AluOp    <= ALU_OP_SUBIU;
             o_IsSigned <= '1';   -- Set Offset is Signed

          elsif ( i_IR_Opcode = OPCODE_ANDI ) then 
             o_AluOp    <= ALU_OP_ANDI;

          elsif ( i_IR_Opcode = OPCODE_ORI ) then 
             o_AluOp    <= ALU_OP_ORI;

          elsif ( i_IR_Opcode = OPCODE_XORI ) then 
             o_AluOp    <= ALU_OP_XORI;

          elsif ( i_IR_Opcode = OPCODE_SLTI ) then 
             -- Need to Set since Offset (Immediate) is Signed 
             o_AluOp    <= ALU_OP_SLTI;
             o_IsSigned <= '1';  

          elsif ( i_IR_Opcode = OPCODE_SLTIU ) then 
             -- Note: for this instruction Offset (Immediate) is Unsigned
             o_AluOp    <= ALU_OP_SLTIU;

          elsif ( i_IR_Opcode = OPCODE_BEQ ) then 
             -- Note: This Inst. compares the two Registers so 
             --       need to overide the default and select
             --       RegFile Register as the B-Operand to ALU
             o_AluOp    <= ALU_OP_BEQ;
             o_AluSrcB  <= "00";  -- Select RegFile as B-Operand
             -- Now need to look at the ALU Branch-Taken signal 
             -- to see if the two registers are equal.
             -- Branch-Taken = 1  Reg A  = B  Proceed to Load PC  (PC<-Offset)
             -- Branch-Taken = 0  Reg A != B  No Action necessary (PC<-PC + 4)
             if ( i_BranchTaken = '1' ) then   
               next_state <= LOAD_PC_JUMP_BRANCH;
             else 
               next_state <= IR_FETCH;
             end if;

				
			elsif(I_IR_Opcode = OPCODE_BNE) then
				o_Aluop<= ALU_OP_BNE;
				o_AluSrcB  <= "00";  
 
				if ( i_BranchTaken = '1' ) then   
               next_state <= LOAD_PC_JUMP_BRANCH;
             else 
               next_state <= IR_FETCH;
             end if;
 
 
			elsif(I_IR_Opcode = OPCODE_BLEZ ) then
				 o_Aluop<= ALU_OP_BLEZ;
				 o_AluSrcB  <= "00";  
 
				if ( i_BranchTaken = '1' ) then   
               next_state <= LOAD_PC_JUMP_BRANCH;
				else 
               next_state <= IR_FETCH;
            end if;
 
 
			elsif(I_IR_Opcode = OPCODE_BGTZ  ) then
					o_Aluop<= ALU_OP_BGTZ;
					o_AluSrcB  <= "00";  
 
					if ( i_BranchTaken = '1' ) then   
                  next_state <= LOAD_PC_JUMP_BRANCH;
               else 
                  next_state <= IR_FETCH;
               end if;
 
					-- Have to check if IR BIT 16 is 1 or 0 to determine which function to do
			elsif(I_IR_Opcode = OPCODE_BLTZ_GEZ) then
					
				if(i_IR_Bit16 = '1') then
				
					o_Aluop<= ALU_OP_BGEZ;
					o_AluSrcB  <= "00";  
					
					if ( i_BranchTaken = '1' ) then   
						next_state <= LOAD_PC_JUMP_BRANCH;
					else 
						next_state <= IR_FETCH;
					end if;
 
				else
					o_Aluop<= ALU_OP_BLTZ;
					o_AluSrcB  <= "00";  
 
					if ( i_BranchTaken = '1' ) then   
						next_state <= LOAD_PC_JUMP_BRANCH;
					else 
						next_state <= IR_FETCH;
					end if;
					
				end if;
				

         elsif ( i_IR_Opcode = OPCODE_LW ) then 
             -- Add RegA ($s) to RegB (Offset)
             -- RESULT = RegA + RegB = ($s + Offset)
             o_AluOp    <= ALU_OP_ADDU;
             next_state <= MEM_READ; -- Proceed to access Memory [$S+Offset]
				 
				 
			
         elsif ( i_IR_Opcode = OPCODE_SW ) then 
             
             o_AluOp    <= ALU_OP_ADDU;
             next_state <= MEM_Write; -- Proceed to Write Memory [$S+Offset]
				 
 
          -- TODO: Need to Implement SW Instruction (Most likely add new State MEM_Write)

          elsif(i_IR_Opcode = OPCODE_JAL) then
			  o_AluSrcB   <= "01";  -- Need to add 4
			  o_AluSrca   <= '0';  -- Need to add pc 
			  o_Aluop    <= ALU_OP_PASSA; -- PassA;  Need to Add if After JAL is a NOP to make it plus 8
			 next_state <= Load_PC_jump_branch;
			 
			 
		   else
             -- Should never hit this statement 
             next_state <= IR_FETCH;

          end if;




      -- -----------------------------------------------------------------
      --      Load PC for all Jump and Branch Instructions 
      -- -----------------------------------------------------------------
      -- This state will load PC register when the R-TYPE Instruction
      -- JUMP Register is executed.  The ALU OUT Register will have the 
      -- address (RegA) which will be loaded into the PC Register
      when LOAD_PC_JUMP_BRANCH  =>
          -- State Defaults
          o_PcWrite     <= '1';  -- Update PC (Based on Instruction) 
          o_IorD        <= '0';
          o_MemWrite    <= '0';
          o_MemRead     <= '0';  
          o_MemToReg    <= '0';
          o_IRWrite     <= '0';     
          o_IsSigned    <= '0';
          o_RegWrite    <= '0';
          o_JumpAndLink <= '0';
          o_RegDst      <= '0';
          o_AluSrcA     <= '0';            
          o_AluSrcB     <= "00";            
          o_PCSrc       <= "01";  -- ALU OUT = $S (RegA)
          o_AluOp       <= ALU_OP_ADDU; 
          -- Proceed to Fetch Instruction and update PC to next Instruction
          next_state    <= IR_FETCH;

          -- For JR  Instruction PC<-RegA 
          -- For BEQ Instruction PC<-Offset<<2 

          if ( i_IR_Opcode = OPCODE_BEQ ) then 
             -- Need to provide ALU with Opcode = PASS B (Offset)
             o_AluOp    <= ALU_OP_PASSB;  -- Pass OFFSET
             o_AluSrcB  <= "11";          -- 3: Select Offset<<2
             o_PCSrc    <= "00";          -- 0: Select ALU Resut=RegB=Offset<<2
				 
			elsif(I_IR_Opcode = OPCODE_BNE) then
			  -- Need to provide ALU with Opcode = PASS B (Offset)
             o_AluOp    <= ALU_OP_PASSB;  -- Pass OFFSET
             o_AluSrcB  <= "11";          -- 3: Select Offset<<2
             o_PCSrc    <= "00";          -- 0: Select ALU Resut=RegB=Offset<<2
 
			elsif(I_IR_Opcode = OPCODE_BLEZ ) then
			  -- Need to provide ALU with Opcode = PASS B (Offset)
             o_AluOp    <= ALU_OP_PASSB;  -- Pass OFFSET
             o_AluSrcB  <= "11";          -- 3: Select Offset<<2
             o_PCSrc    <= "00";          -- 0: Select ALU Resut=RegB=Offset<<2
 
 
				elsif(I_IR_Opcode = OPCODE_BGTZ  ) then
														-- Need to provide ALU with Opcode = PASS B (Offset)
             o_AluOp    <= ALU_OP_PASSB;  -- Pass OFFSET
             o_AluSrcB  <= "11";          -- 3: Select Offset<<2
             o_PCSrc    <= "00";          -- 0: Select ALU Resut=RegB=Offset<<2
					
         
 
					-- Have to check if IR BIT 16 is 1 or 0 to determine which function to do
			 elsif(I_IR_Opcode = OPCODE_BLTZ_GEZ) then
			
					  -- Need to provide ALU with Opcode = PASS B (Offset)
             o_AluOp    <= ALU_OP_PASSB;  -- Pass OFFSET
             o_AluSrcB  <= "11";          -- 3: Select Offset<<2
             o_PCSrc    <= "00";          -- 0: Select ALU Resut=RegB=Offset<<2
				 
				 
				 
				 
				 
				 
			 elsif( I_ir_opcode = OPCODE_J ) then
				  o_PCSrc  <= "10";  --Pcsrc = IR[25:0] shifted left by 2
				  
				
			 elsif( I_ir_opcode = OPCODE_Jal ) then
			   o_PCSrc  <= "10";  --Pcsrc = IR[25:0] shifted left by 2	
				o_Regwrite<= '1';
				o_jumpandLink<= '1';
				
				
          end if;



      -- -----------------------------------------------------------------
      --      Write Register-File 
      -- -----------------------------------------------------------------
      -- When entering this state the ALU OUT Register should be valid and 
      -- will be writing ALU OUT to regfile destination reg = IR Bits[20:16]
      -- Exceptions: MFHI and MFLO instructions 
      when REGFILE_WR =>
          o_PcWrite     <= '0';
          o_IorD        <= '0';
          o_MemWrite    <= '0';
          o_MemRead     <= '0';
          o_MemToReg    <= '0';   -- Select ALU Output Mux (RegFile WrData)
          o_IRWrite     <= '0';
          o_IsSigned    <= '0';
          o_RegWrite    <= '1';   -- Write RegFile 
          o_JumpAndLink <= '0';
          o_RegDst      <= '0';   -- WrAdrs <- IR Bits[20:16]
          o_AluSrcA     <= '0';  
          o_AluSrcB     <= "00"; 
          o_AluOp       <= ALU_OP_ADDU;
          o_PCSrc       <= "00";  -- N/A

          -- Concludes processing -> Proceed to Fetch Next Instruction
          next_state <= IR_FETCH;

          -- ------------------------------------------------------------
          -- These instructions are exceptions for this state
          -- ------------------------------------------------------------
          -- NOTE: MFHI and LO Instruction Destination required the Write
          --       address to be Bits are [15:11] (WrAdrs <- IR Bits[15:11])
          --       The default for this state is Bits[20:16]
          if ( i_IR_Opcode  = OPCODE_RTYPE ) then 
           
            -- Select Dest Reg using IR Bits[15:11] for all R-Type Instructions 
            -- NOTE: The default is 0 which is correct for I-Type Instruction
            o_RegDst  <= '1';  

            -- For Move LO and HI Instructions need to provide the correct
            -- opcode to ALU so appropriate register is muxed out of ALU
            if ( i_IR_Func = OP0_FUNC_MFHI ) then 
              -- ALU Top will used this opcode to drive HI Reg to Muxed Output
              o_AluOp   <= ALU_OP_MFHI;
            elsif ( i_IR_Func = OP0_FUNC_MFLO ) then 
              -- ALU Top will used this opcode to drive LO Reg to Muxed Output
              o_AluOp   <= ALU_OP_MFLO;
            end if;

          elsif ( i_IR_Opcode = OPCODE_LW ) then  
            -- For LW need to select MEMORY DATA REG 
            -- Write  Register $t = MEM[$s+Offset] $t=IR Bits[20:16]
            o_MemToReg  <= '1';   

          end if; 


      -- ------------------------------------------------------------
      --                Memory Access State (LW)  
      -- ------------------------------------------------------------
      -- When this state is entered the ALU OUT bus contains valid
      -- Read Address.  Need to assert the MEM Read signal and  
      -- proceed to load the datapath MEMORY DATA REGISTER.
      when MEM_READ =>
          -- Defaults 
          o_PcWrite     <= '0';
          o_IorD        <= '1'; -- Select ALU OUT as MemAdrs versus PC
          o_MemWrite    <= '0';
          o_MemRead     <= '1'; -- Access Memory
          o_MemToReg    <= '0';
          o_IRWrite     <= '0';
          o_IsSigned    <= '0';
          o_RegWrite    <= '0';   
          o_JumpAndLink <= '0';
          o_RegDst      <= '0'; 
          o_AluSrcA     <= '0';  
          o_AluSrcB     <= "00"; 
          o_AluOp       <= ALU_OP_ADDU;
          o_PCSrc       <= "00"; 
           
          -- For LW Instruction ALU OUT = ($S + Offset)
          -- Need to access Memory at Address [$S + Offset]

          -- Proceed to Register FILE to write MEMORY DATA REG
          next_state <= REGFILE_WR;
			 
			 
			 

 -- ------------------------------------------------------------
      --                Memory WRITE State (SW)  
      -- ------------------------------------------------------------
      -- When this state is entered the ALU OUT bus contains valid
      -- WRITE Address.  Need to assert the MEM WRITE signal and  
      -- proceed to load the datapath MEMORY DATA REGISTER.
   when MEM_WRITE=>
	 -- Defaults 
          o_PcWrite     <= '0';
          o_IorD        <= '1'; -- Select ALU OUT as MemAdrs 
          o_MemWrite    <= '1'; -- Write memory
          o_MemRead     <= '0'; 
          o_MemToReg    <= '0';
          o_IRWrite     <= '0';
          o_IsSigned    <= '0';
          o_RegWrite    <= '0';   
          o_JumpAndLink <= '0';
          o_RegDst      <= '0'; 
          o_AluSrcA     <= '0';  
          o_AluSrcB     <= "00"; 
          o_AluOp       <= ALU_OP_ADDU;
          o_PCSrc       <= "00"; 
			 o_RegDst      <= '0';
	
			 next_state<= IR_FETCH;
			 
			 
      -- ------------------------------------------------------------
      --            HALT State used for Debug 
      -- ------------------------------------------------------------
      when State_OPCODE_HALT =>
          -- Defaults 
          o_PcWrite     <= '0';
          o_IorD        <= '0';
          o_MemWrite    <= '0';
          o_MemRead     <= '0';
          o_MemToReg    <= '0';
          o_IRWrite     <= '0';
          o_IsSigned    <= '0';
          o_RegWrite    <= '0';   
          o_JumpAndLink <= '0';
          o_RegDst      <= '0'; 
          o_AluSrcA     <= '0';  
          o_AluSrcB     <= "00"; 
          o_AluOp       <= ALU_OP_ADDU;
          o_PCSrc       <= "00"; 

          -- Stay in this state forever till reset
          next_state <= state_OPCODE_HALT;


      when others => null;

    end case;
  end process;
end logic;
