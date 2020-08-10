#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdlib.h>
#include <stdint.h>

int paeth_predictor (int a, int b, int c) {
    int p = a + b - c;
    int pa = abs(p - a);
    int pb = abs(p - b);
    int pc = abs(p - c);
    if ((pa <= pb ) && (pa <= pc)) {
        return a;
    }
    else if (pb <= pc) {
        return b;
    }
    else {
        return c;
    }
}

MODULE = PDF::API2::XS::ImagePNG  PACKAGE = PDF::API2::XS::ImagePNG
PROTOTYPES: ENABLE

AV*
unfilter (AV * line, AV * prev, int filter, int bpp)
  CODE:
    int line_length = av_len(line);
    uint8_t * in_array   = (uint8_t *)malloc((line_length) * sizeof(uint8_t));
    uint8_t * prev_array = (uint8_t *)malloc((line_length) * sizeof(uint8_t));
    uint8_t * out_array  = (uint8_t *)malloc((line_length) * sizeof(uint8_t));
    if (in_array == NULL || out_array == NULL || prev_array == NULL) { 
      croak("Null pointer from memory allocation in ImagePNG.xs");
      return;
    }

    for (int i = 0; i < line_length; i++) {
      SV** elem = av_fetch(line, i, 0);
      char * ptr = SvPV_nolen(*elem);
      uint8_t byte = (uint8_t) *ptr;
      *(in_array + i) = byte;
    }

    for (int i = 0; i < line_length; i++) {
      uint8_t byte;
      SV** elem = av_fetch(prev, i, 0);
      if (elem != NULL) {
        char * ptr = SvPV_nolen(*elem);
        byte = (uint8_t) *ptr;
      }
      else {
        byte = 0;
      }
      *(prev_array + i) = byte;
    }

    switch (filter) {
      case 0 :
        for (int i = 0; i < line_length; i++) {
          *(out_array + i) = *(in_array + i);
        }
        break;

      case 1 :
        for (int i = 0; i < line_length; i++) {
          uint8_t sub;
          if (i < bpp) {
            sub = *(in_array + i);
          }
          else {
            sub = *(in_array + i) + *(out_array + i - bpp);
          }
          *(out_array + i) = sub;
        }
        break;

      case 2 :
        for (int i = 0; i < line_length; i++) {
          *(out_array + i) = *(in_array + i) + *(prev_array + i);
        }
        break;

      case 3 :
        for (int i = 0; i < line_length; i++) {
          uint8_t sub;
          if (i < bpp) {
            sub = *(in_array + i) + (*(prev_array + i) / 2); 
          }
          else {
            sub = *(in_array + i) + ((*(out_array + i - bpp) + *(prev_array + i)) / 2);
          }
          *(out_array + i) = sub;
        }
        break;

      case 4 : 
        for (int i = 0; i < line_length; i++) {
          uint8_t a, b, c;
          b = *(prev_array + i);
          if (i < bpp) {
            a = 0;
            c = 0;
          }
          else {
            a = *(out_array + i - bpp);
            c = *(prev_array + i - bpp);
          }
          *(out_array + i) = *(in_array + i) + paeth_predictor(a, b, c);
        }
        break;
    }

    // Put the results back into a new Perl AV.
    AV * clearstream_av = newAV();
    for (int i = 0; i < (line_length); i++) {
      SV* this_sv = newSVuv(*(out_array + i));
      av_push(clearstream_av, this_sv);
    }

    free(in_array);
    free(out_array);
    free(prev_array);

    RETVAL = clearstream_av;
  OUTPUT:
    RETVAL

AV*
split_channels (AV * stream, int w, int h)
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

    if (in_array == NULL || out_array == NULL || dict_array == NULL) {
      croak("Null pointer from memory allocation in ImagePNG.xs");
      return;
    }

    for (int i = 0; i < av_len(stream); i++) {
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

