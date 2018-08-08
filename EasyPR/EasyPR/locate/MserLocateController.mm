//
//  MserLocateController.m
//  EasyPR
//
//  Created by 丁秀伟 on 2018/8/8.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//
#import <opencv2/opencv.hpp>

#import "MserLocateController.h"

using namespace cv;
using namespace std;

@implementation MserLocateController
- (void)handleImage:(cv::Mat)srcImagge
{
    // HSV空间转换
    Mat gray,gray_neg;
    Mat hsv;
    cvtColor(srcImagge, hsv, CV_RGB2HSV);
    //    // 通道分离
    //    vector<Mat> channels;
    //    cv::split(hsv, channels);
    //    // 提取h通道
    //    gray = channels[0];
    // 灰度转换
    cvtColor(srcImagge, gray, CV_RGB2GRAY);
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:gray]];
    
    // 取反值灰度
    gray_neg = 255 - gray;
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:gray_neg]];
    
    vector<vector<cv::Point>> regContours;
    vector<vector<cv::Point>> charContours;
    // 创建MSER对象
    //2表示灰度值的变化量，10和5000表示检测到的组块面积的范围，0.5为最大的变化率，0.3为稳定区域的最小变换量
    cv::Ptr<cv::MSER> mser1 = cv::MSER::create(2,10,5000,0.5,0.3);
    cv::Ptr<cv::MSER> mser2 = cv::MSER::create(2,2,400,0.1,0.3);
    
    vector<cv::Rect> bboxes1;
    vector<cv::Rect> bboxes2;
    
    // MSER+ 检测
    mser1->detectRegions(gray, regContours, bboxes1);
    // MSER-操作
    mser2->detectRegions(gray_neg, charContours, bboxes2);
    
    Mat mserMapMat = cv::Mat::zeros(srcImagge.size(), CV_8UC1);
    Mat mserNegMapMat = cv::Mat::zeros(srcImagge.size(), CV_8UC1);
    // MSER+ 检测
    for (int i = (int)regContours.size() - 1; i >= 0; i--) {
        //// 根据检测区域点生成mser+结果
        const std::vector<cv::Point>& r = regContours[i];
        for (int j = 0; j<(int)r.size(); j++) {
            cv::Point pt = r[j];
            mserMapMat.at<unsigned char>(pt) = 255;
        }
    }
    // MSER- 检测
    for (int i = (int)charContours.size() - 1; i >= 0; i--) {
        // 根据检测区域点生成mser-结果
        const std::vector<cv::Point>& r = charContours[i];
        for (int j = 0; j < (int)r.size(); j++) {
            cv::Point pt = r[j];
            mserNegMapMat.at<unsigned char>(pt) = 255;
        }
    }
    
    // mser结果输出
    cv::Mat mserResMat;
    // mser+与mser-位与操作
    mserResMat = mserMapMat & mserNegMapMat;
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:mserMapMat]];
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:mserNegMapMat]];
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:mserResMat]];
    // 闭操作连接缝隙
    cv::Mat mserClosedMat;
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(17,8));
    cv::morphologyEx(mserResMat, mserClosedMat,
                     cv::MORPH_CLOSE, element/*cv::Mat::ones(1, 20, CV_8UC1)*/);
    
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:mserClosedMat]];
    
    // 寻找外部轮廓
    std::vector<std::vector<cv::Point> > plate_contours;
    cv::findContours(mserClosedMat, plate_contours,CV_RETR_EXTERNAL,CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    // 候选车牌区域判断输出
    std::vector<cv::Rect> candidates;
    for (size_t i = 0; i != plate_contours.size(); ++i)
    {
        // 求解最小外界矩形
        cv::Rect rect = cv::boundingRect(plate_contours[i]);
        // 宽高比例
        double wh_ratio = rect.width / double(rect.height);
        // 不符合尺寸条件判断
        if (rect.height > 20 && wh_ratio > 4 && wh_ratio < 7)
            candidates.push_back(rect);
    }
    drawContours(srcImagge, plate_contours, -1, Scalar(255, 0, 0));
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:srcImagge]];
    for (int i = 0; i < candidates.size(); ++i)
    {
        cv::rectangle(srcImagge, candidates[i], Scalar(0,255,0));
        [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:srcImagge]];
        [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:srcImagge(candidates[i])]];
    }
}
@end
