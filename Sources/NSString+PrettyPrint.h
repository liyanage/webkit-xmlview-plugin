//
//  NSStringPrettyPrint.h
//  XMLWebKitPlugin
//
//  Created by Juan Germán Castañeda Echevarría on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (PrettyPrint)

- (NSXMLElement *) prettyPrintMe;

@end
