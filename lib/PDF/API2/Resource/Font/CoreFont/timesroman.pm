#=======================================================================
#    ____  ____  _____              _    ____ ___   ____
#   |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#   | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#   |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#   |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#   A Perl Module Chain to faciliate the Creation and Modification
#   of High-Quality "Portable Document Format (PDF)" Files.
#
#   Copyright 1999-2005 Alfred Reibenschuh <areibens@cpan.org>.
#
#=======================================================================
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Lesser General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public
#   License along with this library; if not, write to the
#   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
#   Boston, MA 02111-1307, USA.
#
#   $Id$
#
#=======================================================================
package PDF::API2::Resource::Font::CoreFont::timesroman;

$FONTDATA = {
    'fontname' => 'Times-Roman',
    'type' => 'Type1',
    'apiname' => 'TiRo',
    'ascender' => '683',
    'capheight' => '662',
    'descender' => '-217',
    'iscore' => '1',
    'isfixedpitch' => '0',
    'italicangle' => '0',
    'missingwidth' => '250',
    'stdhw' => '28',
    'stdvw' => '84',
    'underlineposition' => '-100',
    'underlinethickness' => '50',
    'xheight' => '450',
    'firstchar' => '32',
    'lastchar' => '255',
    'fontbbox' => [-168, -218, 1000, 898],
    'char' => [
        '.notdef',           # C+00, U+0000
        '.notdef',           # C+01, U+0000
        '.notdef',           # C+02, U+0000
        '.notdef',           # C+03, U+0000
        '.notdef',           # C+04, U+0000
        '.notdef',           # C+05, U+0000
        '.notdef',           # C+06, U+0000
        '.notdef',           # C+07, U+0000
        '.notdef',           # C+08, U+0000
        '.notdef',           # C+09, U+0000
        '.notdef',           # C+0A, U+0000
        '.notdef',           # C+0B, U+0000
        '.notdef',           # C+0C, U+0000
        '.notdef',           # C+0D, U+0000
        '.notdef',           # C+0E, U+0000
        '.notdef',           # C+0F, U+0000
        '.notdef',           # C+10, U+0000
        '.notdef',           # C+11, U+0000
        '.notdef',           # C+12, U+0000
        '.notdef',           # C+13, U+0000
        '.notdef',           # C+14, U+0000
        '.notdef',           # C+15, U+0000
        '.notdef',           # C+16, U+0000
        '.notdef',           # C+17, U+0000
        '.notdef',           # C+18, U+0000
        '.notdef',           # C+19, U+0000
        '.notdef',           # C+1A, U+0000
        '.notdef',           # C+1B, U+0000
        '.notdef',           # C+1C, U+0000
        '.notdef',           # C+1D, U+0000
        '.notdef',           # C+1E, U+0000
        '.notdef',           # C+1F, U+0000
        'space',             # C+20, U+0020
        'exclam',            # C+21, U+0021
        'quotedbl',          # C+22, U+0022
        'numbersign',        # C+23, U+0023
        'dollar',            # C+24, U+0024
        'percent',           # C+25, U+0025
        'ampersand',         # C+26, U+0026
        'quoteright',        # C+27, U+2019
        'parenleft',         # C+28, U+0028
        'parenright',        # C+29, U+0029
        'asterisk',          # C+2A, U+002A
        'plus',              # C+2B, U+002B
        'comma',             # C+2C, U+002C
        'hyphen',            # C+2D, U+002D
        'period',            # C+2E, U+002E
        'slash',             # C+2F, U+002F
        'zero',              # C+30, U+0030
        'one',               # C+31, U+0031
        'two',               # C+32, U+0032
        'three',             # C+33, U+0033
        'four',              # C+34, U+0034
        'five',              # C+35, U+0035
        'six',               # C+36, U+0036
        'seven',             # C+37, U+0037
        'eight',             # C+38, U+0038
        'nine',              # C+39, U+0039
        'colon',             # C+3A, U+003A
        'semicolon',         # C+3B, U+003B
        'less',              # C+3C, U+003C
        'equal',             # C+3D, U+003D
        'greater',           # C+3E, U+003E
        'question',          # C+3F, U+003F
        'at',                # C+40, U+0040
        'A',                 # C+41, U+0041
        'B',                 # C+42, U+0042
        'C',                 # C+43, U+0043
        'D',                 # C+44, U+0044
        'E',                 # C+45, U+0045
        'F',                 # C+46, U+0046
        'G',                 # C+47, U+0047
        'H',                 # C+48, U+0048
        'I',                 # C+49, U+0049
        'J',                 # C+4A, U+004A
        'K',                 # C+4B, U+004B
        'L',                 # C+4C, U+004C
        'M',                 # C+4D, U+004D
        'N',                 # C+4E, U+004E
        'O',                 # C+4F, U+004F
        'P',                 # C+50, U+0050
        'Q',                 # C+51, U+0051
        'R',                 # C+52, U+0052
        'S',                 # C+53, U+0053
        'T',                 # C+54, U+0054
        'U',                 # C+55, U+0055
        'V',                 # C+56, U+0056
        'W',                 # C+57, U+0057
        'X',                 # C+58, U+0058
        'Y',                 # C+59, U+0059
        'Z',                 # C+5A, U+005A
        'bracketleft',       # C+5B, U+005B
        'backslash',         # C+5C, U+005C
        'bracketright',      # C+5D, U+005D
        'asciicircum',       # C+5E, U+005E
        'underscore',        # C+5F, U+005F
        'quoteleft',         # C+60, U+2018
        'a',                 # C+61, U+0061
        'b',                 # C+62, U+0062
        'c',                 # C+63, U+0063
        'd',                 # C+64, U+0064
        'e',                 # C+65, U+0065
        'f',                 # C+66, U+0066
        'g',                 # C+67, U+0067
        'h',                 # C+68, U+0068
        'i',                 # C+69, U+0069
        'j',                 # C+6A, U+006A
        'k',                 # C+6B, U+006B
        'l',                 # C+6C, U+006C
        'm',                 # C+6D, U+006D
        'n',                 # C+6E, U+006E
        'o',                 # C+6F, U+006F
        'p',                 # C+70, U+0070
        'q',                 # C+71, U+0071
        'r',                 # C+72, U+0072
        's',                 # C+73, U+0073
        't',                 # C+74, U+0074
        'u',                 # C+75, U+0075
        'v',                 # C+76, U+0076
        'w',                 # C+77, U+0077
        'x',                 # C+78, U+0078
        'y',                 # C+79, U+0079
        'z',                 # C+7A, U+007A
        'braceleft',         # C+7B, U+007B
        'bar',               # C+7C, U+007C
        'braceright',        # C+7D, U+007D
        'asciitilde',        # C+7E, U+007E
        '.notdef',           # C+7F, U+0000
        'Euro',              # C+80, U+20AC
        'bullet',            # C+81, U+2022
        'quotesinglbase',    # C+82, U+201A
        'florin',            # C+83, U+0192
        'quotedblbase',      # C+84, U+201E
        'ellipsis',          # C+85, U+2026
        'dagger',            # C+86, U+2020
        'daggerdbl',         # C+87, U+2021
        'circumflex',        # C+88, U+02C6
        'perthousand',       # C+89, U+2030
        'Scaron',            # C+8A, U+0160
        'guilsinglleft',     # C+8B, U+2039
        'OE',                # C+8C, U+0152
        'bullet',            # C+8D, U+2022
        'Zcaron',            # C+8E, U+017D
        'bullet',            # C+8F, U+2022
        'bullet',            # C+90, U+2022
        'quoteleft',         # C+91, U+2018
        'quoteright',        # C+92, U+2019
        'quotedblleft',      # C+93, U+201C
        'quotedblright',     # C+94, U+201D
        'bullet',            # C+95, U+2022
        'endash',            # C+96, U+2013
        'emdash',            # C+97, U+2014
        'tilde',             # C+98, U+02DC
        'trademark',         # C+99, U+2122
        'scaron',            # C+9A, U+0161
        'guilsinglright',    # C+9B, U+203A
        'oe',                # C+9C, U+0153
        'bullet',            # C+9D, U+2022
        'zcaron',            # C+9E, U+017E
        'Ydieresis',         # C+9F, U+0178
        'space',             # C+A0, U+0020
        'exclamdown',        # C+A1, U+00A1
        'cent',              # C+A2, U+00A2
        'sterling',          # C+A3, U+00A3
        'fraction',          # C+A4, U+2044
        'yen',               # C+A5, U+00A5
        'florin',            # C+A6, U+0192
        'section',           # C+A7, U+00A7
        'currency',          # C+A8, U+00A4
        'quotesingle',       # C+A9, U+0027
        'quotedblleft',      # C+AA, U+201C
        'guillemotleft',     # C+AB, U+00AB
        'guilsinglleft',     # C+AC, U+2039
        'guilsinglright',    # C+AD, U+203A
        'fi',                # C+AE, U+FB01
        'fl',                # C+AF, U+FB02
        'degree',            # C+B0, U+00B0
        'endash',            # C+B1, U+2013
        'dagger',            # C+B2, U+2020
        'daggerdbl',         # C+B3, U+2021
        'periodcentered',    # C+B4, U+00B7
        'mu',                # C+B5, U+00B5
        'paragraph',         # C+B6, U+00B6
        'bullet',            # C+B7, U+2022
        'quotesinglbase',    # C+B8, U+201A
        'quotedblbase',      # C+B9, U+201E
        'quotedblright',     # C+BA, U+201D
        'guillemotright',    # C+BB, U+00BB
        'ellipsis',          # C+BC, U+2026
        'perthousand',       # C+BD, U+2030
        'threequarters',     # C+BE, U+00BE
        'questiondown',      # C+BF, U+00BF
        'Agrave',            # C+C0, U+00C0
        'grave',             # C+C1, U+0060
        'acute',             # C+C2, U+00B4
        'circumflex',        # C+C3, U+02C6
        'tilde',             # C+C4, U+02DC
        'macron',            # C+C5, U+00AF
        'breve',             # C+C6, U+02D8
        'dotaccent',         # C+C7, U+02D9
        'dieresis',          # C+C8, U+00A8
        'Eacute',            # C+C9, U+00C9
        'ring',              # C+CA, U+02DA
        'cedilla',           # C+CB, U+00B8
        'Igrave',            # C+CC, U+00CC
        'hungarumlaut',      # C+CD, U+02DD
        'ogonek',            # C+CE, U+02DB
        'caron',             # C+CF, U+02C7
        'emdash',            # C+D0, U+2014
        'Ntilde',            # C+D1, U+00D1
        'Ograve',            # C+D2, U+00D2
        'Oacute',            # C+D3, U+00D3
        'Ocircumflex',       # C+D4, U+00D4
        'Otilde',            # C+D5, U+00D5
        'Odieresis',         # C+D6, U+00D6
        'multiply',          # C+D7, U+00D7
        'Oslash',            # C+D8, U+00D8
        'Ugrave',            # C+D9, U+00D9
        'Uacute',            # C+DA, U+00DA
        'Ucircumflex',       # C+DB, U+00DB
        'Udieresis',         # C+DC, U+00DC
        'Yacute',            # C+DD, U+00DD
        'Thorn',             # C+DE, U+00DE
        'germandbls',        # C+DF, U+00DF
        'agrave',            # C+E0, U+00E0
        'AE',                # C+E1, U+00C6
        'acircumflex',       # C+E2, U+00E2
        'ordfeminine',       # C+E3, U+00AA
        'adieresis',         # C+E4, U+00E4
        'aring',             # C+E5, U+00E5
        'ae',                # C+E6, U+00E6
        'ccedilla',          # C+E7, U+00E7
        'Lslash',            # C+E8, U+0141
        'Oslash',            # C+E9, U+00D8
        'OE',                # C+EA, U+0152
        'ordmasculine',      # C+EB, U+00BA
        'igrave',            # C+EC, U+00EC
        'iacute',            # C+ED, U+00ED
        'icircumflex',       # C+EE, U+00EE
        'idieresis',         # C+EF, U+00EF
        'eth',               # C+F0, U+00F0
        'ae',                # C+F1, U+00E6
        'ograve',            # C+F2, U+00F2
        'oacute',            # C+F3, U+00F3
        'ocircumflex',       # C+F4, U+00F4
        'dotlessi',          # C+F5, U+0131
        'odieresis',         # C+F6, U+00F6
        'divide',            # C+F7, U+00F7
        'lslash',            # C+F8, U+0142
        'oslash',            # C+F9, U+00F8
        'oe',                # C+FA, U+0153
        'germandbls',        # C+FB, U+00DF
        'udieresis',         # C+FC, U+00FC
        'yacute',            # C+FD, U+00FD
        'thorn',             # C+FE, U+00FE
        'ydieresis',         # C+FF, U+00FF
    ],
    'wx' => {
        'a'                  => 444,
        'A'                  => 722,
        'Aacute'             => 722,
        'aacute'             => 444,
        'abreve'             => 444,
        'Abreve'             => 722,
        'acircumflex'        => 444,
        'Acircumflex'        => 722,
        'acute'              => 333,
        'adieresis'          => 444,
        'Adieresis'          => 722,
        'AE'                 => 889,
        'ae'                 => 667,
        'agrave'             => 444,
        'Agrave'             => 722,
        'amacron'            => 444,
        'Amacron'            => 722,
        'ampersand'          => 778,
        'Aogonek'            => 722,
        'aogonek'            => 444,
        'aring'              => 444,
        'Aring'              => 722,
        'asciicircum'        => 469,
        'asciitilde'         => 541,
        'asterisk'           => 500,
        'at'                 => 921,
        'atilde'             => 444,
        'Atilde'             => 722,
        'B'                  => 667,
        'b'                  => 500,
        'backslash'          => 278,
        'bar'                => 200,
        'braceleft'          => 480,
        'braceright'         => 480,
        'bracketleft'        => 333,
        'bracketright'       => 333,
        'breve'              => 333,
        'brokenbar'          => 200,
        'bullet'             => 350,
        'C'                  => 667,
        'c'                  => 444,
        'cacute'             => 444,
        'Cacute'             => 667,
        'caron'              => 333,
        'Ccaron'             => 667,
        'ccaron'             => 444,
        'ccedilla'           => 444,
        'Ccedilla'           => 667,
        'cedilla'            => 333,
        'cent'               => 500,
        'circumflex'         => 333,
        'colon'              => 278,
        'comma'              => 250,
        'commaaccent'        => 250,
        'copyright'          => 760,
        'currency'           => 500,
        'd'                  => 500,
        'D'                  => 722,
        'dagger'             => 500,
        'daggerdbl'          => 500,
        'dcaron'             => 588,
        'Dcaron'             => 722,
        'dcroat'             => 500,
        'Dcroat'             => 722,
        'degree'             => 400,
        'Delta'              => 612,
        'dieresis'           => 333,
        'divide'             => 564,
        'dollar'             => 500,
        'dotaccent'          => 333,
        'dotlessi'           => 278,
        'e'                  => 444,
        'E'                  => 611,
        'eacute'             => 444,
        'Eacute'             => 611,
        'ecaron'             => 444,
        'Ecaron'             => 611,
        'ecircumflex'        => 444,
        'Ecircumflex'        => 611,
        'edieresis'          => 444,
        'Edieresis'          => 611,
        'Edotaccent'         => 611,
        'edotaccent'         => 444,
        'egrave'             => 444,
        'Egrave'             => 611,
        'eight'              => 500,
        'ellipsis'           => 1000,
        'Emacron'            => 611,
        'emacron'            => 444,
        'emdash'             => 1000,
        'endash'             => 500,
        'eogonek'            => 444,
        'Eogonek'            => 611,
        'equal'              => 564,
        'Eth'                => 722,
        'eth'                => 500,
        'Euro'               => 500,
        'exclam'             => 333,
        'exclamdown'         => 333,
        'F'                  => 556,
        'f'                  => 333,
        'fi'                 => 556,
        'five'               => 500,
        'fl'                 => 556,
        'florin'             => 500,
        'four'               => 500,
        'fraction'           => 167,
        'G'                  => 722,
        'g'                  => 500,
        'Gbreve'             => 722,
        'gbreve'             => 500,
        'gcommaaccent'       => 500,
        'Gcommaaccent'       => 722,
        'germandbls'         => 500,
        'grave'              => 333,
        'greater'            => 564,
        'greaterequal'       => 549,
        'guillemotleft'      => 500,
        'guillemotright'     => 500,
        'guilsinglleft'      => 333,
        'guilsinglright'     => 333,
        'H'                  => 722,
        'h'                  => 500,
        'hungarumlaut'       => 333,
        'hyphen'             => 333,
        'I'                  => 333,
        'i'                  => 278,
        'Iacute'             => 333,
        'iacute'             => 278,
        'Icircumflex'        => 333,
        'icircumflex'        => 278,
        'idieresis'          => 278,
        'Idieresis'          => 333,
        'Idotaccent'         => 333,
        'igrave'             => 278,
        'Igrave'             => 333,
        'Imacron'            => 333,
        'imacron'            => 278,
        'Iogonek'            => 333,
        'iogonek'            => 278,
        'j'                  => 278,
        'J'                  => 389,
        'k'                  => 500,
        'K'                  => 722,
        'Kcommaaccent'       => 722,
        'kcommaaccent'       => 500,
        'L'                  => 611,
        'l'                  => 278,
        'lacute'             => 278,
        'Lacute'             => 611,
        'lcaron'             => 344,
        'Lcaron'             => 611,
        'lcommaaccent'       => 278,
        'Lcommaaccent'       => 611,
        'less'               => 564,
        'lessequal'          => 549,
        'logicalnot'         => 564,
        'lozenge'            => 471,
        'Lslash'             => 611,
        'lslash'             => 278,
        'M'                  => 889,
        'm'                  => 778,
        'macron'             => 333,
        'minus'              => 564,
        'mu'                 => 500,
        'multiply'           => 564,
        'n'                  => 500,
        'N'                  => 722,
        'nacute'             => 500,
        'Nacute'             => 722,
        'ncaron'             => 500,
        'Ncaron'             => 722,
        'ncommaaccent'       => 500,
        'Ncommaaccent'       => 722,
        'nine'               => 500,
        'notequal'           => 549,
        'ntilde'             => 500,
        'Ntilde'             => 722,
        'numbersign'         => 500,
        'o'                  => 500,
        'O'                  => 722,
        'oacute'             => 500,
        'Oacute'             => 722,
        'Ocircumflex'        => 722,
        'ocircumflex'        => 500,
        'Odieresis'          => 722,
        'odieresis'          => 500,
        'oe'                 => 722,
        'OE'                 => 889,
        'ogonek'             => 333,
        'ograve'             => 500,
        'Ograve'             => 722,
        'ohungarumlaut'      => 500,
        'Ohungarumlaut'      => 722,
        'Omacron'            => 722,
        'omacron'            => 500,
        'one'                => 500,
        'onehalf'            => 750,
        'onequarter'         => 750,
        'onesuperior'        => 300,
        'ordfeminine'        => 276,
        'ordmasculine'       => 310,
        'Oslash'             => 722,
        'oslash'             => 500,
        'Otilde'             => 722,
        'otilde'             => 500,
        'P'                  => 556,
        'p'                  => 500,
        'paragraph'          => 453,
        'parenleft'          => 333,
        'parenright'         => 333,
        'partialdiff'        => 476,
        'percent'            => 833,
        'period'             => 250,
        'periodcentered'     => 250,
        'perthousand'        => 1000,
        'plus'               => 564,
        'plusminus'          => 564,
        'Q'                  => 722,
        'q'                  => 500,
        'question'           => 444,
        'questiondown'       => 444,
        'quotedbl'           => 408,
        'quotedblbase'       => 444,
        'quotedblleft'       => 444,
        'quotedblright'      => 444,
        'quoteleft'          => 333,
        'quoteright'         => 333,
        'quotesinglbase'     => 333,
        'quotesingle'        => 180,
        'R'                  => 667,
        'r'                  => 333,
        'racute'             => 333,
        'Racute'             => 667,
        'radical'            => 453,
        'rcaron'             => 333,
        'Rcaron'             => 667,
        'rcommaaccent'       => 333,
        'Rcommaaccent'       => 667,
        'registered'         => 760,
        'ring'               => 333,
        'S'                  => 556,
        's'                  => 389,
        'Sacute'             => 556,
        'sacute'             => 389,
        'Scaron'             => 556,
        'scaron'             => 389,
        'Scedilla'           => 556,
        'scedilla'           => 389,
        'Scommaaccent'       => 556,
        'scommaaccent'       => 389,
        'section'            => 500,
        'semicolon'          => 278,
        'seven'              => 500,
        'six'                => 500,
        'slash'              => 278,
        'space'              => 250,
        'sterling'           => 500,
        'summation'          => 600,
        'T'                  => 611,
        't'                  => 278,
        'Tcaron'             => 611,
        'tcaron'             => 326,
        'tcommaaccent'       => 278,
        'Tcommaaccent'       => 611,
        'Thorn'              => 556,
        'thorn'              => 500,
        'three'              => 500,
        'threequarters'      => 750,
        'threesuperior'      => 300,
        'tilde'              => 333,
        'trademark'          => 980,
        'two'                => 500,
        'twosuperior'        => 300,
        'u'                  => 500,
        'U'                  => 722,
        'Uacute'             => 722,
        'uacute'             => 500,
        'ucircumflex'        => 500,
        'Ucircumflex'        => 722,
        'udieresis'          => 500,
        'Udieresis'          => 722,
        'Ugrave'             => 722,
        'ugrave'             => 500,
        'uhungarumlaut'      => 500,
        'Uhungarumlaut'      => 722,
        'umacron'            => 500,
        'Umacron'            => 722,
        'underscore'         => 500,
        'Uogonek'            => 722,
        'uogonek'            => 500,
        'Uring'              => 722,
        'uring'              => 500,
        'V'                  => 722,
        'v'                  => 500,
        'w'                  => 722,
        'W'                  => 944,
        'X'                  => 722,
        'x'                  => 500,
        'y'                  => 500,
        'Y'                  => 722,
        'yacute'             => 500,
        'Yacute'             => 722,
        'Ydieresis'          => 722,
        'ydieresis'          => 500,
        'yen'                => 500,
        'Z'                  => 611,
        'z'                  => 444,
        'zacute'             => 444,
        'Zacute'             => 611,
        'Zcaron'             => 611,
        'zcaron'             => 444,
        'Zdotaccent'         => 611,
        'zdotaccent'         => 444,
        'zero'               => 500,
    },
};


__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.9  2005/09/12 16:56:22  fredo
    applied mod_perl patch by Paul Schilling <pfschill@sbcglobal.net>

    Revision 1.8  2005/06/07 23:21:40  fredo
    fontkey correction

    Revision 1.7  2005/03/14 22:01:29  fredo
    upd 2005

    Revision 1.6  2004/12/28 17:23:47  fredo
    updated to new adobe afm

    Revision 1.5  2004/06/15 09:14:53  fredo
    removed cr+lf

    Revision 1.4  2004/06/07 19:44:44  fredo
    cleaned out cr+lf for lf

    Revision 1.3  2003/12/08 13:06:05  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:32:50  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:06  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 15:52:22  Administrator
    added CVS id/log


=cut
