//
//  TestXmlDataFormatter.h
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "XmlDataFormatter.h"

@interface TestXmlDataFormatter : SenTestCase {

}

- (void)testXmlDataFormatterPlain;
- (void)testBrokenEncodingRecovery;
- (void)testParseErrorRecovery;

@end
