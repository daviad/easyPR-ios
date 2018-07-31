//
//  ViewController.m
//  EasyPR
//
//  Created by  dingxiuwei on 2018/7/30.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//


#import <opencv2/opencv.hpp>

#import "ViewController.h"
#import "UIImageCVMatConverter.h"

using namespace cv;
using namespace std;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpeg"];
    string image_path=[nsstring UTF8String];
    Mat Image = imread(image_path, 0);
    resize(Image, Image, cv::Size(self.view.frame.size.width, self.view.frame.size.height/self.view.frame.size.width * Image.rows/2));

    Mat CannyImg;
    Canny(Image, CannyImg, 150, 250, 3);

    Mat DstImg;
    cvtColor(Image, DstImg, CV_GRAY2BGR);

    vector<Vec4i> Lines;
    HoughLinesP(CannyImg, Lines, 1, CV_PI / 360, 170,30,15);
    for (size_t i = 0; i < Lines.size(); i++)
    {
        line(DstImg, cv::Point(Lines[i][0], Lines[i][1]), cv::Point(Lines[i][2], Lines[i][3]), cv::Scalar(0, 0, 255), 2, 8);
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImageCVMatConverter UIImageFromCVMat:DstImg]];
    [self.view addSubview:imageView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
