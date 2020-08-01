#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdlib.h>
#include <stdint.h>
 
MODULE = PDF::API2::XS::PaethPredictor  PACKAGE = PDF::API2::XS::PaethPredictor
PROTOTYPES: ENABLE
 
int
pp (a, b, c)
  int a
  int b
  int c
  CODE:
    int p = a + b - c;
    int pa = abs(p - a);
    int pb = abs(p - b);
    int pc = abs(p - c);
    if ((pa <= pb ) && (pa <= pc)) {
        RETVAL = a;
    }
    else if (pb <= pc) {
        RETVAL = b;
    }
    else {
        RETVAL = c;
    }
  OUTPUT:
    RETVAL
