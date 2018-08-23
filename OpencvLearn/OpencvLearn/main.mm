//
//  main.cpp
//  OpencvLearn
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#include <opencv2/opencv.hpp>

#import <Foundation/Foundation.h>

using namespace std;
using namespace cv;

int main()
{
    NSString *resourcePath=[[NSBundle mainBundle] resourcePath];
    Mat Image = imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR/EasyPR/images/wATH859.jpg", 0);
    Mat CannyImg;
    Canny(Image, CannyImg, 140, 250, 3);
    imshow("CannyImg", CannyImg);
    
    Mat DstImg;
    cvtColor(Image, DstImg, CV_GRAY2BGR);
    
    vector<Vec4i> Lines;
    HoughLinesP(CannyImg, Lines, 1, CV_PI / 360, 170,30,15);
    for (size_t i = 0; i < Lines.size(); i++)
    {
        line(DstImg, cv::Point(Lines[i][0], Lines[i][1]), cv::Point(Lines[i][2], Lines[i][3]), cv::Scalar(0, 0, 255), 2, 8);
    }
    imshow("HoughLines_Detect", DstImg);
    imwrite("./res/HoughLines_Detect.jpg", DstImg);
    waitKey(0);
    return 0;
}

