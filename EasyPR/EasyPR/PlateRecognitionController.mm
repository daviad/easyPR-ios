//
//  PlateRecognitionController.m
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/7.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//
#import <opencv2/opencv.hpp>

#import "PlateRecognitionController.h"
#import "UIImageCVMatConverter.h"
#import "ShowController.h"

using namespace cv;
using namespace std;

@interface PlateRecognitionController ()

@end

@implementation PlateRecognitionController

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
//    image = img.clone();
    //img.copyTo(image);
    
    Mat resizedImg = orginImg;
//    resize(orginImg, resizedImg, cv::Size(self.view.frame.size.width,self.view.frame.size.width / ratiowh));
    Mat originRGB;
    cvtColor(resizedImg, originRGB, CV_BGR2RGB);
    [imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:originRGB]];
    Mat grayImg = colorMat(originRGB);
    [imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:grayImg]];
    
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(17,8));
    Mat morphImag;
    morphologyEx(grayImg, morphImag, MORPH_CLOSE, element);
    [imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:morphImag]];

    vector<vector<cv::Point>> contours;
    findContours(morphImag, contours,CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    drawContours(originRGB, contours, -1, Scalar(255, 0, 0));
    [imgs addObject:[UIImageCVMatConverter UIImageFromCVMat:originRGB]];

    vector<vector<cv::Point>>::iterator itc = contours.begin();
    while (itc != contours.end()) {
//        RotatedRect mr = minAreaRect(Mat(*itc));
       cv::Rect xx =  cv::boundingRect(Mat(*itc));
        itc ++;
    }
    
    [showCtr loadImages:imgs];
}


void colorReduce(Mat& image, int div)
{
     cout << "R (default) = " << endl <<       image          << endl << endl;
    for(int i=0;i<image.rows;i++)
    {
        for(int j=0;j<image.cols;j++)
        {
//            NSLog(@"(%d,%d):%d,%d,%d",i,j,image.at<Vec3b>(i,j)[1],image.at<Vec3b>(i,j)[0],image.at<Vec3b>(i,j)[2]);
//            image.at<Vec3b>(i,j)[0]=image.at<Vec3b>(i,j)[0]/div*div+div/2;
//            image.at<Vec3b>(i,j)[1]=image.at<Vec3b>(i,j)[1]/div*div+div/2;
//            image.at<Vec3b>(i,j)[2]=image.at<Vec3b>(i,j)[2]/div*div+div/2;
            
        }
    }
}

Mat colorMat(const Mat& srcRGB) {
    //hsv:蓝色: H:200~280 s,v:0.35~1
    //hsv:黄色: H:30~80   s,v:0,35~1
//opencv为了保证HSV三个分量都落在0-255之间（确保一个char能装的下），对H分量除以了2，也就是0-180的范围，S和V分量乘以了 255，将0-1的范围扩展到0-255。我们在设置阈值的时候需要参照opencv的标准，因此对参数要进行一个转换。

    const int min_blue = 100;
    const int max_blue = 140;
    const float max_sv = 255;
    const float minabs_sv = 95;

    Mat imgHsv;
    cvtColor(srcRGB, imgHsv, CV_RGB2HSV);
    GaussianBlur(imgHsv, imgHsv, cv::Size(5,5), 3);
    Mat greyImg;
    inRange(imgHsv, Scalar(min_blue,minabs_sv,minabs_sv), Scalar(max_blue,max_sv,max_sv), greyImg);
    return greyImg;
    
//    vector<Mat> hsvSplit;
//    split(imgHsv, hsvSplit);
//    equalizeHist(hsvSplit[2], hsvSplit[2]);
//    merge(hsvSplit, imgHsv);
    
//    int min_h = 0, max_h = 1;
//    min_h = min_blue;
//    max_h = max_blue;
    
//    float diff_h = float((max_h - min_h) / 2);
//    int avg_h = min_h + diff_h;
    
//    int channels = imgHsv.channels();
//    int nRows = imgHsv.rows;
//    int nCols = imgHsv.cols * channels;
//
//    if (imgHsv.isContinuous()) {
//        nCols *= nRows;
//        nRows = 1;
//    }
//
//    int i,j;
//    uchar* p;
//    float s_all = 0;
//    float v_all = 0;
//    float count = 0;
//    for (i = 0; i < nRows; ++i) {
//        p = imgHsv.ptr<uchar>(i);
//        for (j = 0; j < nCols; j += 3) {
//            int H = int(p[j]); // 0-180
//            int S = int(p[j + 1]);//0-255
//            int V = int(p[j + 2]);//0-255
//
//            s_all += S;
//            v_all += V;
//            count++;
//
//            bool colorMatched = false;
//
//            if (H > min_h && H < max_h) {
////                int Hdiff = 0;
////                if (H > avg_h) {
////                    Hdiff = H - avg_h;
////                } else {
////                    Hdiff = avg_h - H;
////                }
////
////                float Hdiff_p = float(Hdiff)/diff_h;
//
//                float min_sv = minabs_sv;
//                if ((S > min_sv && S < max_sv) && (V > min_sv && V < max_sv)) {
//                    colorMatched = true;
//                }
//
//                if (true == colorMatched) {
//                    p[j] = 0;
//                    p[j + 1] = 0;
//                    p[j + 2] = 255;
//                } else {
//                    p[j] = 0;
//                    p[j + 1] = 0;
//                    p[j + 2] = 0;
//                }
//            }
//        }
//    }
    
//    Mat img_grey;
//    vector<Mat> hsvSplitDone;
//    split(imgHsv, hsvSplitDone);
//    img_grey = hsvSplitDone[2];
//    return img_grey;
    
//    return imgHsv;
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
