module transmitter (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire [6:0] data_in,
    output reg serial_out
);
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sending;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_cnt <= 0;
            sending <= 0;
            serial_out <= 1; // idle
        end else begin
            if (start && !sending) begin
                // inicia com start bit (0)
                serial_out <= 0;
                sending <= 1;
                bit_cnt <= 0;

                // calcula bit de paridade par e monta o shift register
                shift_reg <= {
                    ^data_in,  // bit de paridade
                    data_in    // dados (7 bits)
                };
            end else if (sending) begin
                bit_cnt <= bit_cnt + 1;
                case (bit_cnt)
                    0: serial_out <= shift_reg[0];
                    1: serial_out <= shift_reg[1];
                    2: serial_out <= shift_reg[2];
                    3: serial_out <= shift_reg[3];
                    4: serial_out <= shift_reg[4];
                    5: serial_out <= shift_reg[5];
                    6: serial_out <= shift_reg[6];
                    7: serial_out <= shift_reg[7];
                    8: serial_out <= 1; // stop bit
                    default: begin
                        serial_out <= 1;
                        sending <= 0; // fim da transmissão
                    end
                endcase
            end
        end
    end
endmodule
