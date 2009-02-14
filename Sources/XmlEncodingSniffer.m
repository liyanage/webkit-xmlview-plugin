//
//  XmlEncodingSniffer.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

/*
	Based on http://home.ccil.org/~cowan/XML/xmlenc.c
	See also http://recycledknowledge.blogspot.com/2005/07/hello-i-am-xml-encoding-sniffer.html
*/

#import "XmlEncodingSniffer.h"



# include <stdio.h>
# include <ctype.h>

/* ASCII constants */
# define Alt 0x3C
# define Aques 0x3F
# define Ax 0x78
# define Am 0x6D
# define Al 0x6C
# define Asp 0x20
# define Atab 0x09
# define Acr 0x0D
# define Alf 0x0A
# define Ag 0x67
# define Aeq 0x3D
# define Aquot 0x22
# define Aapos 0x27
# define Agt 0x3E

/* EBCDIC constants */
# define Elt 0x4C
# define Eques 0x6F
# define Ex 0xA7
# define Em 0x94
# define El 0x93
# define Esp 0x40
# define Etab 0x05
# define Ecr 0x0D
# define Elf 0x25
# define Eg 0x87
# define Eeq 0x7E
# define Equot 0x7F
# define Eapos 0x7D
# define Egt 0x6E

#define UNKNOWN_ENCODING 0


/* EBCDIC CP037 to 8859-1 mapping table */
static char ebasci[] = {
0x00, 0x01, 0x02, 0x03, 0x9C, 0x09, 0x86, 0x7F,
0x97, 0x8D, 0x8E, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
0x10, 0x11, 0x12, 0x13, 0x9D, 0x85, 0x08, 0x87,
0x18, 0x19, 0x92, 0x8F, 0x1C, 0x1D, 0x1E, 0x1F,
0x80, 0x81, 0x82, 0x83, 0x84, 0x0A, 0x17, 0x1B,
0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x05, 0x06, 0x07,
0x90, 0x91, 0x16, 0x93, 0x94, 0x95, 0x96, 0x04,
0x98, 0x99, 0x9A, 0x9B, 0x14, 0x15, 0x9E, 0x1A,
0x20, 0xA0, 0xE2, 0xE4, 0xE0, 0xE1, 0xE3, 0xE5,
0xE7, 0xF1, 0xA2, 0x2E, 0x3C, 0x28, 0x2B, 0x7C,
0x26, 0xE9, 0xEA, 0xEB, 0xE8, 0xED, 0xEE, 0xEF,
0xEC, 0xDF, 0x21, 0x24, 0x2A, 0x29, 0x3B, 0xAC,
0x2D, 0x2F, 0xC2, 0xC4, 0xC0, 0xC1, 0xC3, 0xC5,
0xC7, 0xD1, 0xA6, 0x2C, 0x25, 0x5F, 0x3E, 0x3F,
0xF8, 0xC9, 0xCA, 0xCB, 0xC8, 0xCD, 0xCE, 0xCF,
0xCC, 0x60, 0x3A, 0x23, 0x40, 0x27, 0x3D, 0x22,
0xD8, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
0x68, 0x69, 0xAB, 0xBB, 0xF0, 0xFD, 0xFE, 0xB1,
0xB0, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70,
0x71, 0x72, 0xAA, 0xBA, 0xE6, 0xB8, 0xC6, 0xA4,
0xB5, 0x7E, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
0x79, 0x7A, 0xA1, 0xBF, 0xD0, 0xDD, 0xDE, 0xAE,
0x5E, 0xA3, 0xA5, 0xB7, 0xA9, 0xA7, 0xB6, 0xBC,
0xBD, 0xBE, 0x5B, 0x5D, 0xAF, 0xA8, 0xB4, 0xD7,
0x7B, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
0x48, 0x49, 0xAD, 0xF4, 0xF6, 0xF2, 0xF3, 0xF5,
0x7D, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50,
0x51, 0x52, 0xB9, 0xFB, 0xFC, 0xF9, 0xFA, 0xFF,
0x5C, 0xF7, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
0x59, 0x5A, 0xB2, 0xD4, 0xD6, 0xD2, 0xD3, 0xD5,
0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
0x38, 0x39, 0xB3, 0xDB, 0xDC, 0xD9, 0xDA, 0x9F};


static char *xmlenc_buffer(const void *bytes, NSUInteger len);

static const char *knownEncodingStrings[] = {
	"US-ASCII",
	"UTF-8",
	"ISO-8859-1",
	"UTF-16BE",
	"UTF-16-BE",
	"UTF-16LE",
	"UTF-16-LE",
	"EUC-JP",
	"MACINTOSH",
	"WINDOWS-1252",
	"US-ASCII",
	"ISO-2022-JP",
	"SHIFT_JIS",
	NULL
};

