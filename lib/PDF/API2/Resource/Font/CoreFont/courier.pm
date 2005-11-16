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
package PDF::API2::Resource::Font::CoreFont::courier;

$FONTDATA = {
    'fontname' => 'Courier',
    'type' => 'Type1',
    'apiname' => 'Cour',
    'ascender' => '629',
    'capheight' => '562',
    'descender' => '-157',
    'iscore' => '1',
    'isfixedpitch' => '1',
    'italicangle' => '0',
    'missingwidth' => '600',
    'underlineposition' => '-100',
    'underlinethickness' => '50',
    'xheight' => '426',
    'firstchar' => '32',
    'lastchar' => '255',
    'fontbbox' => [-23, -250, 715, 805],
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
        'A' => '600',   # U=0041
        'a' => '600',   # U=0061
        'Aacute' => '600',   # U=00C1
        'aacute' => '600',   # U=00E1
        'Abreve' => '600',   # U=0102
        'abreve' => '600',   # U=0103
        'Acircumflex' => '600',   # U=00C2
        'acircumflex' => '600',   # U=00E2
        'acute' => '600',   # U=00B4
        'Adieresis' => '600',   # U=00C4
        'adieresis' => '600',   # U=00E4
        'AE' => '600',   # U=00C6
        'ae' => '600',   # U=00E6
        'Agrave' => '600',   # U=00C0
        'agrave' => '600',   # U=00E0
        'Amacron' => '600',   # U=0100
        'amacron' => '600',   # U=0101
        'ampersand' => '600',   # U=0026
        'Aogonek' => '600',   # U=0104
        'aogonek' => '600',   # U=0105
        'Aring' => '600',   # U=00C5
        'aring' => '600',   # U=00E5
        'asciicircum' => '600',   # U=005E
        'asciitilde' => '600',   # U=007E
        'asterisk' => '600',   # U=002A
        'at' => '600',   # U=0040
        'Atilde' => '600',   # U=00C3
        'atilde' => '600',   # U=00E3
        'B' => '600',   # U=0042
        'b' => '600',   # U=0062
        'backslash' => '600',   # U=005C
        'bar' => '600',   # U=007C
        'braceleft' => '600',   # U=007B
        'braceright' => '600',   # U=007D
        'bracketleft' => '600',   # U=005B
        'bracketright' => '600',   # U=005D
        'breve' => '600',   # U=02D8
        'brokenbar' => '600',   # U=00A6
        'bullet' => '600',   # U=2022
        'C' => '600',   # U=0043
        'c' => '600',   # U=0063
        'Cacute' => '600',   # U=0106
        'cacute' => '600',   # U=0107
        'caron' => '600',   # U=02C7
        'Ccaron' => '600',   # U=010C
        'ccaron' => '600',   # U=010D
        'Ccedilla' => '600',   # U=00C7
        'ccedilla' => '600',   # U=00E7
        'cedilla' => '600',   # U=00B8
        'cent' => '600',   # U=00A2
        'circumflex' => '600',   # U=02C6
        'colon' => '600',   # U=003A
        'comma' => '600',   # U=002C
        'commaaccent' => '600',   # U=F6C3
        'copyright' => '600',   # U=00A9
        'currency' => '600',   # U=00A4
        'D' => '600',   # U=0044
        'd' => '600',   # U=0064
        'dagger' => '600',   # U=2020
        'daggerdbl' => '600',   # U=2021
        'Dcaron' => '600',   # U=010E
        'dcaron' => '600',   # U=010F
        'Dcroat' => '600',   # U=0110
        'dcroat' => '600',   # U=0111
        'degree' => '600',   # U=00B0
        'Delta' => '600',   # U=0394
        'dieresis' => '600',   # U=00A8
        'divide' => '600',   # U=00F7
        'dollar' => '600',   # U=0024
        'dotaccent' => '600',   # U=02D9
        'dotlessi' => '600',   # U=0131
        'E' => '600',   # U=0045
        'e' => '600',   # U=0065
        'Eacute' => '600',   # U=00C9
        'eacute' => '600',   # U=00E9
        'Ecaron' => '600',   # U=011A
        'ecaron' => '600',   # U=011B
        'Ecircumflex' => '600',   # U=00CA
        'ecircumflex' => '600',   # U=00EA
        'Edieresis' => '600',   # U=00CB
        'edieresis' => '600',   # U=00EB
        'Edotaccent' => '600',   # U=0116
        'edotaccent' => '600',   # U=0117
        'Egrave' => '600',   # U=00C8
        'egrave' => '600',   # U=00E8
        'eight' => '600',   # U=0038
        'ellipsis' => '600',   # U=2026
        'Emacron' => '600',   # U=0112
        'emacron' => '600',   # U=0113
        'emdash' => '600',   # U=2014
        'endash' => '600',   # U=2013
        'Eogonek' => '600',   # U=0118
        'eogonek' => '600',   # U=0119
        'equal' => '600',   # U=003D
        'Eth' => '600',   # U=00D0
        'eth' => '600',   # U=00F0
        'Euro' => '600',   # U=20AC
        'exclam' => '600',   # U=0021
        'exclamdown' => '600',   # U=00A1
        'F' => '600',   # U=0046
        'f' => '600',   # U=0066
        'fi' => '600',   # U=FB01
        'five' => '600',   # U=0035
        'fl' => '600',   # U=FB02
        'florin' => '600',   # U=0192
        'four' => '600',   # U=0034
        'fraction' => '600',   # U=2044
        'G' => '600',   # U=0047
        'g' => '600',   # U=0067
        'Gbreve' => '600',   # U=011E
        'gbreve' => '600',   # U=011F
        'Gcommaaccent' => '600',   # U=0122
        'gcommaaccent' => '600',   # U=0123
        'germandbls' => '600',   # U=00DF
        'grave' => '600',   # U=0060
        'greater' => '600',   # U=003E
        'greaterequal' => '600',   # U=2265
        'guillemotleft' => '600',   # U=00AB
        'guillemotright' => '600',   # U=00BB
        'guilsinglleft' => '600',   # U=2039
        'guilsinglright' => '600',   # U=203A
        'H' => '600',   # U=0048
        'h' => '600',   # U=0068
        'hungarumlaut' => '600',   # U=02DD
        'hyphen' => '600',   # U=002D
        'I' => '600',   # U=0049
        'i' => '600',   # U=0069
        'Iacute' => '600',   # U=00CD
        'iacute' => '600',   # U=00ED
        'Icircumflex' => '600',   # U=00CE
        'icircumflex' => '600',   # U=00EE
        'Idieresis' => '600',   # U=00CF
        'idieresis' => '600',   # U=00EF
        'Idotaccent' => '600',   # U=0130
        'Igrave' => '600',   # U=00CC
        'igrave' => '600',   # U=00EC
        'Imacron' => '600',   # U=012A
        'imacron' => '600',   # U=012B
        'Iogonek' => '600',   # U=012E
        'iogonek' => '600',   # U=012F
        'J' => '600',   # U=004A
        'j' => '600',   # U=006A
        'K' => '600',   # U=004B
        'k' => '600',   # U=006B
        'Kcommaaccent' => '600',   # U=0136
        'kcommaaccent' => '600',   # U=0137
        'L' => '600',   # U=004C
        'l' => '600',   # U=006C
        'Lacute' => '600',   # U=0139
        'lacute' => '600',   # U=013A
        'Lcaron' => '600',   # U=013D
        'lcaron' => '600',   # U=013E
        'Lcommaaccent' => '600',   # U=013B
        'lcommaaccent' => '600',   # U=013C
        'less' => '600',   # U=003C
        'lessequal' => '600',   # U=2264
        'logicalnot' => '600',   # U=00AC
        'lozenge' => '600',   # U=25CA
        'Lslash' => '600',   # U=0141
        'lslash' => '600',   # U=0142
        'M' => '600',   # U=004D
        'm' => '600',   # U=006D
        'macron' => '600',   # U=00AF
        'minus' => '600',   # U=2212
        'mu' => '600',   # U=00B5
        'multiply' => '600',   # U=00D7
        'N' => '600',   # U=004E
        'n' => '600',   # U=006E
        'Nacute' => '600',   # U=0143
        'nacute' => '600',   # U=0144
        'Ncaron' => '600',   # U=0147
        'ncaron' => '600',   # U=0148
        'Ncommaaccent' => '600',   # U=0145
        'ncommaaccent' => '600',   # U=0146
        'nine' => '600',   # U=0039
        'notequal' => '600',   # U=2260
        'Ntilde' => '600',   # U=00D1
        'ntilde' => '600',   # U=00F1
        'numbersign' => '600',   # U=0023
        'O' => '600',   # U=004F
        'o' => '600',   # U=006F
        'Oacute' => '600',   # U=00D3
        'oacute' => '600',   # U=00F3
        'Ocircumflex' => '600',   # U=00D4
        'ocircumflex' => '600',   # U=00F4
        'Odieresis' => '600',   # U=00D6
        'odieresis' => '600',   # U=00F6
        'OE' => '600',   # U=0152
        'oe' => '600',   # U=0153
        'ogonek' => '600',   # U=02DB
        'Ograve' => '600',   # U=00D2
        'ograve' => '600',   # U=00F2
        'Ohungarumlaut' => '600',   # U=0150
        'ohungarumlaut' => '600',   # U=0151
        'Omacron' => '600',   # U=014C
        'omacron' => '600',   # U=014D
        'one' => '600',   # U=0031
        'onehalf' => '600',   # U=00BD
        'onequarter' => '600',   # U=00BC
        'onesuperior' => '600',   # U=00B9
        'ordfeminine' => '600',   # U=00AA
        'ordmasculine' => '600',   # U=00BA
        'Oslash' => '600',   # U=00D8
        'oslash' => '600',   # U=00F8
        'Otilde' => '600',   # U=00D5
        'otilde' => '600',   # U=00F5
        'P' => '600',   # U=0050
        'p' => '600',   # U=0070
        'paragraph' => '600',   # U=00B6
        'parenleft' => '600',   # U=0028
        'parenright' => '600',   # U=0029
        'partialdiff' => '600',   # U=2202
        'percent' => '600',   # U=0025
        'period' => '600',   # U=002E
        'periodcentered' => '600',   # U=00B7
        'perthousand' => '600',   # U=2030
        'plus' => '600',   # U=002B
        'plusminus' => '600',   # U=00B1
        'Q' => '600',   # U=0051
        'q' => '600',   # U=0071
        'question' => '600',   # U=003F
        'questiondown' => '600',   # U=00BF
        'quotedbl' => '600',   # U=0022
        'quotedblbase' => '600',   # U=201E
        'quotedblleft' => '600',   # U=201C
        'quotedblright' => '600',   # U=201D
        'quoteleft' => '600',   # U=2018
        'quoteright' => '600',   # U=2019
        'quotesinglbase' => '600',   # U=201A
        'quotesingle' => '600',   # U=0027
        'R' => '600',   # U=0052
        'r' => '600',   # U=0072
        'Racute' => '600',   # U=0154
        'racute' => '600',   # U=0155
        'radical' => '600',   # U=221A
        'Rcaron' => '600',   # U=0158
        'rcaron' => '600',   # U=0159
        'Rcommaaccent' => '600',   # U=0156
        'rcommaaccent' => '600',   # U=0157
        'registered' => '600',   # U=00AE
        'ring' => '600',   # U=02DA
        'S' => '600',   # U=0053
        's' => '600',   # U=0073
        'Sacute' => '600',   # U=015A
        'sacute' => '600',   # U=015B
        'Scaron' => '600',   # U=0160
        'scaron' => '600',   # U=0161
        'Scedilla' => '600',   # U=015E
        'scedilla' => '600',   # U=015F
        'Scommaaccent' => '600',   # U=0218
        'scommaaccent' => '600',   # U=0219
        'section' => '600',   # U=00A7
        'semicolon' => '600',   # U=003B
        'seven' => '600',   # U=0037
        'six' => '600',   # U=0036
        'slash' => '600',   # U=002F
        'space' => '600',   # U=0020
        'sterling' => '600',   # U=00A3
        'summation' => '600',   # U=2211
        'T' => '600',   # U=0054
        't' => '600',   # U=0074
        'Tcaron' => '600',   # U=0164
        'tcaron' => '600',   # U=0165
        'Tcommaaccent' => '600',   # U=021A
        'tcommaaccent' => '600',   # U=021B
        'Thorn' => '600',   # U=00DE
        'thorn' => '600',   # U=00FE
        'three' => '600',   # U=0033
        'threequarters' => '600',   # U=00BE
        'threesuperior' => '600',   # U=00B3
        'tilde' => '600',   # U=02DC
        'trademark' => '600',   # U=2122
        'two' => '600',   # U=0032
        'twosuperior' => '600',   # U=00B2
        'U' => '600',   # U=0055
        'u' => '600',   # U=0075
        'Uacute' => '600',   # U=00DA
        'uacute' => '600',   # U=00FA
        'Ucircumflex' => '600',   # U=00DB
        'ucircumflex' => '600',   # U=00FB
        'Udieresis' => '600',   # U=00DC
        'udieresis' => '600',   # U=00FC
        'Ugrave' => '600',   # U=00D9
        'ugrave' => '600',   # U=00F9
        'Uhungarumlaut' => '600',   # U=0170
        'uhungarumlaut' => '600',   # U=0171
        'Umacron' => '600',   # U=016A
        'umacron' => '600',   # U=016B
        'underscore' => '600',   # U=005F
        'Uogonek' => '600',   # U=0172
        'uogonek' => '600',   # U=0173
        'Uring' => '600',   # U=016E
        'uring' => '600',   # U=016F
        'V' => '600',   # U=0056
        'v' => '600',   # U=0076
        'W' => '600',   # U=0057
        'w' => '600',   # U=0077
        'X' => '600',   # U=0058
        'x' => '600',   # U=0078
        'Y' => '600',   # U=0059
        'y' => '600',   # U=0079
        'Yacute' => '600',   # U=00DD
        'yacute' => '600',   # U=00FD
        'Ydieresis' => '600',   # U=0178
        'ydieresis' => '600',   # U=00FF
        'yen' => '600',   # U=00A5
        'Z' => '600',   # U=005A
        'z' => '600',   # U=007A
        'Zacute' => '600',   # U=0179
        'zacute' => '600',   # U=017A
        'Zcaron' => '600',   # U=017D
        'zcaron' => '600',   # U=017E
        'Zdotaccent' => '600',   # U=017B
        'zdotaccent' => '600',   # U=017C
        'zero' => '600',   # U=0030
    },
    'comps' => {
        'Abreve' => [ 'A', '0', '0', 'breve', '0', '130' ],   # U=0102
        'abreve' => [ 'A', '0', '0', 'breve', '0', '0' ],   # U=0103
        'Acaron' => [ 'A', '0', '0', 'caron', '0', '130' ],   # U=01CD
        'acaron' => [ 'A', '0', '0', 'caron', '0', '0' ],   # U=01CE
        'Amacron' => [ 'A', '0', '0', 'macron', '0', '130' ],   # U=0100
        'amacron' => [ 'A', '0', '0', 'macron', '0', '0' ],   # U=0101
        'Aogonek' => [ 'A', '0', '0', 'ogonek', '0', '0' ],   # U=0104
        'aogonek' => [ 'A', '0', '0', 'ogonek', '0', '0' ],   # U=0105
        'Bdotaccent' => [ 'B', '0', '0', 'dotaccent', '0', '130' ],   # U=1E02
        'bdotaccent' => [ 'B', '0', '0', 'dotaccent', '0', '0' ],   # U=1E03
        'Cacute' => [ 'C', '0', '0', 'acute', '0', '130' ],   # U=0106
        'cacute' => [ 'C', '0', '0', 'acute', '0', '0' ],   # U=0107
        'Ccaron' => [ 'C', '0', '0', 'caron', '0', '130' ],   # U=010C
        'ccaron' => [ 'C', '0', '0', 'caron', '0', '0' ],   # U=010D
        'Ccircumflex' => [ 'C', '0', '0', 'circumflex', '0', '130' ],   # U=0108
        'ccircumflex' => [ 'C', '0', '0', 'circumflex', '0', '0' ],   # U=0109
        'Cdotaccent' => [ 'C', '0', '0', 'dotaccent', '0', '130' ],   # U=010A
        'cdotaccent' => [ 'C', '0', '0', 'dotaccent', '0', '0' ],   # U=010B
        'Dcaron' => [ 'D', '0', '0', 'caron', '0', '130' ],   # U=010E
        'dcaron' => [ 'D', '0', '0', 'caron', '0', '0' ],   # U=010F
        'Dcedilla' => [ 'D', '0', '0', 'cedilla', '0', '130' ],   # U=1E10
        'dcedilla' => [ 'D', '0', '0', 'cedilla', '0', '0' ],   # U=1E11
        'Ddotaccent' => [ 'D', '0', '0', 'dotaccent', '0', '130' ],   # U=1E0A
        'ddotaccent' => [ 'D', '0', '0', 'dotaccent', '0', '0' ],   # U=1E0B
        'Ebreve' => [ 'E', '0', '0', 'breve', '0', '130' ],   # U=0114
        'ebreve' => [ 'E', '0', '0', 'breve', '0', '0' ],   # U=0115
        'Ecaron' => [ 'E', '0', '0', 'caron', '0', '130' ],   # U=011A
        'ecaron' => [ 'E', '0', '0', 'caron', '0', '0' ],   # U=011B
        'Edotaccent' => [ 'E', '0', '0', 'dotaccent', '0', '130' ],   # U=0116
        'edotaccent' => [ 'E', '0', '0', 'dotaccent', '0', '0' ],   # U=0117
        'Emacron' => [ 'E', '0', '0', 'macron', '0', '130' ],   # U=0112
        'emacron' => [ 'E', '0', '0', 'macron', '0', '0' ],   # U=0113
        'Eogonek' => [ 'E', '0', '0', 'ogonek', '0', '0' ],   # U=0118
        'eogonek' => [ 'E', '0', '0', 'ogonek', '0', '0' ],   # U=0119
        'Etilde' => [ 'E', '0', '0', 'tilde', '0', '130' ],   # U=1EBC
        'etilde' => [ 'E', '0', '0', 'tilde', '0', '0' ],   # U=1EBD
        'Fdotaccent' => [ 'F', '0', '0', 'dotaccent', '0', '130' ],   # U=1E1E
        'fdotaccent' => [ 'F', '0', '0', 'dotaccent', '0', '0' ],   # U=1E1F
        'Gacute' => [ 'G', '0', '0', 'acute', '0', '130' ],   # U=01F4
        'gacute' => [ 'G', '0', '0', 'acute', '0', '0' ],   # U=01F5
        'Gbreve' => [ 'G', '0', '0', 'breve', '0', '130' ],   # U=011E
        'gbreve' => [ 'G', '0', '0', 'breve', '0', '0' ],   # U=011F
        'Gcaron' => [ 'G', '0', '0', 'caron', '0', '136' ],   # U=01E6
        'gcaron' => [ 'g', '0', '0', 'caron', '-30', '0' ],   # U=01E7
        'Gcedilla' => [ 'G', '0', '0', 'cedilla', '0', '130' ],   # U=0122
        'gcedilla' => [ 'G', '0', '0', 'cedilla', '0', '0' ],   # U=0123
        'Gcircumflex' => [ 'G', '0', '0', 'circumflex', '0', '130' ],   # U=011C
        'gcircumflex' => [ 'G', '0', '0', 'circumflex', '0', '0' ],   # U=011D
        'Gdotaccent' => [ 'G', '0', '0', 'dotaccent', '0', '130' ],   # U=0120
        'gdotaccent' => [ 'G', '0', '0', 'dotaccent', '0', '0' ],   # U=0121
        'Gmacron' => [ 'G', '0', '0', 'macron', '0', '130' ],   # U=1E20
        'gmacron' => [ 'G', '0', '0', 'macron', '0', '0' ],   # U=1E21
        'Hcedilla' => [ 'H', '0', '0', 'cedilla', '0', '130' ],   # U=1E28
        'hcedilla' => [ 'H', '0', '0', 'cedilla', '0', '0' ],   # U=1E29
        'Hcircumflex' => [ 'H', '0', '0', 'circumflex', '0', '130' ],   # U=0124
        'hcircumflex' => [ 'H', '0', '0', 'circumflex', '0', '0' ],   # U=0125
        'Hdieresis' => [ 'H', '0', '0', 'dieresis', '0', '130' ],   # U=1E26
        'hdieresis' => [ 'H', '0', '0', 'dieresis', '0', '0' ],   # U=1E27
        'Hdotaccent' => [ 'H', '0', '0', 'dotaccent', '0', '130' ],   # U=1E22
        'hdotaccent' => [ 'H', '0', '0', 'dotaccent', '0', '0' ],   # U=1E23
        'Ibreve' => [ 'I', '0', '0', 'breve', '0', '130' ],   # U=012C
        'ibreve' => [ 'I', '0', '0', 'breve', '0', '0' ],   # U=012D
        'Icaron' => [ 'I', '0', '0', 'caron', '0', '130' ],   # U=01CF
        'icaron' => [ 'I', '0', '0', 'caron', '0', '0' ],   # U=01D0
        'Idotaccent' => [ 'I', '0', '0', 'dotaccent', '0', '130' ],   # U=0130
        'Imacron' => [ 'I', '0', '0', 'macron', '0', '130' ],   # U=012A
        'imacron' => [ 'I', '0', '0', 'macron', '0', '0' ],   # U=012B
        'Iogonek' => [ 'I', '0', '0', 'ogonek', '0', '0' ],   # U=012E
        'iogonek' => [ 'I', '0', '0', 'ogonek', '0', '0' ],   # U=012F
        'Itilde' => [ 'I', '0', '0', 'tilde', '0', '130' ],   # U=0128
        'itilde' => [ 'I', '0', '0', 'tilde', '0', '0' ],   # U=0129
        'Jcircumflex' => [ 'J', '0', '0', 'circumflex', '0', '130' ],   # U=0134
        'jcircumflex' => [ 'J', '0', '0', 'circumflex', '0', '0' ],   # U=0135
        'Kacute' => [ 'K', '0', '0', 'acute', '0', '130' ],   # U=1E30
        'kacute' => [ 'K', '0', '0', 'acute', '0', '0' ],   # U=1E31
        'Kcaron' => [ 'K', '0', '0', 'caron', '0', '130' ],   # U=01E8
        'kcaron' => [ 'K', '0', '0', 'caron', '0', '0' ],   # U=01E9
        'Kcedilla' => [ 'K', '0', '0', 'cedilla', '0', '130' ],   # U=0136
        'kcedilla' => [ 'K', '0', '0', 'cedilla', '0', '0' ],   # U=0137
        'Lacute' => [ 'L', '0', '0', 'acute', '0', '130' ],   # U=0139
        'lacute' => [ 'L', '0', '0', 'acute', '0', '0' ],   # U=013A
        'Lcaron' => [ 'L', '0', '0', 'caron', '0', '130' ],   # U=013D
        'lcaron' => [ 'L', '0', '0', 'caron', '0', '0' ],   # U=013E
        'Lcedilla' => [ 'L', '0', '0', 'cedilla', '0', '130' ],   # U=013B
        'lcedilla' => [ 'L', '0', '0', 'cedilla', '0', '0' ],   # U=013C
        'Ldotaccent' => [ 'L', '0', '0', 'dotaccent', '0', '130' ],   # U=013F
        'ldotaccent' => [ 'L', '0', '0', 'dotaccent', '0', '0' ],   # U=0140
        'Macute' => [ 'M', '0', '0', 'acute', '0', '130' ],   # U=1E3E
        'macute' => [ 'M', '0', '0', 'acute', '0', '0' ],   # U=1E3F
        'Mdotaccent' => [ 'M', '0', '0', 'dotaccent', '0', '130' ],   # U=1E40
        'mdotaccent' => [ 'M', '0', '0', 'dotaccent', '0', '0' ],   # U=1E41
        'Nacute' => [ 'N', '0', '0', 'acute', '0', '130' ],   # U=0143
        'nacute' => [ 'N', '0', '0', 'acute', '0', '0' ],   # U=0144
        'Ncaron' => [ 'N', '0', '0', 'caron', '0', '130' ],   # U=0147
        'ncaron' => [ 'N', '0', '0', 'caron', '0', '0' ],   # U=0148
        'Ncedilla' => [ 'N', '0', '0', 'cedilla', '0', '130' ],   # U=0145
        'ncedilla' => [ 'N', '0', '0', 'cedilla', '0', '0' ],   # U=0146
        'Ndotaccent' => [ 'N', '0', '0', 'dotaccent', '0', '130' ],   # U=1E44
        'ndotaccent' => [ 'N', '0', '0', 'dotaccent', '0', '0' ],   # U=1E45
        'Obreve' => [ 'O', '0', '0', 'breve', '0', '130' ],   # U=014E
        'obreve' => [ 'O', '0', '0', 'breve', '0', '0' ],   # U=014F
        'Ocaron' => [ 'O', '0', '0', 'caron', '0', '130' ],   # U=01D1
        'ocaron' => [ 'O', '0', '0', 'caron', '0', '0' ],   # U=01D2
        'Ohungarumlaut' => [ 'O', '0', '0', 'hungarumlaut', '0', '130' ],   # U=0150
        'ohungarumlaut' => [ 'O', '0', '0', 'hungarumlaut', '0', '0' ],   # U=0151
        'Omacron' => [ 'O', '0', '0', 'macron', '0', '130' ],   # U=014C
        'omacron' => [ 'O', '0', '0', 'macron', '0', '0' ],   # U=014D
        'Oogonek' => [ 'O', '0', '0', 'ogonek', '0', '0' ],   # U=01EA
        'oogonek' => [ 'O', '0', '0', 'ogonek', '0', '0' ],   # U=01EB
        'Pacute' => [ 'P', '0', '0', 'acute', '0', '130' ],   # U=1E54
        'pacute' => [ 'P', '0', '0', 'acute', '0', '0' ],   # U=1E55
        'Pdotaccent' => [ 'P', '0', '0', 'dotaccent', '0', '130' ],   # U=1E56
        'pdotaccent' => [ 'P', '0', '0', 'dotaccent', '0', '0' ],   # U=1E57
        'Racute' => [ 'R', '0', '0', 'acute', '0', '130' ],   # U=0154
        'racute' => [ 'R', '0', '0', 'acute', '0', '0' ],   # U=0155
        'Rcaron' => [ 'R', '0', '0', 'caron', '0', '130' ],   # U=0158
        'rcaron' => [ 'R', '0', '0', 'caron', '0', '0' ],   # U=0159
        'Rcedilla' => [ 'R', '0', '0', 'cedilla', '0', '130' ],   # U=0156
        'rcedilla' => [ 'R', '0', '0', 'cedilla', '0', '0' ],   # U=0157
        'Rdotaccent' => [ 'R', '0', '0', 'dotaccent', '0', '130' ],   # U=1E58
        'rdotaccent' => [ 'R', '0', '0', 'dotaccent', '0', '0' ],   # U=1E59
        'Sacute' => [ 'S', '0', '0', 'acute', '0', '130' ],   # U=015A
        'sacute' => [ 'S', '0', '0', 'acute', '0', '0' ],   # U=015B
        'Scaron' => [ 'S', '0', '0', 'caron', '30', '136' ],   # U=0160
        'scaron' => [ 's', '0', '0', 'caron', '0', '0' ],   # U=0161
        'Scedilla' => [ 'S', '0', '0', 'cedilla', '0', '130' ],   # U=015E
        'scedilla' => [ 'S', '0', '0', 'cedilla', '0', '0' ],   # U=015F
        'Scircumflex' => [ 'S', '0', '0', 'circumflex', '0', '130' ],   # U=015C
        'scircumflex' => [ 'S', '0', '0', 'circumflex', '0', '0' ],   # U=015D
        'Sdotaccent' => [ 'S', '0', '0', 'dotaccent', '0', '130' ],   # U=1E60
        'sdotaccent' => [ 'S', '0', '0', 'dotaccent', '0', '0' ],   # U=1E61
        'Tcaron' => [ 'T', '0', '0', 'caron', '0', '130' ],   # U=0164
        'tcaron' => [ 'T', '0', '0', 'caron', '0', '0' ],   # U=0165
        'Tcedilla' => [ 'T', '0', '0', 'cedilla', '0', '130' ],   # U=0162
        'tcedilla' => [ 'T', '0', '0', 'cedilla', '0', '0' ],   # U=0163
        'Tdotaccent' => [ 'T', '0', '0', 'dotaccent', '0', '130' ],   # U=1E6A
        'tdotaccent' => [ 'T', '0', '0', 'dotaccent', '0', '0' ],   # U=1E6B
        'Ubreve' => [ 'U', '0', '0', 'breve', '0', '130' ],   # U=016C
        'ubreve' => [ 'U', '0', '0', 'breve', '0', '0' ],   # U=016D
        'Ucaron' => [ 'U', '0', '0', 'caron', '0', '130' ],   # U=01D3
        'ucaron' => [ 'U', '0', '0', 'caron', '0', '0' ],   # U=01D4
        'Uhungarumlaut' => [ 'U', '0', '0', 'hungarumlaut', '0', '130' ],   # U=0170
        'uhungarumlaut' => [ 'U', '0', '0', 'hungarumlaut', '0', '0' ],   # U=0171
        'Umacron' => [ 'U', '0', '0', 'macron', '0', '130' ],   # U=016A
        'umacron' => [ 'U', '0', '0', 'macron', '0', '0' ],   # U=016B
        'Uogonek' => [ 'U', '0', '0', 'ogonek', '0', '0' ],   # U=0172
        'uogonek' => [ 'U', '0', '0', 'ogonek', '0', '0' ],   # U=0173
        'Uring' => [ 'U', '0', '0', 'ring', '0', '130' ],   # U=016E
        'uring' => [ 'U', '0', '0', 'ring', '0', '0' ],   # U=016F
        'Utilde' => [ 'U', '0', '0', 'tilde', '0', '130' ],   # U=0168
        'utilde' => [ 'U', '0', '0', 'tilde', '0', '0' ],   # U=0169
        'Vtilde' => [ 'V', '0', '0', 'tilde', '0', '130' ],   # U=1E7C
        'vtilde' => [ 'V', '0', '0', 'tilde', '0', '0' ],   # U=1E7D
        'Wacute' => [ 'W', '0', '0', 'acute', '0', '130' ],   # U=1E82
        'wacute' => [ 'W', '0', '0', 'acute', '0', '0' ],   # U=1E83
        'Wcircumflex' => [ 'W', '0', '0', 'circumflex', '0', '130' ],   # U=0174
        'wcircumflex' => [ 'W', '0', '0', 'circumflex', '0', '0' ],   # U=0175
        'Wdieresis' => [ 'W', '0', '0', 'dieresis', '0', '130' ],   # U=1E84
        'wdieresis' => [ 'W', '0', '0', 'dieresis', '0', '0' ],   # U=1E85
        'Wdotaccent' => [ 'W', '0', '0', 'dotaccent', '0', '130' ],   # U=1E86
        'wdotaccent' => [ 'W', '0', '0', 'dotaccent', '0', '0' ],   # U=1E87
        'Wgrave' => [ 'W', '0', '0', 'grave', '0', '130' ],   # U=1E80
        'wgrave' => [ 'W', '0', '0', 'grave', '0', '0' ],   # U=1E81
        'Xdieresis' => [ 'X', '0', '0', 'dieresis', '0', '130' ],   # U=1E8C
        'xdieresis' => [ 'X', '0', '0', 'dieresis', '0', '0' ],   # U=1E8D
        'Xdotaccent' => [ 'X', '0', '0', 'dotaccent', '0', '130' ],   # U=1E8A
        'xdotaccent' => [ 'X', '0', '0', 'dotaccent', '0', '0' ],   # U=1E8B
        'Ycircumflex' => [ 'Y', '0', '0', 'circumflex', '0', '130' ],   # U=0176
        'ycircumflex' => [ 'Y', '0', '0', 'circumflex', '0', '0' ],   # U=0177
        'Ydieresis' => [ 'Y', '0', '0', 'dieresis', '0', '136' ],   # U=0178
        'Ydotaccent' => [ 'Y', '0', '0', 'dotaccent', '0', '130' ],   # U=1E8E
        'ydotaccent' => [ 'Y', '0', '0', 'dotaccent', '0', '0' ],   # U=1E8F
        'Ygrave' => [ 'Y', '0', '0', 'grave', '0', '130' ],   # U=1EF2
        'ygrave' => [ 'Y', '0', '0', 'grave', '0', '0' ],   # U=1EF3
        'Ytilde' => [ 'Y', '0', '0', 'tilde', '0', '130' ],   # U=1EF8
        'ytilde' => [ 'Y', '0', '0', 'tilde', '0', '0' ],   # U=1EF9
        'Zacute' => [ 'Z', '0', '0', 'acute', '0', '130' ],   # U=0179
        'zacute' => [ 'Z', '0', '0', 'acute', '0', '0' ],   # U=017A
        'Zcaron' => [ 'Z', '0', '0', 'caron', '0', '136' ],   # U=017D
        'zcaron' => [ 'z', '0', '0', 'caron', '10', '0' ],   # U=017E
        'Zcircumflex' => [ 'Z', '0', '0', 'circumflex', '0', '130' ],   # U=1E90
        'zcircumflex' => [ 'Z', '0', '0', 'circumflex', '0', '0' ],   # U=1E91
        'Zdotaccent' => [ 'Z', '0', '0', 'dotaccent', '0', '130' ],   # U=017B
        'zdotaccent' => [ 'Z', '0', '0', 'dotaccent', '0', '0' ],   # U=017C
    },
};


__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.2  2005/11/16 01:27:50  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.11  2005/09/28 17:00:52  fredo
    added composites

    Revision 1.10  2005/09/26 19:28:16  fredo
    no message

    Revision 1.9  2005/09/12 16:56:21  fredo
    applied mod_perl patch by Paul Schilling <pfschill@sbcglobal.net>

    Revision 1.8  2005/06/07 23:21:39  fredo
    fontkey correction

    Revision 1.7  2005/03/14 22:01:28  fredo
    upd 2005

    Revision 1.6  2004/12/16 01:09:12  fredo
    updated to new adobe afm

    Revision 1.5  2004/06/15 09:14:53  fredo
    removed cr+lf

    Revision 1.4  2004/06/07 19:44:43  fredo
    cleaned out cr+lf for lf

    Revision 1.3  2003/12/08 13:06:01  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:32:49  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:05  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 15:52:21  Administrator
    added CVS id/log


=cut
