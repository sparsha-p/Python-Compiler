#include "dstruct.h"

void addTab(string &s, int indent) {
	s = "";
	for (int i = 0; i < indent; i++) {
		s += "\t";
	}
	return;
}
