000010 IDENTIFICATION DIVISION.
000020 PROGRAM-ID. DDA.
000030 AUTHOR.     STEPHEN.
000040
000050 ENVIRONMENT DIVISION.
000060 INPUT-OUTPUT SECTION.
000070 FILE-CONTROL.
000080     SELECT INPUT-FILE ASSIGN TO DISK
000090       ORGANIZATION IS LINE SEQUENTIAL
000100       FILE STATUS IS INPUT-FILE-STATUS.
000110     SELECT OUTPUT-FILE ASSIGN TO DISK
000120       ORGANIZATION IS LINE SEQUENTIAL
000130       FILE STATUS IS OUTPUT-FILE-STATUS.
000140
000150 DATA DIVISION.
000160 FILE SECTION.
000170 FD INPUT-FILE
000180     LABEL RECORDS ARE STANDARD
000190     VALUE OF FILE-ID IS "input.txt".
000200 01 NUM       PIC 99.
000210 01 POINTS.
000220    03 X-COORDINATE PIC 99.
000230    03 SEPERATION   PIC X.
000240    03 Y-COORDINATE PIC 99.
000250 FD OUTPUT-FILE
000260     LABEL RECORDS ARE STANDARD
000270     VALUE OF FILE-ID IS "output.txt".
000280 01 ONE-LINE PIC X(79).
000290 WORKING-STORAGE SECTION.
000300 01 GRAPH-TABLE.
000310    03 Y OCCURS 23.
000320       05 X PIC X OCCURS 79.
000330 01 NUM-POINTS  PIC 99.
000340 01 POINT-1.
000350    03 X1      PIC 99.
000360    03 SPACE-1 PIC X.
000370    03 Y1      PIC 99.
000380 01 POINT-2.
000390    03 X2      PIC 99.
000400    03 SPACE-2 PIC X.
000410    03 Y2      PIC 99.
000420 01 NEED-TO-SKIP PIC 99 VALUE 00.
000430 01 COUNTER      PIC 99 VALUE 00.
000440 01 SLOPE PIC S99V9999.
000450 01 I     PIC 99 VALUE 01.
000460 01 J     PIC 99 VALUE 01.
000470 01 TEMP-X   PIC 99.
000480 01 TEMP-Y   PIC 99.
000490 01 INPUT-FILE-STATUS  PIC XX.
000500 01 OUTPUT-FILE-STATUS PIC XX.
000510
000520*In order to save memory space, we will not declare a large array
000530*in advance to handle a possibly large number of data points.
000540*Instead, we only declare two variables to store two points each
000550*time. Every time we draw a line, we discard the oldest data point
000560*and read in a new one and draw another line, and so on.
000570
000580*To achieve this, we should read in two points, draw a line,
000590*backspace once, and read two points again. However, a function
000600*like the "backspace" is not known, so we will open and close
000610*the input file multiple times. In subsequent reads, we will skip
000620*some records.
000630
000640*One important point to notice is that in order to make the 2-D
000650*table declared in this program look like the real coordinate
000660*system, the real x-coordinate will correspond to the second
000670*subscript of the 2-D table, while the y-coordinate will
000680*correspond to the first subscript of the table.
000690
000700*Usually the variable I will correspond to the x-coordinate,
000710*and the variable J will correspond to the y-coordinate.
000720
000730 PROCEDURE DIVISION.
000740 PROG-MAIN.
000750     PERFORM INITIALIZATION.
000760     OPEN INPUT INPUT-FILE.
000770*If any error occurs when opening the file
000780     IF INPUT-FILE-STATUS NOT = "00"
000790        DISPLAY "Error occurred when opening file. Program ends."
000800        GO TO PROG-DONE.
000810     READ INPUT-FILE.
000820     INSPECT NUM REPLACING ALL ' ' BY '0'.
000830     MOVE NUM TO NUM-POINTS.
000840*If we have N points, we only need to draw N - 1 lines.
000850     COMPUTE NUM-POINTS = NUM-POINTS - 1.
000860     CLOSE INPUT-FILE.
000870     PERFORM GET-INFO-AND-CALCULATE.
000880     OPEN OUTPUT OUTPUT-FILE.
000890     IF OUTPUT-FILE-STATUS NOT = "00"
000900        DISPLAY "Error occurred when opening file. Program ends."
000910        GO TO PROG-DONE.
000920     MOVE 23 TO I.
000930     PERFORM DRAW-GRAPH.
000940     CLOSE OUTPUT-FILE.
000950
000960 PROG-DONE.
000970     STOP RUN.
000980
000990*This paragraph is for initializing the graph, i.e. filling in
001000*spaces, the origin '+', the x-axis '-' and the y-axis '|'.
001010 INITIALIZATION.
001020     IF I NOT > 79
001030        GO TO ASSIGN-INITIAL.
001040*When I > 79, it means the current row is finished,
001050*and we should proceed to the next row.
001060     IF I > 79
001070        COMPUTE J = J + 1
001080        MOVE 1 TO I.
001090     IF J NOT > 23
001100        GO TO ASSIGN-INITIAL.
001110*When J > 23, it means the whole graph is initialized.
001120
001130 ASSIGN-INITIAL.
001140     IF I NOT = 1 AND J = 1
001150        MOVE '-' TO X(J, I).
001160     IF I = 1 AND J = 1
001170        MOVE '+' TO X(J, I).
001180     IF I = 1 AND J NOT = 1
001190        MOVE '|' TO X(J, I).
001200     IF I NOT = 1 AND J NOT = 1
001210        MOVE ' ' TO X(J, I).
001220     COMPUTE I = I + 1.
001230     GO TO INITIALIZATION.
001240
001250*This is the major part of the program. We start to read in
001260*data ponits and draw lines between them.
001270 GET-INFO-AND-CALCULATE.
001280*When we still have points to read, continue
001290     IF NUM-POINTS > 0
001300        OPEN INPUT INPUT-FILE
001310        READ INPUT-FILE
001320        PERFORM SKIP-RECORDS
001330        GO TO GET-TWO-POINTS.
001340
001350*The following two paragraphs is for skipping data points in the
001360*input file, so that we can arrive at the correct place to read
001370*in new data points.
001380 SKIP-RECORDS.
001390*There are still data point(s) to skip.
001400     IF COUNTER > 0
001410        GO TO DUMMY-READ.
001420
001430 DUMMY-READ.
001440     READ INPUT-FILE.
001450     COMPUTE COUNTER = COUNTER - 1.
001460     GO TO SKIP-RECORDS.
001470
001480*This paragraph is for reading two data points from the input
001490*file.
001500 GET-TWO-POINTS.
001510     READ INPUT-FILE INTO POINT-1.
001520     READ INPUT-FILE INTO POINT-2.
001530     INSPECT X1 REPLACING ALL ' ' BY '0'.
001540     INSPECT Y1 REPLACING ALL ' ' BY '0'.
001550     INSPECT X2 REPLACING ALL ' ' BY '0'.
001560     INSPECT Y2 REPLACING ALL ' ' BY '0'.
001570     CLOSE INPUT-FILE.
001580*Each time we read two points, we close the file, and remember
001590*that next time we need to skip one more data point
001600     COMPUTE NEED-TO-SKIP = NEED-TO-SKIP + 1.
001610*NEED-TO-SKIP will keep increasing, while COUNTER will share the
001620*same value, but will decrease when we skip the records when
001630*reading the input file.
001640     MOVE NEED-TO-SKIP TO COUNTER.
001650*There is one less line to draw.
001660     COMPUTE NUM-POINTS = NUM-POINTS - 1.
001670     GO TO CONNECT-TWO-POINTS.
001680
001690*This paragraph is for really drawing the line between the two
001700*previously read data points.
001710 CONNECT-TWO-POINTS.
001720*The line is a vertical line, i.e. the slope is infinity.
001730     IF X1 = X2 AND Y1 > Y2
001740        PERFORM SWAP
001750        GO TO VERTICAL-LINE.
001760     IF X1 = X2 AND Y1 NOT > Y2
001770        GO TO VERTICAL-LINE.
001780*If X1 is not equal to X2, then we can calculate the slope.
001790     COMPUTE SLOPE = (Y2 - Y1)/(X2 - X1).
001800*This is case 2.
001810     IF (SLOPE > 1 OR SLOPE < -1) AND Y1 > Y2
001820        PERFORM SWAP
001830        MOVE 0 TO J
001840        GO TO LARGE-SLOPE.
001850     IF (SLOPE > 1 OR SLOPE < -1) AND Y1 < Y2
001860        MOVE 0 TO J
001870        GO TO LARGE-SLOPE.
001880*This remaining part is case 1.
001890     IF X1 > X2
001900        PERFORM SWAP
001910        MOVE 0 TO I
001920        GO TO SMALL-SLOPE.
001930     IF X1 < X2
001940        MOVE 0 TO I
001950        GO TO SMALL-SLOPE.
001960
001970 VERTICAL-LINE.
001980     IF Y1 NOT > Y2
001990        GO TO ASSIGN-STAR-VERTICAL.
002000     GO TO GET-INFO-AND-CALCULATE.
002010
002020 ASSIGN-STAR-VERTICAL.
002030     MOVE '*' TO X(Y1 + 1, X1 + 1).
002040     COMPUTE Y1 = Y1 + 1.
002050     GO TO VERTICAL-LINE.
002060
002070*Case 2: absolute value of the slope is larger than 1.
002080 LARGE-SLOPE.
002090     IF Y1 NOT > Y2
002100        GO TO ASSIGN-STAR-LARGE.
002110     GO TO GET-INFO-AND-CALCULATE.
002120
002130 ASSIGN-STAR-LARGE.
002140     COMPUTE I ROUNDED = X1 + J / SLOPE.
002150     MOVE '*' TO X(Y1 + 1, I + 1).
002160     COMPUTE J = J + 1.
002170     COMPUTE Y1 = Y1 + 1.
002180     GO TO LARGE-SLOPE.
002190
002200*Case 1: absolute value of the slope is small than or equal to 1.
002210 SMALL-SLOPE.
002220     IF X1 NOT > X2
002230        GO TO ASSIGN-STAR-SMALL.
002240     GO TO GET-INFO-AND-CALCULATE.
002250
002260 ASSIGN-STAR-SMALL.
002270     COMPUTE J ROUNDED = Y1 + I * SLOPE.
002280     MOVE '*' TO X(J + 1, X1 + 1).
002290     COMPUTE I = I + 1.
002300     COMPUTE X1 = X1 + 1.
002310     GO TO SMALL-SLOPE.
002320
002330*Just a macro for swapping two data points.
002340 SWAP.
002350     MOVE X1 TO TEMP-X.
002360     MOVE Y1 TO TEMP-Y.
002370     MOVE X2 TO X1.
002380     MOVE Y2 TO Y1.
002390     MOVE TEMP-X TO X2.
002400     MOVE TEMP-Y TO Y2.
002410
002420 DRAW-GRAPH.
002430     IF I NOT < 1
002440        GO TO DRAW.
002450 DRAW.
002460     WRITE ONE-LINE FROM Y(I).
002470     COMPUTE I = I - 1.
002480     GO TO DRAW-GRAPH.
002490
002500
002510* -- Declaration --
002520*
002530* I declare that the assignment here submitted is original except
002540* for source material explicitly acknowledged. I also acknowledge
002550* that I am aware of University policy and regulations on honesty
002560* in academic work, and of the disciplinary guidelines and
002570* procedures applicable to breaches of such policy and
002580* regulations, as contained in the website
002590* http://www.cuhk.edu.hk/policy/academichonesty/
002600*
002610* Assignment 1
002620* Name:       CHEONG Man Hoi
002630* Student ID: 1155043317
002640* Email Addr: stephencheong623@yahoo.com.hk
