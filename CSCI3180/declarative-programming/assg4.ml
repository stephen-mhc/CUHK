(*CSCI3180 Principles of Programming Languages*)
(*--- Declaration ---*)
(*I declare that the assignment here submitted is original except for source material explicitly*)
(*acknowledged. I also acknowledge that I am aware of University policy and regulations on*)
(*honesty in academic work, and of the disciplinary guidelines and procedures applicable to*)
(*breaches of such policy and regulations, as contained in the website*)
(*http://www.cuhk.edu.hk/policy/academichonesty/*)
(*Assignment 4*)
(*Name:			CHEONG Man Hoi*)
(*Student ID:	1155043317*)
(*Email Addr:	stephencheong623@yahoo.com.hk*)

(*Definition of the bTree type*)
datatype 'a bTree = nil | bt of 'a bTree * 'a * 'a bTree;

(*Q3 (a)*)
(*In-order traversal of a binary tree is the in-order traversal of the root's left sub-tree, followed by the root itself, followed by the in-order traversal of the root's right sub-tree*)
fun inorder nil = []
  | inorder (bt(left, i, right)) = inorder(left) @ [i] @ inorder(right);

(*Q3 (b)*)
fun preorder nil = []
  | preorder (bt(left, i, right)) = [i] @ preorder(left) @ preorder(right);

(*Q3 (c)*)
fun postorder nil = []
  | postorder (bt(left, i, right)) = postorder(left) @ postorder(right) @ [i];

(*Q4 (a)*)
(*If the element we want to check is the first element of the list, we check it against the last element of the list. Else, we remove the first and the last element and keep checking until the original i-th element becomes the first element. If in the process i is larger than n/2, then we reverse the list first and keep checking.*)
fun symmetric(i, n, h::tail) = let val rev_h::rev_tail = rev(tail) in
    if i = 1 then h = rev_h
    else if i > n div 2 then symmetric(n - i + 1, n, rev(h::tail))
    else symmetric(i - 1, n - 2, rev(rev_tail))
end;



(*Q4 (b)*)
(*We constantly check whether the first and the last element match with each other, and remove them from the list. We assume [] and [_] are palindromes for convenience*)
fun palindrome(0, []) = true
  | palindrome(1, [h]) = true
  | palindrome(n, h::tail) = let val rev_h::rev_tail = rev(tail) in
    symmetric(1, n, h::tail) andalso palindrome(n - 2, rev(rev_tail))
end;

(*Q4 (c)*)
fun rev([h]) = [h]
  | rev(h::tail) = rev(tail) @ [h];
