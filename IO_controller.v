module IO_controller(iRESET, iCLK, iQ0_X, iI0_X, oQ0_X, oI0_X);

	input iRESET;
	input iCLK;
	input [7:0]iQ0_X;
	input [7:0] iI0_X;
		
	output reg [7:0] oQ0_X;
	output reg [7:0] oI0_X;
	


	
	reg [11:0]oAI0_X_register[7:0];
	
	reg [2:0]incremento; //reg [2:0]incremento=3'b000; Edited Agous 27 2025

	
	
	always @(posedge iCLK)
	begin	
		oQ0_X <= iQ0_X;
		oI0_X <= iI0_X;
	end
	
 
endmodule