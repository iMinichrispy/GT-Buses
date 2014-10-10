//
//  GT_BusesTests.m
//  GT-BusesTests
//
//  Created by Alex Perez on 2/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XMLReader.h"
#import "GBRoute.h"

@interface GT_BusesTests : XCTestCase

@end

@implementation GT_BusesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testRouteConfigPerformance {
    NSMutableArray *routes = [NSMutableArray new];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RouteConfig" ofType:@"xml"];
    NSLog(@"%@",path);
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:nil];
    
    [self measureBlock:^{
        NSError *error;
        NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
        NSArray *newRoutes = dictionary[@"body"][@"route"];
        
        for (NSDictionary *dictionary in newRoutes) {
            GBRoute *route = [dictionary toRoute];
            [routes addObject:route];
        }
    }];
    
    
    
//    XCTAssert(!error, @"An error occured: %@", [error localizedDescription]);
}

- (void)testPredictionsPerformance {
    
}


@end
