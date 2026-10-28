
module sps30_cmd_controller (
    input  wire clk,
    input  wire rst,
    output wire uart_tx
);

    reg [7:0] data;
    reg start;
    wire busy;

    uart_tx u_tx (
        .clk(clk),
        .data(data),
        .start(start),
        .tx(uart_tx),
        .busy(busy)
    );

    reg [7:0] start_cmd [0:7];
    initial begin
        start_cmd[0]=8'h7E; start_cmd[1]=8'h00;
        start_cmd[2]=8'h00; start_cmd[3]=8'h02;
        start_cmd[4]=8'h01; start_cmd[5]=8'h05;
        start_cmd[6]=8'hF7; start_cmd[7]=8'h7E;
    end

    reg [7:0] read_cmd [0:5];
    initial begin
        read_cmd[0]=8'h7E; read_cmd[1]=8'h00;
        read_cmd[2]=8'h03; read_cmd[3]=8'h00;
        read_cmd[4]=8'hFC; read_cmd[5]=8'h7E;
    end

    parameter WAIT_CYCLES = 100_000_000;
    parameter READ_CYCLES = 100_000_000;

    reg [26:0] wait_cnt = 0;
    reg [3:0] byte_idx = 0;

    parameter WAIT       = 3'd0;
    parameter SEND_START = 3'd1;
    parameter WAIT_FAN   = 3'd2;
    parameter SEND_READ  = 3'd3;
    parameter WAIT_READ  = 3'd4;

    reg [2:0] state = WAIT;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= WAIT;
            wait_cnt <= 0;
            byte_idx <= 0;
            start <= 0;
            data <= 0;
        end else begin
            start <= 0;
            case(state)
                WAIT: begin
                    if(wait_cnt == WAIT_CYCLES-1) begin
                        wait_cnt <= 0;
                        byte_idx <= 0;
                        state <= SEND_START;
                    end else wait_cnt <= wait_cnt + 1;
                end

                SEND_START: begin
                    if(byte_idx < 8) begin
                        if(!busy && !start) begin
                            data <= start_cmd[byte_idx];
                            start <= 1;
                            byte_idx <= byte_idx + 1;
                        end
                    end else begin
                        wait_cnt <= 0;
                        byte_idx <= 0;
                        state <= WAIT_FAN;
                    end
                end

                WAIT_FAN: begin
                    if(wait_cnt == WAIT_CYCLES-1) begin
                        wait_cnt <= 0;
                        byte_idx <= 0;
                        state <= SEND_READ;
                    end else wait_cnt <= wait_cnt + 1;
                end

                SEND_READ: begin
                    if(byte_idx < 6) begin
                        if(!busy && !start) begin
                            data <= read_cmd[byte_idx];
                            start <= 1;
                            byte_idx <= byte_idx + 1;
                        end
                    end else begin
                        wait_cnt <= 0;
                        byte_idx <= 0;
                        state <= WAIT_READ;
                    end
                end

                WAIT_READ: begin
                    if(wait_cnt == READ_CYCLES-1) begin
                        wait_cnt <= 0;
                        byte_idx <= 0;
                        state <= SEND_READ;
                    end else wait_cnt <= wait_cnt + 1;
                end
            endcase
        end
    end
endmodule


