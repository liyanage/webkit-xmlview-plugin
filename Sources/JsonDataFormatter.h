//
//  JsonDataFormatter.h
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XmlDataFormatter.h"
#import "NSDictionary+PrettyPrint.h"
#import "NSArray+PrettyPrint.h"


@interface JsonDataFormatter : XmlDataFormatter {

}

- (NSData *)prettyPrintedData;
- (NSXMLDocument *)transformData;
- (NSString *)xpathEscapeString:(NSString *)string;

@end
