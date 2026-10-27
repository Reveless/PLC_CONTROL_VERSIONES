module FS_machine(
iclk,
ireset,
iVAL_CC,
iINSTR37_32,
oINC_PC,
oWR_CC_en,
oWR_CC_en_sig,
oWR_W,
oWR_b,
oexe,
odec,
oWR_PC
);


input iclk, ireset;
input [5:0]iINSTR37_32;
input [2:0] iVAL_CC;
output oINC_PC,oWR_W, oWR_b,oWR_PC; 
output  oWR_CC_en, oWR_CC_en_sig , oexe, odec;

//==============================================================
// FSM states
//==============================================================

parameter initialization    = 2'b00;
parameter Instruction_fetch = 2'b01;
parameter Decoding          = 2'b10;
parameter Execution         = 2'b11;

//==============================================================
// State registers
//==============================================================
reg [1:0] state;
reg [1:0] next_state;

//==============================================================
// 1. STATE REGISTER
//==============================================================

	always @( posedge ireset or posedge iclk) 
		begin
			if( ireset) state <= initialization; 
			else state <= next_state;
		end

//==============================================================
// 2. NEXT-STATE LOGIC
//==============================================================
	
	always @(*)begin
		case(state)
			initialization: 
			begin
				next_state= Decoding;
			end
			
			Decoding: 
			begin
				next_state = Execution;
			end
			
			Execution: 
			begin
				if (iVAL_CC != 3'd0 ) 
					next_state = Execution;
				else 
					next_state = Instruction_fetch;
			end
			
			Instruction_fetch: 
			begin
				next_state = Decoding;
			end
			
			default: begin
               			next_state = initialization;
            		end
		endcase
	
	end

//==============================================================
// Instruction classification
//==============================================================

wire bit_result;

assign bit_result =
    (iINSTR37_32 == 6'b111001) ||  // Greater-than word comparison, bit result
    (iINSTR37_32 == 6'b111010) ||  // Equal word comparison, bit result
    (iINSTR37_32 == 6'b111011) ||  // Less-than word comparison, bit result
    (iINSTR37_32 == 6'b101110);    // Greater-than FPU comparison, bit result
//==============================================================
// Control outputs
//==============================================================
	
//==============================================================
// Program Counter write enable.
// Asserted during the Decoding state only for the jump
// instruction (opcode 111101), allowing the PC to load
// the branch/jump destination address.
//==============================================================
assign oWR_PC = (state == Decoding) && (iINSTR37_32 == 6'b111101); // Revised August 7th 2026
//==============================================================
// Command Counter write enable.
// Asserted during the Decoding state to enable the command
// counter operation associated with the current instruction.
//==============================================================
assign oWR_CC_en = (state == Decoding); // Revised August 7th 2026
//==============================================================
// Command Counter synchronization/write signal.
// Asserted during the Instruction_fetch state after the
// execution phase has completed, indicating the end of the
// current instruction cycle.
//==============================================================
assign oWR_CC_en_sig = (state == Instruction_fetch); // Revised August 7th 2026
//==============================================================
// Program Counter increment enable.
// Asserted during the Instruction_fetch state to advance
// the program counter to the address of the next instruction.
//==============================================================
assign oINC_PC = (state == Instruction_fetch); // Revised August 7th 2026
//==============================================================
// Allows to wire the command counter,
// and the memory pointer process.
assign oWR_W = (state == Instruction_fetch) && (!bit_result) && (iINSTR37_32[5] == 1'b1); // Revised August 7th 2026
assign oWR_b = (state == Instruction_fetch) && (bit_result || (iINSTR37_32[5] == 1'b0)); // Revised August 7th 2026
//==============================================================

//==============================================================
// state machine Execution state indicator.
//==============================================================
assign oexe = (state == Execution); // Revised Agost 7th 2026
//==============================================================
// FS decodification state indicator.
//==============================================================
assign odec = (state == Decoding); // Revised Agost 7th 2026



endmodule