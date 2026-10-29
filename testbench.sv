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

        // No tarneeb played, highest lead card wins (x2) 
        // TODO

        // Tarneeb beats higher-ranked lead card (x2) 
        // TODO

        // Multiple tarneeb, highest tarneeb wins (x2) 
        // TODO

        // Lead suit is the tarneeb suit (x1) 
        // TODO

        // Duplicate cards (x2) 
        // TODO

        // Invalid rank < 2 or > 14 (x2), include ranks 0, 1, 15 
        // TODO

        // Higher off-suit card loses to lower lead card (x1) 
        // TODO

        // Coverage checklist (valid vectors):
        //  [ ] player 0 wins   
        //  [ ] player 1 wins
        //  [ ] player 2 wins   
        //  [ ] player 3 wins
        //  [ ] rank 2 appears  
        //  [ ] rank 14 (Ace) appears

        $display("--------------------------------");
        $display("Passed: %0d  Failed: %0d", pass_count, fail_count);
        $display("--------------------------------");
        $finish;
    end

endmodule