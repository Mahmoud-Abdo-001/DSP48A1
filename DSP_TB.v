module DSP48A1_TB(); // Using all as default, because it's just for check operation 
   parameter  A0REG =1'b0;            
   parameter  A1REG =1'b1;           
   parameter  B0REG =1'b0;            
   parameter  B1REG =1'b1;          
   parameter  CREG  =1'b1;
   parameter  DREG  =1'b1;
   parameter  MREG =1'b1;
   parameter  PREG  =1'b1;
   parameter  CARRYINREG=1'b1;
   parameter  CARRYOUTREG=1'b1;
   parameter  OPMODEREG=1'b1;
   parameter  CARRYINSEL="OPMODE5";  
   parameter  B_INPUT="DIRECT";   
   parameter  RSTTYPE="SYNC";
   parameter  w18=18;    
   parameter  w48=48;    
   parameter  w36=36;  
   parameter  w8=8;  
   parameter  w1=1;

    reg [w18-1:0] A,B,D;
    reg [w48-1:0] C;
    reg [w8-1:0] OPMODE;
    reg   RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE;
    reg   clk,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;  
    wire  [w18-1:0] BCOUT;                    
    wire  [w48-1:0] P,PCOUT;
    wire  CARRYOUTF,CARRYOUT;
    wire  [w36-1:0] M ;

DSP48A1 #(
    .A0REG(A0REG),
    .A1REG(A1REG),
    .B0REG(B0REG),
    .B1REG(B1REG),
    .CREG(CREG),
    .DREG(DREG),
    .MREG(MREG),
    .PREG(PREG),
    .CARRYOUTREG(CARRYOUTREG),
    .B_INPUT(B_INPUT),
    .RSTTYPE(RSTTYPE),
    .w18(w18),
    .w48(w48),
    .w36(w36),
    .w1(w1)
    ) 
     DUT(
        .A(A),
        .B(B),
        .C(C),
		.D(D),
        .OPMODE(OPMODE),
        .RSTA(RSTA),
        .RSTB(RSTB),
        .RSTC(RSTC),
        .RSTM(RSTM),
        .RSTD(RSTD),
        .RSTP(RSTP),
        .RSTCARRYIN(RSTCARRYIN),
        .RSTOPMODE(RSTOPMODE),
        .clk(clk),
        .CEA(CEA),
        .CEB(CEB),
        .CEM(CEM),
        .CEP(CEP),
        .CEC(CEC),
        .CED(CED),
        .CECARRYIN(CECARRYIN),
        .CEOPMODE(CEOPMODE),
		.BCOUT(BCOUT),
		.P(P),
		.PCOUT(PCOUT),
		.CARRYOUTF(CARRYOUTF),
		.CARRYOUT(CARRYOUT),
		.M (M )
        );

initial begin
    clk=0;
	forever
    #5 clk=~clk;
end

initial begin
    RSTA=0;
    RSTB=0;
    RSTM=0;
    RSTP=0;
    RSTC=0;
    RSTD=0;
    RSTCARRYIN=0;
    RSTOPMODE=0;
    CEA=1;
    CEB=1;
    CEM=1;
    CEP=1;
    CEC=1;
    CED=1;
    CECARRYIN=1;
    CEOPMODE=1;
end
initial begin
    repeat(1000)begin
        A=$random;
        B=$random;
        C=$random;
        D=$random;
        OPMODE=$random;
        #5;
    end
    $stop;
end
endmodule 
