% CSCI3180 Principles of Programming Languages
% --- Declaration ---
% I declare that the assignment here submitted is original except for source material explicitly
% acknowledged. I also acknowledge that I am aware of University policy and regulations on
% honesty in academic work, and of the disciplinary guidelines and procedures applicable to
% breaches of such policy and regulations, as contained in the website
% http://www.cuhk.edu.hk/policy/academichonesty/
% Assignment 4
% Name:			CHEONG Man Hoi
% Student ID:	1155043317
% Email Addr:	stephencheong623@yahoo.com.hk

% definition of successor
s(A, B) :- B is A + 1.

% definition of sum
sum(X, 0, X).
% sum(X, Y, Z) :- sum(X, B, C), s(B, Y), s(C, Z).
sum(X, s(Y), s(Z)) :- sum(X, Y, Z).

% Q1 (a)
product(X, 0, 0).
product(X, s(Y), Z1) :- product(X, Y, Z), sum(X, Z, Z1).

% Q1 (b)
% product(s(s(s(0))), s(s(s(s(0)))), X).

% Q1 (c)
% product(s(s(s(s(0)))), X, s(s(s(s(s(s(s(s(0))))))))).

% Q1 (d)
% product(X, Y, s(s(s(s(s(s(0))))))).

% Q1 (e)
exp(X, 0, s(0)).
exp(X, s(Y), Z1) :- exp(X, Y, Z), product(Z, X, Z1).

% Q1 (f)
% exp(s(s(0)), s(s(s(0))), X).

% Q1 (g)
% exp(s(s(0)), X, s(s(s(s(s(s(s(s(0))))))))).



% Q2 (a)
% one fact per transition
transition(a, 0, c).
transition(a, 1, a).
transition(b, 0, c).
transition(b, 1, a).
transition(c, 0, c).
transition(c, 1, b).

% Q2 (b)
% straightforward comparison
state(N) :- N = a; N = b; N = c.

% Q2 (c)
% when there is only one element left in the list, check whether there is such transition
walk([H], B, E) :- transition(B, H, E), state(B), state(E).

% check if the first element of the list will lead us from state B to a particular state S, and whether the remaining of the list will lead us from state S to the ending state E
walk([H|T], B, E) :- transition(B, H, C), walk(T, C, E), state(B), state(E), state(C).
