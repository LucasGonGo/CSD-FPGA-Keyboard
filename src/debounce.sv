module debounce#(
    parameter COUNTER_SIZE = 19 // counter size (19 bits gives 10.5ms with 50MHz clock)
)(
    input wire clk,
    input wire btn_in,
    output reg btn_out
);
    logic flipflops[1:0]; // input flip-flops
    logic counter_set;      
    logic counter_out[COUNTER_SIZE:0];

    counter_set = (flipflops[0] ^ flipflops[1]); // XOR, detecta mudança no estado do botão

    always_ff @(posedge clk) begin

        flipflops[0] <= btn_in;
        flipflops[1] <= flipflops[0];

        if (counter_set) begin
            counter_out <= 0;
        end else if (!counter_out[COUNTER_SIZE]) begin // conta um certo numero de clocks
            counter_out <= counter_out + 1;
        end else begin
            btn_out <= flipflops[1];    // atualiza a saída do botão
        end
    end
endmodule