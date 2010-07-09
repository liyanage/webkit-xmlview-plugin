//
//  JsonDataFormatter.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JsonDataFormatter.h"
#import "JSON.h"
#import "GTMBase64.h"


@implementation JsonDataFormatter

// Formatted and Styled
- (NSData *)prettyPrintedData {
	NSXMLDocument *xsltResult = [self transformData];
	if (!xsltResult) return nil;
	return [xsltResult XMLData];
}

// Formatted
- (NSString *)prettyPrintedString {
	return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];;
}

- (NSXMLDocument *)transformData {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    SBJSON *parser = [[[SBJSON alloc] init] autorelease];
    NSString *json_string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    id json = [parser objectWithString:json_string error:nil];
    
    NSXMLElement *content = (NSXMLElement *)[json prettyPrintMe];
    [content addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:@"json"]];
     
    NSXMLDocument *xmlDoc = [NSXMLNode documentWithRootElement: content];
    
    NSString *xsltPath = [bundle pathForResource:@"xml-to-html" ofType:@"xslt"];
	NSString *webResourcePath = [bundle pathForResource:@"web-resources" ofType:@""];
	NSURL *webResourceUrl = [NSURL fileURLWithPath:webResourcePath];
    
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
		//[self storeError:error forStage:@"xslt transform"];
		return nil;
	}
	
	if (!xmlDoc) {
		self.errorMessage = @"Unable to run XSLT transformation";
		NSLog(@"failed to pretty-print (%@): %@", @"xslt", self.errorMessage);
		return nil;
	}
    
    return xmlDoc;
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

@end
