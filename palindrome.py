def is_palindrome(string):
	if not isinstance(string, str):
		return False
	l = len(string)
	for i in range(l):
		if string[i] != string[l-i-1]:
			return False
	return True
