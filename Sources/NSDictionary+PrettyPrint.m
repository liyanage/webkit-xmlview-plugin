//
//  NSDictionaryPrettyPrint.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+PrettyPrint.h"


@implementation NSDictionary (PrettyPrint)

- (NSXMLElement *) prettyPrintMe {
    NSXMLElement *result = [NSXMLNode elementWithName:@"div"];
    [result addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"element mixed"]];
    
    NSXMLElement *open = [NSXMLNode elementWithName:@"span"];
    [open addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"tag open mixed"]];
    [open addChild:[NSXMLNode textWithStringValue:@"{"]];
    
    [result addChild:open];
    
    NSXMLElement *content = [NSXMLNode elementWithName:@"div"];
    [content addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"mixedcontent"]];
    [content addAttribute:[NSXMLNode attributeWithName:@"style" stringValue:@""]];
    
    int i = 1;
    for (id key in self) {
        NSXMLElement *element = [NSXMLNode elementWithName:@"div"];
        NSString *classes = @"element nomixed";
        
        NSXMLElement *tag = [NSXMLNode elementWithName:@"span"];
        [tag addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"element nomixed key"]];
        [tag addChild:[NSXMLNode textWithStringValue:[[NSString alloc] initWithFormat:@"%@: ", key]]];
        NSXMLElement *value = [[self valueForKey:key] prettyPrintMe];
        
        [element addChild: tag]; // key
        [element addChild: value]; // value
        
        if (i < [self count]) {
            NSRange i = [[[value attributeForName:@"class"] stringValue] rangeOfString:@"mixed"];
            if (i.location != NSNotFound) {
                [value addAttribute:[NSXMLNode attributeWithName:@"class" 
                                               stringValue:[[[value attributeForName:@"class"] stringValue] 
                                                            stringByAppendingString:@" append-comma"]]];
            } else {
                classes = [classes stringByAppendingString:@" append-comma"];
            }
        }
        [element addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:classes]];
        [content addChild: element];
        i++;
    }
    
    [result addChild: content];
    
    NSXMLElement *close = [NSXMLNode elementWithName:@"span"];
    [close addAttribute:[NSXMLNode attributeWithName:@"class" stringValue:@"tag close mixed"]];
    [close addChild:[NSXMLNode textWithStringValue:@"}"]];
    
    [result addChild:close];
    
    return result;
}

@end
