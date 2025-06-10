module receiver (
    input wire clk,
    input wire rstn,
    input wire serial_in,
    output reg [6:0] data_out,
    output reg parity_ok_n,
    output reg ready
);
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg receiving;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_cnt <= 0;
            receiving <= 0;
            shift_reg <= 0;
            data_out <= 0;
            parity_ok_n <= 1;
            ready <= 0;
        end else begin
            ready <= 0; // só fica alto por um ciclo

            if (!receiving && serial_in == 0) begin
                receiving <= 1; // detecta start bit
                bit_cnt <= 0;
            end else  begin
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt < 8)
                    shift_reg <= {serial_in, shift_reg[7:1]};

            
                if (bit_cnt == 8) begin
                    receiving <= 0;
                    data_out <= shift_reg[6:0];
                        parity_ok_n <= ^{shift_reg[7:0]}; // paridade ok → 0
                    ready <= 1;
                end
            end
        end
    end
endmodule
