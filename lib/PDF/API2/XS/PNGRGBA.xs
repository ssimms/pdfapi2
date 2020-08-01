#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
 
MODULE = PDF::API2::XS::PNGRGBA  PACKAGE = PDF::API2::XS::PNGRGBA
PROTOTYPES: ENABLE
 
AV*
process (AV * stream, int w, int h)
  CODE:
    // The image is passed as a Perl AV (Array Variable)
    // First we need to turn it into a C array of bytes
    uint8_t * in_array = (uint8_t *)malloc((w * h * 4) * sizeof(uint8_t));
    for (int i=0; i < av_len(stream); i++) {
      SV** elem = av_fetch(stream, i, 0);
      char * ptr = SvPV_nolen(*elem);
      uint8_t byte = (uint8_t) *ptr;
      *(in_array + i) = byte;
    }

    // Now we can do the transformation into a C array of bytes
    uint8_t * out_array = (uint8_t *)malloc((w * h * 3) * sizeof(uint8_t));
    for (int i = 0; i < w * h; i++) {
      *(out_array + (i * 3) + 0 ) = *(in_array + (i * 4) + 0 );
      *(out_array + (i * 3) + 1 ) = *(in_array + (i * 4) + 1 );
      *(out_array + (i * 3) + 2 ) = *(in_array + (i * 4) + 2 );
      *(out_array + (i * 0) + 0 ) = *(in_array + (i * 4) + 3 );
    }

    // Put the results back into a Perl AV
    AV * outstream = newAV();
    for (int i = 0; i < (w * h * 3); i++) {
      SV* this_sv = newSVuv(*(out_array + i));
      av_push(outstream, this_sv);
    }

    // Send it back to Perl
    RETVAL = outstream;
  OUTPUT:
    RETVAL