static NSStringEncoding knownEncodingIds[] = {
	NSASCIIStringEncoding,
  	NSUTF8StringEncoding,
	NSISOLatin1StringEncoding,
	NSUTF16BigEndianStringEncoding,
	NSUTF16BigEndianStringEncoding,
	NSUTF16LittleEndianStringEncoding,
	NSUTF16LittleEndianStringEncoding,
	NSJapaneseEUCStringEncoding,
	NSMacOSRomanStringEncoding,
	NSWindowsCP1252StringEncoding,
	NSASCIIStringEncoding,
	NSISO2022JPStringEncoding,
	NSShiftJISStringEncoding,
	0
};


@implementation XmlEncodingSniffer

+ (NSStringEncoding)encodingForXmlData:(NSData *)xmlData {

	if (!xmlData) return UNKNOWN_ENCODING;
	NSUInteger len = [xmlData length];
	if (len < 1) return UNKNOWN_ENCODING;

	const void *bytes = [xmlData bytes];
	char *result = xmlenc_buffer(bytes, len);

	int i = 0;
	while (knownEncodingStrings[i]) {
		if (!strcmp(result, knownEncodingStrings[i])) return knownEncodingIds[i];
		i++;
	}
	
	NSLog(@"unknown encoding: %s", result);
	
	return UNKNOWN_ENCODING;
}

@end


static int nextchar(const unsigned char *bytes, NSUInteger len, NSUInteger *pos) {
	while (1) {
		if (*pos >= len) return EOF;
		int value = bytes[*pos];
		(*pos)++;
		if (value) return value;
	}
}

#define GETC ch = nextchar(bytes, len, &pos)
static char *xmlenc_buffer(const void *bytes, NSUInteger len) {
	int ch;
	static char buffer[100];
	char *p = buffer;
	char *def = "UTF-8";
	int delim;
	
	NSUInteger pos = 0;

	if (!bytes) return ("NULL");
	GETC;
	if (ch == Elt) goto ebcdic;
	else if (ch == 0xFE) {
		def = "UTF-16-BE";
		GETC;
		GETC;
		}
	else if (ch == 0xFF) {
		def = "UTF-16-LE";
		GETC;
		GETC;
		}
	if (ch != Alt) return def;
	GETC;
	if (ch != Aques) return def;
	GETC;
	if (ch != Ax) return def;
	GETC;
	if (ch != Am) return def;
	GETC;
	if (ch != Al) return def;
	GETC;
	if (ch != Asp && ch != Atab && ch != Acr && ch != Alf)
		return def;
	for (;;) {
		GETC;
		if (ch == Ag) break;
		else if (ch == EOF || ch == Agt) return def;
		}
	for (;;) {
		GETC;
		if (ch == Aapos || ch == Aquot) break;
		else if (ch == EOF || ch == Agt) return def;
		}
	delim = ch;
	for (;;) {
		GETC;
		if (ch == delim) break;
		else if (ch == EOF) return def;
		else *p++ = toupper(ch);
		}
	*p = 0;
	return buffer;

ebcdic:
	def = "EBCDIC-CP-US";		/* better than nothing */
	GETC;
	if (ch != Eques) return def;
	GETC;
	if (ch != Ex) return def;
	GETC;
	if (ch != Em) return def;
	GETC;
	if (ch != El) return def;
	GETC;
	if (ch != Esp && ch != Etab && ch != Ecr && ch != Elf)
		return def;
	for (;;) {
		GETC;
		if (ch == Eg) break;
		else if (ch == EOF || ch == Egt) return def;
		}
	for (;;) {
		GETC;
		if (ch == Eapos || ch == Equot) break;
		else if (ch == EOF || ch == Egt) return def;
		}
	delim = ch;
	for (;;) {
		GETC;
		if (ch == delim) break;
		else if (ch == EOF) return def;
		else *p++ = toupper(ebasci[ch]);
		}
	*p = 0;
	return buffer;
}





/* Everything after this is part of the test scaffolding.
 * It works only on ASCII machines.
 * You can run the program as follows:
 * xmlenc prints the encoding of the XML document on stdin
 * xmlenc <file> prints the encoding of the XML document in <file>
 * xmlenc -e writes an EBCDIC XML document named "ebcdic.xml"
 * xmlenc -b writes a big-endian Unicode XML document named "unibe.xml"
 * xmlenc -l writes a little-endian Unicode XML document named "unile.xml"
 */


