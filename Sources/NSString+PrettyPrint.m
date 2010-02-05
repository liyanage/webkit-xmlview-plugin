//
//  NSStringPrettyPrint.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+PrettyPrint.h"


@implementation NSString (PrettyPrint)

- (NSXMLNode *) prettyPrintMe {
    NSXMLElement *root = [NSXMLNode elementWithName:@"span"];
    [root addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"string"]];
    NSString *pretty = [NSString stringWithFormat:@"\"%@\"", self];
    [root addChild:[NSXMLNode textWithStringValue:pretty]];
    
    return root;
}

@end
