module clock_with_alarm (
input clock, reset,
input [1:0] hou1,
input [3:0] hou0,
input [3:0] min1, min0,
input loatim,
input loaala,
input stoala,
input alaon,
output reg alarm,
output [1:0] houout1,
output [3:0] houout0,
output [3:0] minout1,
output [3:0] minout0,
output [3:0] secout1,
output [3:0] secout0
);

reg onesec;
reg [3:0] temonesec;
reg [5:0] temhou, temmin, temsec;
reg [1:0] clohou1, alahou1;
reg [3:0] clohou0, alahou0;
reg [3:0] clomin1, alamin1;
reg [3:0] clomin0, alamin0;
reg [3:0] closec1;
reg [3:0] closec0;

function [3:0] mod_10;
 input [5:0] number;
 begin
    mod_10 = (number >= 50) ? 5 : ((number >= 40) ? 4 : ((number >= 30) ? 3 : ((number >= 20) ? 2 : ((number >= 10) ? 1 : 0))));
 end
endfunction

always @(posedge onesec or posedge reset) begin
    if(reset) begin
        alahou1 <= 2'b00;
        alahou0 <= 4'b0000;
        alamin1 <= 4'b0000;
        alamin0 <= 4'b0000;
        temhou <= (hou1*10 + hou0);
        temmin <= (min1*10 + min0);
        temsec <= 0;
    end 
    else begin
    if(loaala) begin
        alahou1 <= hou1;
        alahou0 <= hou0;
        alamin1 <= min1;
        alamin0 <= min0;
    end

    if(loatim) begin 
        temhou <= (hou1*10 + hou0);
        temmin <= (min1*10 + min0);
        temsec <= 0;
    end 
    else begin  
        temsec <= temsec + 1;
        if(temsec >=59) begin
            temmin <= (temmin + 1);
            temsec <= 0;
        if(temmin >=59) begin
            temmin <= 0;
            temhou <= (temhou + 1);
        if(temhou >= 24) begin
            temhou <= 0;
        end
        end 
        end
    end 
    end 
end 
 
 always @(posedge clock or posedge reset) begin
    if(reset) begin
        temonesec <= 0;
        onesec <= 0;
    end
    else begin
        temonesec <= (temonesec + 1);
        if(temonesec <= 5) 
            onesec <= 0;
        else if (temonesec >= 10) begin
            onesec <= 1;
            temonesec <= 1;
        end
        else
            onesec <= 1;
    end
 end

 always @(*) begin
    if(temhou>=20) begin
        clohou1 = 2;
    end
    else begin
        if(temhou >= 10) 
            clohou1  = 1;
        else
            clohou1 = 0;
    end
    clohou0  = (temhou - (clohou1 * 10)); 
    clomin1 = mod_10(temmin); 
    clomin0 = (temmin - (clomin1 * 10));
    closec1 = mod_10(temsec);
    closec0 = (temsec - (closec1 * 10)); 
 end


always @(posedge onesec or posedge reset) begin
 if(reset) 
    alarm <=0; 
 else begin
    if({alahou1, alahou0, alamin1, alamin0} == {clohou1, clohou0, clomin1, clomin0}) begin
        if(alaon) 
            alarm <= 1; 
    end
    if(stoala) 
        alarm <=0;
 end
end


 assign houout1 = clohou1; 
 assign houout0 = clohou0;  
 assign minout1 = clomin1; 
 assign minout0 = clomin0; 
 assign secout1 = closec1;
 assign secout0 = closec0;

endmodule

module Clock_With_Alarm_Test_Bench;

 reg clock, reset;
 reg [1:0] hou1;
 reg [3:0] hou0;
 reg [3:0] min1, min0;
 reg loatim, loaala, stoala, alaon;

 // Outputs
 wire alarm;
 wire [1:0] houout1;
 wire [3:0] houout0;
 wire [3:0] minout1, minout0;
 wire [3:0] secout1, secout0;

 
 clock_with_alarm uut (
 .reset(reset), 
 .clock(clock), 
 .hou1(hou1), 
 .hou0(hou0), 
 .min1(min1), 
 .min0(min0), 
 .loatim(loatim), 
 .loaala(loaala), 
 .stoala(stoala), 
 .alaon(alaon), 
 .alarm(alarm), 
 .houout1(houout1), 
 .houout0(houout0), 
 .minout1(minout1), 
 .minout0(minout0), 
 .secout1(secout1), 
 .secout0(secout0)
 );

 initial begin 
  clock = 0;
  forever #50 clock = ~clock;
 end
 initial begin
 // Initialize Inputs
 reset = 1;
 hou1 = 0;
 hou0 = 7;
 min1 = 3;
 min0 = 0;
 loatim = 0;
 loaala = 0;
 stoala = 0;
 alaon = 0;

 #100;
 reset = 0;
 hou1 = 0;
 hou0 = 7;
 min1 = 3;
 min0 = 0;
 loatim = 0;
 loaala = 1;
 stoala = 0;
 alaon = 1; 
 

#100;
 reset = 0;
 hou1 = 0;
 hou0 = 7;
 min1 = 3;
 min0 = 0;
 loatim = 0;
 loaala = 0;
 stoala = 0;
 alaon = 1;

wait(alarm);
#100;
#100;
#100;
#100;
#100;
#100;
stoala = 1;

 
end
endmodule