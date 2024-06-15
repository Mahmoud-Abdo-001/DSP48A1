//////////////////////////////////////////////////////////////////////////
//-----------AUTHER : MAHMOUD ABDOU HOSIN
//-----------DESCRITPION : SPARTAN 6 DSP48A1 PIPLINE STAGE (DFF & MUX)
//------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////
module dff_mux #(
    parameter width = 18,
    parameter RESETTYPE = "SYNC"
)(
    input CLK, EN , RST, CEN,                       // CEN for clock enable 
    input [width-1:0] D,                           // DFF input 
    output reg [width-1:0] Q                       // DFF output
);

always @(*) begin
    if (!EN) begin
        Q = D;
    end
end

generate
    if (RESETTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RST) begin
            if (RST) begin
                Q <= 0;
            end else if (EN && CEN) begin
                Q <= D;
            end
        end
    end else if (RESETTYPE == "SYNC") begin
        always @(posedge CLK) begin
            if (RST) begin
                Q <= 0;
            end else if (EN && CEN) begin
                Q <= D;
            end
        end
    end
endgenerate

endmodule