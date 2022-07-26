`timescale 1ns / 1ps



module flame(

    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    input wire sw0,
    input wire sw1,
    input wire [2:0] direction,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_sprite_hit
    );

    
    reg [15:0] sprite_x     = 16'd640;
    reg [15:0] sprite_y     = 16'd270; 
    reg sprite_x_direction  = 1;
    reg sprite_y_direction  = 1;
    reg sprite_x_flip       = 0;
    reg sprite_y_flip       = 0;
    wire sprite_hit_x, sprite_hit_y;
    wire [4:0] sprite_render_x;
    wire [4:0] sprite_render_y;
    
    assign out_x = sprite_x;

    localparam [0:3][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'hFF, 8'h00, 8'h00,
        8'hFF, 8'h99, 8'h00,
        8'hFF, 8'hFF, 8'h00
    };
   
    localparam [0:23][0:23][3:0] sprite_data = {
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd2, 4'd1, 4'd1, 4'd1, 4'd0, 4'd1, 4'd1, 4'd1, 4'd0, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd2, 4'd2, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd2, 4'd2, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd2, 4'd2, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd2, 4'd2, 4'd1, 4'd1, 4'd2, 4'd3, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd2, 4'd1, 4'd1, 4'd2, 4'd3, 4'd3, 4'd3, 4'd3, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd1, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd3, 4'd2, 4'd2, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0
    };
    
    localparam [0:23][0:23][3:0] sprite_data_2 = {
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd1, 4'd1, 4'd0, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd3, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd2, 4'd3, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd2, 4'd3, 4'd3, 4'd2, 4'd2, 4'd3, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd3, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd1, 4'd1, 4'd2, 4'd2, 4'd1, 4'd1, 4'd3, 4'd3, 4'd3, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd1, 4'd1, 4'd2, 4'd1, 4'd3, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0

    };
    
    localparam [0:23][0:23][3:0] sprite_data_3 = {
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd3, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd1, 4'd1, 4'd1, 4'd2, 4'd3, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd3, 4'd1, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0
    };
    
    localparam [0:23][0:23][3:0] sprite_data_4 = {
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd3, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd1, 4'd1, 4'd3, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd1, 4'd1, 4'd1, 4'd1, 4'd3, 4'd3, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd3, 4'd1, 4'd1, 4'd1, 4'd2, 4'd1, 4'd1, 4'd3, 4'd3, 4'd3, 4'd2, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd2, 4'd3, 4'd3, 4'd1, 4'd1, 4'd2, 4'd1, 4'd3, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
    4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0
    };
    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 96);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 96);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;
    
    
    wire [1:0] selected_palette;
    wire [1:0] selected_palette_2;
    wire [1:0] selected_palette_3;
    wire [1:0] selected_palette_4;
    wire [1:0] current_palette;
    reg ctr_sgnl_1 = 1'd0;
    reg ctr_sgnl_2 = 1'd0;
    reg [31:0] clk_cnt;
    assign selected_palette = sprite_x_flip ? (sprite_y_flip ? sprite_data[23-sprite_render_x][23-sprite_render_y] : sprite_data[sprite_render_x][sprite_render_y]) : (sprite_y_flip ? sprite_data[23-sprite_render_y][sprite_render_x] : sprite_data[sprite_render_y][sprite_render_x]);
    
    assign selected_palette_2 = sprite_x_flip ? (sprite_y_flip ? sprite_data_2[23-sprite_render_x][23-sprite_render_y] : sprite_data_2[sprite_render_x][sprite_render_y]) : (sprite_y_flip ? sprite_data_2[23-sprite_render_y][sprite_render_x] : sprite_data_2[sprite_render_y][sprite_render_x]);
                                           
    assign selected_palette_3 = sprite_x_flip ? (sprite_y_flip ? sprite_data_3[23-sprite_render_x][23-sprite_render_y] : sprite_data_3[sprite_render_x][sprite_render_y]) : (sprite_y_flip ? sprite_data_3[23-sprite_render_y][sprite_render_x] : sprite_data_3[sprite_render_y][sprite_render_x]);
                                            
    assign selected_palette_4 = sprite_x_flip ? (sprite_y_flip ? sprite_data_4[23-sprite_render_x][23-sprite_render_y] : sprite_data_4[sprite_render_x][sprite_render_y]) : (sprite_y_flip ? sprite_data_4[23-sprite_render_y][sprite_render_x] : sprite_data_4[sprite_render_y][sprite_render_x]);
    
    
    assign current_palette = ctr_sgnl_1 ? (ctr_sgnl_2 ? selected_palette_4 : selected_palette_2) : (ctr_sgnl_2 ? selected_palette_3 : selected_palette); 
    
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[current_palette][0] : 8'hXX;
    assign o_sprite_hit = (sw1==1 && sw0==1) ? ((sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0)) : 1'd0;
    
    always @(negedge i_v_sync) begin
        if(clk_cnt==32'd10) begin
            if(ctr_sgnl_1==0) begin //00->01, 10->11
                ctr_sgnl_1<=1'd1;
            end
            else if(ctr_sgnl_2==0) begin //01->10
                ctr_sgnl_1<=1'd0;
                ctr_sgnl_2<=1'd1;
            end
            else if(ctr_sgnl_2==1) begin //11->00
                ctr_sgnl_1<=1'd0;
                ctr_sgnl_2<=1'd0;
            end
            else begin
            end
            clk_cnt<=0;
        end
        else begin
            clk_cnt = clk_cnt+1;
        end
    end
    
    always @(negedge i_v_sync) begin
        if(direction==3'd0) begin //up
            sprite_x_flip <= 0;
            sprite_y_flip <= 0;
            sprite_x <= 16'd640; 
            sprite_y <= 16'd230;
        end
        else if(direction==3'd1) begin //down
            sprite_x_flip <= 0;
            sprite_y_flip <= 1;
            sprite_x <= 16'd640; 
            sprite_y <= 16'd500;
        end
        else if(direction==3'd2) begin //left
            sprite_x_flip <= 1;
            sprite_y_flip <= 1;
            sprite_x <= 16'd740; 
            sprite_y <= 16'd360;
        end
        else if(direction==3'd3) begin //right
            sprite_x_flip <= 1;
            sprite_y_flip <= 0;
            sprite_x <= 16'd510; 
            sprite_y <= 16'd360;
        end

    end    
    

endmodule