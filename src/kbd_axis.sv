module kbd_axis
(
	// external interface signals
    input wire kbd_code_new_i,
	input wire [DATA_WIDTH - 1:0] kbd_code_i,
	// AXI stream interface signals
	input wire axis_aclk_i,
	input wire axis_aresetn_i,
	// master axi stream interface
	input wire m_axis_tready_i,
	output wire m_axis_tvalid_o,
	output reg [DATA_WIDTH - 1:0] m_axis_tdata_o
);

	parameter int [31:0] DATA_WIDTH = 11;
    parameter int [31:0] DEBOUNCE_COUNTER_SIZE = 8;
    parameter int [31:0] CLK_FREQ = 50000000;


    ps2_keyboard #(
        .debounce_counter_size(DEBOUNCE_COUNTER_SIZE),
        .clk_freq(CLK_FREQ)
    ) ps2_keyboard
    (
        .clk(axis_aclk_i),
        .ps2_code_new(kbd_code_new_i),
        .ps2_code(kbd_code_i)
    );

	reg tvalid;
	parameter [0:0] st_idle = 0, st_data = 1;
	reg state;
	wire [DATA_WIDTH - 1:0] data;

	assign m_axis_tvalid_o = tvalid;
	assign data = switches_i;

	always @(posedge axis_aclk_i, negedge axis_aresetn_i) begin
		if (axis_aresetn_i == 1'b0) begin
			tvalid <= 1'b0;
			state <= st_idle;
		end else begin
			case (state)
			st_idle : begin
				tvalid <= 1'b1;
				if (m_axis_tready_i == 1'b1) begin
					m_axis_tdata_o <= data;
					state <= st_data;
				end
			end
			st_data : begin
				tvalid <= 1'b0;
				state <= st_idle;
			end
			endcase
		end
	end

endmodule
