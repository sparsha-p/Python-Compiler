# Knuth-Morris-Pratt string matching
# David Eppstein, UC Irvine, 1 Mar 2002

#from http://code.activestate.com/recipes/117214/
def KMP(text, pattern):
    # allow indexing into pattern and protect against change during yield
    pattern = list(pattern)

    # build table of shift amounts
    shifts = [1] * (len(pattern) + 1)    
    shift = 1    
	return True
