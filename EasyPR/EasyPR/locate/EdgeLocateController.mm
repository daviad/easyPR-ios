//
//  EdgeLocateController.m
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/9.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//
#import <opencv2/opencv.hpp>

#import "EdgeLocateController.h"
#import "UIImageCVMatConverter.h"
//#import "EdgeSettingController.swift"
using namespace cv;
using namespace std;

@interface EdgeLocateController ()

@end

@implementation EdgeLocateController
- (void)handleImage:(cv::Mat)rgbImagge {
    Mat gaussImage;
    GaussianBlur(rgbImagge, gaussImage, cv::Size(3,3), 2);
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:gaussImage]];
    cvtColor(gaussImage, gaussImage, CV_RGB2GRAY);
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:gaussImage]];
    Mat grad_x;
    Sobel(gaussImage, grad_x, -1, 1, 0);
    convertScaleAbs(grad_x, grad_x);
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:grad_x]];
    
    threshold(grad_x, grad_x, 0, 255, CV_THRESH_OTSU + CV_THRESH_BINARY);
    
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(10,10));
    morphologyEx(grad_x, grad_x, MORPH_CLOSE, element);
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:grad_x]];

    

}

- (void)setting {
//    [self.navigationController pushViewController:[EdgeSettingController new] animated:YES]
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
