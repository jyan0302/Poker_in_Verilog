/*
module drawImage
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,SW,LEDR,							// On Board Keys
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
	input	[9:0]	SW;
	output	[9:0]	LEDR;				
	// Declare your inputs and outputs here
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire reset = ~KEY[0];
	wire clk = CLOCK_50;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire writeEn;
	
	// Signals
	wire drawCardBackEnable;
	wire drawCardBackEnd;
	wire screenDrawEnable;
	wire screenDrawEnd;
	
	wire [8:0] x_curr;
	wire [8:0] y_curr;
	wire [23:0] outColour;

		
	vga_adapter VGA(
			.resetn(~reset),
			.clock(CLOCK_50),
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
			
	wire [15:0] drawCounter;
	
	
	cardPosition cp (
	clk,
	reset,
	SW[9:7],
	SW[2:0],
	'd0, // testing only spades
	SW[6:3], // card position [0-8]
	outColour,
	x_curr,
	y_curr,
	LEDR[0],
	drawCounter
	);
	
endmodule
*/

module cardPosition (
	clk,
	reset,
	drawCardEnable,
	card_num,
	card_suit,
	card_pos,
	outColour,
	x_curr,
	y_curr,
	drawFinished,
	drawCounter);
	
	input clk, reset;
	input [2:0] drawCardEnable; // increased from 1 to 3 bits
	input [3:0] card_num;
	input [1:0] card_suit;
	input [3:0] card_pos;
	output [23:0] outColour;
	output [7:0] x_curr, y_curr;
	output drawFinished;
	output [15:0] drawCounter;
	
	reg [7:0] x, y;
	wire [15:0] draw_pos = {x, y}; //[7:0] = y , [15:8] = x
	
	always @ (*)
		case (card_pos)
			4'b0000: begin
				x = 'd75;
				y = 'd163;
			end
			4'b0001: begin
				x = 'd180;
				y = 'd163;
			end
			4'b0010: begin
				x = 'd115;
				y = 'd163;
			end
			4'b0011: begin
				x = 'd220;
				y = 'd163;
			end
			4'b0100: begin
				x = 'd77;
				y = 'd80;
			end
			4'b0101: begin
				x = 'd112;
				y = 'd80;
			end
			4'b0110: begin
				x = 'd147;
				y = 'd80;
			end
			4'b0111: begin
				x = 'd182;
				y = 'd80;
			end
			4'b1000: begin
				x = 'd217;
				y = 'd80;
			end
			4'b1001: begin //p1wins
				x = 'd126;
				y = 'd117;
			end
			4'b1010: begin //p2wins
				x = 'd126;
				y = 'd117;
			end
//			4'b1011: begin // tie
//				x = 'd128;
//				y = 'd117;
//			end
			default: begin
				x = 'd75;
				y = 'd163;
			end
		endcase


drawAndErase d1(
	clk,
	reset,
	drawCardEnable,
	card_num,
	card_suit,
	draw_pos[15:8],
	draw_pos[7:0],
	outColour,
	x_curr,
	y_curr,
	drawFinished,
	drawCounter
);

endmodule 

