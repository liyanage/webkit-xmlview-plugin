//
//  TestXmlEncodingSniffer.h
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 08.02.09.
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface TestXmlEncodingSniffer : SenTestCase {

}

- (void)testNullData;
- (void)testEncodings;
- (void)testWithoutXmlDecl;

@end
