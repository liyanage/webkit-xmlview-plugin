//
//  TestXmlDataFormatter.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "TestXmlDataFormatter.h"


@implementation TestXmlDataFormatter

- (void)testXmlDataFormatterPlain {

	XmlDataFormatter *xdf = [[XmlDataFormatter alloc] initWithData:nil];
	STAssertNil(xdf, @"nil input = nil output");

	NSData *data;
	data = [@"<?xml version='1.0' encoding='utf-8' ?><ro\xc2\xabot/>" dataUsingEncoding:NSUTF8StringEncoding];
	xdf = [[[XmlDataFormatter alloc] initWithData:data] autorelease];
	
	STAssertEquals(xdf.encoding, (NSStringEncoding)NSUTF8StringEncoding, @"sniffed encoding");
	
	STAssertEquals(xdf.prettyPrint, NO, @"pretty print setting default value");
	STAssertEqualObjects([xdf formattedString], @"<?xml version='1.0' encoding='utf-8' ?><ro\xc2\xabot/>", @"non-pretty-printed result");

	data = [@"<?xml version='1.0' encoding='iso-8859-1' ?><ro\xc2\xabot/>" dataUsingEncoding:NSISOLatin1StringEncoding];
	xdf = [[XmlDataFormatter alloc] initWithData:data];
	STAssertEqualObjects([xdf formattedString], @"<?xml version='1.0' encoding='iso-8859-1' ?><ro\xc2\xabot/>", @"non-pretty-printed result");
	
}



- (void)testXmlDataFormatterPrettyPrinted {

	NSData *data;
//	data = [@"<?xml version='1.0' encoding='utf-8' ?><ro\xc2\xabot/>" dataUsingEncoding:NSUTF8StringEncoding];
	data = [@"<?xml version='1.0' encoding='utf-8' ?><ro\xc3\x84ot/>" dataUsingEncoding:NSUTF8StringEncoding];
	XmlDataFormatter *xdf = [[[XmlDataFormatter alloc] initWithData:data] autorelease];
	STAssertNotNil(xdf, nil);

	STAssertEquals(xdf.prettyPrint, NO, @"prettyprint setter");
	xdf.prettyPrint = YES;
	STAssertEquals(xdf.prettyPrint, YES, @"prettyprint setter");

	NSString *result = [xdf formattedString];
	STAssertEqualObjects(result, @"<?xml version='1.0' encoding='utf-8'?>\n<ro\xc3\x84ot />\n", @"pretty-printed result");
	//                              123456789 123456789 123456789 123456789 123456789 123456789

}


- (void)testBrokenEncodingRecovery {
	
	// utf8 sequence c2ab is Unicode character LEFT-POINTING DOUBLE ANGLE QUOTATION MARK, this is our test character.
	// Serialize it to MacRoman encoding.
	// Then hand it over to the formatter, while the xml declaration says it's utf-8
	// The formatter should try as utf8 first, fail, then fall back to interpret the bytes as
	// iso-latin-1. The result is that the test character comes out as utf-8 sequence c387, Unicode character LATIN CAPITAL LETTER C WITH CEDILLA
	NSData *data = [@"<?xml version='1.0' encoding='utf-8' ?><ro\xc2\xabot/>" dataUsingEncoding:NSMacOSRomanStringEncoding];
	NSAssert(data, @"data");
	XmlDataFormatter *xdf = [[[XmlDataFormatter alloc] initWithData:data] autorelease];
	STAssertEquals(xdf.encoding, (NSStringEncoding)NSUTF8StringEncoding, @"sniffed encoding is utf-8");
	STAssertEqualObjects([xdf formattedString], @"<?xml version='1.0' encoding='utf-8' ?><ro\xc3\x87ot/>", @"non-pretty-printed result");
}


- (void)testParseErrorRecovery {
	NSData *data;
	data = [@"<?xml version='1.0' encoding='utf-8' ?><root><broken </root>" dataUsingEncoding:NSUTF8StringEncoding];
	XmlDataFormatter *xdf = [[[XmlDataFormatter alloc] initWithData:data] autorelease];
	STAssertNotNil(xdf, nil);
	xdf.prettyPrint = YES;
	NSString *result = [xdf formattedString];
	STAssertEqualObjects(result, @"<?xml version='1.0' encoding='utf-8' ?><root><broken </root>", @"parse error falls back to raw data");
}


@end
