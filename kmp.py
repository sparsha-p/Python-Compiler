# Knuth-Morris-Pratt string matching
# David Eppstein, UC Irvine, 1 Mar 2002

#from http://code.activestate.com/recipes/117214/
def KMP(text, pattern):

    # allow indexing into pattern and protect against change during yield
    if (not isinstance(text, str)) or (not isinstance(pattern, str)):
    	return False
    pattern = list(pattern)

    # build table of shift amounts
    shifts = [1]
    for pos in range(len(pattern)):
    	shifts.append(1)
    shift = 1
    for pos in range(len(pattern)):
        while shift <= pos and pattern[pos] != pattern[pos-shift]:
            shift += shifts[pos-shift]
        shifts[pos+1] = shift

    # do the actual search
    startPos = 0
    matchLen = 0
    result = []
    l = len(text)
    for c in range(l):
        while matchLen == len(pattern) or matchLen >= 0 and pattern[matchLen] != text[c]:
            startPos += shifts[matchLen]
            matchLen -= shifts[matchLen]
        matchLen += 1
        if matchLen == len(pattern):
            result.append(startPos)
	l = len(result)
	if l==0:
		return False
	else:
		for i in range(l):
			print result[i]
