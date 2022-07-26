`timescale 1ns / 1ps



module sprite_compositor(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [2:0] direction,
    input wire is_attacked, //공격받는 경우 이 변수가 변해, 비행기의 색이 변하게 된다.
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit,
    output wire [15:0] out_x, //총알의 위치를 설정해주기 위해 output으로 비행기 위치를 내보내준다.
    output wire [15:0] out_y
    );
    
    reg [15:0] sprite_x     = 16'd640;
    reg [15:0] sprite_y     = 16'd360; 
    reg sprite_x_direction  = 1;
    reg sprite_y_direction  = 1;
    reg sprite_x_flip       = 0;
    reg sprite_y_flip       = 0;
    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [4:0] sprite_render_y;
    wire [1:0] palette_const;
    
    assign out_x = sprite_x;
    assign out_y = sprite_y;
    
    localparam [0:12][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'h33, 8'h00, 8'h00,
        8'h99, 8'h33, 8'h66,
        8'hFF, 8'hCC, 8'hCC,
        8'h21, 8'h21, 8'h21,
        8'hFF, 8'h66, 8'h00,
        8'hFF, 8'h66, 8'h66,
        8'hFF, 8'h33, 8'h66,
        8'h00, 8'h33, 8'h99,
        8'h33, 8'h66, 8'h99,
        8'hFF, 8'hFF, 8'hFF,
        8'hFF, 8'hCC, 8'h66,
        8'h66, 8'hCC, 8'hCC
    };
    
   
    localparam [0:20][0:14][3:0] sprite_data = {
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd1,	4'd1,	4'd7,	4'd7,	4'd7,	4'd11,	4'd7,	4'd1,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd1,	4'd7,	4'd7,	4'd2,	4'd2,	4'd11,	4'd11,	4'd10,	4'd1,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd1,	4'd2,	4'd7,	4'd2,	4'd2,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,	4'd0,
    4'd0,	4'd1,	4'd2,	4'd2,	4'd2,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,
    4'd0,	4'd1,	4'd3,	4'd4,	4'd4,	4'd4,	4'd6,	4'd4,	4'd6,	4'd4,	4'd6,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd1,	4'd3,	4'd5,	4'd3,	4'd4,	4'd6,	4'd3,	4'd4,	4'd3,	4'd4,	4'd3,	4'd5,	4'd5,	4'd0,	4'd0,
    4'd1,	4'd6,	4'd5,	4'd3,	4'd4,	4'd4,	4'd3,	4'd3,	4'd3,	4'd3,	4'd3,	4'd3,	4'd3,	4'd5,	4'd0,
    4'd1,	4'd4,	4'd6,	4'd3,	4'd4,	4'd3,	4'd3,	4'd4,	4'd3,	4'd3,	4'd3,	4'd3,	4'd3,	4'd5,	4'd0,
    4'd0,	4'd4,	4'd4,	4'd6,	4'd6,	4'd3,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd4,	4'd5,	4'd5,	4'd6,	4'd6,	4'd6,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd1,	4'd2,	4'd5,	4'd5,	4'd5,	4'd5,	4'd8,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd1,	4'd2,	4'd2,	4'd7,	4'd9,	4'd9,	4'd12,	4'd12,	4'd8,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd1,	4'd5,	4'd5,	4'd5,	4'd9,	4'd10,	4'd10,	4'd12,	4'd10,	4'd8,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd5,	4'd10,	4'd10,	4'd10,	4'd5,	4'd10,	4'd10,	4'd12,	4'd10,	4'd8,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd5,	4'd10,	4'd10,	4'd5,	4'd9,	4'd9,	4'd9,	4'd12,	4'd12,	4'd8,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd5,	4'd10,	4'd10,	4'd5,	4'd9,	4'd9,	4'd8,	4'd9,	4'd8,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd5,	4'd5,	4'd5,	4'd5,	4'd4,	4'd5,	4'd4,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd4,	4'd5,	4'd5,	4'd5,	4'd3,	4'd4,	4'd3,	4'd4,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,	4'd0,	4'd0,	4'd0
    };
    
    
    localparam [0:20][0:14][3:0] sprite_data_2 = {
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd1,	4'd1,	4'd7,	4'd7,	4'd7,	4'd11,	4'd7,	4'd1,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd1,	4'd7,	4'd7,	4'd2,	4'd2,	4'd11,	4'd11,	4'd10,	4'd1,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd1,	4'd2,	4'd7,	4'd2,	4'd2,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,	4'd0,
    4'd0,	4'd1,	4'd2,	4'd2,	4'd2,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,
    4'd0,	4'd1,	4'd3,	4'd4,	4'd4,	4'd4,	4'd6,	4'd4,	4'd6,	4'd4,	4'd6,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd1,	4'd3,	4'd5,	4'd3,	4'd4,	4'd6,	4'd3,	4'd4,	4'd3,	4'd4,	4'd3,	4'd5,	4'd5,	4'd0,	4'd0,
    4'd1,	4'd6,	4'd5,	4'd3,	4'd4,	4'd4,	4'd3,	4'd3,	4'd3,	4'd3,	4'd3,	4'd3,	4'd3,	4'd5,	4'd0,
    4'd1,	4'd4,	4'd6,	4'd3,	4'd4,	4'd3,	4'd3,	4'd4,	4'd6,	4'd6,	4'd6,	4'd6,	4'd6,	4'd5,	4'd0,
    4'd0,	4'd4,	4'd4,	4'd6,	4'd6,	4'd3,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd4,	4'd5,	4'd5,	4'd6,	4'd6,	4'd6,	4'd4,	4'd4,	4'd4,	4'd4,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd5,	4'd2,	4'd5,	4'd5,	4'd5,	4'd5,	4'd5,	4'd8,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd5,	4'd2,	4'd2,	4'd7,	4'd5,	4'd9,	4'd9,	4'd9,	4'd8,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd4,	4'd5,	4'd10,	4'd10,	4'd10,	4'd5,	4'd10,	4'd10,	4'd9,	4'd10,	4'd8,	4'd4,	4'd4,	4'd0,
    4'd4,	4'd5,	4'd5,	4'd10,	4'd10,	4'd5,	4'd9,	4'd10,	4'd10,	4'd9,	4'd10,	4'd4,	4'd3,	4'd4,	4'd4,
    4'd4,	4'd5,	4'd5,	4'd10,	4'd10,	4'd5,	4'd9,	4'd9,	4'd9,	4'd9,	4'd8,	4'd4,	4'd5,	4'd4,	4'd4,
    4'd4,	4'd5,	4'd8,	4'd5,	4'd5,	4'd9,	4'd9,	4'd9,	4'd9,	4'd8,	4'd4,	4'd5,	4'd4,	4'd4,	4'd0,
    4'd4,	4'd5,	4'd3,	4'd4,	4'd0,	4'd8,	4'd8,	4'd8,	4'd8,	4'd0,	4'd4,	4'd5,	4'd4,	4'd4,	4'd0,
    4'd0,	4'd4,	4'd4,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd4,	4'd4,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0
    };
    
    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 60);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 84);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    

    wire [3:0] selected_palette;
    wire [3:0] selected_palette_2;
    wire [3:0] current_palette;
    reg moving = 1'b1;
    wire [7:0] o_red_normal;
    wire [7:0] o_green_normal;
    wire [7:0] o_blue_normal;
    reg [31:0] moving_clk;

    assign selected_palette = sprite_x_flip ? (sprite_y_flip ? sprite_data[20-sprite_render_y][14-sprite_render_x]: sprite_data[sprite_render_y][14-sprite_render_x])
                                            : (sprite_y_flip ? sprite_data[20-sprite_render_y][sprite_render_x]   : sprite_data[sprite_render_y][sprite_render_x]);
                                            
    assign selected_palette_2 = sprite_x_flip ? (sprite_y_flip ? sprite_data_2[20-sprite_render_y][14-sprite_render_x]: sprite_data_2[sprite_render_y][14-sprite_render_x])
                                            : (sprite_y_flip ? sprite_data_2[20-sprite_render_y][sprite_render_x]   : sprite_data_2[sprite_render_y][sprite_render_x]);
                                                                    
   assign current_palette = moving ? selected_palette : selected_palette_2;
   
                                                                    
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][2] : 8'hXX; //공격 받을 경우 palette_const의 결과가 달라져 색이 변하게 된다.
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][0] : 8'hXX;
    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x) && (current_palette != 4'd0);
    
    always @(posedge i_v_sync) begin
        if(moving_clk==32'd15) begin
            if(direction==3'd2) begin
                sprite_x_flip<=0;
                moving<=~moving;
            end
            else if(direction==3'd3) begin
                sprite_x_flip<=1;
                moving<=~moving;
            end
            else if(direction==3'd0||direction==3'd1) begin
                moving<=~moving;
            end
            moving_clk<=0;
        end
        else begin
            moving_clk <= moving_clk+1;
        end
    end

    
endmodule