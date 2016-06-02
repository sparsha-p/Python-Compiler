# Knuth-Morris-Pratt string matching
# David Eppstein, UC Irvine, 1 Mar 2002

#from http://code.activestate.com/recipes/117214/
def KMP(text, pattern):

    # allow indexing into pattern and protect against change during yield
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
    l = len(text)
    for c in range(l):
        while matchLen == len(pattern) or matchLen >= 0 and pattern[matchLen] != text[c]:
            startPos += shifts[matchLen]
            matchLen -= shifts[matchLen]
        matchLen += 1
        if matchLen == len(pattern):
            print startPos
