#ifndef DSTRUCT_H
#define DSTRUCT_H

#include <stdio.h>
#include <string.h>
#include <iostream>
using namespace std;

typedef struct line {
	int i;
	string s;
};

void addTab(string &s, int indent);

#endif
