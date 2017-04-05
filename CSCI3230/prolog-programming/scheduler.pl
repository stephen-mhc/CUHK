match([a], [a], [a]).
match([X], [Y], [n]) :-
	X \= Y;
	(X = Y, Y = n).

match([a|Atail], [a|Btail], [a|Ttail]) :-
	match(Atail, Btail, Ttail).

match([X|Atail], [Y|Btail], [n|Ttail]) :-
	(X \= Y; (X = Y, Y = n)),
	match(Atail, Btail, Ttail).

match_tutor([FirstTutor|OtherTutor], Result) :-
	match_tutor(OtherTutor, OldResult),
	tutor(FirstTutor, Ttable),
	match(Ttable, OldResult, Result).

match_tutor([OnlyTutor], Onlytable) :-
	tutor(OnlyTutor, Onlytable).

can_join([a|_], [a|_]).

can_join([_|T1], [_|T2]) :-
	can_join(T1, T2).

check_all_can_join([FirstStudent|OtherStudent], Timetable) :-
	check_all_can_join(OtherStudent, Timetable),
	student(FirstStudent, FirstTable),
	can_join(FirstTable, Timetable).

check_all_can_join([OnlyStudent], Timetable) :-
	student(OnlyStudent, OnlyTable),
	can_join(OnlyTable, Timetable).

delete_dummy([All_n, a|Tail], Students, [All_n, a|Tail]) :-
	delete_dummy(Tail, Students, Tail),
	student(S, Stable),
	not(can_join(Stable, [All_n, n|Tail])).

delete_dummy([All_n, a|Tail], Students, [All_n, n|Tail]) :-
	delete_dummy(Tail, Students, Tail),
	check_all_can_join(Students, Tail).

delete_dummy([_|Tail], Students, [_|Tail]) :-
	Tail = [].

find_time_slots(Constraints, Students, Tutorials) :-
	match_tutor(Constraints, TempResult),
	delete_dummy(TempResult,Students, Tutorials).
