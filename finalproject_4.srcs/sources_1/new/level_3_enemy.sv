`timescale 1ns / 1ps



module level_3_enemy(   
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input reg [15:0] spawn_x,
    input reg [15:0] spawn_y,
    input reg attacked,
    input reg [2:0] stage,
    input wire [2:0] direction,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit
    );
    
    reg direction_x = 1'd1;
    reg direction_y = 1'd1;
    reg [15:0] distance_x;
    reg [15:0] distance_y;

    reg [15:0] sprite_x = 16'd100;
    reg [15:0] sprite_y = 16'd100; 
    
    wire sprite_hit_x, sprite_hit_y;
    wire [4:0] sprite_render_x;
    wire [3:0] sprite_render_y;
    
    localparam [0:6][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'h21, 8'h21, 8'h21,
        8'h00, 8'hFF, 8'h00,
        8'hFF, 8'hFF, 8'hFF,
        8'hFF, 8'h00, 8'h00,
        8'h00, 8'h00, 8'hFF,
        8'hCC, 8'h00, 8'h51
    };
   
    localparam [0:12][0:17][3:0] sprite_data = {
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd1, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd3, 4'd3, 4'd3, 4'd1, 4'd3, 4'd2, 4'd3, 4'd3, 4'd3, 4'd1, 4'd3, 4'd0, 4'd0, 
    4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd3, 4'd3, 4'd1, 4'd1, 4'd2, 4'd2, 4'd3, 4'd3, 4'd1, 4'd1, 4'd0, 4'd0, 
    4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 
    4'd0, 4'd2, 4'd2, 4'd2, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd0, 4'd0, 
    4'd0, 4'd2, 4'd2, 4'd2, 4'd4, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 
    4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd0, 4'd0, 
    4'd2, 4'd5, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 
    4'd0, 4'd0, 4'd5, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd2, 
    4'd0, 4'd0, 4'd0, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 
    4'd0, 4'd0, 4'd0, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2
    };
    
    localparam [0:12][0:17][3:0] sprite_data_2 = {
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd6, 4'd6, 4'd6, 4'd6, 4'd0, 4'd6, 4'd6, 4'd6, 4'd6, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd1, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd6, 4'd6, 4'd6, 4'd3, 4'd3, 4'd3, 4'd1, 4'd3, 4'd6, 4'd3, 4'd3, 4'd3, 4'd1, 4'd3, 4'd0, 4'd0, 
    4'd0, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd3, 4'd3, 4'd1, 4'd1, 4'd6, 4'd6, 4'd3, 4'd3, 4'd1, 4'd1, 4'd0, 4'd0, 
    4'd0, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd0, 4'd0, 
    4'd0, 4'd6, 4'd6, 4'd6, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd0, 4'd0, 
    4'd0, 4'd6, 4'd6, 4'd6, 4'd4, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 
    4'd0, 4'd6, 4'd6, 4'd6, 4'd6, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd4, 4'd0, 4'd0, 
    4'd6, 4'd5, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd0, 
    4'd0, 4'd0, 4'd5, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd6, 4'd0, 4'd0, 4'd0, 4'd6, 
    4'd0, 4'd0, 4'd0, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd6, 
    4'd0, 4'd0, 4'd0, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd6
    };
    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 72);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 52);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    reg [1:0] life = 2'd2;
    wire [3:0] selected_palette;
    wire [3:0] selected_palette_2;
    wire [3:0] current_palette;

    assign selected_palette = direction_x ? sprite_data[sprite_render_y][17-sprite_render_x] : sprite_data[sprite_render_y][sprite_render_x];

    assign selected_palette_2 = direction_x ? sprite_data_2[sprite_render_y][17-sprite_render_x] : sprite_data_2[sprite_render_y][sprite_render_x];

    assign current_palette = (life==2'd2) ? selected_palette : selected_palette_2;
                                                             
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][0] : 8'hXX;
    assign o_sprite_hit = (stage==3'd2) ? (sprite_hit_y & sprite_hit_x) && (current_palette != 3'd0) : 1'd0;
    reg [31:0] clk_cnt = 0;
    
    always @(posedge i_v_sync ) begin  
    if(stage==3'd2) begin
       if(clk_cnt == 32'd20) begin
            if(attacked==1) begin
                if(life == 2'd2) begin
                    life = 2'd1;
            end
                else if(life == 2'd1) begin
                    sprite_x = spawn_x;
                    sprite_y = spawn_y;
                    life = 2'd2;
                end
            end
            clk_cnt = 0;
        end
        else begin
            clk_cnt = clk_cnt+1;
        end
        if(direction==3'd0) begin
            sprite_y=sprite_y+2;
        end
        else if(direction==3'd1 && sprite_y>=4) begin
            sprite_y=sprite_y-2;
        end
        else if(direction==3'd2  && sprite_x>=4) begin
            sprite_x=sprite_x-2;
        end
        else if(direction==3'd3) begin
            sprite_x=sprite_x+2;
        end
        else begin
        end
        
        direction_x = (sprite_x>=16'd640);
        direction_y = (sprite_y>=16'd360);
        distance_x = (direction_x) ? (sprite_x-16'd640) : (16'd640-sprite_x);
        distance_y = (direction_y) ? (sprite_y-16'd360) : (16'd360-sprite_y);
        if(distance_x + distance_y<=20) begin
            sprite_x = spawn_x;
            sprite_y = spawn_y;
            life = 2'd2;
        end
        if(distance_x >= distance_y) begin
            sprite_x=sprite_x + (direction_x ? -1 : 1);
        end
        else if(distance_y>distance_x) begin
            sprite_y=sprite_y + (direction_y ? -1 : 1);
        end
        else begin
        end
    end

    end

                 
endmodule