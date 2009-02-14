//
//  XmlDataFormatter.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "XmlDataFormatter.h"
#import "XmlEncodingSniffer.h"
#include <tidy/tidy.h>
#include <tidy/buffio.h>

@implementation XmlDataFormatter

@synthesize data;
@synthesize errorMessage;
@synthesize errorMessageDetail;
@synthesize status;
@synthesize encoding;
@synthesize prettyPrint;


- (id)initWithData:(NSData *)xmlData {
	if (!(self = [super init])) return nil;
	if (!xmlData) {
		NSLog(@"nil xml data");
		[self release];
		return nil;
	}
	self.data = xmlData;
	[self sniffEncoding];
	return self;
}


- (void)sniffEncoding {
	encoding = [XmlEncodingSniffer encodingForXmlData:data];
	if (!encoding) {
		self.errorMessage = @"Unable to determine encoding, falling back to ISO-8859-1";
		NSLog(errorMessage);
		encoding = NSISOLatin1StringEncoding;
	}
}


- (NSString *)formattedString {
	if (!data) return nil;
	if (prettyPrint) return [self prettyPrintedString];
	return [self plainString];
}


- (NSString *)prettyPrintedString {

	TidyDoc tdoc = tidyCreate();
	TidyBuffer output;
	tidyBufInit(&output);
	TidyBuffer errbuf;
	tidyBufInit(&errbuf);
	int rc = -1;

	TidyBuffer input;
	tidyBufInit(&input);
	tidyBufAlloc(&input, [data length]);
	tidyBufAppend(&input, (void *)[data bytes], [data length]);

    rc = tidySetErrorBuffer(tdoc, &errbuf);      // Capture diagnostics

	rc = tidyOptSetBool(tdoc, TidyXmlTags, yes);
	rc = tidyOptSetValue(tdoc, TidyIndentContent, "auto");

	rc = tidySetInCharEncoding(tdoc, [self tidyEncodingString]);
	rc = tidySetOutCharEncoding(tdoc, "utf8");
    rc = tidyParseBuffer(tdoc, &input);

    rc = tidyCleanAndRepair(tdoc);
    rc = tidySaveBuffer(tdoc, &output);

	NSString *result;
	if (output.bp) {
		result = [NSString stringWithUTF8String:(const char *)output.bp];
	} else {
		result = [self plainString];
		NSString *longMessage = [NSString stringWithFormat:@"unable to pretty-print: %s", errbuf.bp ? (char *)errbuf.bp : "(unknown error)"];
		NSArray *lines = [longMessage componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		self.errorMessage = [self firstErrorLineInTidyDiagnostics:lines];
		if ([lines count] > 1) {
			self.errorMessageDetail = longMessage;
		}
		NSLog(@"failed to pretty-print: %@", longMessage);
	}

	tidyBufFree(&input);
	tidyBufFree(&output);
	tidyBufFree(&errbuf);
	tidyRelease(tdoc);

	return result;
}


- (NSString *)firstErrorLineInTidyDiagnostics:(NSArray *)lines {
	if ([lines count] < 1) return nil;
	for (NSString *line in lines) {
		if ([line rangeOfString:@"Error:"].location != NSNotFound) return line;
	}
	return [lines objectAtIndex:0];
}


- (char *)tidyEncodingString {

	if (encoding == NSASCIIStringEncoding)             return "ascii";
	if (encoding == NSISOLatin1StringEncoding)         return "latin1";
	if (encoding == NSUTF8StringEncoding)              return "utf8";
	if (encoding == NSUTF16StringEncoding)             return "utf16";
	if (encoding == NSUTF16BigEndianStringEncoding)    return "utf16be";
	if (encoding == NSUTF16LittleEndianStringEncoding) return "utf16le";
	if (encoding == NSMacOSRomanStringEncoding)        return "mac";
	if (encoding == NSWindowsCP1252StringEncoding)     return "win1252";
	if (encoding == NSISO2022JPStringEncoding)         return "iso2022";
	if (encoding == NSShiftJISStringEncoding)          return "shiftjis";
	

	self.errorMessage = [NSString stringWithFormat:@"unknown encoding (%d), falling back to ISO-8859-1", encoding];
	NSLog(errorMessage);
	return "latin1";
}


- (NSString *)plainString {
	NSString *result = [[NSString alloc] initWithData:data encoding:encoding];
	if (!result) {
		self.errorMessage = @"Encoding mismatch, falling back to ISO-8859-1";
		NSLog(self.errorMessage);
		result = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
	}
	return result;
}


- (void) dealloc {
	[self reset];
	[super dealloc];
}


- (void)reset {
	self.errorMessage = nil;
	self.errorMessageDetail = nil;
	self.data = nil;
	self.encoding = 0;
	self.status = 0;
}



@end
