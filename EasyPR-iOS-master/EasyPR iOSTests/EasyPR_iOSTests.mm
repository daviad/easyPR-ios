//
//  EasyPR_iOSTests.m
//  EasyPR iOSTests
//
//  Created by  dingxiuwei on 2018/7/30.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>

#endif


#import <XCTest/XCTest.h>
#include "easypr.h"

@interface EasyPR_iOSTests : XCTestCase

@end

@implementation EasyPR_iOSTests

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
    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    std::string image_path=[nsstring UTF8String];
    
    cv::Mat source_image= cv::imread(image_path);
    easypr::CPlateRecognize pr;

    UIImage *plateimage;
    vector<easypr::CPlate> plateVec;

    int result = pr.plateRecognize(source_image, plateVec);
    if (result == 0) {
        size_t num = plateVec.size();
        for (size_t j = 0; j < num; j++) {
            cout << "plateRecognize: " << plateVec[j].getPlateStr() << endl;
        }
    }


    string name=plateVec[0].getPlateStr();
    NSString *resultMessage = [NSString stringWithCString:plateVec[0].getPlateStr().c_str()
                                                 encoding:NSUTF8StringEncoding];

    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
