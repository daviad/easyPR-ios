//
//  EasyPRTests.m
//  EasyPRTests
//
//  Created by  dingxiuwei on 2018/7/30.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//
#include "ann_train.hpp"

#import <XCTest/XCTest.h>

@interface EasyPRTests : XCTestCase

@end

@implementation EasyPRTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
   easypr::AnnTrain train = easypr::AnnTrain("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann","/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann1.xml");
//    train.train();
    
    train.test("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/1/9-5.jpg");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
