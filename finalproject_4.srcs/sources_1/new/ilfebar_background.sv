`timescale 1ns / 1ps



module lifebar_background(   
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [15:0] spawn_x,
    input wire [15:0] spawn_y,
    input wire [3:0] total_life,
    output wire o_sprite_hit
    );

    wire sprite_hit_x, sprite_hit_y;
    wire [6:0] horizontal_length;
   assign horizontal_length = total_life * 5;
    
   

    assign sprite_hit_x = (i_x >= spawn_x) && (i_x < spawn_x + 60);
    assign sprite_hit_y = (i_y >= spawn_y) && (i_y < spawn_y + 10);
    

    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x);
    
                 
endmodule