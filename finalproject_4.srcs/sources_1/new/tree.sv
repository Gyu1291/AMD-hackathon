`timescale 1ns / 1ps



module tree(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [15:0] spawn_x,
    input wire [15:0] spawn_y,
    input wire [2:0] direction,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit
    );
    
    reg [15:0] sprite_x     = spawn_x;
    reg [15:0] sprite_y     = spawn_y; 

    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [3:0] sprite_render_y;
    
    localparam [0:3][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'ha5, 8'h2a, 8'h2a,
        8'h32, 8'h59, 8'h28,
        8'h21, 8'h21, 8'hFF
    };
   
    localparam [0:15][0:15][3:0] sprite_data = {
    4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0,  4'd0,
    4'd2, 4'd2, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0,  4'd0,
    4'd2, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd2, 4'd2, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd2, 4'd2,  4'd0,
    4'd0, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd2,  4'd0,
    4'd0, 4'd2, 4'd2, 4'd0, 4'd0, 4'd1, 4'd2, 4'd2, 4'd2, 4'd0, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd2, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd2, 4'd2, 4'd0, 4'd0, 4'd2, 4'd2, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd2, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd2, 4'd2, 4'd0, 4'd0, 4'd2, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,  4'd0,
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,  4'd0
    };
    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 64);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 64);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    

    wire [1:0] selected_palette;

    assign selected_palette = sprite_data[sprite_render_y][sprite_render_x];
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0);
               
    always @(negedge i_v_sync ) begin
        if(sprite_y==16'd2) begin
            sprite_y = 16'd760;
        end
        else if(sprite_y==16'd770) begin
            sprite_y = 16'd42;
        end
        else if(sprite_x==16'd2) begin
            sprite_x = 16'd1330;
        end
        else if(sprite_x==16'd1340) begin
            sprite_x = 16'd4;
        end
        
        else if(direction==3'd0) begin //up
            sprite_y <= sprite_y + 2;
        end
        else if(direction==3'd1) begin //down
            sprite_y <= sprite_y - 2;
        end
        else if(direction==3'd2) begin //left
            sprite_x <= sprite_x - 2;
        end
        else if(direction==3'd3) begin //right
            sprite_x <= sprite_x + 2;
        end
    end
    
endmodule