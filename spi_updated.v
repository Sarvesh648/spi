`timescale 1ns / 1ps
module spi_updated #(parameter N = 4)(
    input wire clk,
    input wire rst,
    input wire [15:0] din,
    output wire [15:0] dout,
    input wire [1:0] spi_mode,
    input wire [1:0] slave_sel,
    output reg [N-1:0] ss,
    output reg sclk,
    output wire mosi,
    input wire miso,
    output wire [4:0] counter
);

    reg [15:0] MOSI;
    reg [15:0] MISO;
    reg [4:0] count;
    reg [2:0] state;

    wire CPOL = spi_mode[1];  // Clock polarity
    wire CPHA = spi_mode[0];  // Clock phase

    reg sclk_gen;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            MOSI <= 0;
            MISO <= 0;
            count <= 5'd15;
            ss <= {N{1'b1}};
            sclk_gen <= CPOL;
            sclk <= CPOL;
            state <= 0;
        end else begin
            case (state)
                3'd0: begin
                    ss <= {N{1'b1}};  
                    sclk <= CPOL;
                    state <= 3'd1;
                end
                3'd1: begin
                    ss[slave_sel] <= 1'b0;   
                    MOSI <= din;
                    MISO <= 0;
                    count <= 5'd15;
                    sclk_gen <= CPOL;
                    sclk <= CPOL;
                    state <= CPHA ? 3'd3 : 3'd2;
                end
                3'd2: begin
                    sclk_gen <= ~CPOL;
                    sclk <= sclk_gen;
                    state <= 3'd3;
                end
                3'd3: begin
                    sclk_gen <= ~sclk_gen;
                    sclk <= sclk_gen;

                    if (sclk_gen == ~CPOL) begin  // Sample on active edge
                        MISO[count] <= miso;
                        if (count > 0)
                            count <= count - 1;
                        else
                            state <= 3'd4;
                    end
                end
                3'd4: begin
                    ss <= {N{1'b1}};
                    sclk <= CPOL;
                    state <= 3'd0;
                end
            endcase
        end
    end

    assign mosi = MOSI[count];
    assign dout = MISO;
    assign counter = count;

endmodule
