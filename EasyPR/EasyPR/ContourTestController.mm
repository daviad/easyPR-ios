//
//  ContourTestController.m
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/7.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//
#import <opencv2/opencv.hpp>

#import "UIImageCVMatConverter.h"
#import "ShowController.h"
#import "ContourTestController.h"

using namespace cv;
using namespace std;

@interface ContourTestController ()

@end

@implementation ContourTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ShowController *showCtr = [[ShowController alloc] init];
    [self addChildViewController:showCtr];
    [self.view addSubview:showCtr.view];
    NSMutableArray *imgs = [NSMutableArray array];
    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"plate_judge" ofType:@"jpg"];
    //    nsstring=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    //    nsstring=[[NSBundle mainBundle] pathForResource:@"test2" ofType:@"jpeg"];
    
    string image_path=[nsstring UTF8String];
    Mat orginImg = imread(image_path, IMREAD_UNCHANGED);
    Mat rgbImg;
    cvtColor(orginImg, rgbImg, CV_BGR2RGB);
    [imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:rgbImg]];

    //初始化结果图
    Mat dstImage;
    int ElementShape = MORPH_RECT;
    Mat element = getStructuringElement(ElementShape, cv::Size(2 * 2 + 1,
                                                               2 * 2 + 1), cv::Point(2, 2));
    
    morphologyEx(rgbImg, dstImage, MORPH_OPEN, element, cv::Point(-1, -1), 4);
    
    //定义轮廓和层次结构
    vector<vector<cv::Point>>contours;
    vector<Vec4i>hierarchy;
    findContours(dstImage, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_NONE);
    //迭代器输出
    /*for (vector<vector<Point>>::iterator it=contours.begin();it!=contours.end();++it)
     {
     for (vector<Point>::iterator inner_it=it->begin();inner_it!=it->end();++inner_it)
     {
     cout<<*inner_it<<endl;
     }
     }
     */
    //下标输出
    for (int i = 0; i<contours.size(); i++)
    {
        for (int j = 0; j<contours[i].size(); j++)
        {
            cout << contours[i][j].x << "   " << contours[i][j].y << endl;
            /*ofstream f;
             f.open("E:/坐标轮廓线.txt", ios::out | ios::app);
             f << contours[i][j].x << "  " << contours[i][j].y << endl;*/
        }
    }
    
    //遍历顶层轮廓，以随机颜色绘制出每个连接组件颜色
    int index = 0;
    for (; index >= 0; index = hierarchy[index][0])
    {
        Scalar color(rand() % 255, rand() % 255, rand() % 255);
        drawContours(dstImage, contours, index, color, 1, 8, hierarchy);
    }

    
    [showCtr loadImages:imgs];

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
