//////////////////////////////////////////////////////////////////////////////////////////
//----------AUTHER : MAHMOUD ABDO HOSIN---------------------------------------------------
//----------DESCRIPTION :  Spartan6 - DSP48A1---------------------------------------------
//----------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////
module DSP48A1 #(
   parameter  A0REG =1'b0,           //default  > no register 
   parameter  A1REG =1'b1,           //default  > register
   parameter  B0REG =1'b0,           //default  > no register 
   parameter  B1REG =1'b1,           //default  > register 
   parameter  CREG  =1'b1,
   parameter  DREG  =1'b1,
   parameter  MREG =1'b1,
   parameter  PREG  =1'b1,
   parameter  CARRYINREG=1'b1,
   parameter  CARRYOUTREG=1'b1,
   parameter  OPMODEREG=1'b1,
   parameter  CARRYINSEL="OPMODE5",  // sel between OPMODE[5] or CARRYIN
   parameter  B_INPUT="DIRECT",      //sel between B or BCIN to be the output on the mux after the final B port.
   parameter  RSTTYPE="SYNC",
   parameter  w18=18,    
   parameter  w48=48,    
   parameter  w36=36,  
   parameter  w8=8,  
   parameter  w1=1
)(
	input   [w18-1:0] A,B,D,
	input   [w48-1:0] C,
	input   [w8-1:0] OPMODE,
	input   RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,
	input   clk,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,  
	output  [w18-1:0] BCOUT,                     
	output  [w48-1:0] P,PCOUT,
	output  CARRYOUTF,CARRYOUT,
	output  [w36-1:0] M 
);


//outputs of the pipline stages and muxs
	wire  [w18-1:0] A0FIN,B0FIN,B1FIN,A1FIN,DFIN;
	wire  [w48-1:0] MIN,MFIN;  
	wire  [w8-1:0]  OPMODEFIN;
	wire  [w48-1:0] CFIN;
	wire  [w48-1:0] D_A_B_CON;
	wire  CYIFIN;            //CARRY OUT OF POST SUBTRACTOR.
	wire  [w48-1:0] PCIN;    // takes PCOUT value 
	wire  CARRYIN ;          // takes carryout value
	reg   [w48-1:0] OUTX,OUTZ,POST_OUT; //outx > mux x output ,outx > mux z output
	reg   CYOIN,CYIIN ;
	reg   [w18-1:0] B1IN,PRE_OUT;
	reg   [ w18-1:0] B0;     // takes BCOUT OR DIRECT B value

assign PCIN     =PCOUT;
assign CARRYIN  =CARRYOUT;

always@(*)begin         //direct or casecade input on port B 
   if(B_INPUT == "DIRECT")begin
      B0 = B;
   end else if(B_INPUT=="CASCADE")begin
      B0=BCOUT;
   end
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////PIPLINE STAGES INSTANTIATION////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

dff_mux #(.width(w8),.RESETTYPE("SYNC")) U_OPMODE(.CLK(clk),.EN(OPMODEREG),.RST(bRSTOPMOD),.CEN(CEOPMODE),.D(OPMODE),.Q(OPMODEFIN));
dff_mux #(.width(w18),.RESETTYPE("SYNC")) U_A0(.CLK(clk),.EN(A0REG),.RST(RSTA),.CEN(CEA),.D(A),.Q(A0FIN));
dff_mux #(.width(w18),.RESETTYPE("SYNC")) U_B0(.CLK(clk),.EN(B0REG),.RST(RSTB),.CEN(CEB),.D(B0),.Q(B0FIN));
dff_mux #(.width(w48),.RESETTYPE("SYNC")) U_C(.CLK(clk),.EN(CREG),.RST(RSTC),.CEN(CEC),.D(C),.Q(CFIN));
dff_mux #(.width(w18),.RESETTYPE("SYNC")) U_D(.CLK(clk),.EN(DREG),.RST(RSTD),.CEN(CED),.D(D),.Q(DFIN));
dff_mux #(.width(w18),.RESETTYPE("SYNC")) U_A1(.CLK(clk),.EN(A1REG),.RST(RSTA),.CEN(CEA),.D(A0FIN),.Q(A1FIN));

//pre adder / subtractor
always @(*) begin      
   if (OPMODEFIN[6])begin       //perform a subtraction  operation
      PRE_OUT = DFIN-B0FIN;
   end else begin               //perform an addition operation 
      PRE_OUT = DFIN + B0FIN ; 
   end
end

//B1 input MUX 
always @(*) begin                  
   if(OPMODEFIN[4])begin          //takes pre adder / subtractor output
       B1IN = PRE_OUT;
   end else begin                 //takes from U_B0 directly
       B1IN = B0FIN;
   end
end

dff_mux #(.width(w18),.RESETTYPE("SYNC")) U_B1(.CLK(clk),.EN(B1REG),.RST(RSTB),.CEN(CEB),.D(B1IN),.Q(B1FIN));


assign  MIN = B1FIN * A1FIN;
dff_mux #(.width(w48),.RESETTYPE("SYNC")) U_M(.CLK(clk),.EN(MREG),.RST(RSTM),.CEN(CEM),.D(MIN),.Q(MFIN));

//CARRYIN pipline stage
always @(*) begin 
   if(CARRYINSEL== "OPMODE5")begin
      CYIIN = OPMODEFIN[5];
   end else if (CARRYINSEL== "CASCADE")begin
      CYIIN = CARRYIN;
   end
end

dff_mux #(.width(w1),.RESETTYPE("SYNC")) U_CYI(.CLK(clk),.EN(CARRYINREG),.RST(RSTCARRYIN),.CEN(CECARRYIN),.D(CYIIN),.Q(CYIFIN));

// MUX X 
assign D_A_B_CON = {DFIN[11:0],A1FIN,B1FIN};
always @(*) begin
   case (OPMODEFIN[1:0])
      2'b00:OUTX = 48'd0;
      2'b01:OUTX = MFIN;
      2'b10:OUTX = P;
      2'b11:OUTX = D_A_B_CON;
      default:OUTX = 48'd0; 
   endcase
end
//MUX Z
always @(*) begin
   case (OPMODEFIN[3:2])
      2'b00: OUTZ =48'd0;
      2'b01: OUTZ = PCIN;
      2'b10: OUTZ = P;
      2'b11: OUTZ = CFIN;
      default: OUTZ = 48'd0;
   endcase  
end
//post adder / subtractor operations 
always @(*) begin
   if(OPMODEFIN[7])begin
      {CYOIN,POST_OUT} = CYIFIN + OUTX + OUTZ;
   end else begin
      {CYOIN , POST_OUT} = OUTZ - (OUTX + CYIFIN);
   end
end

dff_mux #(.width(w48),.RESETTYPE("SYNC")) U_P(.CLK(clk),.EN(PREG),.RST(RSTP),.CEN(CEP),.D(POST_OUT),.Q(P));
dff_mux #(.width(w1),.RESETTYPE("SYNC")) U_CYO(.CLK(clk),.EN(CARRYOUTREG),.RST(RSTCARRYIN),.CEN(CECARRYIN),.D(CYOIN),.Q(CARRYOUT));

assign PCOUT = P;
assign CARRYOUTF = CARRYOUT;
assign BCOUT = B1FIN;
assign M =  MFIN[w48-13:0];

endmodule 


