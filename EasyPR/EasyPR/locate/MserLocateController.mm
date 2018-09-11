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
#import "ann_train.hpp"

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

- (void)xx {
    Mat c = Mat::zeros(3, 5, CV_8UC1);
    Mat d = Mat::ones(3, 3, CV_8UC1);
    
//    //对a的第一列进行赋值
//    a.col(0) = c.col(0);
//    //将c的1-5列赋值给a
    d.copyTo(c.colRange(1, 4));
//    c.colRange(1, 4) = d;
       cout<<d<<endl;
//    c.col(0) = 1;
    cout<<c<<endl;
    Mat dst(1,5,CV_8UC1,cv::Scalar(0));
    cout<<"dist"<<dst<<endl;
    reduce(c, dst, 0, CV_REDUCE_SUM,CV_32S);
    cout << dst<<endl;
    
    double a[5][4] =
    {
        { 4, 0, 2, 5 },
        { 1, 1, 0, 7 },
        { 0, 5, 2, 0 },
        { 0, 3, 4, 0 },
        { 8, 0, 1, 2 }
    };
    Mat ma(5, 4, CV_64FC1, a);
    Mat mb(5, 1, CV_64FC1, Scalar(0));
    Mat mc(1, 4, CV_64FC1, Scalar(0));
    
    cout << "原矩阵：" << endl;
    cout << ma << endl;
    
    reduce(ma, mb, 1, CV_REDUCE_SUM);
    cout << "列向量" << endl;
    cout << mb << endl;
    
    reduce(ma, mc, 0, CV_REDUCE_SUM);
    cout << "行向量" << endl;
    cout << mc << endl;
    
    
}

- (void)handleImage:(cv::Mat)srcImagge
{
//    [self xx];
//    return;
    
//    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"plate" ofType:@"jpg"];
//    string image_path=[nsstring UTF8String];
//    Mat plate = imread(image_path, IMREAD_UNCHANGED);
////    cvtColor(plate, plate, CV_BGR2RGB);
//    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:plate]];
////    cv::Rect roiRect(0,0,17,28);
////    Mat(plate,roiRect).clone()
//    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:plate.colRange(1, 17).clone()]];

//    return;
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
    
    roi = [self clearNoisePoint:roi];
    cv::resize(roi, roi, cv::Size(136,(136.8*28.0)/141.0));
//    垂直投影
    vector<Mat> roiList = [self verticalProjectionMat:roi];
    for (int i = 0;i < roiList.size();i++) {
        Mat c = roiList[i];
        [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:c]];
    }
    vector<Mat> normalizeList;
    for (int i = 0;i < roiList.size();i++) {
        Mat c = roiList[i];
        Mat c1 = cv::Mat(c.rows, c.rows, CV_8UC1,cv::Scalar(0));
        int cap = (c.rows - c.cols)/2;
        c.copyTo(c1.colRange(cap,cap+c.cols));
        normalizeList.push_back(c1);
        cv::resize(c1, c1, cv::Size(20,20));
        [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:c1]];
    }
    
//    vector<Mat> testList;
//    testList.push_back(imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/0/15-3.jpg",0));
//     testList.push_back(imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/7/13-3.jpg",0));
//     testList.push_back(imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/B/48-7.jpg",0));
//     testList.push_back(imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/A/35-5.jpg",0));
//     testList.push_back(imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/A/45-6.jpg",0));
//     testList.push_back(imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/zh_su/20-0-3.jpg",0));
//    testList.push_back(imread("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann/zh_shan/debug_chineseMat467.jpg",0));
    [self annCharRecongnise:normalizeList];
}

- (cv::Mat)clearNoisePoint:(cv::Mat)plate {
    int cols = plate.cols;
    for (int col = 0 ; col < cols; col++) {
       Mat tmp = plate.col(col);
        int c =  cv::countNonZero(tmp);
//        cout << "tmp " << col << ":" << tmp << "count"<< c <<endl;
        if (c < 5) {
            plate.col(col) = 0;
        }
    }
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:plate]];
    return plate;
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
            roiList.push_back(roiImg.clone());
        }
    }
    delete[] projectValArry;
    return roiList.front();
}

