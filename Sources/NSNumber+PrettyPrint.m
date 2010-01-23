//
//  NSNumber+PrettyPrint.m
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+PrettyPrint.h"


@implementation NSNumber (PrettyPrint)

- (NSXMLNode *) prettyPrintMe {
    NSString *boolValue = [NSString stringWithString:@"false"];
    if ([self boolValue]) {
        boolValue = [NSString stringWithString:@"true"];
    }
    
    return [NSXMLNode textWithStringValue: boolValue];
}

@end
