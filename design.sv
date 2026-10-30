// ---------------------------------------------------------------
// Top level (in module hierarchy)
// ---------------------------------------------------------------

module tarneeb_referee (
    input  [7:0] card0, card1, card2, card3,
    input  [1:0] tarneeb,
    output [1:0] winner,
    output       valid
);
    wire       inputs_valid;
    wire [1:0] winner_candidate;

    input_validator u_val (
        .card0(card0), .card1(card1), .card2(card2), .card3(card3),
        .valid(inputs_valid)
    ); // outputs into inputs_valid

    trick_evaluator u_eval (
        .card0(card0), .card1(card1), .card2(card2), .card3(card3),
        .tarneeb(tarneeb),
        .winner(winner_candidate)
    ); // outputs into winner_candidate

    assign valid  = inputs_valid;
    // Logic: winner is winner_candidate if valid, otherwise return 2'b00
    assign winner = valid ? winner_candidate : 2'b00;

endmodule

// ---------------------------------------------------------------
// Input validation
// ---------------------------------------------------------------

/*
By convention, we consider invalid input to be (valid = 0, winner = 00) such that:
    - any rank is < 2 or > 14
    - any two cards are identical (same rank and same suit) 
Reference: circuit specification, section 3.3. 
Note: the reason why duplicates are invalid is because a deck has only ONE of each card. 
*/

module input_validator (
    input  [7:0] card0, card1, card2, card3,
    output       valid
);
    // This function validates that ranks in 2..14 and no duplicate cards are present 
    wire ok0, ok1, ok2, ok3;
    wire ranks_ok;
    wire no_dupes;

    rank_checker rc0 (.card(card0), .ok(ok0));
    rank_checker rc1 (.card(card1), .ok(ok1));
    rank_checker rc2 (.card(card2), .ok(ok2));
    rank_checker rc3 (.card(card3), .ok(ok3));

    // check if all ranks are legal (4 ok's)
    assign ranks_ok = ({ok0, ok1, ok2, ok3} == 4'b1111) ? 1'b1 : 1'b0;

    // check eza fi duplicates, i.e. compare all 6 pairs (01, 02, 03, 12, 13, 23) on the full 8 bits
    assign no_dupes = (card0 != card1) && (card0 != card2) && (card0 != card3) && 
                      (card1 != card2) && (card1 != card3) && (card2 != card3);

    assign valid = ranks_ok & no_dupes;

endmodule

// ---------------------------------------------------------------
// ---------------------------------------------------------------

module rank_checker (
    input  [7:0] card,
    output reg ok
);
    // This function validates the rank of an individual card, i.e. checks if 2 <= card[7:2] <= 14
    // Note the ranks in Tarneeb: 2 < 3 < … < 10 < J(11) < Q(12) < K(13) < A(14).
    wire [5:0] rank = card[7:2]; // for readability

    always @(*) begin // keep in mind that always @(*) forces ok to be a reg
        if ((rank >= 6'd2) && (rank <= 6'd14))
            ok = 1'b1;
        else
            ok = 1'b0;
    end

endmodule

// ---------------------------------------------------------------
// Input and game outcome evaluation
// ---------------------------------------------------------------

module trick_evaluator (
    input  [7:0] card0, card1, card2, card3,
    input  [1:0] tarneeb,
    output [1:0] winner
);
    /*
    "A trick consists of four cards played in sequence, one by each player. 
    The first card played determines the lead suit."
    -- Relevant Tarneeb Rules (Section 2)
    */
    // This function evaluates the outcome (winner) of any given trick. 
    wire [1:0] lead = card0[1:0];

    wire b1, b2, b3; // intermediate variables to store whether challenger beat current best
    wire [7:0] best01, best012;
    wire [1:0] idx01,  idx012;

    // Round 1: card1 vs card0 (so best over indices 0 and 1)
    card_beats cb1 (.challenger(card1), .best(card0),
                    .lead(lead), .tarneeb(tarneeb), .beats(b1)); // output feeds into b1
    assign best01 = b1 ? card1 : card0; 
    assign idx01  = b1 ? 2'd1  : 2'd0;

    // Round 2: card2 vs best card so far (so best over indices 0, 1, and 2)
    card_beats cb2 (.challenger(card2), .best(best01),
                    .lead(lead), .tarneeb(tarneeb), .beats(b2));
    assign best012 = b2 ? card2 : best01;
    assign idx012  = b2 ? 2'd2  : idx01; 

    // Round 3: card3 vs best card so far (so best over indices 0, 1, 2, and 3)
    card_beats cb3 (.challenger(card3), .best(best012),
                    .lead(lead), .tarneeb(tarneeb), .beats(b3));
    
    assign winner = b3 ? 2'd3 : idx012;

endmodule

// ---------------------------------------------------------------
// ---------------------------------------------------------------

module card_beats (
    input  [7:0] challenger, // the new card being compared
    input  [7:0] best,       // the current winning card
    input  [1:0] lead,       // lead suit
    input  [1:0] tarneeb,    // trump suit aka "tarneeb"
    output reg   beats
);
    // This functions returns whether the challenger beats best under the tarneeb rules
    wire [1:0] c_suit = challenger[1:0];
    wire [1:0] b_suit = best[1:0];
    wire [5:0] c_rank = challenger[7:2];
    wire [5:0] b_rank = best[7:2];

    /*
    Consider the comparison rules (I don't know Tarneeb and am very bad at card games so I need the memo): 

        1. Challenger is tarneeb
            Case 1: Best is not tarneeb -> challenger wins (keep in mind that any trump beats any non-trump)
            Case 2: Best is also tarneeb -> challenger wins only if its rank is higher.

        2. Challenger is the lead suit (and not tarneeb)
            Case 1: Best is tarneeb -> challenger loses. A non-trump can’t beat a trump.
            Case 2: Best is also lead suit -> challenger wins only if its rank is higher.

        3. Challenger is neither tarneeb nor lead
            No matter what: Challenger always loses, whatever its rank.
    
    Keep in mind that best is always either tarneeb or lead suit (as card0 starts).
    */

    always @(*) begin
    beats = 1'b0;
    if((c_suit==tarneeb)&&(b_suit!=tarneeb)) begin
        beats=1'b1;
    end
    else if((c_suit==tarneeb)&&(b_suit==tarneeb)) begin
        if (c_rank>b_rank)begin
            beats= 1'b1;
        end
    end
    else if ((c_suit==lead)&&(b_suit==lead))begin
        if(lead!=tarneeb)begin
            if(c_rank>b_rank)begin
                beats=1'b1;
                end
            end
        end
    end
    // Shortcut Version (conditions 2 & 3 are grouped together in one check)
    always @(*) begin
    beats = 1'b0;
    if((c_suit==tarneeb) && (b_suit!=tarneeb)) begin
        beats=1'b1;
    end
    else if((c_suit==b_suit)&&(c_rank>b_rank)) begin
        beats= 1'b1;
    end
    end
endmodule