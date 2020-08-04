#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdlib.h>
#include <stdint.h>
 
MODULE = PDF::API2::XS::ImagePNG  PACKAGE = PDF::API2::XS::ImagePNG
PROTOTYPES: ENABLE
 
AV*
outstream (AV * stream, int w, int h)
  CODE:
    //
    // The image is passed as a Perl AV (Array Variable).
    //
    // It cannot be passed in as a regular C char string
    // or converted to a regular C char string because
    // it gets truncated at the first zero byte.
    //
    // First we need to turn it into a C array of bytes.
    // av_len, av_fetch and SvPV_nolen are XS macros.
    // See documentation here: https://perldoc.perl.org/perlguts.html
    //
    uint8_t * in_array = (uint8_t *)malloc((w * h * 4) * sizeof(uint8_t));
    uint8_t * out_array = (uint8_t *)malloc((w * h * 4) * sizeof(uint8_t));
    uint8_t * dict_array = (uint8_t *)malloc((w * h) * sizeof(uint8_t));

    if (in_array == NULL || out_array == NULL || dict_array == NULL) { return; }

    for (int i=0; i < av_len(stream); i++) {
      SV** elem = av_fetch(stream, i, 0);
      char * ptr = SvPV_nolen(*elem);
      uint8_t byte = (uint8_t) *ptr;
      *(in_array + i) = byte;
    }

    // Transform the image into a new C array of bytes.
    for (int i = 0; i < w * h; i++) {
      *(out_array + (i * 3) + 0 ) = *(in_array + (i * 4) + 0 );
      *(out_array + (i * 3) + 1 ) = *(in_array + (i * 4) + 1 );
      *(out_array + (i * 3) + 2 ) = *(in_array + (i * 4) + 2 );

      *(dict_array + i) = *(in_array + (i * 4) + 3 );
    }

    // Put the results back into a new Perl AV.
    AV * outstream_av = newAV();
    for (int i = 0; i < (w * h * 3); i++) {
      SV* this_sv = newSVuv(*(out_array + i));
      av_push(outstream_av, this_sv);
    }

    for (int i = 0; i < (w * h * 3); i++) {
      SV* this_sv = newSVuv(*(dict_array + i));
      av_push(outstream_av, this_sv);
    }

    free(in_array);
    free(out_array);
    free(dict_array);

    // Send the transformed image back to Perl in the new AV.
    RETVAL = outstream_av;
  OUTPUT:
    RETVAL

int
paeth_predictor (a, b, c)
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
