def is_palindrome(string):
	l = len(string)
	for i in range(l):
		if string[i] != string[l-i-1]:
			return False
	return True
