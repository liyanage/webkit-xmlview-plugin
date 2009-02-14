//
//  XmlDataFormatter.h
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XmlDataFormatter : NSObject {
	NSData *data;
	NSString *errorMessage;
	NSString *errorMessageDetail;
	NSUInteger status;
	NSStringEncoding encoding;
	BOOL prettyPrint;
}

#pragma mark public
@property BOOL prettyPrint;
- (id)initWithData:(NSData *)xmlData;
- (NSString *)formattedString;

#pragma mark private
@property(retain) NSData *data;
@property(retain) NSString *errorMessage;
@property(retain) NSString *errorMessageDetail;
@property NSUInteger status;
@property NSStringEncoding encoding;
- (void)reset;
- (void)sniffEncoding;
- (NSString *)prettyPrintedString;
- (NSString *)plainString;
- (char *)tidyEncodingString;
- (NSString *)firstErrorLineInTidyDiagnostics:(NSArray *)lines;

@end