module sps30_parser(
    input clk,
    input [7:0] data,
    input done,
    output reg [15:0] pm25
);
    reg [5:0] count = 0;
    reg frame = 0;
    reg [7:0] msb = 0;

    always @(posedge clk) begin
        if(done) begin
            if(data == 8'h7E && !frame) begin
                frame <= 1;
                count <= 0;
            end else if(frame) begin
                if(data == 8'h7E) begin
                    frame <= 0;
                    count <= 0;
                end else begin
                    count <= count + 1;
                    if(count == 7) msb <= data;
                    if(count == 8) pm25 <= {msb, data};
                end
            end
        end
    end
endmodule


module uart_rx(
    input clk,
    input rx,
    output reg [7:0] data,
    output reg done
);
    parameter CLKS_PER_BIT = 868;

    reg [3:0] state = 0;
    reg [9:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_shift = 0;

    always @(posedge clk) begin
        case(state)
            0: begin
                done <= 0;
                if(rx == 0) begin
                    state <= 1;
                    clk_count <= 0;
                end
            end

            1: begin
                if(clk_count == CLKS_PER_BIT/2) begin
                    state <= 2;
                    clk_count <= 0;
                    bit_index <= 0;
                end else clk_count <= clk_count + 1;
            end

            2: begin
                if(clk_count == CLKS_PER_BIT) begin
                    clk_count <= 0;
                    rx_shift[bit_index] <= rx;
                    bit_index <= bit_index + 1;
                    if(bit_index == 7) state <= 3;
                end else clk_count <= clk_count + 1;
            end

            3: begin
                if(clk_count == CLKS_PER_BIT) begin
                    data <= rx_shift;
                    done <= 1;
                    state <= 0;
                end else clk_count <= clk_count + 1;
            end
        endcase
    end
endmodule


module bin_to_bcd(
    input [15:0] bin,
    output reg [3:0] h,t,o
);
    always @(*) begin
        h=(bin/100)%10;
        t=(bin/10)%10;
        o=bin%10;
    end
endmodule


module uart_tx(
    input clk,
    input [7:0] data,
    input start,
    output reg tx,
    output reg busy
);
    parameter CLKS_PER_BIT = 868;

    reg [3:0] state = 0;
    reg [9:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] tx_data;

    always @(posedge clk) begin
        case(state)
            0: begin
                tx <= 1;
                busy <= 0;
                if(start) begin
                    busy <= 1;
                    tx_data <= data;
                    state <= 1;
                    clk_count <= 0;
                end
            end

            1: begin
                tx <= 0;
                if(clk_count == CLKS_PER_BIT) begin
                    clk_count <= 0;
                    state <= 2;
                    bit_index <= 0;
                end else clk_count <= clk_count + 1;
            end

            2: begin
                tx <= tx_data[bit_index];
                if(clk_count == CLKS_PER_BIT) begin
                    clk_count <= 0;
                    bit_index <= bit_index + 1;
                    if(bit_index == 7) state <= 3;
                end else clk_count <= clk_count + 1;
            end

            3: begin
                tx <= 1;
                if(clk_count == CLKS_PER_BIT) begin
                    clk_count <= 0;
                    state <= 0;
                end else clk_count <= clk_count + 1;
            end
        endcase
    end
endmodule


module uart_tx_esp(
    input wire clk,
    input wire [7:0] data,
    input wire start,
    output reg tx,
    output reg busy
);
    parameter CLKS_PER_BIT = 10416;

    reg [13:0] clk_count = 0;
    reg [3:0] state = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] tx_data = 0;

    always @(posedge clk) begin
        case(state)
            0: begin
                tx <= 1;
                busy <= 0;
                clk_count <= 0;
                bit_index <= 0;
                if(start) begin
                    busy <= 1;
                    tx_data <= data;
                    state <= 1;
                end
            end

            1: begin
                tx <= 0;
                if(clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 0;
                    state <= 2;
                end else clk_count <= clk_count + 1;
            end

            2: begin
                tx <= tx_data[bit_index];
                if(clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 0;
                    if(bit_index == 7)
                        state <= 3;
                    else
                        bit_index <= bit_index + 1;
                end else clk_count <= clk_count + 1;
            end

            3: begin
                tx <= 1;
                if(clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 0;
                    state <= 0;
                end else clk_count <= clk_count + 1;
            end

            default: state <= 0;
        endcase
    end
endmodule


module uart_pm25_sender(
    input wire clk,
    input wire [15:0] pm25,
    output wire esp_tx
);
    reg [7:0] tx_data = 0;
    reg tx_start = 0;
    wire tx_busy;

    uart_tx_esp esp_uart(
        .clk(clk),
        .data(tx_data),
        .start(tx_start),
        .tx(esp_tx),
        .busy(tx_busy)
    );

    parameter SEND_INTERVAL = 100_000_000;
    reg [26:0] timer = 0;
    reg send_trigger = 0;

    always @(posedge clk) begin
        if(timer == SEND_INTERVAL-1) begin
            timer <= 0;
            send_trigger <= 1;
        end else begin
            timer <= timer + 1;
            send_trigger <= 0;
        end
    end

    wire [15:0] pm_scaled = pm25 / 10;
    wire [3:0] d3 = (pm_scaled / 1000) % 10;
    wire [3:0] d2 = (pm_scaled / 100) % 10;
    wire [3:0] d1 = (pm_scaled / 10) % 10;
    wire [3:0] d0 = pm_scaled % 10;

    reg [3:0] byte_idx = 0;
    reg [7:0] tx_buf [0:5];

    parameter IDLE = 2'd0;
    parameter LOAD = 2'd1;
    parameter SENDING = 2'd2;
    parameter WAIT_TX = 2'd3;

    reg [1:0] state = IDLE;

    always @(posedge clk) begin
        tx_start <= 0;
        case(state)
            IDLE: if(send_trigger) state <= LOAD;

            LOAD: begin
                tx_buf[0] <= 8'd48 + d3;
                tx_buf[1] <= 8'd48 + d2;
                tx_buf[2] <= 8'd48 + d1;
                tx_buf[3] <= 8'd48 + d0;
                tx_buf[4] <= 8'd13;
                tx_buf[5] <= 8'd10;
                byte_idx <= 0;
                state <= SENDING;
            end

            SENDING: begin
                if(!tx_busy && !tx_start) begin
                    if(byte_idx < 6) begin
                        tx_data <= tx_buf[byte_idx];
                        tx_start <= 1;
                        byte_idx <= byte_idx + 1;
                        state <= WAIT_TX;
                    end else state <= IDLE;
                end
            end

            WAIT_TX: if(!tx_busy) state <= SENDING;
        endcase
    end
endmodule


module aqi_led(
    input [15:0] pm,
    output reg [3:0] led
);
    always @(*) begin
        if(pm<=500) led=4'b0001;
        else if(pm<=1000) led=4'b0010;
        else if(pm<=1500) led=4'b0100;
        else led=4'b1000;
    end
endmodule


module top_final(
    input wire clk,
    input wire rx,
    output wire tx,
    output reg [6:0] seg,
    output reg [3:0] an,
    output wire [3:0] led,
    output wire esp_tx
);
    wire [7:0] rx_data;
    wire rx_done;

    uart_rx uart_rx_inst(
        .clk(clk),
        .rx(rx),
        .data(rx_data),
        .done(rx_done)
    );

    sps30_cmd_controller cmd_inst(
        .clk(clk),
        .rst(1'b0),
        .uart_tx(tx)
    );

    wire [15:0] pm25;

    sps30_parser parser_inst(
        .clk(clk),
        .data(rx_data),
        .done(rx_done),
        .pm25(pm25)
    );

    wire [15:0] pm25_display = pm25 / 10;

    wire [3:0] th = (pm25_display / 1000) % 10;
    wire [3:0] h  = (pm25_display / 100) % 10;
    wire [3:0] t  = (pm25_display / 10) % 10;
    wire [3:0] o  = pm25_display % 10;

    aqi_led aqi_inst(
        .pm(pm25_display),
        .led(led)
    );

    reg [19:0] cnt = 0;
    wire [1:0] sel;

    always @(posedge clk)
        cnt <= cnt + 1;

    assign sel = cnt[19:18];

    always @(*) begin
        case(sel)
            2'b00: begin an=4'b1110; seg=decode(o); end
            2'b01: begin an=4'b1101; seg=decode(t); end
            2'b10: begin an=4'b1011; seg=decode(h); end
            2'b11: begin an=4'b0111; seg=decode(th); end
        endcase
    end

    function [6:0] decode;
        input [3:0] d;
        begin
            case(d)
                0: decode=7'b1000000;
                1: decode=7'b1111001;
                2: decode=7'b0100100;
                3: decode=7'b0110000;
                4: decode=7'b0011001;
                5: decode=7'b0010010;
                6: decode=7'b0000010;
                7: decode=7'b1111000;
                8: decode=7'b0000000;
                9: decode=7'b0010000;
                default: decode=7'b1111111;
            endcase
        end
    endfunction

    uart_pm25_sender esp_sender_inst(
        .clk(clk),
        .pm25(pm25),
        .esp_tx(esp_tx)
    );
endmodule