module drawAndErase(
	clk,
	reset,
	drawEnable,
	card_num,
	card_suit,
	x,
	y,
	outColour,
	x_curr,
	y_curr,
	drawFinished,
	drawCounter
);

	input clk, reset;
	input [2:0] drawEnable;
	input [3:0]card_num;
	input [1:0]card_suit;
	input [7:0] x;
	input [7:0] y;
	output reg [23:0] outColour;
	output reg [7:0] x_curr, y_curr;
	output reg drawFinished;
	output reg [15:0] drawCounter;
	
	wire [4:0] drawEnable_wire = {drawCardEnable, drawBackEnable, drawP1Enable, drawP2Enable, drawTieEnable};
	reg drawCardEnable, drawBackEnable, drawP1Enable, drawP2Enable, drawTieEnable;

	
	wire [23:0] outColour_back, outColour_card, outColour_p1, outColour_p2, outColour_tie;
	wire [7:0] x_curr_back, x_curr_card, y_curr_back, y_curr_card, x_curr_p1, x_curr_p2, y_curr_p1, y_curr_p2, x_curr_tie, y_curr_tie;
	wire drawFinished_back, drawFinished_card, drawFinished_p1, drawFinished_p2, drawFinished_tie;
	
	reg [15:0] drawCounter_back, drawCounter_card;
	
	always @ (posedge clk)
		begin
			if (drawEnable == 3'b000)
			begin
				outColour <= outColour_card;
				x_curr <= x_curr_card;
				y_curr <= y_curr_card;
				drawCardEnable = 1'b1;
				drawBackEnable = 1'b0;
				drawP1Enable = 1'b0;
				drawP2Enable = 1'b0;
				drawTieEnable = 1'b0;
				drawFinished <= drawFinished_card;
			end
			else if(drawEnable == 3'b001)
			begin
				outColour <= outColour_back;
				x_curr <= x_curr_back;
				y_curr <= y_curr_back;
				drawCardEnable = 1'b0;
				drawBackEnable = 1'b1;
				drawP1Enable = 1'b0;
				drawP2Enable = 1'b0;
				drawTieEnable = 1'b0;
				drawFinished <= drawFinished_back;
			end
			else if(drawEnable == 3'b010)
			begin
				outColour <= outColour_p1;
				x_curr <= x_curr_p1;
				y_curr <= y_curr_p1;
				drawCardEnable = 1'b0;
				drawBackEnable = 1'b0;
				drawP1Enable = 1'b1;
				drawP2Enable = 1'b0;
				drawTieEnable = 1'b0;
				drawFinished <= drawFinished_p1;
			end
			else if(drawEnable == 3'b011)
			begin
				outColour <= outColour_p2;
				x_curr <= x_curr_p2;
				y_curr <= y_curr_p2;
				drawCardEnable = 1'b0;
				drawBackEnable = 1'b0;
				drawP1Enable = 1'b0;
				drawP2Enable = 1'b1;
				drawTieEnable = 1'b0;
				drawFinished <= drawFinished_p2;
			end
//			else if(drawEnable == 3'b100)
//			begin
//				outColour <= outColour_tie;
//				x_curr <= x_curr_tie;
//				y_curr <= y_curr_tie;
//				drawCardEnable = 1'b0;
//				drawBackEnable = 1'b0;
//				drawP1Enable = 1'b0;
//				drawP2Enable = 1'b0;
//				drawTieEnable = 1'b1;
//				drawFinished <= drawFinished_tie;
//			end
		end
	
	
	drawCardBack dcb (
		clk,
		reset,
		drawBackEnable,
		//drawEnable_wire[3]
		x,
		y,
		outColour_back,
		x_curr_back,
		y_curr_back,
		drawFinished_back
	);
	
	drawCard dc (
		clk,
		reset,
		drawCardEnable, //writeEn
		//drawEnable_wire[4]
		card_num, //card selection
		card_suit, //suit selection
		x,
		y,
		outColour_card,
		x_curr_card,
		y_curr_card,
		drawFinished_card
	);
	
	draw_p1wins p1w (
	clk,
	reset,
	drawP1Enable,
	//drawEnable_wire[2]
	x,
	y,
	outColour_p1,
	x_curr_p1,
	y_curr_p1,
	drawFinished_p1,
	//cardCounter
);

	draw_p2wins p2w (
	clk,
	reset,
	drawP2Enable,
	//drawEnable_wire[1]
	x,
	y,
	outColour_p2,
	x_curr_p2,
	y_curr_p2,
	drawFinished_p2,
	//cardCounter
);
//	draw_tie dt (
//	clk,
//	reset,
//	drawTieEnable,
//	//drawEnable_wire[0]
//	x,
//	y,
//	outColour_tie,
//	x_curr_tie,
//	y_curr_tie,
//	drawFinished_tie,
//	//cardCounter
//);

endmodule 

//module drawWinner(
//	clk,
//	reset,
//	drawCardEnable,
//	card_num,
//	card_suit,
//	x,
//	y,
//	outColour,
//	x_curr,
//	y_curr,
//	drawFinished,
//	drawCounter
//);
//
//	input clk, reset, drawCardEnable;
//	input [3:0]card_num;
//	input [1:0]card_suit;
//	input [7:0] x;
//	input [7:0] y;
//	output reg [23:0] outColour;
//	output reg [7:0] x_curr, y_curr;
//	output reg drawFinished;
//	output reg [15:0] drawCounter;
//	
//	wire drawBackEnable;
//	assign drawBackEnable = ~drawCardEnable;
//	
//	wire [23:0] outColour_back, outColour_card;
//	wire [7:0] x_curr_back, x_curr_card, y_curr_back, y_curr_card;
//	wire drawFinished_back, drawFinished_card;
//	
//	reg [15:0] drawCounter_back, drawCounter_card;
//		
//	always @ (posedge clk)
//		begin
//			if (drawBackEnable)
//			begin
//				outColour <= outColour_back;
//				x_curr <= x_curr_back;
//				y_curr <= y_curr_back;
//				drawFinished <= drawFinished_back;
//			end
//			else
//			begin
//				outColour <= outColour_card;
//				x_curr <= x_curr_card;
//				y_curr <= y_curr_card;
//				drawFinished <= drawFinished_card;
//			end
//			
//		end
//	
//	
//	draw_p1wins p1w (
//		clk,
//		reset,
//		drawBackEnable,
//		x,
//		y,
//		outColour_back,
//		x_curr_back,
//		y_curr_back,
//		drawFinished_back
//	);
//	
//endmodule 

module draw_p1wins(
	clk,
	reset,
	drawEnable,
	x,
	y,
	outColour,
	x_curr,
	y_curr,
	drawEnd,
	cardCounter
);
	// Inputs
	
	// Postion to draw card back at
	input [7:0] x;
	input [7:0] y;
	
	input clk,reset,drawEnable;
	
	// Ouputs
	output [23:0] outColour;
	
	// Image size
	localparam [7:0] card_height = 'd47 , card_width = 'd61;
	
	//  X,Y Counters
	output reg [15:0] cardCounter;
	wire [7:0] x_count = cardCounter[7:0];
	wire [7:0] y_count = cardCounter[15:8];
	
	// current X,Y locations
	output [7:0] x_curr;
	assign x_curr = x_count + x;
	output [7:0] y_curr;
	assign y_curr = y_count + y;
	
	// Memory Location
	wire [15:0] card_position = x_count + y_count * card_width;
	
	// Signal to indicate finish drawing
	output reg drawEnd;
	
	//  counting
	always@(posedge clk)
		begin
			if(drawEnable) begin
				if(cardCounter[7:0] < card_width )
					cardCounter <= cardCounter + 1;
				else if(cardCounter[15:8] < card_height )
					cardCounter <= {cardCounter[15:8] + 1 , 8'b0};
				else 
					drawEnd <= 1;
			end
			if(reset) begin
				cardCounter <= 0;
				drawEnd <= 0;
			end
		end
	
	// Accessing from Memory
	p1wins p1w(.address(card_position), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
endmodule 

module draw_p2wins(
	clk,
	reset,
	drawEnable,
	x,
	y,
	outColour,
	x_curr,
	y_curr,
	drawEnd,
	cardCounter
);
	// Inputs
	
	// Postion to draw card back at
	input [7:0] x;
	input [7:0] y;
	
	input clk,reset,drawEnable;
	
	// Ouputs
	output [23:0] outColour;
	
	// Image size
	localparam [7:0] card_height = 'd47 , card_width = 'd61;
	
	//  X,Y Counters
	output reg [15:0] cardCounter;
	wire [7:0] x_count = cardCounter[7:0];
	wire [7:0] y_count = cardCounter[15:8];
	
	// current X,Y locations
	output [7:0] x_curr;
	assign x_curr = x_count + x;
	output [7:0] y_curr;
	assign y_curr = y_count + y;
	
	// Memory Location
	wire [15:0] card_position = x_count + y_count * card_width;
	
	// Signal to indicate finish drawing
	output reg drawEnd;
	
	//  counting
	always@(posedge clk)
		begin
			if(drawEnable) begin
				if(cardCounter[7:0] < card_width )
					cardCounter <= cardCounter + 1;
				else if(cardCounter[15:8] < card_height )
					cardCounter <= {cardCounter[15:8] + 1 , 8'b0};
				else 
					drawEnd <= 1;
			end
			if(reset) begin
				cardCounter <= 0;
				drawEnd <= 0;
			end
		end
	
	// Accessing from Memory
	p2wins p2w(.address(card_position), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
endmodule 

//module draw_tie(
//	clk,
//	reset,
//	drawEnable,
//	x,
//	y,
//	outColour,
//	x_curr,
//	y_curr,
//	drawEnd,
//	cardCounter
//);
//	// Inputs
//	
//	// Postion to draw card back at
//	input [7:0] x;
//	input [7:0] y;
//	
//	input clk,reset,drawEnable;
//	
//	// Ouputs
//	output [23:0] outColour;
//	
//	// Image size
//	localparam [7:0] card_height = 'd40 , card_width = 'd61;
//	
//	//  X,Y Counters
//	output reg [15:0] cardCounter;
//	wire [7:0] x_count = cardCounter[7:0];
//	wire [7:0] y_count = cardCounter[15:8];
//	
//	// current X,Y locations
//	output [7:0] x_curr;
//	assign x_curr = x_count + x;
//	output [7:0] y_curr;
//	assign y_curr = y_count + y;
//	
//	// Memory Location
//	wire [15:0] card_position = x_count + y_count * card_width;
//	
//	// Signal to indicate finish drawing
//	output reg drawEnd;
//	
//	//  counting
//	always@(posedge clk)
//		begin
//			if(drawEnable) begin
//				if(cardCounter[7:0] < card_width )
//					cardCounter <= cardCounter + 1;
//				else if(cardCounter[15:8] < card_height )
//					cardCounter <= {cardCounter[15:8] + 1 , 8'b0};
//				else 
//					drawEnd <= 1;
//			end
//			if(reset) begin
//				cardCounter <= 0;
//				drawEnd <= 0;
//			end
//		end
//	
//	// Accessing from Memory
//	tie p1 (.address(card_position), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
//endmodule 


module drawCardBack(
	clk,
	reset,
	drawCardBackEnable,
	x,
	y,
	outColour,
	x_curr,
	y_curr,
	drawCardBackEnd,
	cardCounter
);
	// Inputs
	
	// Postion to draw card back at
	input [7:0] x;
	input [7:0] y;
	
	input clk,reset,drawCardBackEnable;
	
	// Ouputs
	output [23:0] outColour;
	
	// Image size
	localparam [7:0] card_height = 'd34 , card_width = 'd25;
	
	//  X,Y Counters
	output reg [15:0] cardCounter;
	wire [7:0] x_count = cardCounter[7:0];
	wire [7:0] y_count = cardCounter[15:8];
	
	// current X,Y locations
	output [7:0] x_curr;
	assign x_curr = x_count + x;
	output [7:0] y_curr;
	assign y_curr = y_count + y;
	
	// Memory Location
	wire [10:0] card_position = x_count + y_count * card_width;
	
	// Signal to indicate finish drawing
	output reg drawCardBackEnd;
	
	//  counting
	always@(posedge clk)
		begin
			if(drawCardBackEnable) begin
				if(cardCounter[7:0] < card_width )
					cardCounter <= cardCounter + 1;
				else if(cardCounter[15:8] < card_height )
					cardCounter <= {cardCounter[15:8] + 1 , 8'b0};
				else 
					drawCardBackEnd <= 1;
			end
			if(reset) begin
				cardCounter <= 0;
				drawCardBackEnd <= 0;
			end
		end
	
	// Accessing from Memory
	cardback pm1(.address(card_position), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
endmodule 

module drawCard(
	clk,
	reset,
	drawEnable,
	card_num,
	card_suit,
	x,
	y,
	outColour,
	x_draw,
	y_draw,
	drawFinished,
	drawCounter
);
	// Inputs
	//which card to draw [1:13]
	input [3:0]card_num;
	// 0 = spades, 1 = hearts, 2 = clubs, 3 = diamonds
	input [1:0]card_suit;
	
	// Postion on screen to draw at
	input [7:0] x;
	input [7:0] y;
	
	input clk,reset,drawEnable;
	
	// Ouputs
	output [23:0] outColour;
	
	// size of each card
	localparam [7:0] card_height = 'd34 , card_width = 'd25;
	localparam [8:0] x_max = 'd325;
	
	// X,Y Counters
	output reg [15:0] drawCounter;
	wire [7:0] x_count = drawCounter[7:0];
	wire [7:0] y_count = drawCounter[15:8];
	
	//starting position
	wire [8:0] x_start = (card_num - 1) * card_width;
	wire [8:0] y_start = (card_suit) * card_height;
	
	// x,y location in memory
	wire [8:0] x_card = x_start + x_count;
	wire [8:0] y_card = y_start + y_count;
	
	// position in memory
	wire [15:0] card_position = x_card + y_card * x_max;
	
	
	//current x y locations
	output [7:0] x_draw;
	assign x_draw = x + x_count;
	output [7:0] y_draw;
	assign y_draw = y + y_count;
	
	// Signal to indicate finish drawing
	output reg drawFinished;
	
	//  Couting process/datapath
	always@(posedge clk)
		begin
			if(drawEnable) begin
				if(drawCounter[7:0] < card_width )
					drawCounter <= drawCounter + 1;
				else if(drawCounter[15:8] < card_height )
					drawCounter <= {drawCounter[15:8] + 1 , 8'b0};
				else 
					drawFinished <= 1;
			end
			if(reset) begin
				drawCounter <= 0;
				drawFinished <= 0;
			end
		end
	
	// Accessing from Memory
	CardMem pm1(.address(card_position), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
	
	
endmodule 
