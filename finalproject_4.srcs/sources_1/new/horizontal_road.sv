`timescale 1ns / 1ps



module horizontal_road(   
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [2:0] direction,
    output wire o_sprite_hit
    );

    reg [15:0] sprite_x = 0;
    reg [15:0] sprite_y = 16'd440;
    wire sprite_hit_x, sprite_hit_y;
    
   

    assign sprite_hit_x = (i_x >= 0) && (i_x <1280);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 40);
    

    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x);
    
    always @(negedge i_v_sync ) begin
        if(sprite_y==16'd2) begin
            sprite_y = 16'd760;
        end
        else if(sprite_y==16'd770) begin
            sprite_y = 16'd42;
        end
        else if(direction==3'd0) begin //up
            sprite_y <= sprite_y + 2;
        end
        else if(direction==3'd1) begin //down
            sprite_y <= sprite_y - 2;
        end
    end

                 
endmodule