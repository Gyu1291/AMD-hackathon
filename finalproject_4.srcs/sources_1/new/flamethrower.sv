`timescale 1ns / 1ps



module flamethrower(

    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [2:0] direction,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit
    );

    
    reg [15:0] sprite_x     = 16'd640;
    reg [15:0] sprite_y     = 16'd360; 
    reg sprite_x_direction  = 1;
    reg sprite_y_direction  = 1;
    reg sprite_x_flip       = 0;
    reg sprite_y_flip       = 0;
    wire sprite_hit_x, sprite_hit_y, sprite_hit_x_2, sprite_hit_y_2, current_sprite_hit_x, current_sprite_hit_y;
    wire [4:0] sprite_render_x;
    wire [4:0] sprite_render_y;
    
    assign out_x = sprite_x;

    localparam [0:4][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'h21, 8'h21, 8'h21,
        8'hFF, 8'h99, 8'h00,
        8'hCC, 8'hCC, 8'hCC,
        8'h99, 8'h99, 8'h00
    };
   
    localparam [0:19][0:19][3:0] sprite_data = {
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd1,	4'd1,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd1,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd1,	4'd1,	4'd3,	4'd3,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd2,	4'd1,	4'd0,
    4'd0,	4'd1,	4'd3,	4'd3,	4'd3,	4'd3,	4'd1,	4'd2,	4'd1,	4'd2,	4'd2,	4'd2,	4'd2,	4'd2,	4'd2,	4'd2,	4'd1,	4'd1,	4'd2,	4'd1,
    4'd0,	4'd1,	4'd1,	4'd1,	4'd3,	4'd1,	4'd0,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd1,	4'd2,	4'd2,	4'd1,	4'd0,
    4'd1,	4'd1,	4'd0,	4'd0,	4'd1,	4'd0,	4'd1,	4'd1,	4'd4,	4'd4,	4'd4,	4'd1,	4'd0,	4'd0,	4'd0,	4'd0,	4'd1,	4'd1,	4'd1,	4'd1,
    4'd0,	4'd0,	4'd1,	4'd1,	4'd0,	4'd0,	4'd0,	4'd1,	4'd1,	4'd1,	4'd1,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,
    4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0,	4'd0
    };

    
    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 80);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 80);

    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    
    wire [2:0] selected_palette;

    assign selected_palette = sprite_x_flip ? (sprite_y_flip ? sprite_data[19-sprite_render_x][19-sprite_render_y] : sprite_data[sprite_render_x][sprite_render_y]) : (sprite_y_flip ? sprite_data[sprite_render_y][19-sprite_render_x] : sprite_data[sprite_render_y][sprite_render_x]);

    
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x) && (selected_palette != 3'd0);
    
    
    always @(negedge i_v_sync) begin
        if(direction==3'd0) begin //up
            sprite_x_flip <= 1;
            sprite_y_flip <= 0;
            sprite_x <= 16'd640;
            sprite_y <= 16'd340;
        end
        else if(direction==3'd1) begin //down
            sprite_x_flip <= 1;
            sprite_y_flip <= 1;
            sprite_x <= 16'd640;
            sprite_y <= 16'd390;
        end
        else if(direction==3'd2) begin //left
            sprite_x_flip <= 0;
            sprite_y_flip <= 0;
            sprite_x <= 16'd650;
            sprite_y <= 16'd375;
        end
        else if(direction==3'd3) begin //right
            sprite_x_flip <= 0;
            sprite_y_flip <= 1;
            sprite_x <= 16'd620;
            sprite_y <= 16'd375;
        end

    end    
    

endmodule