//
//  XmlDataFormatter.h
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XmlDataFormatter.h"

@interface XmlDataFormatterTidy : XmlDataFormatter {
}


- (char *)tidyEncodingString;
- (NSString *)firstErrorLineInTidyDiagnostics:(NSArray *)lines;

@end
