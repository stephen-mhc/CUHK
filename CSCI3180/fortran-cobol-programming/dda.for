* -- Declaration --
*
* I declare that the assignment here submitted is original except
* for source material explicitly acknowledged. I also acknowledge
* that I am aware of University policy and regulations on honesty
* in academic work, and of the disciplinary guidelines and
* procedures applicable to breaches of such policy and regulations,
* as contained in the website
* http://www.cuhk.edu.hk/policy/academichonesty/
*
* Assignment 1
* Name:       CHEONG Man Hoi
* Student ID: 1155043317
* Email Addr: stephencheong623@yahoo.com.hk

      PROGRAM DDA
      IMPLICIT NONE
*Using a 2-D array to represent every integer point in the 2-D space
*The ROW no. of the 2-D array GRAPH corresponds to the x coordinate
*The COLUMN no. corresponds to the y coordinate
      CHARACTER*1 GRAPH(0:78, 0:22)
      INTEGER NPTS, N
      INTEGER X1, Y1, X2, Y2
      INTEGER IOS
*Initialize the graph
      CALL INITIALIZE(GRAPH)
      OPEN (UNIT = 1, FILE = 'input.txt', IOSTAT = IOS, STATUS = 'OLD')
*When I/O error occurs, terminate the program
      IF (IOS .NE. 0) THEN
        WRITE (*, *) "Error occurred when opening file. Program ends."
        GOTO 100
      ENDIF
      READ (UNIT = 1, *) NPTS
      N = 1
*Each time reading TWO points and drawing a line between them
*Hence we need to BACKSPACE once every time we try to get new points
70    READ (UNIT = 1, *) X1, Y1
      READ (UNIT = 1, *) X2, Y2
      CALL LINE(GRAPH, X1, Y1, X2, Y2)
      N = N + 1
      IF (N .GE. NPTS) THEN
*No more points
        GOTO 60
      ENDIF
      BACKSPACE (UNIT = 1)
*After the BACKSPACE, go back and read the following two points
      GOTO 70
*Plot the graph
60    CALL DRAW(GRAPH)
      CLOSE (UNIT = 1)
100   END

      SUBROUTINE INITIALIZE(GRAPH)
*Initialize the coordinate system, i.e. the x axis '-',
*the y axis '|', the origin '+' and all the spaces ' '
      CHARACTER*1 GRAPH(0:78, 0:22)
      INTEGER I, J
      I = 0
20    J = 0
10    IF (I .NE. 0) THEN
        IF (J .NE. 0) THEN
          GRAPH(I, J) = ' '
        ENDIF
        IF (J .EQ. 0) THEN
          GRAPH(I, J) = '-'
        ENDIF
      ENDIF
      IF (I .EQ. 0) THEN
        IF (J .NE. 0) THEN
          GRAPH(I, J) = '|'
        ENDIF
        IF (J .EQ. 0) THEN
          GRAPH(I, J) = '+'
        ENDIF
      ENDIF
*Initialize every point in the current column
      J = J + 1
      IF (J .LE. 22) THEN
*Loop until the last one is reached
        GOTO 10
      ENDIF
      IF (J .GT. 22) THEN
*Finished the current x-column, move to the next
        I = I + 1
        IF (I .LE. 78) THEN
*After incrementing I by 1, we have to set J back to 0, and loop
          GOTO 20
        ENDIF
        IF (I .GT. 78) THEN
*Finished the whole graph
          GOTO 30
        ENDIF
      ENDIF
30    END

      SUBROUTINE LINE(GRAPH, X1, Y1, X2, Y2)
*This part is for drawing a line between the two input points
      CHARACTER*1 GRAPH(0:78, 0:22)
      INTEGER X1, Y1, X2, Y2
      INTEGER N
      REAL SLOPE
      SLOPE = (Y2 - Y1) / ((X2 - X1) * 1.0)
*Check the absolute value of the slope
      IF (ABS(SLOPE) .LE. 1) THEN
        IF (X1 .GT. X2) THEN
          CALL SWAP(X1, X2)
          CALL SWAP(Y1, Y2)
        ENDIF
        N = 0
80      GRAPH(X1 + N, NINT(Y1 + N * SLOPE)) = '*'
        N = N + 1
        IF (X1 + N .LE. X2) THEN
*Loop until every point in the line has been marked '*'
          GOTO 80
        ENDIF
      ENDIF
      IF (ABS(SLOPE) .GT. 1) THEN
        IF (Y1 .GT. Y2) THEN
          CALL SWAP(X1, X2)
          CALL SWAP(Y1, Y2)
        ENDIF
        N = 0
90      GRAPH(NINT(X1 + N / SLOPE), Y1 + N) = '*'
        N = N + 1
        IF (Y1 + N .LE. Y2) THEN
*Loop until every point in the line has been marked '*'
          GOTO 90
        ENDIF
      ENDIF
      END

      SUBROUTINE DRAW(GRAPH)
*This part is for outputing the final graph to the console
      CHARACTER*1 GRAPH(0:78, 0:22)
      INTEGER I, J
*Start drawing from up to bottom
      J = 22
50    I = 0
*When I <= 77 we dont need the blank following the WRITE statement
40    WRITE (*, FMT = '(0X, A$)') GRAPH(I, J)
      I = I + 1
      IF (I .LE. 77) THEN
        GOTO 40
      ENDIF
      IF (I .EQ. 78) THEN
        WRITE (*, FMT = '(0X, A)') GRAPH(I, J)
      ENDIF
*Finished the current J-row, move one level lower, and start from I = 0
      J = J - 1
      IF (J .GE. 0) THEN
        GOTO 50
      ENDIF
      END

      SUBROUTINE SWAP(A, B)
*Just a subroutine for swapping two elements
      INTEGER A, B, T
      T = A
      A = B
      B = T
      END
