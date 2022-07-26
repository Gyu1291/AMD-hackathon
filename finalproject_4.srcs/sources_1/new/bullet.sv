`timescale 1ns / 1ps



module bullet(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [2:0] direction,
    input wire sw0,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit
    );
    
    reg [15:0] sprite_x = 16'd626;
    reg [15:0] sprite_y = 16'd346;
    
    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [3:0] sprite_render_y;
    
    
    localparam [0:3][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'hff, 8'h0a, 8'hff,
        8'hff, 8'h00, 8'h00,
        8'hf0, 8'hf0, 8'hf0
    };
   
    localparam [0:6][0:6][3:0] sprite_data = {
    4'd0, 	4'd0, 	4'd1, 	4'd1, 	4'd1, 	4'd0, 	4'd0, 
    4'd0, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd0, 
    4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 
    4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 
    4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 
    4'd0, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd1, 	4'd0, 
    4'd0, 	4'd0, 	4'd1, 	4'd1, 	4'd1, 	4'd0, 	4'd0
    };
    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 28);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 28);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    

    wire [1:0] selected_palette;

    assign selected_palette = sprite_data[sprite_render_y][sprite_render_x];
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_sprite_hit = sw0 ? 1'd0 : ((sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0));
    
    reg [2:0] bullet_direction = 2'd0;
    always @(posedge i_v_sync ) begin
        if(sprite_x<10 || sprite_x>1260 || sprite_y <10 || sprite_y>710) begin
            sprite_x = 16'd626;
            sprite_y = 16'd346;
            if(direction==3'd0) begin
                bullet_direction = 2'd0;
            end
            else if(direction==3'd1) begin
                bullet_direction = 2'd1;
            end
            else if(direction==3'd2) begin
                bullet_direction = 2'd2;
            end
            else begin
                bullet_direction = 2'd3;
            end
        end
        else if(bullet_direction==2'd0) begin
            sprite_y = sprite_y + 3;
        end
        else if(bullet_direction==2'd1) begin
            sprite_y = sprite_y - 3;
        end
        else if(bullet_direction==2'd2) begin
            sprite_x = sprite_x - 3;
        end
        else if(bullet_direction==2'd3) begin
            sprite_x = sprite_x + 3;
        end
    end

endmodule