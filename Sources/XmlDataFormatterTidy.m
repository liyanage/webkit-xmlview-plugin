//
//  XmlDataFormatter.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "XmlDataFormatterTidy.h"
#include <tidy/tidy.h>
#include <tidy/buffio.h>

@implementation XmlDataFormatterTidy



- (NSString *)prettyPrintedString {

	TidyDoc tdoc = tidyCreate();
	TidyBuffer output;
	tidyBufInit(&output);
	TidyBuffer errbuf;
	tidyBufInit(&errbuf);

	TidyBuffer input;
	tidyBufInit(&input);
	tidyBufAlloc(&input, [data length]);
	tidyBufAppend(&input, (void *)[data bytes], [data length]);

    tidySetErrorBuffer(tdoc, &errbuf);      // Capture diagnostics

	tidyOptSetBool(tdoc, TidyXmlTags, yes);
	tidyOptSetValue(tdoc, TidyIndentContent, "auto");
	tidyOptSetInt(tdoc, TidyWrapLen, 120);

	tidySetInCharEncoding(tdoc, [self tidyEncodingString]);
	tidySetOutCharEncoding(tdoc, "utf8");
    tidyParseBuffer(tdoc, &input);

    tidyCleanAndRepair(tdoc);
    tidySaveBuffer(tdoc, &output);

	NSString *result = nil;
	if (output.bp) {
		result = [NSString stringWithUTF8String:(const char *)output.bp];
	} else {
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
	NSLog(@"%@", errorMessage);
	return "latin1";
}



@end
