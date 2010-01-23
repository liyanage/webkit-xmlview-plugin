//
//  NSDecimalNumber+PrettyPrint.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDecimalNumber+PrettyPrint.h"


@implementation NSDecimalNumber (PrettyPrint)

- (NSXMLNode *) prettyPrintMe {
    return [NSXMLNode textWithStringValue:[self stringValue]];
}

@end
