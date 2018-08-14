//
//  MserLocateController.m
//  EasyPR
//
//  Created by 丁秀伟 on 2018/8/8.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//
#import <opencv2/opencv.hpp>

#import "MserLocateController.h"

#import "lbp.hpp"

using namespace cv;
using namespace std;

@implementation MserLocateController

//图像剪切
//参数：src为源图像， dst为结果图像, rect为剪切区域
//返回值：返回0表示成功，否则返回错误代码
int imageCrop(InputArray src, OutputArray dst, cv::Rect rect)
{
    Mat input = src.getMat();
    if( input.empty() ) {
        return -1;
    }
    
    //计算剪切区域：  剪切Rect与源图像所在Rect的交集
    cv::Rect srcRect(0, 0, input.cols, input.rows);
    rect = rect & srcRect;
    if ( rect.width <= 0  || rect.height <= 0 ) return -2;
    
    //创建结果图像
    dst.create(cv::Size(rect.width, rect.height), src.type());
    Mat output = dst.getMat();
    if ( output.empty() ) return -1;
    
    try {
        //复制源图像的剪切区域 到结果图像
        input(rect).copyTo( output );
        return 0;
    } catch (...) {
        return -3;
    }
}

- (void)handleImage:(cv::Mat)srcImagge
{
    Mat rgbImage = srcImagge.clone();
    // HSV空间转换
    Mat gray,gray_neg;
    Mat hsv;
//    cvtColor(srcImagge, hsv, CV_RGB2HSV);
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
//        RotatedRect mr = minAreaRect(plate_contours[i]);
//        mr.boundingRect();
        cv::Rect rect = cv::boundingRect(plate_contours[i]);
        // 宽高比例
        double wh_ratio = rect.width / double(rect.height);
        // 不符合尺寸条件判断
        if (rect.height > 20 && wh_ratio > 3 && wh_ratio < 7)
            candidates.push_back(rect);
    
    }
    drawContours(srcImagge, plate_contours, -1, Scalar(255, 0, 0));
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:srcImagge]];
    
    vector<Mat> plates;
    
    for (int i = 0; i < candidates.size(); ++i)
    {
        cv::rectangle(srcImagge, candidates[i], Scalar(0,255,0));
        cv::Mat roi ;
        int r = imageCrop(rgbImage, roi, candidates[i]);
        if (0 == r) {
            int recod = (int)[self svmpredict:roi];
            if (recod == -1) {
                plates.push_back(roi);
            }
        }
        [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:roi]];
    }
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:srcImagge]];

    for (int i = 0; i< plates.size();i++) {
        [self chars:plates[i]];
    }
}

//! LBP feature
void getLBPFeatures(const Mat& image, Mat& features) {
    
    Mat grayImage;
    cvtColor(image, grayImage, CV_RGB2GRAY);
    
    //if (1) {
    //  imshow("grayImage", grayImage);
    //  waitKey(0);
    //  destroyWindow("grayImage");
    //}
    
//    spatial_ostu(grayImage, 8, 2);
    
    //if (1) {
    //  imshow("grayImage", grayImage);
    //  waitKey(0);
    //  destroyWindow("grayImage");
    //}
    
    Mat lbpimage;
    lbpimage = libfacerec::olbp(grayImage);
    Mat lbp_hist = libfacerec::spatial_histogram(lbpimage, 32, 4, 4);
//
    features = lbp_hist;
}

- (CGFloat)svmpredict:(Mat)plate {
    cv::Ptr<ml::SVM> svm_;
    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"model/svm" ofType:@"xml"];
    string path=[nsstring UTF8String];
    svm_ = ml::SVM::load<ml::SVM>(path);
    Mat features;
    getLBPFeatures(plate, features);
    float score = svm_->predict(features, noArray(), cv::ml::StatModel::Flags::RAW_OUTPUT);
    printf("score:%f \n",score);
    return score;
}

//chars

- (void)chars:(cv::Mat)plate {
    Mat grayPlate;
    cv::cvtColor(plate, grayPlate, CV_RGB2GRAY);
    cv::threshold(grayPlate, grayPlate, 0, 255, CV_THRESH_BINARY + CV_THRESH_OTSU);
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:grayPlate]];
    Mat roi = [self horizontalProjectionMat:grayPlate];
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:roi]];
    
