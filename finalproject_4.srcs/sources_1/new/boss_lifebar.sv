`timescale 1ns / 1ps



module boss_lifebar(   
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [15:0] spawn_x,
    input wire [15:0] spawn_y,
    input reg game_clear,
    input reg [2:0] stage,
    input wire [9:0] life, //<1024
    output wire o_sprite_hit
    );

    wire sprite_hit_x, sprite_hit_y;
    wire [9:0] horizontal_length; //<128
   assign horizontal_length = life;

    assign sprite_hit_x = (i_x >= spawn_x) && (i_x <spawn_x + horizontal_length);
    assign sprite_hit_y = (i_y >= spawn_y) && (i_y < spawn_y + 15);
    

    assign o_sprite_hit = (stage==3'd3 && game_clear==1'd0) ? (sprite_hit_y & sprite_hit_x) : 1'd0;
    
                 
endmodule