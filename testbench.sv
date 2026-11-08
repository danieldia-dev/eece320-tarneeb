module tarneeb_TB ();
    // Self-checking testbench
    // Only instantiates the tarneeb_referee interface.
    // Card encoding: {rank[5:0], suit[1:0]}
    // Suits: C=00, D=01, H=10, S=11
    reg  [7:0] card0, card1, card2, card3;
    reg  [1:0] tarneeb;
    wire [1:0] winner;
    wire       valid;

    integer pass_count;
    integer fail_count;

    tarneeb_referee UUT (
        .card0(card0), .card1(card1), .card2(card2), .card3(card3),
        .tarneeb(tarneeb),
        .winner(winner),
        .valid(valid)
    );

    initial begin
        // Waveform dumpfile for the timing diagram (EPWave)
        $dumpfile("dump.vcd");
        $dumpvars(0, tarneeb_TB);

        pass_count = 0;
        fail_count = 0;

        // Test 1: No tarneeb played, highest lead-suit card wins (Table 1, case 1): expected (1,1)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h36;   // K of Hearts
        card2 = 8'h0C;   // 3 of Clubs
        card3 = 8'h1E;   // 7 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b1) && (winner === 2'd1)) begin
            $display("Test 1: PASS (No tarneeb played, highest lead-suit card wins)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: FAIL expected (valid=1, winner=1), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 2: Tarneeb (2 of Spades) beats higher-ranked lead card (Ace of Hearts) (Table 1, case 2): expected (1,1)
        card0 = 8'h3A;   // A of Hearts
        card1 = 8'h0B;   // 2 of Spades
        card2 = 8'h36;   // K of Hearts
        card3 = 8'h2A;   // 10 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b1) && (winner === 2'd1)) begin
            $display("Test 2: PASS (Tarneeb 2 of Spades beats higher-ranked Ace of Hearts)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: FAIL expected (valid=1, winner=1), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 3: No tarneeb played, highest lead-suit card wins over higher off-suit Ace (Table 1, case 3): expected (1,1)
        card0 = 8'h25;   // 9 of Diamonds
        card1 = 8'h2D;   // J of Diamonds
        card2 = 8'h38;   // A of Clubs
        card3 = 8'h13;   // 4 of Spades
        tarneeb = 2'b10; // Hearts

        #10;

        if ((valid === 1'b1) && (winner === 2'd1)) begin
            $display("Test 3: PASS (No tarneeb played, highest lead-suit card beats off-suit Ace)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: FAIL expected (valid=1, winner=1), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 4: Multiple tarneeb, highest tarneeb wins (Table 1, case 4): expected (1,2)
        card0 = 8'h14;   // 5 of Clubs
        card1 = 8'h38;   // A of Clubs
        card2 = 8'h37;   // K of Spades
        card3 = 8'h0B;   // 2 of Spades
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b1) && (winner === 2'd2)) begin
            $display("Test 4: PASS (Multiple tarneeb, highest tarneeb wins)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: FAIL expected (valid=1, winner=2), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 5: Duplicate cards (0 & 1) (Table 1, case 5): expected (0,0)
        card0 = 8'h32;   // Q of Hearts
        card1 = 8'h32;   // Q of Hearts
        card2 = 8'h0C;   // 3 of Clubs
        card3 = 8'h11;   // 4 of Diamonds
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 5: PASS (Duplicate cards 0 & 1)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 6: Invalid rank < 2 or > 14, includes rank 0 for card 0 (Table 1, case 6): expected (0,0)
        card0 = 8'h00;   // 0 of Clubs
        card1 = 8'h12;   // 4 of Hearts
        card2 = 8'h15;   // 5 of Diamonds
        card3 = 8'h1B;   // 6 of Spades
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 6: PASS (Invalid rank 0 for card 0)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 6: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 7: Lead suit is the tarneeb suit: expected (1,0)
        card0 = 8'h2D;   // J of Diamonds
        card1 = 8'h25;   // 9 of Diamonds
        card2 = 8'h30;   // Q of Club
        card3 = 8'h2A;   // 10 of Heart
        tarneeb = 2'b01; // Diamonds 

        #10;

        if ((valid === 1'b1) && (winner === 2'd0)) begin
            $display("Test 7: PASS (Lead suit is the tarneeb suit)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 7: FAIL expected (valid=1, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 8: Tarneeb (5 of Clubs) beats higher-ranked lead card (Ace of Hearts): expected (1,3)
        card0 = 8'h3A;   // Ace of Heart
        card1 = 8'h2B;   // 10 of Spades
        card2 = 8'h2A;   // 10 of Hearts
        card3 = 8'h14;   // 5 of Club
        tarneeb = 2'b00; // Clubs

        #10;

        if ((valid === 1'b1) && (winner === 2'd3)) begin
            $display("Test 8: PASS (Tarneeb 5 of Clubs beats higher-ranked Ace of Hearts)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 8: FAIL expected (valid=1, winner=3), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 9: Multiple tarneeb, highest tarneeb wins: expected (1,2)
        card0 = 8'h34;   // K of Club
        card1 = 8'h1D;   // 7 of Diamonds
        card2 = 8'h32;   // Q of Heart 
        card3 = 8'h26;   // 9 of Heart
        tarneeb = 2'b10; // Heart

        #10;

        if ((valid === 1'b1) && (winner === 2'd2)) begin
            $display("Test 9: PASS (Multiple tarneeb, highest tarneeb wins)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 9: FAIL expected (valid=1, winner=2), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 10: Duplicate cards (0 & 3): expected (0,0)
        card0 = 8'h16;   // 5 of Hearts
        card1 = 8'h1B;   // 6 of Spades
        card2 = 8'h25;   // 9 of Diamond
        card3 = 8'h16;   // 5 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 10: PASS (Duplicate cards 0 & 3)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 10: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 11: Invalid rank < 2 or > 14, includes rank 15 for card 0: expected (0,0)
        card0 = 8'h3E;   // 15 of Hearts
        card1 = 8'h0E;   // 3 of  Hearts
        card2 = 8'h20;   // 8 of Clubs
        card3 = 8'h13;   // 4 of Spades
        tarneeb = 2'b01; // Diamond

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 11: PASS (Invalid rank 15 for card 0)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 11: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 12: Invalid rank < 2 or > 14, includes rank 1 for card 0: expected (0,0)
        card0 = 8'h04;   // 1 of Clubs
        card1 = 8'h2A;   // 10 of Hearts
        card2 = 8'h2D;   // 11 of Diamonds
        card3 = 8'h0F;   // 3 of Spades
        tarneeb = 2'b00; // Club

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 12: PASS (Invalid rank 1 for card 0)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 12: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 13: Higher-ranked off-suit card (Ace of Clubs) loses to lower lead-suit card: expected (1,0)
        card0 = 8'h1A;   // 6 of Hearts
        card1 = 8'h38;   // A of Clubs 
        card2 = 8'h0E;   // 3 of Hearts
        card3 = 8'h35;   // K of Diamonds
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b1) && (winner === 2'd0)) begin
            $display("Test 13: PASS (Higher-ranked off-suit Ace loses to lower lead-suit card)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 13: FAIL expected (valid=1, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 14: Invalid rank < 2 or > 14, includes rank 15 for card 3: expected (0,0)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h36;   // K of Hearts
        card2 = 8'h0C;   // 3 of Clubs
        card3 = 8'h3C;   // 15 of Clubs
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 14: PASS (Invalid rank 15 for card 3)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 14: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 15: Duplicate cards (1 & 2): expected (0,0)
        card0 = 8'h14;   // 5 of Clubs
        card1 = 8'h1E;   // 7 of Hearts
        card2 = 8'h1E;   // 7 of Hearts
        card3 = 8'h37;   // K of Spades
        tarneeb = 2'b11; // Spades

        #10;
        
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 15: PASS (Duplicate cards 1 & 2)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 15: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end
        
        // Test 16: Duplicate cards (0 & 2): expected (0,0)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h36;   // K of Hearts
        card2 = 8'h2A;   // 10 of Hearts
        card3 = 8'h0C;   // 3 of Clubs
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 16: PASS (Duplicate cards 0 & 2)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 16: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 17: Duplicate cards (1 & 3): expected (0,0)
        card0 = 8'h14;   // 5 of Clubs
        card1 = 8'h1E;   // 7 of Hearts
        card2 = 8'h37;   // K of Spades
        card3 = 8'h1E;   // 7 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 17: PASS (Duplicate cards 1 & 3)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 17: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 18: Duplicate cards (2 & 3): expected (0,0)
        card0 = 8'h3A;   // A of Hearts
        card1 = 8'h0B;   // 2 of Spades
        card2 = 8'h26;   // 9 of Hearts
        card3 = 8'h26;   // 9 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 18: PASS (Duplicate cards 2 & 3)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 18: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 19: Invalid rank < 2 or > 14, includes rank 1 for card 1: expected (0,0)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h04;   // 1 of Clubs
        card2 = 8'h36;   // K of Hearts
        card3 = 8'h1E;   // 7 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 19: PASS (Invalid rank 1 for card 1)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 19: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 20: Invalid rank < 2 or > 14, includes rank 0 for card 2: expected (0,0)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h36;   // K of Hearts
        card2 = 8'h02;   // 0 of Diamonds
        card3 = 8'h1E;   // 7 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 20: PASS (Invalid rank 0 for card 2)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 20: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        // Test 21: Invalid rank > 14 whose low 4 bits look legal (rank 18 = 6'b010010) for card 3: expected (0,0)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h36;   // K of Hearts
        card2 = 8'h0C;   // 3 of Clubs
        card3 = 8'h4A;   // 18 of Hearts
        tarneeb = 2'b11; // Spades

        #10;

        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 21: PASS (Invalid rank 18 for card 3)");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 21: FAIL expected (valid=0, winner=0), got (valid=%b, winner=%0d)", valid, winner);
            $display("  inputs: card0=%h card1=%h card2=%h card3=%h tarneeb=%b", card0, card1, card2, card3, tarneeb);
            fail_count = fail_count + 1;
        end

        /*  
        Coverage summary:
            - Tests 1, 3: No tarneeb card is played; highest lead-suit card wins.
            - Tests 2, 8: Tarneeb beats a higher-ranked lead-suit card.
            - Tests 4, 9: Multiple tarneeb cards; highest tarneeb wins.
            - Test 7: Lead suit is the same as the tarneeb suit.
            - Tests 5, 10, 15, 16, 17, 18: Duplicate cards are detected (all six pairs).
            - Tests 6, 11, 12, 14, 19, 20, 21: Invalid ranks (0, 1, 15, 18) are rejected in every card position.
            - Test 13: Higher-ranked off-suit card loses to a lower-ranked lead-suit card.
        
        Winner coverage:
            - Player 0 wins: Tests 7 and 13.
            - Player 1 wins: Tests 1, 2, and 3.
            - Player 2 wins: Tests 4 and 9.
            - Player 3 wins: Test 8.
    
        Coverage checklist (valid vectors):
            - [x] player 0 wins   
            - [x] player 1 wins
            - [x] player 2 wins   
            - [x] player 3 wins
            - [x] rank 2 appears  
            - [x] rank 14 (Ace) appears
        */ 

        $display("--------------------------------");
        $display("Passed: %0d  Failed: %0d", pass_count, fail_count);
        $display("--------------------------------");
        $finish;
    end

endmodule

// P.S. Thank you Hiba for using spaces when appropriate, I like my code spaced out