//    垂直投影
//    https://blog.csdn.net/u011574296/article/details/70139563
}
//https://blog.csdn.net/m0_38025293/article/details/70182513
//https://blog.csdn.net/lichengyu/article/details/21888609
- (cv::Mat)horizontalProjectionMat:(Mat)binImg {
//    blur(srcImg, binImg, cv::Size(3, 3));
    int perPixelValue = 0;//每个像素的值
    int width = binImg.cols;
    int height = binImg.rows;
    int *projectValArry = new int[height];//创建一个储存每行白色像素个数的数组
    memset(projectValArry, 0, height*4);
    for (int col = 0; col < height; col++) { //遍历每个像素点
        for (int row = 0; row < width; row++) {
            perPixelValue = binImg.at<uchar>(col,row);
            if (perPixelValue == 255) {
                projectValArry[col]++;
            }
        }
    }
    
    Mat horizontalProjectionMat(height,width,CV_8UC1);//创建画布
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            perPixelValue = 255;
            horizontalProjectionMat.at<uchar>(i,j) = perPixelValue;//设置背景为白色
        }
    }
    
    for (int i = 0; i < height; i++) {//水平直方图
        for (int j = 0; j < projectValArry[i]; j++) {
            perPixelValue = 0;
            horizontalProjectionMat.at<uchar>(i,j) = perPixelValue;//设置直方图为黑色
        }
    }
    Mat tmp = horizontalProjectionMat;
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:tmp]];

    vector<Mat> roiList;//用于储存分割出来的每个字符
    //记录进入字符区的索引
    int startIndex = 0;
    //记录进入空白区域的索引
    int endIndex = 0;
    //是否遍历到了字符区内
    bool inBlock = false;
    for (int i = 0; i <binImg.rows; i++)
    {
        if (!inBlock && projectValArry[i] >  10)//进入字符区
        {
            inBlock = true;
            startIndex = i;
        }
        else if (inBlock && projectValArry[i] < 10)//进入空白区
        {
            endIndex = i;
            inBlock = false;
            Mat roiImg = binImg(Range(startIndex, endIndex + 1), Range(0, binImg.cols));//从原图中截取有图像的区域
            roiList.push_back(roiImg);
        }
    }
    delete[] projectValArry;
    return roiList.front();
}


//vector<Mat> verticalProjectionMat(Mat srcImg)//垂直投影
//{
//    Mat binImg;
//    blur(srcImg, binImg, Size(3, 3));
//    threshold(binImg, binImg, 0, 255, CV_THRESH_OTSU);
//    int perPixelValue;//每个像素的值
//    int width = srcImg.cols;
//    int height = srcImg.rows;
//    int* projectValArry = new int[width];//创建用于储存每列白色像素个数的数组
//    memset(projectValArry, 0, width * 4);//初始化数组
//    for (int col = 0; col < width; col++)
//    {
//        for (int row = 0; row < height;row++)
//        {
//            perPixelValue = binImg.at<uchar>(row, col);
//            if (perPixelValue == 0)//如果是白底黑字
//            {
//                projectValArry[col]++;
//            }
//        }
//    }
//    Mat verticalProjectionMat(height, width, CV_8UC1);//垂直投影的画布
//    for (int i = 0; i < height; i++)
//    {
//        for (int j = 0; j < width; j++)
//        {
//            perPixelValue = 255;  //背景设置为白色
//            verticalProjectionMat.at<uchar>(i, j) = perPixelValue;
//        }
//    }
//    for (int i = 0; i < width; i++)//垂直投影直方图
//    {
//        for (int j = 0; j < projectValArry[i]; j++)
//        {
//            perPixelValue = 0;  //直方图设置为黑色
//            verticalProjectionMat.at<uchar>(height - 1 - j, i) = perPixelValue;
//        }
//    }
//    imshow("垂直投影",verticalProjectionMat);
//    cvWaitKey(0);
//    vector<Mat> roiList;//用于储存分割出来的每个字符
//    int startIndex = 0;//记录进入字符区的索引
//    int endIndex = 0;//记录进入空白区域的索引
//    bool inBlock = false;//是否遍历到了字符区内
//    for (int i = 0; i < srcImg.cols; i++)//cols=width
//    {
//        if (!inBlock && projectValArry[i] != 0)//进入字符区
//        {
//            inBlock = true;
//            startIndex = i;
//        }
//        else if (projectValArry[i] == 0 && inBlock)//进入空白区
//        {
//            endIndex = i;
//            inBlock = false;
//            Mat roiImg = srcImg(Range(0, srcImg.rows), Range(startIndex, endIndex + 1));
//            roiList.push_back(roiImg);
//        }
//    }
//    delete[] projectValArry;
//    return roiList;
//}
//int main(int argc, char* argv[])
//{
//    Mat srcImg = imread("E:\\b.png", 0);//读入原图像
//    char szName[30] = { 0 };
//    vector<Mat> b = verticalProjectionMat(srcImg);//先进行垂直投影
//    for (int i = 0; i < b.size(); i++)
//    {
//        vector<Mat> a = horizontalProjectionMat(b[i]);//水平投影
//        sprintf(szName,"E:\\picture\\%d.jpg",i);
//        for (int j = 0; j < a.size(); j++)
//        {
//            imshow(szName,a[j]);
//            IplImage img = IplImage(a[j]);
//            cvSaveImage(szName, &img);//保存切分的结果
//        }
//    }
//    /*
//     vector<Mat> a = horizontalProjectionMat(srcImg);
//     char szName[30] = { 0 };
//     for (int i = 0; i < a.size(); i++)
//     {
//     vector<Mat> b = verticalProjectionMat(a[i]);
//     for (int j = 0; j<b.size();j++)
//     {
//     sprintf(szName, "E:\\%d.jpg", j);
//     imshow(szName, b[j]);
//     }
//     }
//     */
//    cvWaitKey(0);
//    getchar();
//    return 0;
//}



@end
