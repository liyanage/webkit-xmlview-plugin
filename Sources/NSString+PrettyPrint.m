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
    NSString *pretty = [NSString stringWithFormat:@"\"%@\"", self];
    return [NSXMLNode textWithStringValue:pretty];
}

@end
