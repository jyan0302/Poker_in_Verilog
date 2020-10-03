`timescale 1ns/ 1ns

module Poker
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,
		LEDR,
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4,
		HEX5,
		// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
		
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;

	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	
	
	wire [6:0]bet=SW[6:0];
	
	wire clk = CLOCK_50;
	
	wire proceed = ~KEY[0];
	wire check = SW[7];
	wire raise = SW[8];
	
	wire resetn = ~KEY[1];
	
	wire [4:0] choosedraw = SW[4:0];
	
	wire [3:0] display0,display1,display2,display3,display4,display5;
	
	wire invalid_input, skip_bet, shuffle_success;
	
	wire player1_bet_status, player2_bet_status, start_game, player1_check_status, player2_check_status;
	
	wire initialize,
	 start_again,
	 player1_fold_data,
	 player1_check_data,
	 player1_raise_data,
	 player2_fold_data,
	 player2_check_data,
	 player2_raise_data,
	 display_winner_data,
	 tablecard0_data,
	 tablecard1_data,
	 tablecard2_data,
	 tablecard3_data,
	 tablecard4_data,
	 playercard0_data,
	 playercard1_data,
	 playercard2_data,
	 playercard3_data,
	 check_shuffle_data,
	 
	 deal_player_1_on_data,
	 deal_player_1_off_data,
	 deal_player_2_on_data,
	 deal_player_2_off_data,
	 deal_player_3_on_data,
	 deal_player_3_off_data,
	 deal_player_4_on_data,
	 deal_player_4_off_data,
	 deal_1_on_data,
	 deal_1_off_data,
	 deal_2_on_data,
	 deal_2_off_data,
	 deal_3_on_data,
	 deal_3_off_data,
	 deal_4_on_data,
	 deal_4_off_data,
	 deal_5_on_data,
	 deal_5_off_data,
	 
	 unshow_1_on_data,
	 unshow_2_on_data,
	 unshow_3_on_data,
	 unshow_4_on_data,
	 unshow_5_on_data,
	 unshow_6_on_data,
	 unshow_7_on_data,
	 unshow_8_on_data,
	 unshow_9_on_data,
	 unshow_1_off_data,
	 unshow_2_off_data,
	 unshow_3_off_data,
	 unshow_4_off_data,
	 unshow_5_off_data,
	 unshow_6_off_data,
	 unshow_7_off_data,
	 unshow_8_off_data,
	 unshow_9_off_data;
	
	
	hexDisplay hexDisplay0(display0,HEX0);
	hexDisplay hexDisplay1(display1,HEX1);
	hexDisplay hexDisplay2(display2,HEX2);
	hexDisplay hexDisplay3(display3,HEX3);
	hexDisplay hexDisplay4(display4,HEX4);
	hexDisplay hexDisplay5(display5,HEX5);
	
	reg led0,led1,led2,led3,led4,led5,led6,led7,led8,led9;
	
	always @(*) begin
		if (SW[9]) begin
		 led0 = tablecard0_data;
		 led1 = tablecard1_data;
		 led2 = tablecard2_data;
		 led3 = tablecard3_data;
		 led4 = tablecard4_data;
		 led5 = playercard0_data;
		 led6 = playercard1_data;
		 led7 = playercard2_data;
		 led8 = playercard3_data;
		 led9 = display_winner_data;
		end
		
		else begin
		led0 = player1_bet_status;
		led1 = player2_bet_status;
		led2 = start_game;
		led3 = deal_player_1_on_data||deal_player_2_on_data||deal_player_3_on_data||deal_player_4_on_data;
		led4 = deal_1_on_data||deal_2_on_data||deal_3_on_data;
		led5 = deal_4_on_data;
		led6 = deal_5_on_data;
		led7 = invalid_input;
		led8 = display_winner_data;
		led9 = start_again;
		end
	end
	
	assign LEDR[0] = led0;
	assign LEDR[1] = led1;
	assign LEDR[2] = led2;
	assign LEDR[3] = led3;
	assign LEDR[4] = led4;
	assign LEDR[5] = led5;
	assign LEDR[6] = led6;
	assign LEDR[7] = led7;
	assign LEDR[8] = led8;
	assign LEDR[9] = led9;
	
	
	
	control control(//clk,
	 proceed, resetn, check, raise,
	 invalid_input, skip_bet, shuffle_success, choosedraw,
	 
	 initialize,
	 start_again,
	 
	 player1_fold_data,
	 player1_check_data,
	 player1_raise_data,
	 
	 player2_fold_data,
	 player2_check_data,
	 player2_raise_data,
	 
	 display_winner_data,
	 player1_bet_status,
	 player2_bet_status,
	 start_game,
	 player1_check_status, player2_check_status,
	 
	 tablecard0_data,
	 tablecard1_data,
	 tablecard2_data,
	 tablecard3_data,
	 tablecard4_data,
	 playercard0_data,
	 playercard1_data,
	 playercard2_data,
	 playercard3_data,
	 check_shuffle_data,
	 
	 deal_player_1_on_data,
	 deal_player_1_off_data,
	 deal_player_2_on_data,
	 deal_player_2_off_data,
	 deal_player_3_on_data,
	 deal_player_3_off_data,
	 deal_player_4_on_data,
	 deal_player_4_off_data,
	 deal_1_on_data,
	 deal_1_off_data,
	 deal_2_on_data,
	 deal_2_off_data,
	 deal_3_on_data,
	 deal_3_off_data,
	 deal_4_on_data,
	 deal_4_off_data,
	 deal_5_on_data,
	 deal_5_off_data,
	 
	 unshow_1_on_data,
	 unshow_2_on_data,
	 unshow_3_on_data,
	 unshow_4_on_data,
	 unshow_5_on_data,
	 unshow_6_on_data,
	 unshow_7_on_data,
	 unshow_8_on_data,
	 unshow_9_on_data,
	 unshow_1_off_data,
	 unshow_2_off_data,
	 unshow_3_off_data,
	 unshow_4_off_data,
	 unshow_5_off_data,
	 unshow_6_off_data,
	 unshow_7_off_data,
	 unshow_8_off_data,
	 unshow_9_off_data
	 );
	 
	datapath datapath(
    clk,
	 proceed,
    bet,
	 initialize,
	 start_again,
	 player1_fold_data,
	 player1_check_data,
	 player1_raise_data,
	 player2_fold_data,
	 player2_check_data,
	 player2_raise_data,
	 
	 tablecard0_data,
	 tablecard1_data,
	 tablecard2_data,
	 tablecard3_data,
	 tablecard4_data,
	 playercard0_data,
	 playercard1_data,
	 playercard2_data,
	 playercard3_data,
	 check_shuffle_data,
	 
	 deal_player_1_on_data,
	 deal_player_1_off_data,
	 deal_player_2_on_data,
	 deal_player_2_off_data,
	 deal_player_3_on_data,
	 deal_player_3_off_data,
	 deal_player_4_on_data,
	 deal_player_4_off_data,
	 deal_1_on_data,
	 deal_1_off_data,
	 deal_2_on_data,
	 deal_2_off_data,
	 deal_3_on_data,
	 deal_3_off_data,
	 deal_4_on_data,
	 deal_4_off_data,
	 deal_5_on_data,
	 deal_5_off_data,
	 
	 unshow_1_on_data,
	 unshow_2_on_data,
	 unshow_3_on_data,
	 unshow_4_on_data,
	 unshow_5_on_data,
	 unshow_6_on_data,
	 unshow_7_on_data,
	 unshow_8_on_data,
	 unshow_9_on_data,
	 unshow_1_off_data,
	 unshow_2_off_data,
	 unshow_3_off_data,
	 unshow_4_off_data,
	 unshow_5_off_data,
	 unshow_6_off_data,
	 unshow_7_off_data,
	 unshow_8_off_data,
	 unshow_9_off_data,
	 display_winner_data,
	
	 invalid_input,
	 skip_bet,
	 shuffle_success,
	 display0,
	 display1,
	 display2,
	 display3,
	 display4,
	 display5,
	 card_reset_FSM,
	draw_card_FSM,
	card_num_FSM, 
   card_suit_FSM, // testing only spades
   card_pos_FSM
    );
	
	wire card_reset_FSM;
	wire [2:0] draw_card_FSM;
	wire  [3:0] card_num_FSM;
	wire  [1:0] card_suit_FSM;
	wire  [3:0] card_pos_FSM;
	
	vga_adapter VGA(
			.resetn(~card_reset_FSM),
			.clock(clk),
			.colour(outColour),
			.x(x_curr),
			.y(y_curr),
			.plot(1'b1),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "rsz_pokertable.mif";
		
	wire writeEn;
	
	// Signals
	wire drawCardBackEnable;
	wire drawCardBackEnd;
	wire screenDrawEnable;
	wire screenDrawEnd;
	
	wire [7:0] x_curr;
	wire [7:0] y_curr;
	wire [23:0] outColour;
	wire useless;
			
	wire [15:0] drawCounter;
	
	
	cardPosition cp (
	clk,
	card_reset_FSM,
	draw_card_FSM,
	card_num_FSM, 
	card_suit_FSM, // testing only spades
	card_pos_FSM, // card position [0-8]
	outColour,
	x_curr,
	y_curr,
	useless,
	drawCounter
	);
	
endmodule

module control(
    //input clk,
	 input proceed, resetn, check, raise,
	 input invalid_input, skip_bet, shuffle_success, input [4:0] choosedraw,
	 
	 output reg initialize,
	 output reg start_again,
	 
	 
	 output reg player1_fold_data,
	 output reg player1_check_data,
	 output reg player1_raise_data,
	 
	 output reg player2_fold_data,
	 output reg player2_check_data,
	 output reg player2_raise_data,
	 
	 output reg display_winner_data,
	 output reg player1_bet_status,
	 output reg player2_bet_status,
	 output reg start_game,
	 output reg player1_check_status, player2_check_status,
	 
	 tablecard0_data,
	 tablecard1_data,
	 tablecard2_data,
	 tablecard3_data,
	 tablecard4_data,
	 playercard0_data,
	 playercard1_data,
	 playercard2_data,
	 playercard3_data,
	 check_shuffle_data,
	 
	 deal_player_1_on_data,
	 deal_player_1_off_data,
	 deal_player_2_on_data,
	 deal_player_2_off_data,
	 deal_player_3_on_data,
	 deal_player_3_off_data,
	 deal_player_4_on_data,
	 deal_player_4_off_data,
	 deal_1_on_data,
	 deal_1_off_data,
	 deal_2_on_data,
	 deal_2_off_data,
	 deal_3_on_data,
	 deal_3_off_data,
	 deal_4_on_data,
	 deal_4_off_data,
	 deal_5_on_data,
	 deal_5_off_data,
	 
	 unshow_1_on_data,
	 unshow_2_on_data,
	 unshow_3_on_data,
	 unshow_4_on_data,
	 unshow_5_on_data,
	 unshow_6_on_data,
	 unshow_7_on_data,
	 unshow_8_on_data,
	 unshow_9_on_data,
	 unshow_1_off_data,
	 unshow_2_off_data,
	 unshow_3_off_data,
	 unshow_4_off_data,
	 unshow_5_off_data,
	 unshow_6_off_data,
	 unshow_7_off_data,
	 unshow_8_off_data,
	 unshow_9_off_data
	 
    );

    reg [6:0] current_state, next_state; 
	 reg [6:0] current_round;
    
    localparam 
					 state_game 		= 7'd0, //request input to start game, KEY0
                state_initialize = 7'd2, //initialize game, give players 100, ran once
					 state_play_again       = 7'd3, //request input to play again, if possible, KEY0
					 
					 player1_bet     	= 7'd7, //player1's turn to bet
					 player2_bet      = 7'd8, //player2's turn to bet
					 player1_fold     = 7'd9,
					 player2_fold     = 7'd10, 
					 player1_check    = 7'd11,
					 player2_check    = 7'd12, 
					 player1_raise    = 7'd13,
					 player2_raise    = 7'd14,
					 
					 check_shuffle = 7'd15, //check if deck is shuffled, no duplicates
					
					 pick_table0_on = 7'd16,	//manually picks card 1-9
					 pick_table0_off = 7'd17,
					 pick_table1_on = 7'd18,
					 pick_table1_off = 7'd19,
					 pick_table2_on = 7'd20,
					 pick_table2_off = 7'd21,
					 pick_table3_on = 7'd22,
					 pick_table3_off = 7'd23,
					 pick_table4_on = 7'd24,
					 pick_table4_off = 7'd25,
					 pick_player0_on = 7'd26,
					 pick_player0_off = 7'd27,
					 pick_player1_on = 7'd28,
					 pick_player1_off = 7'd29,
					 pick_player2_on = 7'd30,
					 pick_player2_off = 7'd31,
					 pick_player3_on = 7'd32,
					 pick_player3_off = 7'd33,
					 
					 deal_player_1_on      = 7'd34, //deals 4 cards, 2 to each player
					 deal_player_1_off      = 7'd35,
					 deal_player_2_on      = 7'd36,
					 deal_player_2_off      = 7'd37,
					 deal_player_3_on      = 7'd38,
					 deal_player_3_off      = 7'd39,
					 deal_player_4_on      = 7'd40,
					 deal_player_4_off      = 7'd41,
					 
					 
					 deal_1_on      = 7'd42,		//deals 5 cards on the table
					 deal_1_off      = 7'd43,
					 deal_2_on      = 7'd44,
					 deal_2_off      = 7'd45,
					 deal_3_on      = 7'd46,
					 deal_3_off      = 7'd47,
					 deal_4_on      = 7'd50,
					 deal_4_off      = 7'd51,
					 deal_5_on      = 7'd52,
					 deal_5_off      = 7'd53,
					 
					 display_winner   = 7'd54, //determine winner and check for replay conditions
					 
					 unshow_1_on = 7'd55,		//unshows all cards on the table
					 unshow_1_off = 7'd56,
					 unshow_2_on = 7'd57,
					 unshow_2_off = 7'd58,
					 unshow_3_on = 7'd59,
					 unshow_3_off = 7'd60,
					 unshow_4_on = 7'd61,
					 unshow_4_off = 7'd62,
					 unshow_5_on = 7'd63,
					 unshow_5_off = 7'd64,
					 unshow_6_on = 7'd65,
					 unshow_6_off = 7'd66,
					 unshow_7_on = 7'd67,
					 unshow_7_off = 7'd68,
					 unshow_8_on = 7'd69,
					 unshow_8_off = 7'd70,
					 unshow_9_on = 7'd71,
					 unshow_9_off = 7'd72;
					 
					 
				
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                state_game: next_state = state_initialize; //startgame does nothing, just waits
                state_initialize: next_state = pick_table0_on+choosedraw;//pick_table0_on; //initializes game
					 state_play_again: next_state = pick_table0_on+choosedraw; //play again also does nothing, just waits

					 pick_table0_on: next_state = pick_table0_off;
					 pick_table0_off: next_state = deal_player_1_on;
					 
					 pick_table1_on: next_state = pick_table1_off;
					 pick_table1_off: next_state = display_winner;
					 
					 pick_table2_on: next_state = pick_table2_off;
					 pick_table2_off: next_state = display_winner;
					 
					 pick_table3_on: next_state = pick_table3_off;
					 pick_table3_off: next_state = display_winner;
					 
					 pick_table4_on: next_state = pick_table4_off;
					 pick_table4_off: next_state = display_winner;
					 
					 pick_player0_on: next_state = pick_player0_off;
					 pick_player0_off: next_state = display_winner;
					 
					 pick_player1_on: next_state = pick_player1_off;
					 pick_player1_off: next_state = display_winner;
					 
					 pick_player2_on: next_state = pick_player2_off;
					 pick_player2_off: next_state = display_winner;
					 
					 pick_player3_on: next_state = pick_player3_off;
					 pick_player3_off: next_state = display_winner;
					 
					 deal_player_1_on: next_state = deal_player_1_off;
					 
					 deal_player_1_off: next_state = deal_player_2_on;
					 
					 deal_player_2_on: next_state = deal_player_2_off;
					 
					 deal_player_2_off: next_state = deal_player_3_on;
					 
					 deal_player_3_on: next_state = deal_player_3_off;
					 
					 deal_player_3_off: next_state = deal_player_4_on;
					 
					 deal_player_4_on: next_state = deal_player_4_off;
					 
					 deal_player_4_off: next_state = deal_1_on;
					 
					 player1_bet: begin
						 if (skip_bet) begin
						 next_state = display_winner;
						 end
						 else if (check&&raise) begin
						 next_state = player1_fold;
						 end
						 else if (check) begin
						 next_state = player1_check;
						 end
						 else if (raise) begin
						 next_state = player1_raise;
						 end
						 else begin
						 next_state = player1_bet;
						 end
					 end
					 
					 player1_fold: next_state = display_winner;
					 player1_check: next_state = player2_check_status? (current_round) : player2_bet;
					 player1_raise: next_state = player2_bet;
					 
					 player2_bet: begin
						 if (skip_bet) begin
						 next_state = display_winner;
						 end
						 else if (check&&raise) begin
						 next_state = player2_fold;
						 end
						 else if (check)begin
						 next_state = player2_check;
						 end
						 else if (raise) begin
						 next_state = player2_raise;
						 end
						 else begin
						 next_state = player2_bet;
						 end
					 end
					
					 player2_fold: next_state = display_winner;
					 player2_check: next_state = player1_check_status? (current_round) : player1_bet;
					 player2_raise: next_state = player1_bet;
					 
					 deal_1_on: next_state = deal_1_off;
					 
					 deal_1_off: next_state = deal_2_on;
					 
					 deal_2_on: next_state = deal_2_off;
					 
					 deal_2_off: next_state = deal_3_on;
					 
					 deal_3_on: next_state = deal_3_off;
					
					 deal_3_off: next_state = deal_4_on;
					 
					 deal_4_on: next_state = deal_4_off;
					
					 deal_4_off: next_state = deal_5_on;
					 
					 deal_5_on: next_state = deal_5_off;
					
					 deal_5_off: next_state = display_winner;
					 
					 display_winner: next_state = state_play_again;
					 
					 unshow_1_on: next_state = unshow_1_off;
					 
					 unshow_1_off: next_state = unshow_2_on;
					 
					 unshow_2_on: next_state = unshow_2_off;
					 
					 unshow_2_off: next_state = unshow_3_on;
					 
					 unshow_3_on: next_state = unshow_3_off;
					 
					 unshow_3_off: next_state = unshow_4_on;
					 
					 unshow_4_on: next_state = unshow_4_off;
					 
					 unshow_4_off: next_state = unshow_5_on;
					 
					 unshow_5_on: next_state = unshow_5_off;
					 
					 unshow_5_off: next_state = unshow_6_on;
					 
					 unshow_6_on: next_state = unshow_6_off;
					 
					 unshow_6_off: next_state = unshow_7_on;
					 
					 unshow_7_on: next_state = unshow_7_off;
					 
					 unshow_7_off: next_state = unshow_8_on;
					 
					 unshow_8_on: next_state = unshow_8_off;
					 
					 unshow_8_off: next_state = unshow_9_on;
					 
					 unshow_9_on: next_state = unshow_9_off;
					 
					 unshow_9_off: next_state = pick_table0_on;
					
            default:     next_state = state_game;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
	 start_game = 1'b0;
	 initialize = 1'b0;
	 start_again = 1'b0;
	 
	 player1_fold_data = 1'b0;
	 player1_check_data = 1'b0;
	 player1_raise_data = 1'b0;
	 
	 player2_fold_data = 1'b0;
	 player2_check_data = 1'b0;
	 player2_raise_data = 1'b0;
	 
	 display_winner_data = 1'b0;
	 player1_bet_status = 1'b0;
	 player2_bet_status = 1'b0;
	 
	 tablecard0_data = 1'b0;
	 tablecard1_data = 1'b0;
	 tablecard2_data = 1'b0;
	 tablecard3_data = 1'b0;
	 tablecard4_data = 1'b0;
	 playercard0_data = 1'b0;
	 playercard1_data = 1'b0;
	 playercard2_data = 1'b0;
	 playercard3_data = 1'b0;
	 
	 check_shuffle_data = 1'b0;
	 
	 deal_player_1_on_data = 1'b0;
	 deal_player_1_off_data = 1'b0;
	 deal_player_2_on_data = 1'b0;
	 deal_player_2_off_data = 1'b0;
	 deal_player_3_on_data = 1'b0;
	 deal_player_3_off_data = 1'b0;
	 deal_player_4_on_data = 1'b0;
	 deal_player_4_off_data = 1'b0;
	 deal_1_on_data = 1'b0;
	 deal_1_off_data = 1'b0;
	 deal_2_on_data = 1'b0;
	 deal_2_off_data = 1'b0;
	 deal_3_on_data = 1'b0;
	 deal_3_off_data = 1'b0;
	 deal_4_on_data = 1'b0;
	 deal_4_off_data = 1'b0;
	 deal_5_on_data = 1'b0;
	 deal_5_off_data = 1'b0;
	 
	 unshow_1_on_data = 1'b0;
	 unshow_2_on_data = 1'b0;
	 unshow_3_on_data = 1'b0;
	 unshow_4_on_data = 1'b0;
	 unshow_5_on_data = 1'b0;
	 unshow_6_on_data = 1'b0;
	 unshow_7_on_data = 1'b0;
	 unshow_8_on_data = 1'b0;
	 unshow_9_on_data = 1'b0;
	 unshow_1_off_data = 1'b0;
	 unshow_2_off_data = 1'b0;
	 unshow_3_off_data = 1'b0;
	 unshow_4_off_data = 1'b0;
	 unshow_5_off_data = 1'b0;
	 unshow_6_off_data = 1'b0;
	 unshow_7_off_data = 1'b0;
	 unshow_8_off_data = 1'b0;
	 unshow_9_off_data = 1'b0;
	 
	 
        case (current_state)
		  
				state_game: begin
				start_game = 1'b1;
				end

				state_initialize: begin
				initialize = 1'b1;
				end

				state_play_again: begin
				start_again = 1'b1;
				end

				player1_bet: begin
				player1_bet_status = 1'b1;
				end

				player1_fold: begin
				player1_fold_data = 1'b1;
				end

				player1_check: begin
				player1_check_data = 1'b1;
				end

				player1_raise: begin
				player1_raise_data = 1'b1;
				end


				player2_bet: begin
				player2_bet_status = 1'b1;
				end

				player2_fold: begin
				player2_fold_data = 1'b1;
				end

				player2_check: begin
				player2_check_data = 1'b1;
				end

				player2_raise: begin
				player2_raise_data = 1'b1;
				end

				display_winner: begin
				display_winner_data = 1'b1;
				end

				pick_table0_on: begin
				tablecard0_data = 1'b1;
				end

				pick_table1_on: begin
				tablecard1_data = 1'b1;
				end
				pick_table2_on: begin
				tablecard2_data = 1'b1;
				end
				pick_table3_on: begin
				tablecard3_data = 1'b1;
				end
				pick_table4_on: begin
				tablecard4_data = 1'b1;
				end
				pick_player0_on: begin
				playercard0_data = 1'b1;
				end
				pick_player1_on: begin
				playercard1_data = 1'b1;
				end
				pick_player2_on: begin
				playercard2_data = 1'b1;
				end
				pick_player3_on: begin
				
				check_shuffle: begin
				check_shuffle_data = 1'b1;
				end
				playercard3_data = 1'b1;
				end
				
				deal_player_1_on: deal_player_1_on_data = 1'b1;
				
				deal_player_1_off: deal_player_1_off_data = 1'b1;
				
				deal_player_2_on: deal_player_2_on_data = 1'b1;
				
				deal_player_2_off: deal_player_2_off_data = 1'b1;

				deal_player_3_on: deal_player_3_on_data = 1'b1;
				
				deal_player_3_off: deal_player_3_off_data = 1'b1;

				deal_player_4_on: deal_player_4_on_data = 1'b1;
				
				deal_player_4_off: deal_player_4_off_data = 1'b1;
				
				deal_1_on: deal_1_on_data = 1'b1;
				
				deal_1_off: deal_1_off_data = 1'b1;
				
				deal_2_on: deal_2_on_data = 1'b1;
				
				deal_2_off: deal_2_off_data = 1'b1;

				deal_3_on: deal_3_on_data = 1'b1;
				
				deal_3_off: deal_3_off_data = 1'b1;

				deal_4_on: deal_4_on_data = 1'b1;
				
				deal_4_off: deal_4_off_data = 1'b1;

				deal_5_on: deal_5_on_data = 1'b1;
				
				deal_5_off: deal_5_off_data = 1'b1;
				
				unshow_1_on: unshow_1_on_data = 1'b1;
				unshow_2_on: unshow_2_on_data = 1'b1;
				unshow_3_on: unshow_3_on_data = 1'b1;
				unshow_4_on: unshow_4_on_data = 1'b1;
				unshow_5_on: unshow_5_on_data = 1'b1;
				unshow_6_on: unshow_6_on_data = 1'b1;
				unshow_7_on: unshow_7_on_data = 1'b1;
				unshow_8_on: unshow_8_on_data = 1'b1;
				unshow_9_on: unshow_9_on_data = 1'b1;
				
				unshow_1_off: unshow_1_off_data = 1'b1;
				unshow_2_off: unshow_2_off_data = 1'b1;
				unshow_3_off: unshow_3_off_data = 1'b1;
				unshow_4_off: unshow_4_off_data = 1'b1;
				unshow_5_off: unshow_5_off_data = 1'b1;
				unshow_6_off: unshow_6_off_data = 1'b1;
				unshow_7_off: unshow_7_off_data = 1'b1;
				unshow_8_off: unshow_8_off_data = 1'b1;
				unshow_9_off: unshow_9_off_data = 1'b1;
				

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(negedge proceed) begin
				if (resetn) begin
				current_state = state_game;
				end
				else if (~invalid_input) begin
					if (next_state == player1_check)
					player1_check_status = 1'b1;
					else if (next_state == player2_check)
					player2_check_status = 1'b1;
					else if (next_state == player1_bet)
					player1_check_status = 1'b0;
					else if (next_state == player2_bet)
					player2_check_status = 1'b0;
					else if (next_state == deal_player_1_on) begin
					current_round = 7'd42;
					player1_check_status = 1'b0;
					player2_check_status = 1'b0;
					end
					else if (next_state == deal_1_on) begin
					current_round = 7'd50;
					player1_check_status = 1'b0;
					player2_check_status = 1'b0;
					end
					else if (next_state == deal_4_on) begin
					current_round = 7'd52;
					player1_check_status = 1'b0;
					player2_check_status = 1'b0;
					end
					else if (next_state == deal_5_on) begin
					current_round = 7'd54;
					player1_check_status = 1'b0;
					player2_check_status = 1'b0;
					end
					if ((current_state == check_shuffle) && (shuffle_success==0)) begin
					current_state = pick_table0_on;
					end
					else 
					current_state = next_state;
				end
    end // state_FFS
endmodule

module datapath(
    input clk,
	 input proceed,
    input [6:0]bet,
	 input initialize,
	
	 input start_again,
	 input player1_fold_data,
	 input player1_check_data,
	 input player1_raise_data,

	 input player2_fold_data,
	 input player2_check_data,
	 input player2_raise_data,
		
	 input tablecard0_data,
	 tablecard1_data,
	 tablecard2_data,
	 tablecard3_data,
	 tablecard4_data,
	 playercard0_data,
	 playercard1_data,
	 playercard2_data,
	 playercard3_data,
	 check_shuffle_data,
	 
	 deal_player_1_on_data,
	 deal_player_1_off_data,
	 deal_player_2_on_data,
	 deal_player_2_off_data,
	 deal_player_3_on_data,
	 deal_player_3_off_data,
	 deal_player_4_on_data,
	 deal_player_4_off_data,
	 deal_1_on_data,
	 deal_1_off_data,
	 deal_2_on_data,
	 deal_2_off_data,
	 deal_3_on_data,
	 deal_3_off_data,
	 deal_4_on_data,
	 deal_4_off_data,
	 deal_5_on_data,
	 deal_5_off_data,
	 
	 unshow_1_on_data,
	 unshow_2_on_data,
	 unshow_3_on_data,
	 unshow_4_on_data,
	 unshow_5_on_data,
	 unshow_6_on_data,
	 unshow_7_on_data,
	 unshow_8_on_data,
	 unshow_9_on_data,
	 unshow_1_off_data,
	 unshow_2_off_data,
	 unshow_3_off_data,
	 unshow_4_off_data,
	 unshow_5_off_data,
	 unshow_6_off_data,
	 unshow_7_off_data,
	 unshow_8_off_data,
	 unshow_9_off_data,
	 
	 display_winner_data,
	
	 output reg invalid_input,
	 output reg skip_bet, shuffle_success,
	 output [3:0] display0,
	 output [3:0] display1,
	 output [3:0] display2,
	 output [3:0] display3,
	 output [3:0] display4,
	 output [3:0] display5,
	 
	 output  reg card_reset_FSM,
	output reg [2:0] draw_card_FSM,
	output reg [3:0] card_num_FSM, 
   output reg [1:0] card_suit_FSM, // testing only spades
   output reg [3:0] card_pos_FSM
 	
    );
	   
    
 
 reg [7:0] player1_cash;
 reg [7:0] player2_cash;
 reg [7:0] cashpot;
 reg [7:0] current_bet;
 
reg [7:0] tablecard0,tablecard1,tablecard2,tablecard3,tablecard4,playercard0,playercard1,playercard2,playercard3;
 
 /*
 assign display5 = current_bet[7:4];
 assign display4 = current_bet [3:0];
 assign display3 = player2_cash[7:4];
 assign display2 = player2_cash[3:0];
 assign display1 = player1_cash[7:4];
 assign display0 = player1_cash[3:0];
 */
 
	reg [3:0] player1card0equalnum;
	reg [3:0] player1card1equalnum;
	reg [3:0] player1card0equalsuit;
	reg [3:0] player1card1equalsuit;
	reg [7:0] player1highestwin;
	reg player1fourkind, player1flush, player1straight;//[7:4] for marker, [3:0] for win type
 
 

 always@(posedge proceed) begin
	 invalid_input = 1'b0;
	 
	 if (initialize) begin
		 player1_cash=8'b01100100;
		 player2_cash=8'b01100100;
		 cashpot=8'b0;
		 current_bet=8'b0;
		 skip_bet=1'b0;
		 invalid_input = 1'b0;
		 player1card0equalnum=1'b0;
		 player1card1equalnum=1'b0;
		 player1card0equalsuit=1'b0;
		 player1card1equalsuit=1'b0;
		 player1highestwin=1'b0;
		 player1fourkind=1'b0;
		 player1flush=1'b0;
		 player1straight=1'b0;
	 end
	 
	 else if (start_again) begin
		 cashpot=8'b0;
		 current_bet=8'b0;
		 skip_bet=1'b0;
		 invalid_input = 1'b0;
		 player1card0equalnum=1'b0;
		 player1card1equalnum=1'b0;
		 player1card0equalsuit=1'b0;
		 player1card1equalsuit=1'b0;
		 player1highestwin=1'b0;
		 player1fourkind=1'b0;
		 player1flush=1'b0;
		 player1straight=1'b0;
	 end
	 
	 else if (player1_check_data)begin
		 if (player1_cash>current_bet) begin //has enough money to check
			 player1_cash = player1_cash - current_bet;
			 cashpot = cashpot + current_bet;
			 current_bet=8'b0;
		 end
		 
		 else begin
			 cashpot = cashpot + player1_cash; //doesn't have enough money to check, puts all in and ends betting, proceed to last round
			 player1_cash = 8'b0;
			 current_bet = 8'b0;
			 skip_bet = 1'b1;
		 end
		 
	 end
	 
	 else if (player1_raise_data)begin
		 if ((player1_cash>=(current_bet+bet)) && (bet>7'b0)) begin //has enough money to check
			 player1_cash = player1_cash - (current_bet+bet);
			 cashpot = cashpot + current_bet;
			 current_bet = bet;
		 end
		 
		 else
			invalid_input = 1'b1;
	 end
	 
	 else if (player2_check_data)begin
		 if (player2_cash>current_bet) begin //has enough money to check
			 player2_cash = player2_cash - current_bet;
			 cashpot = cashpot + current_bet;
			 current_bet=8'b0;
		 end
		 
		 else begin
			 cashpot = cashpot + player2_cash; //doesn't have enough money to check, puts all in and ends betting, proceed to last round
			 player2_cash = 8'b0;
			 current_bet = 8'b0;
			 skip_bet = 1'b1;
		 end
	 end
	 
	 else if (player2_raise_data)begin
		 if ((player2_cash>=(current_bet+bet)) && (bet>7'b0))begin //has enough money to check
			 player2_cash = player2_cash - (current_bet+bet);
			 cashpot = cashpot + current_bet;
			 current_bet = bet;
		 end
		 
		 else
			invalid_input = 1'b1;
	 end
	 else if (check_shuffle_data) begin
		 if 
		   ((tablecard0!=tablecard1)
			&&(tablecard0!=tablecard2)
			&&(tablecard0!=tablecard3)
			&&(tablecard0!=tablecard4)
			&&(tablecard0!=playercard0)
			&&(tablecard0!=playercard1)
			&&(tablecard0!=playercard2)
			&&(tablecard0!=playercard3)
			
			&&(tablecard1!=tablecard2)
			&&(tablecard1!=tablecard3)
			&&(tablecard1!=tablecard4)
			&&(tablecard1!=playercard0)
			&&(tablecard1!=playercard1)
			&&(tablecard1!=playercard2)
			&&(tablecard1!=playercard3)

			&&(tablecard2!=tablecard3)
			&&(tablecard2!=tablecard4)
			&&(tablecard2!=playercard0)
			&&(tablecard2!=playercard1)
			&&(tablecard2!=playercard2)
			&&(tablecard2!=playercard3)

			&&(tablecard3!=tablecard4)
			&&(tablecard3!=playercard0)
			&&(tablecard3!=playercard1)
			&&(tablecard3!=playercard2)
			&&(tablecard3!=playercard3)
			
			&&(tablecard4!=playercard0)
			&&(tablecard4!=playercard1)
			&&(tablecard4!=playercard2)
			&&(tablecard4!=playercard3)
			
			&&(playercard0!=playercard1)
			&&(playercard0!=playercard2)
			&&(playercard0!=playercard3)
			
			&&(playercard1!=playercard2)
			&&(playercard1!=playercard3)
			
			&&(playercard2!=playercard3)) begin
			
			shuffle_success=1'b1;
			end
			else 
			shuffle_success=1'b0;
		   end
				
					
		else if (deal_player_1_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = playercard0[3:0];
		card_suit_FSM = playercard0[5:4];
		card_pos_FSM = 4'b0;
		card_reset_FSM = 1'b1;
		end
		
		else if (deal_player_2_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = playercard1[3:0];
		card_suit_FSM = playercard1[5:4];
		card_pos_FSM = 4'b10;
		card_reset_FSM = 1'b1;
		end
		
		else if (deal_player_3_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = playercard2[3:0];
		card_suit_FSM = playercard2[5:4];
		card_pos_FSM = 4'b1;
		card_reset_FSM = 1'b1;
		end
		
		else if (deal_player_4_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = playercard3[3:0];
		card_suit_FSM = playercard3[5:4];
		card_pos_FSM = 4'b11;
		card_reset_FSM = 1'b1;
		end
		
		else if (deal_1_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b100;
		card_reset_FSM = 1'b1;
		end
		
		else if (deal_2_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = tablecard1[3:0];
		card_suit_FSM = tablecard1[5:4];
		card_pos_FSM = 4'b101;
		card_reset_FSM = 1'b1;
		end
		
		else if (deal_3_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = tablecard2[3:0];
		card_suit_FSM = tablecard2[5:4];
		card_pos_FSM = 4'b110;
		card_reset_FSM = 1'b1;
		end
		
		
		else if (deal_4_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = tablecard3[3:0];
		card_suit_FSM = tablecard3[5:4];
		card_pos_FSM = 4'b111;
		card_reset_FSM = 1'b1;
		end
		
		
		else if (deal_5_on_data) begin
		draw_card_FSM = 3'b000;
		card_num_FSM = tablecard4[3:0];
		card_suit_FSM = tablecard4[5:4];
		card_pos_FSM = 4'b1000;
		card_reset_FSM = 1'b1;
		end
		
	   else if (deal_player_1_off_data) 
			card_reset_FSM = 1'b0;
	   else if (deal_player_2_off_data) 
			card_reset_FSM = 1'b0;
	   else if (deal_player_3_off_data)
			card_reset_FSM = 1'b0;
	   else if (deal_player_4_off_data)
			card_reset_FSM = 1'b0;
	   else if (deal_1_off_data)
			card_reset_FSM = 1'b0;
	   else if (deal_2_off_data)
			card_reset_FSM = 1'b0;
	   else if (deal_3_off_data)
			card_reset_FSM = 1'b0;
	   else if (deal_4_off_data)
			card_reset_FSM = 1'b0;
	   else if (deal_5_off_data)
			card_reset_FSM = 1'b0;
			
		else if (unshow_1_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b0;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_2_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b10;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_3_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b1;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_4_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b11;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_5_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b100;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_6_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b101;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_7_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b110;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_8_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b111;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_9_on_data) begin
		draw_card_FSM = 3'b001;
		card_num_FSM = tablecard0[3:0];
		card_suit_FSM = tablecard0[5:4];
		card_pos_FSM = 4'b1000;
		card_reset_FSM = 1'b1;
		end
		
		else if (unshow_1_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_2_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_3_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_4_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_5_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_6_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_7_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_8_off_data) 
		card_reset_FSM = 1'b0;
		else if (unshow_9_off_data) 
		card_reset_FSM = 1'b0;
		
		//player1win
		//draw_card_FSM = 3'b10;
		//card_num_FSM = tablecard0[3:0];
		//card_suit_FSM = tablecard0[5:4];
		//card_pos_FSM = 4'b1001;
		//card_reset_FSM = 1'b1;
		
		//player2win
		//draw_card_FSM = 3'b11;
		//card_num_FSM = tablecard0[3:0];
		//card_suit_FSM = tablecard0[5:4];
		//card_pos_FSM = 4'b1001;
		//card_reset_FSM = 1'b1;
		
		else if (display_winner_data) begin
		
		
		//check player1
		
		player1card0equalnum = (playercard0[3:0]==playercard1[3:0]) + (playercard0[3:0]==tablecard0[3:0]) + (playercard0[3:0]==tablecard1[3:0]) + (playercard0[3:0]==tablecard2[3:0]) + (playercard0[3:0]==tablecard3[3:0]) + (playercard0[3:0]==tablecard4[3:0])+'d1;
		player1card1equalnum = (playercard1[3:0]==playercard0[3:0]) + (playercard1[3:0]==tablecard0[3:0]) + (playercard1[3:0]==tablecard1[3:0]) + (playercard1[3:0]==tablecard2[3:0]) + (playercard1[3:0]==tablecard3[3:0]) + (playercard1[3:0]==tablecard4[3:0])+'d1;
		
		player1card0equalsuit = (playercard0[5:4]==playercard1[5:4]) + (playercard0[5:4]==tablecard0[5:4]) + (playercard0[5:4]==tablecard1[5:4]) + (playercard0[5:4]==tablecard2[5:4]) + (playercard0[5:4]==tablecard3[5:4]) + (playercard0[5:4]==tablecard4[5:4])+'d1;
		player1card1equalsuit = (playercard1[5:4]==playercard0[5:4]) + (playercard1[5:4]==tablecard0[5:4]) + (playercard1[5:4]==tablecard1[5:4]) + (playercard1[5:4]==tablecard2[5:4]) + (playercard1[5:4]==tablecard3[5:4]) + (playercard1[5:4]==tablecard4[5:4])+'d1;
		
		
		if (player1card0equalnum=='d4) begin
			player1highestwin[3:0]=4'd8; //four of a kind
			player1highestwin[7:4]=playercard0[3:0];
			player1fourkind=1'b1;
		end
		
		else if (player1card1equalnum=='d4) begin
			player1highestwin[3:0]=4'd8; //four of a kind
			player1highestwin[7:4]=playercard1[3:0];
			player1fourkind=1'b1;
		end
		
		else if (player1card0equalsuit>='d5) begin
			player1highestwin[3:0]=4'd6; //flush
			player1flush=1'b1;
			player1highestwin[7:4]=playercard0[3:0];
			/*
			if (((playercard0[5:4]==playercard1[5:4])&&(playercard0[3:0]>=playercard1[3:0])) //if the same suit and is at least as all the other cards
			+((playercard0[5:4]==tablecard0[5:4])&&(playercard0[3:0]>=tablecard0[3:0]))
			+((playercard0[5:4]==tablecard1[5:4])&&(playercard0[3:0]>=tablecard1[3:0]))
			+((playercard0[5:4]==tablecard2[5:4])&&(playercard0[3:0]>=tablecard2[3:0]))
			+((playercard0[5:4]==tablecard3[5:4])&&(playercard0[3:0]>=tablecard3[3:0]))
			+((playercard0[5:4]==tablecard4[5:4])&&(playercard0[3:0]>=tablecard4[3:0]))==player1card0equalsuit)
			player1highestwin[7:4]=playercard0[3:0];
			
			else if ((playercard0[5:4]==playercard1[5:4])&&((playercard1[3:0]>=playercard0[3:0]) //playercard1 is largest
			+((playercard0[5:4]==tablecard0[5:4])&&(playercard1[3:0]>=tablecard0[3:0]))
			+((playercard0[5:4]==tablecard1[5:4])&&(playercard1[3:0]>=tablecard1[3:0]))
			+((playercard0[5:4]==tablecard2[5:4])&&(playercard1[3:0]>=tablecard2[3:0]))
			+((playercard0[5:4]==tablecard3[5:4])&&(playercard1[3:0]>=tablecard3[3:0]))
			+((playercard0[5:4]==tablecard4[5:4])&&(playercard1[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=playercard1[3:0];
			
			else if ((playercard0[5:4]==tablecard0[5:4])&&((tablecard0[3:0]>=playercard0[3:0]) 
			+((playercard0[5:4]==playercard1[5:4])&&(tablecard0[3:0]>=playercard1[3:0]))
			+((playercard0[5:4]==tablecard1[5:4])&&(tablecard0[3:0]>=tablecard1[3:0]))
			+((playercard0[5:4]==tablecard2[5:4])&&(tablecard0[3:0]>=tablecard2[3:0]))
			+((playercard0[5:4]==tablecard3[5:4])&&(tablecard0[3:0]>=tablecard3[3:0]))
			+((playercard0[5:4]==tablecard4[5:4])&&(tablecard0[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard0[3:0];
			
			else if ((playercard0[5:4]==tablecard1[5:4])&&((tablecard1[3:0]>=playercard0[3:0]) 
			+((playercard0[5:4]==tablecard0[5:4])&&(tablecard1[3:0]>=tablecard0[3:0]))
			+((playercard0[5:4]==playercard1[5:4])&&(tablecard1[3:0]>=playercard1[3:0]))
			+((playercard0[5:4]==tablecard2[5:4])&&(tablecard1[3:0]>=tablecard2[3:0]))
			+((playercard0[5:4]==tablecard3[5:4])&&(tablecard1[3:0]>=tablecard3[3:0]))
			+((playercard0[5:4]==tablecard4[5:4])&&(tablecard1[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard1[3:0];
			
			else if ((playercard0[5:4]==tablecard2[5:4])&&((tablecard2[3:0]>=playercard0[3:0]) 
			+((playercard0[5:4]==tablecard0[5:4])&&(tablecard2[3:0]>=tablecard0[3:0]))
			+((playercard0[5:4]==tablecard1[5:4])&&(tablecard2[3:0]>=tablecard1[3:0]))
			+((playercard0[5:4]==playercard1[5:4])&&(tablecard2[3:0]>=playercard1[3:0]))
			+((playercard0[5:4]==tablecard3[5:4])&&(tablecard2[3:0]>=tablecard3[3:0]))
			+((playercard0[5:4]==tablecard4[5:4])&&(tablecard2[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard2[3:0];
			
			else if ((playercard0[5:4]==tablecard3[5:4])&&((tablecard3[3:0]>=playercard0[3:0])
			+((playercard0[5:4]==tablecard0[5:4])&&(tablecard3[3:0]>=tablecard0[3:0]))
			+((playercard0[5:4]==tablecard1[5:4])&&(tablecard3[3:0]>=tablecard1[3:0]))
			+((playercard0[5:4]==tablecard2[5:4])&&(tablecard3[3:0]>=tablecard2[3:0]))
			+((playercard0[5:4]==playercard1[5:4])&&(tablecard3[3:0]>=playercard1[3:0]))
			+((playercard0[5:4]==tablecard4[5:4])&&(tablecard3[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard3[3:0];
			
			else if ((playercard0[5:4]==tablecard4[5:4])&&((tablecard4[3:0]>=playercard0[3:0]) 
			+((playercard0[5:4]==tablecard0[5:4])&&(tablecard4[3:0]>=tablecard0[3:0]))
			+((playercard0[5:4]==tablecard1[5:4])&&(tablecard4[3:0]>=tablecard1[3:0]))
			+((playercard0[5:4]==tablecard2[5:4])&&(tablecard4[3:0]>=tablecard2[3:0]))
			+((playercard0[5:4]==tablecard3[5:4])&&(tablecard4[3:0]>=tablecard3[3:0]))
			+((playercard0[5:4]==playercard1[5:4])&&(tablecard4[3:0]>=playercard1[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard4[3:0];
			*/
			
		end
		
		else if (player1card1equalsuit>='d5) begin
			player1highestwin[3:0]=4'd6; //flush
			player1flush=1'b1;
			player1highestwin[7:4]=playercard1[3:0];
			/*
			if (((playercard1[5:4]==playercard0[5:4])&&(playercard1[3:0]>=playercard0[3:0])) //if the same suit and is at least as all the other cards
			+((playercard1[5:4]==tablecard0[5:4])&&(playercard1[3:0]>=tablecard0[3:0]))
			+((playercard1[5:4]==tablecard1[5:4])&&(playercard1[3:0]>=tablecard1[3:0]))
			+((playercard1[5:4]==tablecard2[5:4])&&(playercard1[3:0]>=tablecard2[3:0]))
			+((playercard1[5:4]==tablecard3[5:4])&&(playercard1[3:0]>=tablecard3[3:0]))
			+((playercard1[5:4]==tablecard4[5:4])&&(playercard1[3:0]>=tablecard4[3:0]))==player1card0equalsuit)
			player1highestwin[7:4]=playercard1[3:0];
			
			else if ((playercard1[5:4]==playercard0[5:4])&&((playercard0[3:0]>=playercard1[3:0]) //playercard1 is largest
			+((playercard1[5:4]==tablecard0[5:4])&&(playercard0[3:0]>=tablecard0[3:0]))
			+((playercard1[5:4]==tablecard1[5:4])&&(playercard0[3:0]>=tablecard1[3:0]))
			+((playercard1[5:4]==tablecard2[5:4])&&(playercard0[3:0]>=tablecard2[3:0]))
			+((playercard1[5:4]==tablecard3[5:4])&&(playercard0[3:0]>=tablecard3[3:0]))
			+((playercard1[5:4]==tablecard4[5:4])&&(playercard0[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=playercard0[3:0];
			
			else if ((playercard1[5:4]==tablecard0[5:4])&&((tablecard0[3:0]>=playercard1[3:0]) 
			+((playercard1[5:4]==playercard0[5:4])&&(tablecard0[3:0]>=playercard0[3:0]))
			+((playercard1[5:4]==tablecard1[5:4])&&(tablecard0[3:0]>=tablecard1[3:0]))
			+((playercard1[5:4]==tablecard2[5:4])&&(tablecard0[3:0]>=tablecard2[3:0]))
			+((playercard1[5:4]==tablecard3[5:4])&&(tablecard0[3:0]>=tablecard3[3:0]))
			+((playercard1[5:4]==tablecard4[5:4])&&(tablecard0[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard0[3:0];
			
			else if ((playercard1[5:4]==tablecard1[5:4])&&((tablecard1[3:0]>=playercard1[3:0]) 
			+((playercard1[5:4]==tablecard0[5:4])&&(tablecard1[3:0]>=tablecard0[3:0]))
			+((playercard1[5:4]==playercard1[5:4])&&(tablecard1[3:0]>=playercard0[3:0]))
			+((playercard1[5:4]==tablecard2[5:4])&&(tablecard1[3:0]>=tablecard2[3:0]))
			+((playercard1[5:4]==tablecard3[5:4])&&(tablecard1[3:0]>=tablecard3[3:0]))
			+((playercard1[5:4]==tablecard4[5:4])&&(tablecard1[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard1[3:0];
			
			else if ((playercard1[5:4]==tablecard2[5:4])&&((tablecard2[3:0]>=playercard1[3:0]) 
			+((playercard1[5:4]==tablecard0[5:4])&&(tablecard2[3:0]>=tablecard0[3:0]))
			+((playercard1[5:4]==tablecard1[5:4])&&(tablecard2[3:0]>=tablecard1[3:0]))
			+((playercard1[5:4]==playercard1[5:4])&&(tablecard2[3:0]>=playercard0[3:0]))
			+((playercard1[5:4]==tablecard3[5:4])&&(tablecard2[3:0]>=tablecard3[3:0]))
			+((playercard1[5:4]==tablecard4[5:4])&&(tablecard2[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard2[3:0];
			
			else if ((playercard1[5:4]==tablecard3[5:4])&&((tablecard3[3:0]>=playercard1[3:0]) 
			+((playercard1[5:4]==tablecard0[5:4])&&(tablecard3[3:0]>=tablecard0[3:0]))
			+((playercard1[5:4]==tablecard1[5:4])&&(tablecard3[3:0]>=tablecard1[3:0]))
			+((playercard1[5:4]==tablecard2[5:4])&&(tablecard3[3:0]>=tablecard2[3:0]))
			+((playercard1[5:4]==playercard1[5:4])&&(tablecard3[3:0]>=playercard0[3:0]))
			+((playercard1[5:4]==tablecard4[5:4])&&(tablecard3[3:0]>=tablecard4[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard3[3:0];
			
			else if ((playercard1[5:4]==tablecard4[5:4])&&((tablecard4[3:0]>=playercard1[3:0])
			+((playercard1[5:4]==tablecard0[5:4])&&(tablecard4[3:0]>=tablecard0[3:0]))
			+((playercard1[5:4]==tablecard1[5:4])&&(tablecard4[3:0]>=tablecard1[3:0]))
			+((playercard1[5:4]==tablecard2[5:4])&&(tablecard4[3:0]>=tablecard2[3:0]))
			+((playercard1[5:4]==tablecard3[5:4])&&(tablecard4[3:0]>=tablecard3[3:0]))
			+((playercard1[5:4]==playercard1[5:4])&&(tablecard4[3:0]>=playercard0[3:0]))==player1card0equalsuit))
			player1highestwin[7:4]=tablecard4[3:0];
			*/
		end
		
		else if ((playercard1[3:0]==playercard0[3:0]+'d1)||(tablecard0[3:0]==playercard0[3:0]+'d1)||(tablecard1[3:0]==playercard0[3:0]+'d1)||(tablecard2[3:0]==playercard0[3:0]+'d1)||(tablecard3[3:0]==playercard0[3:0]+'d1)||(tablecard4[3:0]==playercard0[3:0]+'d1)) 
					if ((playercard1[3:0]==playercard0[3:0]+'d2)||(tablecard0[3:0]==playercard0[3:0]+'d2)||(tablecard1[3:0]==playercard0[3:0]+'d2)||(tablecard2[3:0]==playercard0[3:0]+'d2)||(tablecard3[3:0]==playercard0[3:0]+'d2)||(tablecard4[3:0]==playercard0[3:0]+'d2)) 
						if ((playercard1[3:0]==playercard0[3:0]+'d3)||(tablecard0[3:0]==playercard0[3:0]+'d3)||(tablecard1[3:0]==playercard0[3:0]+'d3)||(tablecard2[3:0]==playercard0[3:0]+'d3)||(tablecard3[3:0]==playercard0[3:0]+'d3)||(tablecard4[3:0]==playercard0[3:0]+'d3)) 
							if ((playercard1[3:0]==playercard0[3:0]+'d4)||(tablecard0[3:0]==playercard0[3:0]+'d4)||(tablecard1[3:0]==playercard0[3:0]+'d4)||(tablecard2[3:0]==playercard0[3:0]+'d4)||(tablecard3[3:0]==playercard0[3:0]+'d4)||(tablecard4[3:0]==playercard0[3:0]+'d4)) begin
									player1straight=1'b1;
									player1highestwin[3:0]=4'd5;
									player1highestwin[7:4]=playercard0[3:0]+'d4;
								end
				
		if (player1straight==1'b0)  //playercard0 pos2
					if ((playercard1[3:0]==playercard0[3:0]+'d1)||(tablecard0[3:0]==playercard0[3:0]+'d1)||(tablecard1[3:0]==playercard0[3:0]+'d1)||(tablecard2[3:0]==playercard0[3:0]+'d1)||(tablecard3[3:0]==playercard0[3:0]+'d1)||(tablecard4[3:0]==playercard0[3:0]+'d1)) 
						if ((playercard1[3:0]==playercard0[3:0]+'d2)||(tablecard0[3:0]==playercard0[3:0]+'d2)||(tablecard1[3:0]==playercard0[3:0]+'d2)||(tablecard2[3:0]==playercard0[3:0]+'d2)||(tablecard3[3:0]==playercard0[3:0]+'d2)||(tablecard4[3:0]==playercard0[3:0]+'d2)) 
							if ((playercard1[3:0]==playercard0[3:0]+'d3)||(tablecard0[3:0]==playercard0[3:0]+'d3)||(tablecard1[3:0]==playercard0[3:0]+'d3)||(tablecard2[3:0]==playercard0[3:0]+'d3)||(tablecard3[3:0]==playercard0[3:0]+'d3)||(tablecard4[3:0]==playercard0[3:0]+'d3)) 
								if ((playercard1[3:0]==playercard0[3:0]-'d1)||(tablecard0[3:0]==playercard0[3:0]-'d1)||(tablecard1[3:0]==playercard0[3:0]-'d1)||(tablecard2[3:0]==playercard0[3:0]-'d1)||(tablecard3[3:0]==playercard0[3:0]-'d1)||(tablecard4[3:0]==playercard0[3:0]-'d1)) begin
										player1straight=1'b1;
										player1highestwin[3:0]=4'd5;
										player1highestwin[7:4]=playercard0[3:0]+'d3;
									end
									
		if (player1straight==1'b0)  //playercard0 pos3
					if ((playercard1[3:0]==playercard0[3:0]+'d1)||(tablecard0[3:0]==playercard0[3:0]+'d1)||(tablecard1[3:0]==playercard0[3:0]+'d1)||(tablecard2[3:0]==playercard0[3:0]+'d1)||(tablecard3[3:0]==playercard0[3:0]+'d1)||(tablecard4[3:0]==playercard0[3:0]+'d1)) 
						if ((playercard1[3:0]==playercard0[3:0]+'d2)||(tablecard0[3:0]==playercard0[3:0]+'d2)||(tablecard1[3:0]==playercard0[3:0]+'d2)||(tablecard2[3:0]==playercard0[3:0]+'d2)||(tablecard3[3:0]==playercard0[3:0]+'d2)||(tablecard4[3:0]==playercard0[3:0]+'d2)) 
							if ((playercard1[3:0]==playercard0[3:0]-'d2)||(tablecard0[3:0]==playercard0[3:0]-'d2)||(tablecard1[3:0]==playercard0[3:0]-'d2)||(tablecard2[3:0]==playercard0[3:0]-'d2)||(tablecard3[3:0]==playercard0[3:0]-'d2)||(tablecard4[3:0]==playercard0[3:0]-'d2)) 
								if ((playercard1[3:0]==playercard0[3:0]-'d1)||(tablecard0[3:0]==playercard0[3:0]-'d1)||(tablecard1[3:0]==playercard0[3:0]-'d1)||(tablecard2[3:0]==playercard0[3:0]-'d1)||(tablecard3[3:0]==playercard0[3:0]-'d1)||(tablecard4[3:0]==playercard0[3:0]-'d1)) begin
										player1straight=1'b1;
										player1highestwin[3:0]=4'd5;
										player1highestwin[7:4]=playercard0[3:0]+'d2;
									end
		
		if (player1straight==1'b0)  //playercard0 pos4
					if ((playercard1[3:0]==playercard0[3:0]+'d1)||(tablecard0[3:0]==playercard0[3:0]+'d1)||(tablecard1[3:0]==playercard0[3:0]+'d1)||(tablecard2[3:0]==playercard0[3:0]+'d1)||(tablecard3[3:0]==playercard0[3:0]+'d1)||(tablecard4[3:0]==playercard0[3:0]+'d1)) 
						if ((playercard1[3:0]==playercard0[3:0]-'d3)||(tablecard0[3:0]==playercard0[3:0]-'d3)||(tablecard1[3:0]==playercard0[3:0]-'d3)||(tablecard2[3:0]==playercard0[3:0]-'d3)||(tablecard3[3:0]==playercard0[3:0]-'d3)||(tablecard4[3:0]==playercard0[3:0]-'d3)) 
							if ((playercard1[3:0]==playercard0[3:0]-'d2)||(tablecard0[3:0]==playercard0[3:0]-'d2)||(tablecard1[3:0]==playercard0[3:0]-'d2)||(tablecard2[3:0]==playercard0[3:0]-'d2)||(tablecard3[3:0]==playercard0[3:0]-'d2)||(tablecard4[3:0]==playercard0[3:0]-'d2)) 
								if ((playercard1[3:0]==playercard0[3:0]-'d1)||(tablecard0[3:0]==playercard0[3:0]-'d1)||(tablecard1[3:0]==playercard0[3:0]-'d1)||(tablecard2[3:0]==playercard0[3:0]-'d1)||(tablecard3[3:0]==playercard0[3:0]-'d1)||(tablecard4[3:0]==playercard0[3:0]-'d1)) begin
										player1straight=1'b1;
										player1highestwin[3:0]=4'd5;
										player1highestwin[7:4]=playercard0[3:0]+'d1;
									end
		
		if (player1straight==1'b0)  //playercard0 pos5
					if ((playercard1[3:0]==playercard0[3:0]-'d4)||(tablecard0[3:0]==playercard0[3:0]-'d4)||(tablecard1[3:0]==playercard0[3:0]-'d4)||(tablecard2[3:0]==playercard0[3:0]-'d4)||(tablecard3[3:0]==playercard0[3:0]-'d4)||(tablecard4[3:0]==playercard0[3:0]-'d4)) 
						if ((playercard1[3:0]==playercard0[3:0]-'d3)||(tablecard0[3:0]==playercard0[3:0]-'d3)||(tablecard1[3:0]==playercard0[3:0]-'d3)||(tablecard2[3:0]==playercard0[3:0]-'d3)||(tablecard3[3:0]==playercard0[3:0]-'d3)||(tablecard4[3:0]==playercard0[3:0]-'d3)) 
							if ((playercard1[3:0]==playercard0[3:0]-'d2)||(tablecard0[3:0]==playercard0[3:0]-'d2)||(tablecard1[3:0]==playercard0[3:0]-'d2)||(tablecard2[3:0]==playercard0[3:0]-'d2)||(tablecard3[3:0]==playercard0[3:0]-'d2)||(tablecard4[3:0]==playercard0[3:0]-'d2)) 
								if ((playercard1[3:0]==playercard0[3:0]-'d1)||(tablecard0[3:0]==playercard0[3:0]-'d1)||(tablecard1[3:0]==playercard0[3:0]-'d1)||(tablecard2[3:0]==playercard0[3:0]-'d1)||(tablecard3[3:0]==playercard0[3:0]-'d1)||(tablecard4[3:0]==playercard0[3:0]-'d1)) begin
										player1straight=1'b1;
										player1highestwin[3:0]=4'd5;
										player1highestwin[7:4]=playercard0[3:0];
									end
		
		if (player1straight == 1'b0) //playercard1 pos1
					if ((playercard0[3:0] == playercard1[3:0] + 'd1)||(tablecard0[3:0]==playercard1[3:0]+'d1) || (tablecard1[3:0] == playercard1[3:0] + 'd1)||(tablecard2[3:0]==playercard1[3:0]+'d1) || (tablecard3[3:0] == playercard1[3:0] + 'd1)||(tablecard4[3:0]==playercard1[3:0]+'d1))
						if ((playercard0[3:0] == playercard1[3:0] + 'd2)||(tablecard0[3:0]==playercard1[3:0]+'d2) || (tablecard1[3:0] == playercard1[3:0] + 'd2)||(tablecard2[3:0]==playercard1[3:0]+'d2) || (tablecard3[3:0] == playercard1[3:0] + 'd2)||(tablecard4[3:0]==playercard1[3:0]+'d2))
							if ((playercard0[3:0] == playercard1[3:0] + 'd3)||(tablecard0[3:0]==playercard1[3:0]+'d3) || (tablecard1[3:0] == playercard1[3:0] + 'd3)||(tablecard2[3:0]==playercard1[3:0]+'d3) || (tablecard3[3:0] == playercard1[3:0] + 'd3)||(tablecard4[3:0]==playercard1[3:0]+'d3))
								if ((playercard0[3:0] == playercard1[3:0] + 'd4)||(tablecard0[3:0]==playercard1[3:0]+'d4) || (tablecard1[3:0] == playercard1[3:0] + 'd4)||(tablecard2[3:0]==playercard1[3:0]+'d4) || (tablecard3[3:0] == playercard1[3:0] + 'd4)||(tablecard4[3:0]==playercard1[3:0]+'d4)) begin
									player1straight = 1'b1;
									player1highestwin[3:0] = 4'd5;
									player1highestwin[7:4] = playercard1[3:0] + 'd4;
								end

		if (player1straight == 1'b0)  //playercard1 pos2
					if ((playercard0[3:0] == playercard1[3:0] + 'd1)||(tablecard0[3:0]==playercard1[3:0]+'d1) || (tablecard1[3:0] == playercard1[3:0] + 'd1)||(tablecard2[3:0]==playercard1[3:0]+'d1) || (tablecard3[3:0] == playercard1[3:0] + 'd1)||(tablecard4[3:0]==playercard1[3:0]+'d1))
						if ((playercard0[3:0] == playercard1[3:0] + 'd2)||(tablecard0[3:0]==playercard1[3:0]+'d2) || (tablecard1[3:0] == playercard1[3:0] + 'd2)||(tablecard2[3:0]==playercard1[3:0]+'d2) || (tablecard3[3:0] == playercard1[3:0] + 'd2)||(tablecard4[3:0]==playercard1[3:0]+'d2))
							if ((playercard0[3:0] == playercard1[3:0] + 'd3)||(tablecard0[3:0]==playercard1[3:0]+'d3) || (tablecard1[3:0] == playercard1[3:0] + 'd3)||(tablecard2[3:0]==playercard1[3:0]+'d3) || (tablecard3[3:0] == playercard1[3:0] + 'd3)||(tablecard4[3:0]==playercard1[3:0]+'d3))
								if ((playercard0[3:0] == playercard1[3:0] - 'd1)||(tablecard0[3:0]==playercard1[3:0]-'d1) || (tablecard1[3:0] == playercard1[3:0] - 'd1)||(tablecard2[3:0]==playercard1[3:0]-'d1) || (tablecard3[3:0] == playercard1[3:0] - 'd1)||(tablecard4[3:0]==playercard1[3:0]-'d1)) begin
										player1straight = 1'b1;
										player1highestwin[3:0] = 4'd5;
										player1highestwin[7:4] = playercard1[3:0] + 'd3;
									end

		if (player1straight == 1'b0)  //playercard1 pos3
					if ((playercard0[3:0] == playercard1[3:0] + 'd1)||(tablecard0[3:0]==playercard1[3:0]+'d1) || (tablecard1[3:0] == playercard1[3:0] + 'd1)||(tablecard2[3:0]==playercard1[3:0]+'d1) || (tablecard3[3:0] == playercard1[3:0] + 'd1)||(tablecard4[3:0]==playercard1[3:0]+'d1))
						if ((playercard0[3:0] == playercard1[3:0] + 'd2)||(tablecard0[3:0]==playercard1[3:0]+'d2) || (tablecard1[3:0] == playercard1[3:0] + 'd2)||(tablecard2[3:0]==playercard1[3:0]+'d2) || (tablecard3[3:0] == playercard1[3:0] + 'd2)||(tablecard4[3:0]==playercard1[3:0]+'d2))
							if ((playercard0[3:0] == playercard1[3:0] - 'd2)||(tablecard0[3:0]==playercard1[3:0]-'d2) || (tablecard1[3:0] == playercard1[3:0] - 'd2)||(tablecard2[3:0]==playercard1[3:0]-'d2) || (tablecard3[3:0] == playercard1[3:0] - 'd2)||(tablecard4[3:0]==playercard1[3:0]-'d2))
								if ((playercard0[3:0] == playercard1[3:0] - 'd1)||(tablecard0[3:0]==playercard1[3:0]-'d1) || (tablecard1[3:0] == playercard1[3:0] - 'd1)||(tablecard2[3:0]==playercard1[3:0]-'d1) || (tablecard3[3:0] == playercard1[3:0] - 'd1)||(tablecard4[3:0]==playercard1[3:0]-'d1)) begin
										player1straight = 1'b1;
										player1highestwin[3:0] = 4'd5;
										player1highestwin[7:4] = playercard1[3:0] + 'd2;
									end

		if (player1straight == 1'b0)  //playercard1 pos4
					if ((playercard0[3:0] == playercard1[3:0] + 'd1)||(tablecard0[3:0]==playercard1[3:0]+'d1) || (tablecard1[3:0] == playercard1[3:0] + 'd1)||(tablecard2[3:0]==playercard1[3:0]+'d1) || (tablecard3[3:0] == playercard1[3:0] + 'd1)||(tablecard4[3:0]==playercard1[3:0]+'d1))
						if ((playercard0[3:0] == playercard1[3:0] - 'd3)||(tablecard0[3:0]==playercard1[3:0]-'d3) || (tablecard1[3:0] == playercard1[3:0] - 'd3)||(tablecard2[3:0]==playercard1[3:0]-'d3) || (tablecard3[3:0] == playercard1[3:0] - 'd3)||(tablecard4[3:0]==playercard1[3:0]-'d3))
							if ((playercard0[3:0] == playercard1[3:0] - 'd2)||(tablecard0[3:0]==playercard1[3:0]-'d2) || (tablecard1[3:0] == playercard1[3:0] - 'd2)||(tablecard2[3:0]==playercard1[3:0]-'d2) || (tablecard3[3:0] == playercard1[3:0] - 'd2)||(tablecard4[3:0]==playercard1[3:0]-'d2))
								if ((playercard0[3:0] == playercard1[3:0] - 'd1)||(tablecard0[3:0]==playercard1[3:0]-'d1) || (tablecard1[3:0] == playercard1[3:0] - 'd1)||(tablecard2[3:0]==playercard1[3:0]-'d1) || (tablecard3[3:0] == playercard1[3:0] - 'd1)||(tablecard4[3:0]==playercard1[3:0]-'d1)) begin
										player1straight = 1'b1;
										player1highestwin[3:0] = 4'd5;
										player1highestwin[7:4] = playercard1[3:0] + 'd1;
									end

		if (player1straight == 1'b0)  //playercard1 pos5
					if ((playercard0[3:0] == playercard1[3:0] - 'd4)||(tablecard0[3:0]==playercard1[3:0]-'d4) || (tablecard1[3:0] == playercard1[3:0] - 'd4)||(tablecard2[3:0]==playercard1[3:0]-'d4) || (tablecard3[3:0] == playercard1[3:0] - 'd4)||(tablecard4[3:0]==playercard1[3:0]-'d4))
						if ((playercard0[3:0] == playercard1[3:0] - 'd3)||(tablecard0[3:0]==playercard1[3:0]-'d3) || (tablecard1[3:0] == playercard1[3:0] - 'd3)||(tablecard2[3:0]==playercard1[3:0]-'d3) || (tablecard3[3:0] == playercard1[3:0] - 'd3)||(tablecard4[3:0]==playercard1[3:0]-'d3))
							if ((playercard0[3:0] == playercard1[3:0] - 'd2)||(tablecard0[3:0]==playercard1[3:0]-'d2) || (tablecard1[3:0] == playercard1[3:0] - 'd2)||(tablecard2[3:0]==playercard1[3:0]-'d2) || (tablecard3[3:0] == playercard1[3:0] - 'd2)||(tablecard4[3:0]==playercard1[3:0]-'d2))
								if ((playercard0[3:0] == playercard1[3:0] - 'd1)||(tablecard0[3:0]==playercard1[3:0]-'d1) || (tablecard1[3:0] == playercard1[3:0] - 'd1)||(tablecard2[3:0]==playercard1[3:0]-'d1) || (tablecard3[3:0] == playercard1[3:0] - 'd1)||(tablecard4[3:0]==playercard1[3:0]-'d1)) begin
										player1straight = 1'b1;
										player1highestwin[3:0] = 4'd5;
										player1highestwin[7:4] = playercard1[3:0];
									end
											
		
		if ((player1fourkind==1'b0)&&(player1flush==1'b0)&&(player1straight==1'b0)) begin
		
				if (player1card0equalnum=='d3) begin 
					if ((((playercard1[3:0]==tablecard0[3:0]) + (playercard1[3:0]==tablecard1[3:0]) + (playercard1[3:0]==tablecard2[3:0]) + (playercard1[3:0]==tablecard3[3:0]) + (playercard1[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard0[3:0]==tablecard1[3:0]) + (tablecard0[3:0]==tablecard2[3:0]) + (tablecard0[3:0]==tablecard3[3:0]) + (tablecard0[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard1[3:0]==tablecard2[3:0]) + (tablecard1[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard2[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)) begin
							player1highestwin[3:0]=4'd7; //fullhouse
							player1highestwin[7:4]=playercard0[3:0];
					end
					else begin
						player1highestwin[3:0]=4'd4; //three of a kind
						player1highestwin[7:4]=playercard0[3:0];
					end
				end
				
				else if (player1card1equalnum=='d3) begin 
					if ((((playercard0[3:0]==tablecard0[3:0]) + (playercard0[3:0]==tablecard1[3:0]) + (playercard0[3:0]==tablecard2[3:0]) + (playercard0[3:0]==tablecard3[3:0]) + (playercard0[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard0[3:0]==tablecard1[3:0]) + (tablecard0[3:0]==tablecard2[3:0]) + (tablecard0[3:0]==tablecard3[3:0]) + (tablecard0[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard1[3:0]==tablecard2[3:0]) + (tablecard1[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(( (tablecard2[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)) begin
							player1highestwin[3:0]=4'd7; //fullhouse
							player1highestwin[7:4]=playercard1[3:0];
						end
					else begin
						player1highestwin[3:0]=4'd4; //three of a kind
						player1highestwin[7:4]=playercard1[3:0];
					end
				end
				
				else if (player1card0equalnum=='d2) begin 
					if ((((playercard1[3:0]==tablecard0[3:0]) + (playercard1[3:0]==tablecard1[3:0]) + (playercard1[3:0]==tablecard2[3:0]) + (playercard1[3:0]==tablecard3[3:0]) + (playercard1[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard0[3:0]==tablecard1[3:0]) + (tablecard0[3:0]==tablecard2[3:0]) + (tablecard0[3:0]==tablecard3[3:0]) + (tablecard0[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard1[3:0]==tablecard2[3:0]) + (tablecard1[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(( (tablecard2[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)) begin
							player1highestwin[3:0]=4'd3; //two pair
							player1highestwin[7:4]=playercard0[3:0];
						end
					else begin
						player1highestwin[3:0]=4'd2; //pair
						player1highestwin[7:4]=playercard0[3:0];
					end
				end
		
				else if (player1card1equalnum=='d2) begin 
					if ((((playercard0[3:0]==tablecard0[3:0]) + (playercard0[3:0]==tablecard1[3:0]) + (playercard0[3:0]==tablecard2[3:0]) + (playercard0[3:0]==tablecard3[3:0]) + (playercard0[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard0[3:0]==tablecard1[3:0]) + (tablecard0[3:0]==tablecard2[3:0]) + (tablecard0[3:0]==tablecard3[3:0]) + (tablecard0[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(((tablecard1[3:0]==tablecard2[3:0]) + (tablecard1[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)||
						(( (tablecard2[3:0]==tablecard3[3:0]) + (tablecard1[3:0]==tablecard4[3:0])+'d1)>='d2)) begin
							player1highestwin[3:0]=4'd3; //two pair
							player1highestwin[7:4]=playercard1[3:0];
						end
					else begin
						player1highestwin[3:0]=4'd2; //pair
						player1highestwin[7:4]=playercard1[3:0];
					end
				end
		
				else begin
					player1highestwin[3:0]=4'd1;
					if (playercard0[3:0]>=playercard1[3:0]) 
						player1highestwin[7:4]=playercard0[3:0]; //highest card is card0
					else
						player1highestwin[7:4]=playercard1[3:0]; //highest card is card1
				end
		end
		
		else if ((player1straight==1'b1)&&(player1flush==1'b1)) begin
			player1highestwin[3:0] = 4'd9; //straight flush
		end
		
		end
 end
 


reg [7:0] card0,card1,card2,card3,card4,card5,card6,card7,card8,card9,card10,
card11,card12,card13,card14,card15,card16,card17,card18,card19,card20,
card21,card22,card23,card24,card25,card26,card27,card28,card29,card30,
card31,card32,card33,card34,card35,card36,card37,card38,card39,card40,
card41,card42,card43,card44,card45,card46,card47,card48,card49,card50,
card51;
 
localparam

	SpadeAce 		= 8'h01, 
	SpadeTwo 		= 8'h02,
	SpadeThree 		= 8'h03,
   SpadeFour 		= 8'h04,
	SpadeFive		= 8'h05,
	SpadeSix			= 8'h06,
	SpadeSeven		= 8'h07,
	SpadeEight		= 8'h08,
	SpadeNine		= 8'h09,
	SpadeTen			= 8'h0a,
	SpadeJack		= 8'h0b,
	SpadeQueen		= 8'h0c,
	SpadeKing		= 8'h0d,

	HeartAce 		= 8'h11, 
	HeartTwo 		= 8'h12,
	HeartThree 		= 8'h13,
 	HeartFour 		= 8'h14,
	HeartFive		= 8'h15,
	HeartSix			= 8'h16,
	HeartSeven		= 8'h17,
	HeartEight		= 8'h18,
	HeartNine		= 8'h19,
	HeartTen			= 8'h1a,
	HeartJack		= 8'h1b,
	HeartQueen		= 8'h1c,
	HeartKing		= 8'h1d,

	ClubsAce 		= 8'h21, 
	ClubsTwo 		= 8'h22,
	ClubsThree 		= 8'h23,
   ClubsFour 		= 8'h24, 
	ClubsFive		= 8'h25,
	ClubsSix			= 8'h26,
	ClubsSeven		= 8'h27,
	ClubsEight		= 8'h28,
	ClubsNine		= 8'h29,
	ClubsTen			= 8'h2a,
	ClubsJack		= 8'h2b,
	ClubsQueen		= 8'h2c,
	ClubsKing		= 8'h2d,

	DiamondsAce 	= 8'h31, 
	DiamondsTwo 	= 8'h32,
	DiamondsThree	= 8'h33,
   DiamondsFour	= 8'h34,
	DiamondsFive	= 8'h35,
	DiamondsSix		= 8'h36,
	DiamondsSeven	= 8'h37,
	DiamondsEight	= 8'h38,
	DiamondsNine	= 8'h39,
	DiamondsTen		= 8'h3a,
	DiamondsJack	= 8'h3b,
	DiamondsQueen	= 8'h3c,
	DiamondsKing	= 8'h3d;
	
	
always@(posedge clk) begin  //set cards to default
	 if (initialize) begin
		 card0 <=SpadeAce;
		 card1 <=SpadeTwo;
		 card2 <=SpadeThree;
		 card3 <=SpadeFour;
		 card4 <=SpadeFive;
		 card5 <=SpadeSix;
		 card6 <=SpadeSeven;
		 card7 <=SpadeEight;
		 card8 <=SpadeNine;
		 card9 <=SpadeTen;
		 card10 <=SpadeJack;
		 card11 <=SpadeQueen;
		 card12 <=SpadeKing;

		 card13 <=HeartAce;
		 card14 <=HeartTwo;
		 card15 <=HeartThree;
		 card16 <=HeartFour;
		 card17 <=HeartFive;
		 card18 <=HeartSix;
		 card19 <=HeartSeven;
		 card20 <=HeartEight;
		 card21 <=HeartNine;
		 card22 <=HeartTen;
		 card23 <=HeartJack;
		 card24 <=HeartQueen;
		 card25 <=HeartKing;

		 card26 <=ClubsAce;
		 card27 <=ClubsTwo;
		 card28 <=ClubsThree;
		 card29 <=ClubsFour;
		 card30 <=ClubsFive;
		 card31 <=ClubsSix;
		 card32 <=ClubsSeven;
		 card33 <=ClubsEight;
		 card34 <=ClubsNine;
		 card35 <=ClubsTen;
		 card36 <=ClubsJack;
		 card37 <=ClubsQueen;
		 card38 <=ClubsKing;

		 card39 <=DiamondsAce;
		 card40 <=DiamondsTwo;
		 card41 <=DiamondsThree;
		 card42 <=DiamondsFour;
		 card43 <=DiamondsFive;
		 card44 <=DiamondsSix;
		 card45 <=DiamondsSeven;
		 card46 <=DiamondsEight;
		 card47 <=DiamondsNine;
		 card48 <=DiamondsTen;
		 card49 <=DiamondsJack;
		 card50 <=DiamondsQueen;
		 card51 <=DiamondsKing;
		 
	end
	
	else if (tablecard0_data) begin
	//test case 1
	tablecard0 <= SpadeFour;
	tablecard1 <= SpadeSix;
	tablecard2 <= SpadeNine;
	tablecard3 <= SpadeTwo;
	tablecard4 <= SpadeKing;
	playercard0 <= SpadeThree;
	playercard1 <= SpadeFive;
	playercard2 <= SpadeQueen;
	playercard3 <= SpadeTen;
	// player 1 wins
	//win type: straight flush
	//marker: 6//did not detect flush
	//result: 65



	end
	else if (tablecard1_data) begin
		tablecard0 <= SpadeFour;
		tablecard1 <= SpadeSix;
		tablecard2 <= DiamondsNine;
		tablecard3 <= ClubsQueen;
		tablecard4 <= SpadeSeven;
		playercard0 <= DiamondsSeven;
		playercard1 <= ClubsSeven;
		playercard2 <= SpadeQueen;
		playercard3 <= DiamondsQueen;
		// player 2 wins
		//win type: full house
		//marker: 12
	end
	
	else if (tablecard2_data) begin
		//test case 2
		tablecard0 <= SpadeFour;
		tablecard1 <= SpadeQueen;
		tablecard2 <= DiamondsFour;
		tablecard3 <= ClubsAce;
		tablecard4 <= SpadeSeven;
		playercard0 <= HeartTwo;
		playercard1 <= SpadeTwo;
		playercard2 <= ClubsSix;
		playercard3 <= DiamondsSix;
		// player 2 wins
		//win type: two pairs
		//marker: 6
		//detecting pair of 2s but not two-pairs
	end
	
	else if (tablecard3_data) begin
		tablecard0 <= SpadeFour;
		tablecard1 <= SpadeSix;
		tablecard2 <= DiamondsFour;
		tablecard3 <= ClubsAce;
		tablecard4 <= SpadeSeven;
		playercard0 <= HeartTwo;
		playercard1 <= SpadeTwo;
		playercard2 <= ClubsTwo;
		playercard3 <= DiamondsTwo;
		// draw
		//win type: two pair
		//marker: 4
		//
	end
	
	else if (tablecard4_data) begin
		//test case 4
		tablecard0 <= ClubsSix;
		tablecard1 <= SpadeSix;
		tablecard2 <= DiamondsNine;
		tablecard3 <= ClubsQueen;
		tablecard4 <= SpadeSeven;
		playercard0 <= DiamondsSeven;
		playercard1 <= ClubsSeven;
		playercard2 <= SpadeQueen;
		playercard3 <= DiamondsQueen;
		// player 1 loses
		//win type: full house
		//marker: 7
		//
	end
	else if (playercard0_data) begin
				//test case 5
		tablecard0 <= ClubsSix;
		tablecard1 <= SpadeSix;
		tablecard2 <= DiamondsSix;
		tablecard3 <= ClubsQueen;
		tablecard4 <= SpadeSeven;
		playercard0 <= DiamondsAce;
		playercard1 <= ClubsSeven;
		playercard2 <= SpadeQueen;
		playercard3 <= DiamondsQueen;
		// player 1 loses
		//win type: full house
		//marker: 6
	end
	else if (playercard1_data) begin
			//test case 6
		tablecard0 <= ClubsSeven;
		tablecard1 <= SpadeSeven;
		tablecard2 <= DiamondsNine;
		tablecard3 <= ClubsQueen;
		tablecard4 <= SpadeEight;
		playercard0 <= DiamondsSix;
		playercard1 <= ClubsSix;
		playercard2 <= SpadeQueen;
		playercard3 <= DiamondsQueen;
		// player 1 loses
		//win type: two pair
		//marker: 6
	end
	
	else if (playercard2_data) begin
		//test case 7
		tablecard0 <= ClubsSeven;
		tablecard1 <= SpadeNine;
		tablecard2 <= ClubsSix;
		tablecard3 <= ClubsQueen;
		tablecard4 <= SpadeEight;
		playercard0 <= DiamondsSix;
		playercard1 <= ClubsNine;
		playercard2 <= SpadeQueen;
		playercard3 <= DiamondsQueen;
		// player 1 loses
		//win type: two pair
		//marker: 6
	end
	
	else if (playercard3_data) begin
			//test case 8
		tablecard0 <= SpadeTwo;
		tablecard1 <= SpadeQueen;
		tablecard2 <= DiamondsTwo;
		tablecard3 <= ClubsAce;
		tablecard4 <= SpadeSeven;
		playercard0 <= HeartTwo;
		playercard1 <= ClubsTwo;
		playercard2 <= ClubsSix;
		playercard3 <= DiamondsSix;
		// player 1 wins
		//win type: four of a kind
		//marker: 2
		//
	end
	
	else begin  //shift right

		 card1 <=card0;
		 card2 <=card1;
		 card3 <=card2;
		 card4 <=card3;
		 card5 <=card4;
		 card6 <=card5;
		 card7 <=card6;
		 card8 <=card7;
		 card9 <=card8;
		 card10 <=card9;
		 card11 <=card10;
		 card12 <=card11;
		 card13 <=card12;
		 card14 <=card13;
		 card15 <=card14;
		 card16 <=card15;
		 card17 <=card16;
		 card18 <=card17;
		 card19 <=card18;
		 card20 <=card19;
		 card21 <=card20;
		 card22 <=card21;
		 card23 <=card22;
		 card24 <=card23;
		 card25 <=card24;
		 card26 <=card25;
		 card27 <=card26;
		 card28 <=card27;
		 card29 <=card28;
		 card30 <=card29;
		 card31 <=card30;
		 card32 <=card31;
		 card33 <=card32;
		 card34 <=card33;
		 card35 <=card34;
		 card36 <=card35;
		 card37 <=card36;
		 card38 <=card37;
		 card39 <=card38;
		 card40 <=card39;
		 card41 <=card40;
		 card42 <=card41;
		 card43 <=card42;
		 card44 <=card43;
		 card45 <=card44;
		 card46 <=card45;
		 card47 <=card46;
		 card48 <=card47;
		 card49 <=card48;
		 card50 <=card49;
		 card51 <=card50;
		 card0  <=card51;

	end
end



 assign display5 = player1card0equalnum;
 assign display4 = player1card1equalnum;
 assign display3 = player1card0equalsuit;
 assign display2 = player1card1equalsuit;
 assign display1 = player1highestwin[7:4];
 assign display0 = player1highestwin[3:0];

 
 
	
endmodule


module hexDisplay (SW,HEX0);
	input [3:0] SW;
	output reg[6:0] HEX0;
	always @(SW)
	begin
		case (SW)
		4'b0000: HEX0 = 7'b1000000;
		4'b0001: HEX0 = 7'b1111001;
		4'b0010: HEX0 = 7'b0100100;
		4'b0011: HEX0 = 7'b0110000;
		4'b0100: HEX0 = 7'b0011001;
		4'b0101: HEX0 = 7'b0010010;
		4'b0110: HEX0 = 7'b0000010;
		4'b0111: HEX0 = 7'b1111000;
		4'b1000: HEX0 = 7'b0000000;
		4'b1001: HEX0 = 7'b0011000;
		4'b1010: HEX0 = 7'b0001000;
		4'b1011: HEX0 = 7'b0000011;
		4'b1100: HEX0 = 7'b1000110;
		4'b1101: HEX0 = 7'b0100001;
		4'b1110: HEX0 = 7'b0000110;
		4'b1111: HEX0 = 7'b0001110;
		default: HEX0 = 7'b0000000;
		endcase
	end
		
endmodule