/*
char
ebcdic(char c) {
	int i;
	for (i = 0; i <= 255; i++)
		if (ebasci[i] == c) return i;
	return EOF;
	}

int
main(int argc, char *argv[]) {
	if (argc == 2 && argv[1][0] == '-' && argv[1][1] == 'e') {
		FILE *f;
		f = fopen("ebcdic.xml", "wb");
		fputc(Elt, f); fputc(Eques, f);
		fputc(Ex, f); fputc(Em, f); fputc(El, f);
		fputc(Esp, f);
		fputc(ebcdic('e'), f); fputc(ebcdic('n'), f);
		fputc(ebcdic('c'), f); fputc(ebcdic('o'), f);
		fputc(ebcdic('d'), f); fputc(ebcdic('i'), f);
		fputc(ebcdic('n'), f); fputc(Eg, f);
		fputc(ebcdic('='), f);
		fputc(Equot, f);
		fputc(ebcdic('e'), f); fputc(ebcdic('b'), f);
		fputc(ebcdic('c'), f); fputc(ebcdic('d'), f);
		fputc(ebcdic('i'), f); fputc(ebcdic('c'), f);
		fputc(ebcdic('-'), f); fputc(ebcdic('c'), f);
		fputc(ebcdic('p'), f); fputc(ebcdic('-'), f);
		fputc(ebcdic('f'), f); fputc(ebcdic('i'), f);
		fputc(Equot, f); fputc(Eques, f); fputc(Egt, f);
		fputc(Ecr, f); fputc(Elf, f);
		fclose(f);
		exit(0);
		}
	else if (argc == 2 && argv[1][0] == '-' && argv[1][1] == 'b') {
		FILE *f;
		f = fopen("unibe.xml", "wb");
		fputc(0xFE, f); fputc(0xFF, f);
		fputc(0, f); fputc('<', f);
		fputc(0, f); fputc('?', f);
		fputc(0, f); fputc('x', f);
		fputc(0, f); fputc('m', f);
		fputc(0, f); fputc('l', f);
		fputc(0, f); fputc(' ', f);
		fputc(0, f); fputc('e', f);
		fputc(0, f); fputc('n', f);
		fputc(0, f); fputc('c', f);
		fputc(0, f); fputc('o', f);
		fputc(0, f); fputc('d', f);
		fputc(0, f); fputc('i', f);
		fputc(0, f); fputc('n', f);
		fputc(0, f); fputc('g', f);
		fputc(0, f); fputc('=', f);
		fputc(0, f); fputc('"', f);
		fputc(0, f); fputc('u', f);
		fputc(0, f); fputc('c', f);
		fputc(0, f); fputc('s', f);
		fputc(0, f); fputc('-', f);
		fputc(0, f); fputc('2', f);
		fputc(0, f); fputc('-', f);
		fputc(0, f); fputc('b', f);
		fputc(0, f); fputc('e', f);
		fputc(0, f); fputc('"', f);
		fputc(0, f); fputc('?', f);
		fputc(0, f); fputc('>', f);
		fputc(0, f); fputc('\r', f);
		fputc(0, f); fputc('\n', f);
		fclose(f);
		}
	else if (argc == 2 && argv[1][0] == '-' && argv[1][1] == 'l') {
		FILE *f;
		f = fopen("unile.xml", "wb");
		fputc(0xFF, f); fputc(0xFE, f);
		fputc('<', f); fputc(0, f);
		fputc('?', f); fputc(0, f);
		fputc('x', f); fputc(0, f);
		fputc('m', f); fputc(0, f);
		fputc('l', f); fputc(0, f);
		fputc(' ', f); fputc(0, f);
		fputc('e', f); fputc(0, f);
		fputc('n', f); fputc(0, f);
		fputc('c', f); fputc(0, f);
		fputc('o', f); fputc(0, f);
		fputc('d', f); fputc(0, f);
		fputc('i', f); fputc(0, f);
		fputc('n', f); fputc(0, f);
		fputc('g', f); fputc(0, f);
		fputc('=', f); fputc(0, f);
		fputc('"', f); fputc(0, f);
		fputc('u', f); fputc(0, f);
		fputc('c', f); fputc(0, f);
		fputc('s', f); fputc(0, f);
		fputc('-', f); fputc(0, f);
		fputc('2', f); fputc(0, f);
		fputc('-', f); fputc(0, f);
		fputc('l', f); fputc(0, f);
		fputc('e', f); fputc(0, f);
		fputc('"', f); fputc(0, f);
		fputc('?', f); fputc(0, f);
		fputc('>', f); fputc(0, f);
		fputc('\r', f); fputc(0, f);
		fputc('\n', f); fputc(0, f);
		fclose(f);
		}
	else if (argc == 1) printf("stdin encoding: %s\n", xmlenc(stdin));
	else if (argc == 2) printf("%s encoding: %s\n", argv[1],
		xmlenc(fopen(argv[1], "r")));
	else fprintf(stderr, "usage: %s [xml-doc]\n", argv[0]);
	exit(0);
	}
*/