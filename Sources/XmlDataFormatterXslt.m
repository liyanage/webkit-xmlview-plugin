//
//  XmlDataFormatterXslt.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 02.03.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "XmlDataFormatterXslt.h"


@implementation XmlDataFormatterXslt


- (NSData *)prettyPrintedData {

	NSError *error = nil;
	NSXMLDocument *xmlDoc;
	xmlDoc = [[[NSXMLDocument alloc] initWithData:self.data options:0 error:&error] autorelease];
	if (error) {
		[self storeError:error forStage:@"xml parse"];
		return nil;
	}

	NSString *xsltPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"xml-pretty-print" ofType:@"xslt"];
//	NSLog(@"xsltUrl: %@", [NSURL fileURLWithPath:xsltPath]);
	
	NSXMLDocument *xsltResult = [xmlDoc objectByApplyingXSLTAtURL:[NSURL fileURLWithPath:xsltPath] arguments:nil error:&error];
	if (error) {
		[self storeError:error forStage:@"xslt transform"];
		return nil;
	}
	
	if (!xsltResult) {
		self.errorMessage = @"Unable to run XSLT transformation";
		NSLog(@"failed to pretty-print (%@): %@", @"xslt", self.errorMessage);
		return nil;
	}

//	NSLog(@"result %@", [xsltResult stringValue]);
	return [xsltResult XMLData];
}

- (NSString *)prettyPrintedString {
	NSData *resultData = [self prettyPrintedData];
	if (!resultData) return nil;
	return [[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding] autorelease];
}





- (NSString *)storeError:(NSError *)error forStage:(NSString *)stage {
		NSArray *lines = [[error localizedDescription] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		self.errorMessage = [lines objectAtIndex:0];
		self.errorMessageDetail = [error localizedDescription];
		NSLog(@"failed to pretty-print (%@): %@", stage, self.errorMessage);
		return nil;
}


@end
