`define INITIAL 3'b000
`define DEPOSIT 3'b001
`define BUY 3'b010
`define CHANGE 3'b011
`define RETURN 3'b100
module lab05(clk,rst,money_5,money_10,cancel,drink_A,drink_B,drop_money,enough_A,enough_B,DIGIT,DISPLAY);
    input clk;
    input rst;
    input money_5;
    input money_10;
    input cancel;
    input drink_A;
    input drink_B;
    output reg [9:0] drop_money;
    output reg enough_A;
    output reg enough_B;
    output [3:0]DIGIT;
    output [6:0]DISPLAY;

    wire clk16;
    wire clk26;
    wire clk13;
    wire clk_;
    wire money_5_de;
    wire money_5_pul;
    wire money_10_de;
    wire money_10_pul;
    wire drink_A_de;
    wire drink_A_pul;
    wire drink_B_de;
    wire drink_B_pul;
    wire cancel_de;
    wire cancel_pul;

    reg [3:0]BCD0;
    reg [3:0]BCD1;
    reg [3:0]BCD2;
    reg [3:0]BCD3;
    reg [3:0]nextBCD0;
    reg [3:0]nextBCD1;
    reg [3:0]nextBCD2;
    reg [3:0]nextBCD3;
    reg [6:0]display;
    reg [3:0]digit;
    reg [3:0]val;
    reg [1:0]state;
    reg [1:0]nextstate;
    reg [3:0]moneydigit;
    reg [3:0]moneyten;
    reg [3:0]nextmoneydigit;
    reg [3:0]nextmoneyten;
    reg countA;
    reg nextcountA;
    reg countB;
    reg nextcountB;
    reg DetoBuy;
    reg DetoChange;
    reg cofe;
    reg nextcofe;
    reg coke;
    reg nextcoke;
    reg iscancel;
    reg nextiscancel;
    reg [9:0]nextdrop_money;
    reg [3:0]tmpBCD0;
    reg [3:0]tmpBCD1;
    reg [3:0]nexttmpBCD0;
    reg [3:0]nexttmpBCD1;
    reg buyflag;
    reg nextbuyflag;

    clk_divider #(16)clk1 (.clk(clk),.clk_div(clk16));
    clk_divider #(26)clk2 (.clk(clk),.clk_div(clk26));
    clk_divider #(13)clk3 (.clk(clk),.clk_div(clk13));

    debounce de1(.pb_debounced(money_5_de),.pb(money_5),.clk(clk16));
    onepulse on1(.clk(clk16),.pb_debounced(money_5_de),.pb_1pulse(money_5_pul));

    debounce de2(.pb_debounced(money_10_de),.pb(money_10),.clk(clk16));
    onepulse on2(.clk(clk16),.pb_debounced(money_10_de),.pb_1pulse(money_10_pul));

    debounce de3(.pb_debounced(drink_A_de),.pb(drink_A),.clk(clk16));
    onepulse on3(.clk(clk16),.pb_debounced(drink_A_de),.pb_1pulse(drink_A_pul));

    debounce de4(.pb_debounced(drink_B_de),.pb(drink_B),.clk(clk16));
    onepulse on4(.clk(clk16),.pb_debounced(drink_B_de),.pb_1pulse(drink_B_pul));

    debounce de5(.pb_debounced(cancel_de),.pb(cancel),.clk(clk16));
    onepulse on5(.clk(clk16),.pb_debounced(cancel_de),.pb_1pulse(cancel_pul));

    always@(*)
    
        begin
            if(rst==1'b1) begin nextBCD0=4'b0000; nextBCD1=4'b0000; nextBCD2=4'b0000; nextBCD3=4'b0000; nextstate=`INITIAL;
            enough_A=1'b0;enough_B=1'b0;DetoBuy=1'b0; DetoChange=1'b0;nextdrop_money=10'b0000000000; nextbuyflag=1'b0;
            nextcountA=1'b0;nextcountB=1'b0; nextcofe=1'b0; nextcoke=1'b0; nextiscancel=1'b0; end
            case(state)
                `INITIAL:begin
                    nextstate=`DEPOSIT;
                    nextBCD0=4'b0000;
                    nextBCD1=4'b0000;
                    nextBCD2=4'b0000;
                    nextBCD3=4'b0000;
                    nextdrop_money=10'b0000000000;
                    enough_A=1'b0;
                    enough_B=1'b0;
                    DetoBuy=1'b0;
                    DetoChange=1'b0;
                    nextbuyflag=1'b0;
                end
                `DEPOSIT:begin
                    nextbuyflag=1'b0;
                    nexttmpBCD0=BCD0; nexttmpBCD1=BCD1;
                    if(BCD1>=4'b0010) begin enough_A=1'b1; end
                    else begin enough_A=1'b0; end

                    if((BCD1==4'b0010 && BCD0==4'b0101)||(BCD1>4'b0010)) begin enough_B=1'b1; end
                    else begin enough_B=1'b0; end

                    if(money_5_pul==1'b1)
                        begin
                            if(BCD1==4'b1001 && BCD0==4'b0101) begin nextBCD1=BCD1; nextBCD0=BCD0; end
                            else if(BCD1!=4'b1001 && BCD0==4'b0101) begin nextBCD1=BCD1+4'b0001; nextBCD0=4'b0000; end
                            else begin nextBCD1=BCD1; nextBCD0=BCD0+4'b0101; end
                            nextBCD2=BCD2;
                            nextBCD3=BCD3;
                            nextcountA=countA;
                            nextcountB=countB;
                        end
                    else if(money_10_pul==1'b1)
                        begin
                            if((BCD1==4'b1001 && BCD0==4'b0101)||(BCD1==4'b1001 && BCD0==4'b0000))
                                begin
                                    nextBCD1=BCD1; nextBCD0=BCD0;
                                end
                            else begin nextBCD1=BCD1+4'b0001; nextBCD0=BCD0; end
                            nextBCD3=BCD3;nextBCD2=BCD2;
                            nextcountA=countA;
                            nextcountB=countB;
                        end
                    else if(drink_A_pul==1'b1)
                        begin
                            DetoChange=1'b0;
                            nextcountA=countA+1'b1;
                            nextcountB=4'b0000;
                            if(countA==1'b1&&enough_A==1'b1) 
                            begin 
                                DetoBuy=1'b1; nextcoke=1'b1; nextcofe=1'b0;
                                nextBCD3=BCD3; nextBCD2=BCD2; nextBCD1=BCD1; nextBCD0=BCD0;
                                //nexttmpBCD0=tmpBCD0; nexttmpBCD1=tmpBCD1;
                            end
                            else begin DetoBuy=1'b0;  nextBCD3=4'b0010; nextBCD2=4'b0000; nextBCD1=BCD1; nextBCD0=BCD0; end
                            
            
                        end
                    else if(drink_B_pul==1'b1)
                        begin
                            DetoChange=1'b0;
                            nextcountB=countB+1'b1;
                            nextcountA=4'b0000;
                            if(countB==1'b1&&enough_B==1'b1) 
                            begin 
                                DetoBuy=1'b1; nextcoke=1'b0; nextcofe=1'b1; 
                                nextBCD3=BCD3; nextBCD2=BCD2; nextBCD1=BCD1; nextBCD0=BCD0;
                                //nexttmpBCD0=tmpBCD0; nexttmpBCD1=tmpBCD1;
                            end
                            else begin DetoBuy=1'b0; nextBCD3=4'b0010; nextBCD2=4'b0101; nextBCD1=BCD1; nextBCD0=BCD0;end
                            
    
                        end
                    else if(cancel_pul==1'b1&&(BCD0|BCD1)!=4'b0000) 
                        begin
                            DetoChange=1'b1;
                            DetoBuy=1'b0;
                            nextBCD0<=BCD0;
                            nextBCD1<=BCD1;
                            nextBCD2<=4'b0000;
                            nextBCD3<=4'b0000;
                        end
                    else if((cancel_pul==1'b1)&&((BCD0|BCD1)==4'b0000)&&((BCD2|BCD3)!=4'b0000))
                        begin
                            DetoChange=1'b0;
                            DetoBuy=1'b0;
                            nextBCD0<=BCD0;
                            nextBCD1<=BCD1;
                            nextBCD2<=4'b0000;
                            nextBCD3<=4'b0000;
                        end
                   else
                        begin
                            nextcountA<=countA;
                            nextcountB<=countB;
                            nextBCD0<=BCD0;
                            nextBCD1<=BCD1;
                            nextBCD2<=BCD2;
                            nextBCD3<=BCD3;
                            nextcofe<=1'b0;
                            nextcoke<=1'b0;
                        end
                    nextstate=(DetoBuy==1'b1)?`BUY:(DetoChange==1'b1)?`CHANGE:`DEPOSIT;
                end
                `BUY:begin
                    nextstate=`CHANGE;
                    if(BCD2==4'b0101&&BCD0==4'b0000) begin  nexttmpBCD0=4'b0101; nexttmpBCD1=BCD1-4'b0011; end
                    else begin nexttmpBCD0=BCD0-BCD2; nexttmpBCD1=BCD1-BCD3; end
                    nextbuyflag=1'b1;
                    if(coke==1'b1)begin nextBCD3=4'b1010; nextBCD2=4'b1011; nextBCD1=4'b1110; nextBCD0=4'b1101; end
                    else if(cofe==1'b1) begin nextBCD3=4'b1010; nextBCD2=4'b1011; nextBCD1=4'b1100; nextBCD0=4'b1101; end
                end
                `CHANGE:begin
                    enough_A=1'b0; 
                    enough_B=1'b0;
                    nexttmpBCD0=tmpBCD0;
                    nexttmpBCD1=tmpBCD1;
                    if(buyflag==1'b1)
                        begin
                            nextstate=`CHANGE;
                            nextbuyflag=1'b0;
                            nextBCD3=4'b0000; nextBCD2=4'b0000; nextBCD1=tmpBCD1; nextBCD0=tmpBCD0;
                            if(tmpBCD0==4'b0000&&tmpBCD1==4'b0000) begin nextstate=`INITIAL; end
                            else begin nextstate=`CHANGE; end
                        end
                    else
                        begin
                            if(BCD0==4'b0000&&BCD1==4'b0000) 
                                begin 
                                    nextstate=`INITIAL; 
                                    nextBCD0=BCD0; 
                                    nextBCD1=BCD1; 
                                    nextBCD2=4'b0000; 
                                    nextBCD3=4'b0000; 
                                    nextdrop_money=10'b1111100000;
                                end
                            else if(BCD1!=4'b0000)
                                begin
                                    nextstate=`CHANGE;
                                    nextBCD0=BCD0;
                                    nextBCD1=BCD1-4'b0001;
                                    nextBCD2=4'b0000;
                                    nextBCD3=4'b0000;
                                    nextdrop_money=10'b1111111111;
                                end
                            else if(BCD1==4'b0000&&BCD0!=4'b0000)
                                begin 
                                    nextstate=`CHANGE;
                                    nextBCD0=BCD0-4'b0101;
                                    nextBCD1=4'b0000;
                                    nextBCD2=4'b0000;
                                    nextBCD3=4'b0000;
                                    nextdrop_money=10'b1111100000;
                                end
                        end
                    
                    
                    
                end
            endcase

            case(val)
                4'b0000:begin display=7'b0000001; end
                4'b0001:begin display=7'b1001111; end
                4'b0010:begin display=7'b0010010; end
                4'b0011:begin display=7'b0000110; end
                4'b0100:begin display=7'b1001100; end
                4'b0101:begin display=7'b0100100; end
                4'b0110:begin display=7'b0100000; end
                4'b0111:begin display=7'b0001111; end
                4'b1000:begin display=7'b0000000; end
                4'b1001:begin display=7'b0000100; end
                4'b1010:begin display=7'b1110010; end //c=10
                4'b1011:begin display=7'b1100010; end //o=11
                4'b1100:begin display=7'b0111000; end //f=12
                4'b1101:begin display=7'b0110000; end //e=13
                4'b1110:begin display=7'b0101000; end //k=14
                default: begin display=7'b0000001; end
            endcase
        end
    always@(posedge clk_,posedge rst)
        begin
            if(rst==1'b1)
                begin
                    BCD0<=4'b0000;
                    BCD1<=4'b0000;
                    BCD2<=4'b0000;
                    BCD3<=4'b0000;
                    state<=`INITIAL;
                    countA<=1'b0;
                    countB<=1'b0;
                end
            else
                begin
                    BCD0<=nextBCD0;
                    BCD1<=nextBCD1;
                    BCD2<=nextBCD2;
                    BCD3<=nextBCD3;
                    tmpBCD0<=nexttmpBCD0;
                    tmpBCD1<=nexttmpBCD1;
                    countA<=nextcountA;
                    countB<=nextcountB;
                    cofe<=nextcofe;
                    coke<=nextcoke;
                    state<=nextstate;
                    drop_money<=nextdrop_money;
                    buyflag<=nextbuyflag;

                end
    
        end
    /*always@(posedge clk13) //update FSM
            begin
                lastpushA<=pushA;
                lastpushB<=pushB;
            end      */
    always@(posedge clk13)
            begin
                case(digit)
                    4'b1110: begin val=BCD1; digit=4'b1101; end
                    4'b1101: begin val=BCD2; digit=4'b1011; end
                    4'b1011: begin val=BCD3; digit=4'b0111; end
                    4'b0111: begin val=BCD0; digit=4'b1110; end
                    default: begin val=BCD0; digit=4'b1110; end 
                endcase
            end
    assign DISPLAY=display;
    assign DIGIT=digit;
    assign clk_=(state==`INITIAL)?clk16:(state==`DEPOSIT)?clk16:(state==`BUY)?clk26:clk26;

endmodule
module clk_divider(clk,clk_div);
    parameter n=4;
    input clk;
    output clk_div;
    reg [n-1:0]num;
    wire [n-1:0]nextnum;
    always@(posedge clk)
        begin
            num=nextnum;
        end
    assign nextnum=num+1;
    assign clk_div=num[n-1];
endmodule
module debounce(pb_debounced,pb,clk);
    output pb_debounced;
    input pb;
    input clk;  

    reg[3:0] shift_reg;
    always@(posedge clk)
        begin
            shift_reg[3:1]<=shift_reg[2:0];
            shift_reg[0]<=pb;
        end
    assign pb_debounced=((shift_reg==4'b1111)?1'b1:1'b0);
endmodule
module onepulse(pb_debounced,clk,pb_1pulse);
    input pb_debounced;
    input clk;
    output pb_1pulse;
    reg pb_1pulse;
    reg pb_debounced_delay;
    always@(posedge clk)
        begin
            if(pb_debounced==1'b1 & pb_debounced_delay==1'b0)
                begin
                    pb_1pulse<=1'b1;
                end
            else 
                begin
                    pb_1pulse<=1'b0;
                end
            pb_debounced_delay<=pb_debounced;
        end
endmodule




