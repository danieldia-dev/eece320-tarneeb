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
        pass_count = 0;
        fail_count = 0;

        // Test 1 (Table 1, case 1): expected (1,1)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h36;   // King of Hearts
        card2 = 8'h0C;   // 3 of Clubs
        card3 = 8'h1E;   // 7 of Hearts
        tarneeb = 2'b11; // Spades
        #10;
        if ((valid === 1'b1) && (winner === 2'd1)) begin
            $display("Test 1: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 2 (Table 1, case 2): expected (1,1)
        card0 = 8'h3A;
        card1 = 8'h0B;
        card2 = 8'h36;
        card3 = 8'h2A;
        tarneeb = 2'b11;
        #10;
        if ((valid === 1'b1) && (winner === 2'd1)) begin
            $display("Test 2: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 3 (Table 1, case 3): expected (1,1)
        card0 = 8'h25;
        card1 = 8'h2D;
        card2 = 8'h38;
        card3 = 8'h13;
        tarneeb = 2'b10;
        #10;
        if ((valid === 1'b1) && (winner === 2'd1)) begin
            $display("Test 3: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 4 (Table 1, case 4): expected (1,2)
        card0 = 8'h14;
        card1 = 8'h38;
        card2 = 8'h37;
        card3 = 8'h0B;
        tarneeb = 2'b11;
        #10;
        if ((valid === 1'b1) && (winner === 2'd2)) begin
            $display("Test 4: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 5 (Table 1, case 5, duplicate): expected (0,0)
        card0 = 8'h32;
        card1 = 8'h32;
        card2 = 8'h0C;
        card3 = 8'h11;
        tarneeb = 2'b11;
        #10;
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 5: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 6 (Table 1, case 6, rank 0): expected (0,0)
        card0 = 8'h00;
        card1 = 8'h12;
        card2 = 8'h15;
        card3 = 8'h1B;
        tarneeb = 2'b11;
        #10;
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 6: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 6: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 7 Lead suit is the tarneeb suit: expected (1,0)
        card0 = 8'h2D;   // J of Diamonds
        card1 = 8'h25;   // 9 of Diamonds
        card2 = 8'h30;   // Q of Club
        card3 = 8'h2A;   // 10 of Heart
        tarneeb = 2'b01; // Diamonds 
        #10;
        if ((valid === 1'b1) && (winner === 2'd0)) begin
            $display("Test 7: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 7: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 8 Tarneeb beats higher-ranked lead card (x2) 
        card0 = 8'h3A;   // Ace of Heart
        card1 = 8'h2B;   // 10 of Spades
        card2 = 8'h2A;   // 10 of Hearts
        card3 = 8'h14;   // 5 of Club
        tarneeb = 2'b00; // Clubs
        #10;
        if ((valid === 1'b1) && (winner === 2'd3)) begin
            $display("Test 8: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 8: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 9 Multiple tarneeb, highest tarneeb wins: expected (1,2) (x2) 
        card0 = 8'h34;   // K of Club
        card1 = 8'h1D;   // 7 of Diamonds
        card2 = 8'h32;   // Q of Heart 
        card3 = 8'h26;   // 9 of Heart
        tarneeb = 2'b10; // Heart
        #10;
        if ((valid === 1'b1) && (winner === 2'd2)) begin
            $display("Test 9: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 9: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 10 Duplicate cards expected(0,0)(x2) 
        card0 = 8'h16;   // 5 of Hearts
        card1 = 8'h1B;   // 6 of Spades
        card2 = 8'h25;   // 9 of Diamond
        card3 = 8'h16;   // 5 of Hearts
        tarneeb = 2'b11; // Spades
        #10;
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 10: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 10: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 11 Invalid rank < 2 or > 14, includes rank, 15 expected(0,0)
        card0 = 8'h3E;   // 15 of Hearts
        card1 = 8'h0E;   // 3 of  Hearts
        card2 = 8'h20;   // 8 of Clubs
        card3 = 8'h13;   // 4 of Spades
        tarneeb = 2'b01; // Diamond
        #10;
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 11: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 11: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 12 Invalid rank < 2 or > 14 (x2), includes rank 1 expected(0,0)
        card0 = 8'h04;   // 1 of Clubs
        card1 = 8'h2A;   // 10 of Hearts
        card2 = 8'h2D;   // 11 of Diamonds
        card3 = 8'h0F;   // 3 of Spades
        tarneeb = 2'b00; // Club
        #10;
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 12: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 12: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 13 higher off suit card loses expected (1,0)
        card0 = 8'h1A;   // 6 of Hearts
        card1 = 8'h38;   // A of Clubs 
        card2 = 8'h0E;   // 3 of Hearts
        card3 = 8'h35;   // K of Diamonds
        tarneeb = 2'b11; // Spades
        #10;
        if ((valid === 1'b1) && (winner === 2'd0)) begin
            $display("Test 13: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 13: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 14 Invalid rank < 2 or > 14 , include rank 15 for card 3 expected(0,0)
        card0 = 8'h2A;   // 10 of Hearts
        card1 = 8'h36;   // K of Hearts
        card2 = 8'h0C;   // 3 of Clubs
        card3 = 8'h3C;   // 15 of Clubs
        tarneeb = 2'b11; // Spades
        #10;
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 14: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 14: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end

        // Test 15 duplicate cards (1 & 2) expected(0,0)
        card0 = 8'h14;   // 5 of Clubs
        card1 = 8'h1E;   // 7 of Hearts
        card2 = 8'h1E;   // 7 of Hearts
        card3 = 8'h37;   // K of Spades
        tarneeb = 2'b11; // Spades
        #10;
        if ((valid === 1'b0) && (winner === 2'd0)) begin
            $display("Test 15: PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 15: FAIL (valid=%b winner=%d)", valid, winner);
            fail_count = fail_count + 1;
        end
        
        /*
         Coverage summary:
        
         Tests 1 and 3: No tarneeb card is played; highest lead-suit card wins.
         Tests 2 and 8: Tarneeb beats a higher-ranked lead-suit card.
         Tests 4 and 9: Multiple tarneeb cards; highest tarneeb wins.
         Test 7: Lead suit is the same as the tarneeb suit.
         Tests 5, 10, and 15: Duplicate cards are detected.
         Tests 6, 11, 12, and 14: Invalid ranks (0, 1, and 15) are rejected.
         Test 13: Higher-ranked off-suit card loses to a lower-ranked lead-suit card.
         
         Winner coverage:
         Player 0 wins: Tests 7 and 13.
         Player 1 wins: Tests 1, 2, and 3.
         Player 2 wins: Tests 4 and 9.
         Player 3 wins: Test 8.
         */

        // Coverage checklist (valid vectors):
        //  [x] player 0 wins   
        //  [x] player 1 wins
        //  [x] player 2 wins   
        //  [x] player 3 wins
        //  [x] rank 2 appears  
        //  [x] rank 14 (Ace) appears

        $display("--------------------------------");
        $display("Passed: %0d  Failed: %0d", pass_count, fail_count);
        $display("--------------------------------");
        $finish;
    end

endmodule