//
//  XmlEncodingSniffer.h
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XmlEncodingSniffer : NSObject {

}

+ (NSStringEncoding)encodingForXmlData:(NSData *)xmlData;


@end
