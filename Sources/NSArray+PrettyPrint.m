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
    NSXMLElement *result = [NSXMLNode elementWithName:@"div"];
    [result addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"element mixed"]];
    
    NSXMLElement *open = [NSXMLNode elementWithName:@"span"];
    [open addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"tag open mixed"]];
    [open addChild:[NSXMLNode textWithStringValue:@"["]];
    
    [result addChild:open];
    
    NSXMLElement *content = [NSXMLNode elementWithName:@"div"];
    [content addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"mixedcontent"]];
    
    int i = 1;
    for (id jsonElement in self) {
        NSXMLElement *element = [jsonElement prettyPrintMe];
        
        NSString *classes = [[element attributeForName:@"class"] stringValue];
        if (i < [self count]) {
            classes = [classes stringByAppendingString:@" append-comma"];
        }
        
        [element addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:classes]];
        
        [content addChild: element];
        i++;
    }
    
    [result addChild: content];
    
    NSXMLElement *close = [NSXMLNode elementWithName:@"span"];
    [close addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"tag close mixed"]];
    [close addChild:[NSXMLNode textWithStringValue:@"]"]];
    
    [result addChild:close];
    
    return result;
}



@end
