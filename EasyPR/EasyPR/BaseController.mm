//
//  BaseController.m
//  EasyPR
//
//  Created by 丁秀伟 on 2018/8/8.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import "BaseController.h"
#import "ShowController.h"
#import "UIImageCVMatConverter.h"

using namespace cv;
using namespace std;

@interface BaseController ()

@end

@implementation BaseController

- (void)handleImage:(cv::Mat)rgbImage {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ShowController *showCtr = [[ShowController alloc] init];
    [self addChildViewController:showCtr];
    [self.view addSubview:showCtr.view];
    self.imgs = [NSMutableArray array];
    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"plate_judge" ofType:@"jpg"];
    //    nsstring=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
//    nsstring=[[NSBundle mainBundle] pathForResource:@"car3" ofType:@"jpg"];
    
    string image_path=[nsstring UTF8String];
    Mat orginImg = imread(image_path, IMREAD_UNCHANGED);
    Mat resizedImg = orginImg;
    //    resize(orginImg, resizedImg, cv::Size(self.view.frame.size.width,self.view.frame.size.width / ratiowh));
    Mat originRGB;
    cvtColor(resizedImg, originRGB, CV_BGR2RGB);
    [self.imgs addObject:@"原图"];
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:originRGB]];
    [self handleImage:originRGB];
    [showCtr loadImages:self.imgs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
