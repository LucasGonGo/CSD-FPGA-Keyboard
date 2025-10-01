module ps2_keyboard#(
    parameter clk_freq = 50000000,
    parameter debounce_counter_size = 8 // counter size for debounce module
)(
    input wire clk,
    input wire ps2_clk,
    input wire ps2_data,
    output wire ps2_code_new,
    output reg [7:0] ps2_code
)   
    
    localparam MAX_COUNT_IDLE = clk_freq / 18000; // 100ms timeout for idle state  
    localparam MAX_COUNT_IDLE_SIZE = $clog2(MAX_COUNT_IDLE+1); // $clog2 calcula quantos bits precisa pra representar o valor

    logic sync_ffs[1:0];
    logic ps2_clk_int, ps2_data_int;
    logic ps2_word[10:0];
    logic error;
    logic [MAX_COUNT_IDLE_SIZE-1:0] count_idle;

   

    always_ff @(posedge clk) begin
        sync_ffs[0] <= ps2_clk;
        sync_ffs[1] <= ps2_data;
    end

    debounce debounce_ps2_clk#(
        .COUNTER_SIZE(debounce_counter_size)
    ) (
        .clk(clk),
        .btn_in(sync_ffs[0]),
        .btn_out(ps2_clk_int)
    );

    debounce debounce_ps2_data#(
        .COUNTER_SIZE(debounce_counter_size)
    ) (
        .clk(clk),
        .btn_in(sync_ffs[1]),
        .btn_out(ps2_data_int)
    );

    always_ff @(negedge ps2_clk_int) begin
        ps2_word <= {ps2_data_int, ps2_word[10:1]};
    end

    assign error = !(!ps2_word[0] && ps2_word[10] && (ps2_word[9] ^ ps2_word[8] ^ ps2_word[7] ^ ps2_word[6] ^ ps2_word[5] ^ ps2_word[4] ^ ps2_word[3] ^ ps2_word[2] ^ ps2_word[1]));

    always_ff @(posedge clk) begin

        if (!ps2_clk_int) begin 
            count_idle <= 0;
        end else if (count_idle != MAX_COUNT_IDLE) begin
            count_idle <= count_idle + 1;
        end

        if(count_idle == MAX_COUNT_IDLE && !error) begin
            ps2_code_new <= 1;
            ps2_code <= ps2_word[8:1];
        end else begin
            ps2_code_new <= 0; 
        end
    end
 
endmodule