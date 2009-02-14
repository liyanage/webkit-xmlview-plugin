//
//  TestXmlEncodingSniffer.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "TestXmlEncodingSniffer.h"
#import "XmlEncodingSniffer.h"

@implementation TestXmlEncodingSniffer

- (void)testNullData {
	NSStringEncoding result = [XmlEncodingSniffer encodingForXmlData:nil];
	STAssertEquals(result, (NSStringEncoding)0, @"null input data returns null output data");
}

- (void)testEncodings {

	NSData *data;
	NSStringEncoding result;

	NSDictionary *map = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithUnsignedInt:NSASCIIStringEncoding],
		@"us-ascii",
		[NSNumber numberWithUnsignedInt:NSJapaneseEUCStringEncoding],
		@"euc-jp",
		[NSNumber numberWithUnsignedInt:NSUTF8StringEncoding],
		@"utf-8",
		[NSNumber numberWithUnsignedInt:NSISOLatin1StringEncoding],
		@"iso-8859-1",
		[NSNumber numberWithUnsignedInt:0],
		@"x-unknown-dummy-test",
/*		
		[NSNumber numberWithUnsignedInt:NSSymbolStringEncoding],
		@"x-mac-symbol",
		[NSNumber numberWithUnsignedInt:NSShiftJISStringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSISOLatin2StringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSUnicodeStringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSWindowsCP1251StringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSWindowsCP1252StringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSWindowsCP1253StringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSWindowsCP1254StringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSWindowsCP1250StringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSISO2022JPStringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSMacOSRomanStringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSUTF16BigEndianStringEncoding],
		@"utf-16be",
		[NSNumber numberWithUnsignedInt:NSUTF16LittleEndianStringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSUTF32StringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSUTF32BigEndianStringEncoding],
		@"xxxxxxxxxxxx",
		[NSNumber numberWithUnsignedInt:NSUTF32LittleEndianStringEncoding],
		@"xxxxxxxxxxxx",
	*/

		nil
	];

	for (id key	in [map keyEnumerator]) {
		data = [[NSString stringWithFormat:@"<?xml version='1.0' encoding='%@' ?>\n<ro\xc2\xabot/>", key] dataUsingEncoding:NSMacOSRomanStringEncoding];
		result = [XmlEncodingSniffer encodingForXmlData:data];
		STAssertEquals(result, (NSStringEncoding)[[map objectForKey:key] intValue], [NSString stringWithFormat:@"%@ result encoding", key]);
	}

}

// data = [@"<?xml version='1.0' encoding='utf-8' ?><ro\xc7\x9aot/>" dataUsingEncoding:NSMacOSRomanStringEncoding];

- (void)testWithoutXmlDecl {
	NSStringEncoding result = [XmlEncodingSniffer encodingForXmlData:[@"<root/>" dataUsingEncoding:NSUTF8StringEncoding]];
	STAssertEquals(result, (NSStringEncoding)NSUTF8StringEncoding, @"encoding for data without XML declaration");
}


@end
