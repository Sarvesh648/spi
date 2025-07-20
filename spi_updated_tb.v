`timescale 1ns / 1ps

module spi_updated_tb;

    reg clk = 0;
    reg rst = 1;
    reg [15:0] din;
    reg [1:0] spi_mode;
    reg [1:0] slave_sel;
    wire [15:0] dout;
    wire [3:0] ss;
    wire sclk;
    wire mosi;
    reg miso;
    wire [4:0] counter;

    parameter N = 4;
    reg [15:0] miso_data = 16'hCAFE;

    spi_updated #(N) uut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .dout(dout),
        .spi_mode(spi_mode),
        .slave_sel(slave_sel),
        .ss(ss),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .counter(counter)
    );

    always #5 clk = ~clk; // 100 MHz clock

    initial begin
        #10 rst = 0;
        spi_mode = 2'b00;      // CPOL=0, CPHA=0
        slave_sel = 2'd1;
        din = 16'h1234;

        wait(counter < 16);  // wait till transmission starts

        repeat (16) begin
            @(negedge sclk);  // SPI mode 0: sample on leading edge
            miso = miso_data[counter];  // MSB first
        end

        #100;
        $display("Received: %h, Expected: %h", dout, miso_data);
        $stop;
    end

endmodule
