//
//  NSNumber+PrettyPrint.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+PrettyPrint.h"


@implementation NSNumber (PrettyPrint)

- (NSXMLElement *) prettyPrintMe {
    NSString *boolValue = @"false";
    if ([self boolValue]) {
        boolValue = @"true";
    }
    
    NSXMLElement *root = [NSXMLNode elementWithName:@"span"];
    [root addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"boolean"]];
    [root addChild:[NSXMLNode textWithStringValue: boolValue]];
    
    return root;
}

@end