-(vector<Mat>)verticalProjectionMat:(Mat)binImg {
    int perPixelValue;//每个像素的值
    int width = binImg.cols;
    int height = binImg.rows;
    int* projectValArry = new int[width];//创建用于储存每列白色像素个数的数组
    memset(projectValArry, 0, width * 4);//初始化数组
    for (int col = 0; col < width; col++)
    {
        for (int row = 0; row < height;row++)
        {
            perPixelValue = binImg.at<uchar>(row, col);
            if (perPixelValue == 255)//如果是黑底白字
            {
                projectValArry[col]++;
            }
        }
    }
    Mat verticalProjectionMat(height, width, CV_8UC1,cv::Scalar(255));//垂直投影的画布
    
    for (int i = 0; i < width; i++)//垂直投影直方图
    {
        for (int j = 0; j < projectValArry[i]; j++)
        {
            perPixelValue = 0;  //直方图设置为黑色
            verticalProjectionMat.at<uchar>(height - 1 - j, i) = perPixelValue;
        }
    }
    [self.imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:verticalProjectionMat]];
    
    vector<Mat> roiList;//用于储存分割出来的每个字符
    int startIndex = 0;//记录进入字符区的索引
    int endIndex = 0;//记录进入空白区域的索引
    bool inBlock = false;//是否遍历到了字符区内
    for (int i = 0; i < binImg.cols; i++)//cols=width
    {
        if (!inBlock && projectValArry[i] != 0)//进入字符区
        {
            inBlock = true;
            startIndex = i;
        }
        else if (projectValArry[i] == 0 && inBlock)//进入空白区
        {
            endIndex = i;
            inBlock = false;
            Mat roiImg = binImg(Range(0, binImg.rows), Range(startIndex, endIndex + 1));
            roiList.push_back(roiImg.clone());
        }
    }
    
//    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//    UIImage *plateImg = [UIImageCVMatConverter UIImageFromCVMat:binImg];
//    [UIImagePNGRepresentation(plateImg) writeToFile:[documentPath stringByAppendingPathComponent:@"plate.png"] atomically:YES];
//    [UIImageJPEGRepresentation(plateImg, 1) writeToFile:[documentPath stringByAppendingPathComponent:@"plate.jpg"] atomically:YES];
    
    delete[] projectValArry;
    return roiList;
}


- (void)annCharRecongnise:(vector<Mat>)chars {

//    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"model/ann" ofType:@"xml"];
//    string path=[nsstring UTF8String];
    easypr::AnnTrain train = easypr::AnnTrain("/Users/dingxiuwei/Desktop/git/easyPR-ios/EasyPR-iOS-master/resources/train/ann","/Users/dingxiuwei/Desktop/git/easyPR-ios/EasyPR-iOS-master/resources/train/ann1.xml");
//     easypr::AnnTrain train = easypr::AnnTrain("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/train/ann","/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/resources/model/ann.xml");
    
    for (int i = 0; i < chars.size(); i++) {
       auto img = chars[i];
        

       std::string ch = train.predict(img);
        cout << ch << endl;
    }
    
//    vector<Mat> cl;
//    cl.push_back(cv::imread("/Users/dxw/Desktop/YUV/1.png",0));
//    cl.push_back(cv::imread("/Users/dxw/Desktop/YUV/2.png",0));
//    cl.push_back(cv::imread("/Users/dxw/Desktop/YUV/3.jpg",0));
//    cl.push_back(cv::imread("/Users/dxw/Desktop/YUV/4.jpg",0));
//    cl.push_back(cv::imread("/Users/dxw/Desktop/YUV/5.jpg",0));
//        for (int i = 0; i < cl.size(); i++) {
//           auto img = cl[i];
//            cv::resize(img, img, cv::Size(20,20));
//
//           std::string ch = train.predict(img);
//            cout << ch << endl;
//        }
}


@end
