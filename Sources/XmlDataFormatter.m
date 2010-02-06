//
//  XMLDataFormatter.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 02.03.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "XmlDataFormatter.h"
#import "XmlEncodingSniffer.h"


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
		NSLog(@"%@", errorMessage);
		encoding = NSISOLatin1StringEncoding;
	}
}


- (NSString *)formattedString {
	if (!data) return nil;
	if (prettyPrint) {
		NSString *result = [self prettyPrintedString];
		if (result) return result;
		NSLog(@"XML View Plugin: Unable to pretty-print, falling back to plain format");
	}
	return [self plainString];
}



- (NSString *)plainString {
	NSString *result = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
	if (!result) {
		self.errorMessage = @"Encoding mismatch, falling back to ISO-8859-1";
		NSLog(@"%@", errorMessage);
		result = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
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



- (NSString *)prettyPrintedString {
	return nil;
}


@end
