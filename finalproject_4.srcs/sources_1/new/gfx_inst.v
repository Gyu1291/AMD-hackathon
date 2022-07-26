`timescale 1ns / 1ps


module gfx(
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    input wire i_v_sync,
    output reg [7:0] o_red,
    output reg [7:0] o_green,
    output reg [7:0] o_blue,
    input wire btn0,
    input wire btn1,
    input wire btn2,
    input wire btn3,
    input wire sw0,
    input wire sw1,
    input HCLK,
    input [31:0]M_AHB_0_haddr,
    input [2:0]M_AHB_0_hburst,
    input M_AHB_0_hmastlock,
    input [3:0]M_AHB_0_hprot,
    output reg [31:0]M_AHB_0_hrdata,
    output M_AHB_0_hready,
    output M_AHB_0_hresp,
    input [2:0]M_AHB_0_hsize,
    input [1:0]M_AHB_0_htrans,
    input [31:0]M_AHB_0_hwdata,
    input M_AHB_0_hwrite
    );
    
    
    assign M_AHB_0_hready = 1'b1;
    assign M_AHB_0_hresp = 1'b0;

    reg [31:0] mem_A = 4'd0;   /// AMBA_memory
    reg [31:0] hclk_cnt=0;
    reg [1:0]   w_ctrl;
    reg [1:0]   r_ctrl;
    reg [2:0]   w_addr;
    reg [3:0]   r_addr;
    
    wire bg_hit, sprite_hit, score_hit, projectile_hit, enemy_pro_hit_1, stage_clear_hit, score_word_hit, life_word_hit, student_id_hit, life_num_hit, gameover_hit, tree_hit_1, tree_hit_2, tree_hit_3 , healpack_hit, bullet_hit;
    wire pepe_hit_0, pepe_hit_1, pepe_hit_2, pepe_hit_3, pepe_hit_4, pepe_hit_5, pepe_hit_6, player_weapon_hit, player_weapon_hit_2, press_hit, boss_hit ,lifebar_hit, lifebar_background_hit, boss_lifebar_hit, boss_lifebar_bg_hit;//아래 sprite_hit고치기
    wire [7:0] bg_red;
    wire [7:0] bg_green;
    wire [7:0] bg_blue;
    
    wire [7:0] sprite_red;
    wire [7:0] sprite_green;
    wire [7:0] sprite_blue;
    
    wire [7:0] enemy_red_1;
    wire [7:0] enemy_green_1;
    wire [7:0] enemy_blue_1;
    
    wire [7:0] enemy_red_2;
    wire [7:0] enemy_green_2;
    wire [7:0] enemy_blue_2;
    
    wire [7:0] enemy_red_3;
    wire [7:0] enemy_green_3;
    wire [7:0] enemy_blue_3;
    
    wire [7:0] enemy_red_4;
    wire [7:0] enemy_green_4;
    wire [7:0] enemy_blue_4;
    
    wire [7:0] enemy_red_5;
    wire [7:0] enemy_green_5;
    wire [7:0] enemy_blue_5;
    
    wire [7:0] enemy_red_6;
    wire [7:0] enemy_green_6;
    wire [7:0] enemy_blue_6;
    
    wire [7:0] enemy_red_7;
    wire [7:0] enemy_green_7;
    wire [7:0] enemy_blue_7;
    
    wire [7:0] boss_red;
    wire [7:0] boss_green;    
    wire [7:0] boss_blue;
    
    wire [7:0] tree_red_1;
    wire [7:0] tree_green_1;
    wire [7:0] tree_blue_1;
    
    wire [7:0] flame_red;
    wire [7:0] flame_green;
    wire [7:0] flame_blue;
    
    wire [7:0] player_weapon_red;
    wire [7:0] player_weapon_green;
    wire [7:0] player_weapon_blue;

    wire [7:0] player_weapon_red_2;
    wire [7:0] player_weapon_green_2;
    wire [7:0] player_weapon_blue_2;
    
    wire [7:0] healpack_red;
    wire [7:0] healpack_green;
    wire [7:0] healpack_blue;
    
    wire [7:0] bullet_red;
    wire [7:0] bullet_green;
    wire [7:0] bullet_blue;
    
    reg enemy_1_attacked = 1'd0;
    reg enemy_2_attacked = 1'd0;
    reg enemy_3_attacked = 1'd0;
    reg enemy_4_attacked = 1'd0;
    reg enemy_5_attacked = 1'd0;
    reg enemy_6_attacked = 1'd0;
    reg enemy_7_attacked = 1'd0;
    reg boss_attacked = 1'd0;
    
    wire [7:0] life_word_red; //life의 r,g,b값이다. 
    wire [7:0] life_word_green;
    wire [7:0] life_word_blue;

    
    wire [15:0] current_player_x; //현재 플레이어의 좌표이다.
    wire [15:0] current_player_y;
    wire [15:0] current_boss_x; //현재 boss의 좌표이다.
    wire [15:0] current_boss_y;
    wire [15:0] pro_spawn_x = 16'd100;
    wire [15:0] enemy_x_1;
    wire [15:0] enemy_x_2;
    wire [15:0] enemy_x_3;
    wire [15:0] enemy_x_4;
    wire [15:0] enemy_x_5;
    wire [15:0] enemy_x_6;
    
    reg plane_color = 1'd0; //비행기의 색이다.
    reg attacked = 1'd0;
    reg enable_attacked = 1'd1;
    reg [2:0] stage = 3'd0; // 현재 stage
    reg clear_stage = 1'd0; //이것이 1이면 clear글씨가 뜬다.
    reg [3:0] score = 4'd0; //현재 점수
    
    reg [3:0] player_life = 4'd12; //플레이어 남은 목숨
    reg [9:0] boss_life = 10'd250;
    reg player_dead = 1'd0;
    assign pro_spawn_x = current_player_x;
    reg [31:0] clk_cnt = 0;
    reg [31:0] hit_cnt = 0;
    reg hit_clk = 1'd0;
    reg [31:0] sound_cnt = 0;
    reg [3:0] old_score = 4'd0; //효과음을 위한 old score, 이것과 score를 비교해 효과음 구현
    reg delayed_attacked = 1'd0;
    reg healpack_available_1 = 1'd1;
    reg healpack_used = 1'd0;
    reg [2:0] gun_direction;
    wire road_1_hit, road_2_hit;
    reg [5:0] pepe_hit_sum = 6'd0;
        always@(posedge HCLK) begin //AMBA를 구현하기 위한 always문, 어차피 write는 verilog에서 해주고 memory read부분만 가져옴
        if(M_AHB_0_hwrite == 1'b0)// read transfer가 일어나는 상황
            begin
                case(M_AHB_0_htrans)
                    2'b00 : // IDLE
                    begin
                        r_ctrl <= 2'b00;
                    end
                    2'b01 : // BUSY
                    begin
                        r_ctrl <= 2'b01;
                    end
                    2'b10 : // NONSEQ
                    begin
                        r_ctrl <= 2'b10;
                        r_addr <= M_AHB_0_haddr[5:2];
                    end
                    2'b11 : // SEQ
                    begin
                        r_ctrl <= 2'b11;
                    end
                endcase
            end
        end
    
    
        always@(negedge HCLK) begin
                case(r_ctrl)
                    2'b00: // IDLE
                    begin
                            
                    end
                    2'b01: // BUSY
                    begin
                    
                    end
                    2'b10: // NONSEQ transfer, memory의 data를 M_AHB_0_hrdata로
                    begin
                        M_AHB_0_hrdata <= mem_A;
                    end
                    2'b11: // SEQ transfer, memory의 data를 M_AHB_0_hrdata로
                    begin
                        M_AHB_0_hrdata <= mem_A;
                    end
            endcase
        end
    
    reg [7:0] cnt60 = 0;
    reg [7:0] timer = 0;        
    reg [6:0] min = 0;
    reg [2:0] sec10 = 0;
    reg [3:0] sec1 = 0;
    wire min_hit, sec10_hit, sec1_hit;
    reg game_clear = 1'd0;
    always@(negedge(i_v_sync)) begin //clock display
        if(stage>0) begin
            if (cnt60 < 70)
                cnt60 = cnt60 + 1;
            else if (cnt60 == 70) begin
                cnt60 = 0;
                timer = timer + 1;
            end
            min = timer / 60;
            sec10 = (timer % 60) / 10;
            sec1 =  timer % 10;
        end
    end
    
    always@ (negedge i_v_sync) begin //Stage, 효과음, 플레이어 공격받은 상태 등을 다 관리하는 always문이다. 
        if(player_dead == 1'd1) begin //game_over....
            mem_A<=3'd3;
        end
        else if(game_clear==1'd1) begin //game_clear!!
            mem_A<=3'd5;
        end
        else if(stage==3'd0 && (btn0==1 || btn1==1 || btn2==1 || btn3==1)) begin //stage 1
            stage = 3'd1;
        end
        else if(healpack_used==0 && healpack_available_1==0) begin
            player_life = 4'd12;
            healpack_used = 1'd1;
        end
        else if(boss_attacked==1'd1) begin
            boss_life = boss_life-1;
            if(boss_life < 9'd10) begin
                game_clear = 1'd1;
            end
        end
       else if((min==7'd1 && sec10==3'd3 && stage==1)||(min==7'd3 && sec10==3'd0 && stage==2)) begin //stage stage clear
            if(clk_cnt==32'd300) begin
                stage <= stage+1;
                clear_stage <= 1'd0;
                clk_cnt<=0;
                mem_A<=3'd0;
            end
            else begin //stage clear
                clk_cnt = clk_cnt+1;
                clear_stage<=1'd1;
                mem_A<=3'd2;
            end
        end
        else if(plane_color==1) begin //player attacked인 경우 효과음  sound=1, 비행기 색이 바뀌었는지로 구분
            if(sound_cnt>=32'd30) begin //일정시간 지나면  원래 상태로 돌아감
                player_life = player_life-1;
                if(player_life == 0) begin
                    player_dead = 1'd1;
                end
                sound_cnt=0;
                mem_A=0;
                plane_color=1'd0;
                delayed_attacked=1'd0;
            end
            else begin //player_attacked
                sound_cnt<=sound_cnt+1;
                mem_A<=3'd1; //클럭 증가
            end
        end
        else if(attacked==1) begin //총알 맞으면 일단 비행기 색 바꿈
            plane_color=1'd1;
        end
        else begin
            hit_cnt <= hit_cnt+1;
            mem_A<=3'd0;
        end
    end
    
    always @(posedge i_v_sync) begin //optimize control signal -> input을 줄여주는 역할을 해 게임 최적화를 돕는다.
        if(btn0==1) begin //up
            gun_direction = 3'd0;
        end
        else if(btn1==1) begin //down
            gun_direction = 3'd1;
        end
        else if(btn2==1) begin //left
            gun_direction = 3'd2;
        end
        else if(btn3==1) begin //right
            gun_direction = 3'd3;
        end
        else begin
            gun_direction = 3'd4;
        end
    end
    
    numberdisplay printmin(
        .i_x        (i_x),
        .i_y        (i_y),
        .spawn_x    (16'd280),
        .i_v_sync   (i_v_sync),
        .i_num      (min),
        .sprite_hit   (min_hit)    
    ); //i_num에 들어간 숫자를 화면에 띄워줌, score
    
    numberdisplay printsec10(
        .i_x        (i_x),
        .i_y        (i_y),
        .spawn_x    (16'd370),
        .i_v_sync   (i_v_sync),
        .i_num      (sec10),
        .sprite_hit   (sec10_hit)    
    ); //i_num에 들어간 숫자를 화면에 띄워줌, score
    
    numberdisplay printsec1(
        .i_x        (i_x),
        .i_y        (i_y),
        .spawn_x    (16'd435),
        .i_v_sync   (i_v_sync),
        .i_num      (sec1),
        .sprite_hit   (sec1_hit)    
    ); //i_num에 들어간 숫자를 화면에 띄워줌, score
      
     sprite_compositor sprite_compositor_1 (
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .direction(gun_direction),
        .is_attacked(plane_color),
        .o_red      (sprite_red),
        .o_green    (sprite_green),
        .o_blue     (sprite_blue),
        .o_sprite_hit   (sprite_hit),
        .out_x (current_player_x),
        .out_y (current_player_y)
    ); //플레이어
    
    
    sprite_compositor_2 enemy1 (
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .spawn_x    (16'd1200),
        .spawn_y    (16'd500),
        .attacked(enemy_1_attacked),
        .stage(stage),
        .direction(gun_direction),
        .o_red      (enemy_red_1),
        .o_green    (enemy_green_1),
        .o_blue     (enemy_blue_1),
        .o_sprite_hit   (pepe_hit_0)
    );//적 1,2,3
    
    sprite_compositor_2 enemy2 (
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .attacked(enemy_2_attacked),
        .spawn_x    (16'd1000),
        .spawn_y    (16'd600),
        .stage(stage),
        .direction(gun_direction),
        .o_red      (enemy_red_2),
        .o_green    (enemy_green_2),
        .o_blue     (enemy_blue_2),
        .o_sprite_hit   (pepe_hit_1)
    );
    
    sprite_compositor_2 enemy3 (
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .spawn_x    (16'd60),
        .spawn_y    (16'd400),
        .attacked(enemy_3_attacked),
        .stage(stage),
        .direction(gun_direction),
        .o_red      (enemy_red_3),
        .o_green    (enemy_green_3),
        .o_blue     (enemy_blue_3),
        .o_sprite_hit   (pepe_hit_2)
    );
    
    level_3_enemy enemy4 (
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd1100),
    .spawn_y(16'd600),
    .attacked(enemy_4_attacked),
    .stage(stage),
    .direction(gun_direction),
    .o_red(enemy_red_4),
    .o_green(enemy_green_4),
    .o_blue(enemy_blue_4),
    .o_sprite_hit(pepe_hit_3)
    );
    
    level_3_enemy enemy5 (
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd1100),
    .spawn_y(16'd300),
    .attacked(enemy_5_attacked),
    .stage(stage),
    .direction(gun_direction),
    .o_red(enemy_red_5),
    .o_green(enemy_green_5),
    .o_blue(enemy_blue_5),
    .o_sprite_hit(pepe_hit_4)
    );
    
    level_3_enemy enemy6 (
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd60),
    .spawn_y(16'd60),
    .attacked(enemy_6_attacked),
    .stage(stage),
    .direction(gun_direction),
    .o_red(enemy_red_6),
    .o_green(enemy_green_6),
    .o_blue(enemy_blue_6),
    .o_sprite_hit(pepe_hit_5)
    );
    
    
    
    flame player_flame(
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .sw0(sw0),
        .sw1(sw1),
        .direction(gun_direction),
        .o_red      (flame_red),
        .o_green    (flame_green),
        .o_blue     (flame_blue),
        .o_sprite_hit   (flame_hit)
    );
    
    horizontal_road road1(
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .direction(gun_direction),
        .o_sprite_hit(road_1_hit)
    );
    
     vertical_road road2(
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .direction(gun_direction),
        .o_sprite_hit(road_2_hit)
    );

   stageclear stageclear(
        .i_x        (i_x),
        .i_y        (i_y),
        .i_v_sync   (i_v_sync),
        .o_sprite_hit   (stage_clear_hit)
   );//Clear
   
   gun player_weapon (
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .direction(gun_direction),
    .o_red(player_weapon_red),
    .o_green(player_weapon_green),
    .o_blue(player_weapon_blue),
    .o_sprite_hit(player_weapon_hit)
   );
   
   flamethrower player_weapon_2 (
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .direction(gun_direction),
    .o_red(player_weapon_red_2),
    .o_green(player_weapon_green_2),
    .o_blue(player_weapon_blue_2),
    .o_sprite_hit(player_weapon_hit_2)
   );
      
   bosspepe(   
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd1200),
    .spawn_y(16'd700),
    .game_clear(game_clear),
    .attacked(boss_attacked),
    .stage(stage),
    .direction(gun_direction),
    .o_red(boss_red),
    .o_green(boss_green),
    .o_blue(boss_blue),
    .o_sprite_hit(boss_hit),
    .current_boss_x(current_boss_x),
    .current_boss_y(current_boss_y)
    );   
    
     lifebar(   
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd640),
    .spawn_y(16'd460),
    .life(player_life),
    .o_sprite_hit(lifebar_hit)
    );     

     lifebar_background(   
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd640),
    .spawn_y(16'd460),
    .total_life(4'd12),
    .o_sprite_hit(lifebar_background_hit)
    );     
    
     boss_lifebar(   
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(current_boss_x),
    .spawn_y(current_boss_y + 16'd210),
    .life(boss_life),
    .game_clear(game_clear),
    .stage(stage),
    .o_sprite_hit(boss_lifebar_hit)
    );     
    
    boss_lifebar_bg(   
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(current_boss_x),
    .spawn_y(current_boss_y + 16'd210),
    .game_clear(game_clear),
    .stage(stage),
    .o_sprite_hit(boss_lifebar_bg_hit)
    );     
    
    gameover gameover_word(
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .o_sprite_hit(gameover_hit)
    );
    
    tree tree_1(
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd1000),
    .spawn_y(16'd200),
    .direction(gun_direction),
    .o_red(tree_red_1),
    .o_green(tree_green_1),
    .o_blue(tree_blue_1),
    .o_sprite_hit(tree_hit_1)
    );

    healpack healpack_1(
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .spawn_x(16'd1000),
    .spawn_y(16'd400),
    .available(healpack_available_1),
    .direction(gun_direction),
    .o_red(healpack_red),
    .o_green(healpack_green),
    .o_blue(healpack_blue),
    .o_sprite_hit(healpack_hit)
    ); //heal pack
    
    bullet bullet_1(
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .direction(gun_direction),
    .sw0(sw0),
    .o_red(bullet_red),
    .o_green(bullet_green),
    .o_blue(bullet_blue),
    .o_sprite_hit(bullet_hit)
    ); //bullet
    
    pressanybutton initialword(
    .i_x(i_x),
    .i_y(i_y),
    .i_v_sync(i_v_sync),
    .o_sprite_hit(press_hit)
    ); //맨 처음 글자를 띄워주는 모듈이다.
    
    always@(*) begin //sprite띄워주는 always문
    pepe_hit_sum = pepe_hit_0 + pepe_hit_1 + pepe_hit_2 + pepe_hit_3 + pepe_hit_4 + pepe_hit_5 + boss_hit;
   if(press_hit==1 && stage==0) begin
        o_red = 8'hFF;
        o_green = 8'hFF;
        o_blue = 8'hFF;
   end
   else if((stage_clear_hit ==1 && clear_stage==1) || min_hit==1 || sec10_hit==1 || sec1_hit ==1 || (gameover_hit==1 && player_dead==1)) begin
        o_red = 8'hFF;
        o_green = 8'hFF;
        o_blue = 8'hFF;
   end
   else if(player_weapon_hit==1 && sw0==0) begin
        o_red = player_weapon_red;
        o_green = player_weapon_green;
        o_blue = player_weapon_blue;
    end
    else if(player_weapon_hit_2==1 && sw0==1) begin
        o_red = player_weapon_red_2;
        o_green = player_weapon_green_2;
        o_blue = player_weapon_blue_2;
    end
    else if(lifebar_hit==1) begin
        o_red = 8'hFF;
        o_green = 8'h00;
        o_blue = 8'h00;
    end
    else if(lifebar_background_hit==1) begin
        o_red = 8'hFF;
        o_green = 8'hFF;
        o_blue = 8'h00;
    end
    else if(boss_lifebar_hit==1) begin
        o_red = 8'hFF;
        o_green = 8'h00;
        o_blue = 8'h00;
    end
    else if(boss_lifebar_bg_hit==1) begin
        o_red = 8'hFF;
        o_green = 8'hFF;
        o_blue = 8'h00;
    end
    else if(healpack_hit == 1) begin
        o_red = healpack_red;
        o_green = healpack_green;
        o_blue = healpack_blue;
        if(sprite_hit==1) begin
            healpack_available_1 = 1'd0;
        end
    end
    else if(sprite_hit==1) begin//플레이어 
        o_red=sprite_red;
        o_green=sprite_green;
        o_blue=sprite_blue;
        if(pepe_hit_sum >=1) begin
            attacked = 1;
        end
        else begin
            attacked = 0;
        end
    end
    else if(pepe_hit_0==1) begin //적 1,2,3,4,5의 sprite image이다. 
        o_red=enemy_red_1;
        o_green=enemy_green_1;
        o_blue=enemy_blue_1;
        if(flame_hit==1 || bullet_hit==1) begin
            enemy_1_attacked = 1;
        end
        else begin
            enemy_1_attacked = 0;
        end
    end
    
    else if(pepe_hit_1==1) begin
        o_red=enemy_red_2;
        o_green=enemy_green_2;
        o_blue=enemy_blue_2;
        if(flame_hit==1 || bullet_hit==1) begin
            enemy_2_attacked = 1;
        end
        else begin
            enemy_2_attacked = 0;
        end
    end
    
    else if(pepe_hit_2==1) begin
        o_red=enemy_red_3;
        o_green=enemy_green_3;
        o_blue=enemy_blue_3;
        if(flame_hit==1 || bullet_hit==1) begin
            enemy_3_attacked = 1;
        end
        else begin
            enemy_3_attacked = 0;
        end
    end
    else if(pepe_hit_3==1) begin
        o_red=enemy_red_4;
        o_green=enemy_green_4;
        o_blue=enemy_blue_4;
        if(flame_hit==1 || bullet_hit==1) begin
            enemy_4_attacked = 1;
        end
        else begin
            enemy_4_attacked = 0;
        end
    end    
    else if(pepe_hit_4==1) begin
        o_red=enemy_red_5;
        o_green=enemy_green_5;
        o_blue=enemy_blue_5;
        if(flame_hit==1 || bullet_hit==1) begin
            enemy_5_attacked = 1;
        end
        else begin
            enemy_5_attacked = 0;
        end
    end    
    else if(pepe_hit_5==1) begin
        o_red=enemy_red_6;
        o_green=enemy_green_6;
        o_blue=enemy_blue_6;
        if(flame_hit==1 || bullet_hit==1) begin
            enemy_6_attacked = 1;
        end
        else begin
            enemy_6_attacked = 0;
        end
    end
    else if(flame_hit==1) begin
        o_red = flame_red;
        o_green = flame_green;
        o_blue = flame_blue;
        if(boss_hit==1) begin
            boss_attacked = 1'd1;
        end
        else begin
            boss_attacked = 1'd0;
        end
    end
    else if(bullet_hit==1) begin
        o_red = bullet_red;
        o_green = bullet_green;
        o_blue = bullet_blue;
        if(boss_hit==1) begin
            boss_attacked = 1'd1;
        end
        else begin
            boss_attacked = 1'd0;
        end
    end
    
    
    else if(boss_hit==1) begin
        o_red = boss_red;
        o_green = boss_green;
        o_blue = boss_blue;
    end
    else if(tree_hit_1==1) begin
        o_red = tree_red_1;
        o_green = tree_green_1;
        o_blue = tree_blue_1;
    end
    else if(road_1_hit==1 || road_2_hit==1) begin
        o_red=8'hFF;
        o_green=8'h66;
        o_blue=8'h00;
    end
    else begin //배경 풀받은 민트색 이미지로 대체함.
        o_red=8'h33;
        o_green=8'hCC;
        o_blue=8'h66;
    end
    end
    
endmodule