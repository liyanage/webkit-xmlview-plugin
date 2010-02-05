//
//  NSNull+PrettyPrint.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSNull+PrettyPrint.h"


@implementation NSNull (PrettyPrint)

- (NSXMLElement *) prettyPrintMe {
    NSXMLElement *root = [NSXMLNode elementWithName:@"span"];
    [root addChild:[NSXMLNode textWithStringValue:@"null"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"null"]];
    
    return root;
}

@end
