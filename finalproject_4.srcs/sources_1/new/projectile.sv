`timescale 1ns / 1ps



module projectile(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire [15:0] spawn_x,
    input wire [15:0] spawn_y,
    input wire i_v_sync,
    input wire btn1,
    output wire o_sprite_hit
    
    );
    
    
    reg [15:0] sprite_x     = 16'd20;
    reg [15:0] sprite_y     = 16'd600; 
    reg sprite_x_direction  = 1;
    reg sprite_y_direction  = 1;
    reg sprite_x_flip       = 0;
    reg sprite_y_flip       = 0;
    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [3:0] sprite_render_y;

    localparam [0:3][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'hFF, 8'hFF, 8'hFF,
        8'hFF, 8'hFF, 8'hFF,
        8'h21, 8'h21, 8'hFF
    };
   
    localparam [0:5][0:5][3:0] sprite_data= {
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
    4'd1,4'd1,4'd1,4'd1,4'd1,4'd1
    };

    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 24); //sprite_hit = pixel*4
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 24);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    

    wire [1:0] selected_palette;

    assign selected_palette = sprite_x_flip ? (sprite_y_flip ? sprite_data[6-sprite_render_y][6-sprite_render_x]: sprite_data[sprite_render_y][6-sprite_render_x])
                                            : (sprite_y_flip ? sprite_data[6-sprite_render_y][sprite_render_x]   : sprite_data[sprite_render_y][sprite_render_x]);
                                                                         
    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0);
    
    always @(posedge i_v_sync) begin
        if(sprite_y>=720) begin
            if(btn1==1) begin
                sprite_y = 16'd600;
                sprite_x = spawn_x; //spawn_x란 현재 플레이어의 위치이다. y좌표가 고정이라 그냥 600으로 넣어주었다.
            end
        end
        else if(sprite_y<=1) begin
            sprite_y = 16'd740;
        end
        else if(sprite_y<=720) begin
            sprite_y <= sprite_y - 1;
        end
        else begin
            
        end
    end
    
endmodule