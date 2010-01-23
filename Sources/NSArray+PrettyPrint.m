//
//  NSArray+PrettyPrint.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSArray+PrettyPrint.h"


@implementation NSArray (PrettyPrint)


- (NSXMLNode *) prettyPrintMe {
    NSXMLElement *result = [NSXMLNode elementWithName:@"span"];
    [result addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"element mixed"]];
    
    NSXMLElement *open = [NSXMLNode elementWithName:@"span"];
    [open addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"tag open mixed"]];
    [open addChild:[NSXMLNode textWithStringValue:@"["]];
    
    [result addChild:open];
    
    NSXMLElement *content = [NSXMLNode elementWithName:@"div"];
    [content addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"mixedcontent"]];
    
    for (id jsonElement in self) {
        NSXMLElement *element = [NSXMLNode elementWithName:@"div"];
        [element addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"element nomixed"]];
        
//        NSXMLElement *tag = [NSXMLNode elementWithName:@"span"];
//        [tag addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"element nomixed"]];
//        [tag addChild:[NSXMLNode textWithStringValue:[[NSString alloc] initWithFormat:@"%@: ", key]]];
//        
//        [element addChild: tag];
//        [tag addChild: [[self valueForKey:key] prettyPrintMe]];
        
        [element addChild: [jsonElement prettyPrintMe]];
        [content addChild: element];
    }
    
    [result addChild: content];
    
    NSXMLElement *close = [NSXMLNode elementWithName:@"span"];
    [close addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"tag close mixed"]];
    [close addChild:[NSXMLNode textWithStringValue:@"]"]];
    
    [result addChild:close];
    
    return result;
}



@end
