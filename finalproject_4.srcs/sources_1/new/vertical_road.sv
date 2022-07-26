`timescale 1ns / 1ps



module vertical_road(   
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire [2:0] direction,

    output wire o_sprite_hit
    );

    reg [15:0] sprite_y = 0;
    reg [15:0] sprite_x = 16'd300;
    wire sprite_hit_x, sprite_hit_y;
    
   

    assign sprite_hit_x = (i_x >= sprite_x) && (i_x <sprite_x+40);
    assign sprite_hit_y = (i_y >= 16'd0) && (i_y < 16'd721);
    

    assign o_sprite_hit = (sprite_hit_y & sprite_hit_x);
    
    always @(negedge i_v_sync ) begin
        if(sprite_x==16'd2) begin
            sprite_x = 16'd1330;
        end
        else if(sprite_x==16'd1340) begin
            sprite_x = 16'd4;
        end
        else if(direction==3'd2) begin //left
            sprite_x <= sprite_x - 2;
        end
        else if(direction==3'd3) begin //right
            sprite_x <= sprite_x + 2;
        end
    end

                 
endmodule