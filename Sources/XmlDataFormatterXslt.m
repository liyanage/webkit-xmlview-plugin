//
//  XmlDataFormatterXslt.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 02.03.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "XmlDataFormatterXslt.h"
#import "GTMBase64.h"

@implementation XmlDataFormatterXslt


- (NSData *)prettyPrintedData {
	NSXMLDocument *xsltResult = [self transformData:self.data];
	if (!xsltResult) return nil;
	return [xsltResult XMLData];
}


- (NSXMLDocument *)transformData:(NSData *)inputData {
	NSError *error = nil;
	NSXMLDocument *xmlDoc = [[[NSXMLDocument alloc] initWithData:inputData options:0 error:&error] autorelease];
	if (error) {
		[self storeError:error forStage:@"xml parse"];
		return nil;
	}

	NSBundle *bundle = [NSBundle bundleForClass:[self class]];

	NSString *xsltPath = [bundle pathForResource:@"xml-escape-amp-lt" ofType:@"xslt"];
	xmlDoc = [xmlDoc objectByApplyingXSLTAtURL:[NSURL fileURLWithPath:xsltPath] arguments:nil error:&error];
	if (error) {
		[self storeError:error forStage:@"xslt transform"];
		return nil;
	}

	xsltPath = [bundle pathForResource:@"xml-pretty-print" ofType:@"xslt"];
	NSString *webResourcePath = [bundle pathForResource:@"web-resources" ofType:@""];
	NSURL *webResourceUrl = [NSURL fileURLWithPath:webResourcePath];
//	NSLog(@"xsltUrl: %@", [NSURL fileURLWithPath:xsltPath]);

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *userJsBase64Data = [GTMBase64 encodeData:[[defaults stringForKey:@"ch_entropy_xmlViewPlugin_UserJs"] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *userJsBase64String = [[[NSString alloc] initWithData:userJsBase64Data encoding:NSASCIIStringEncoding] autorelease];
	NSDictionary *xsltParameters = [NSDictionary dictionaryWithObjectsAndKeys:
//		[defaults stringForKey:@"ch_entropy_xmlViewPlugin_UserCss"], @"user_css",
		[self xpathEscapeString:[defaults stringForKey:@"ch_entropy_xmlViewPlugin_UserCss"]], @"user_css",
		[self xpathEscapeString:[defaults stringForKey:@"ch_entropy_xmlViewPlugin_UserJs"]], @"user_js",
		[NSString stringWithFormat:@"'%@'", userJsBase64String], @"user_js_base64",
		[self xpathEscapeString:[webResourceUrl absoluteString]], @"web_resource_base",
		nil
	];

	
	xmlDoc = [xmlDoc objectByApplyingXSLTAtURL:[NSURL fileURLWithPath:xsltPath] arguments:xsltParameters error:&error];
	if (error) {
		[self storeError:error forStage:@"xslt transform"];
		return nil;
	}
	
	if (!xmlDoc) {
		self.errorMessage = @"Unable to run XSLT transformation";
		NSLog(@"failed to pretty-print (%@): %@", @"xslt", self.errorMessage);
		return nil;
	}
	
	return xmlDoc;
}




- (NSString *)prettyPrintedString {
	NSData *resultData = [self prettyPrintedData];
	if (!resultData) return nil;
	return [[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding] autorelease];
}



- (NSString *)xpathEscapeString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@"'"];
	if ([components count] < 2) return [NSString stringWithFormat:@"'%@'", string];
	
	NSMutableString *escaped = [NSMutableString string];
	[escaped appendString:@"concat("];
	for (int i = 0; i < [components count]; i++) {
		NSString *component = [components objectAtIndex:i];
		[escaped appendString:[NSString stringWithFormat:@"'%@'", component]];
		if (i + 1 < [components count]) [escaped appendString:@", \"'\", "];
	}
	[escaped appendString:@")"];
	return escaped;
}






- (NSString *)storeError:(NSError *)error forStage:(NSString *)stage {
		NSArray *lines = [[error localizedDescription] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		self.errorMessage = [lines objectAtIndex:0];
		self.errorMessageDetail = [error localizedDescription];
		NSLog(@"failed to pretty-print (%@): %@", stage, self.errorMessage);
		return nil;
}


@end
