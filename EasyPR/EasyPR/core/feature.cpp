//
//  feature.cpp
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/23.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#include "feature.hpp"
#import <opencv2/opencv.hpp>
#import "core_func.h"

namespace easypr {
    cv::Mat getHistogram(cv::Mat in) {
        const int VERTICAL = 0;
        const int HORIZONTAL = 1;
        
        // Histogram features
        cv::Mat vhist = ProjectedHistogram(in, VERTICAL);
        cv::Mat hhist = ProjectedHistogram(in, HORIZONTAL);
        
        // Last 10 is the number of moments components
        int numCols = vhist.cols + hhist.cols;
        
        Mat out = Mat::zeros(1, numCols, CV_32F);
        
        int j = 0;
        for (int i = 0; i < vhist.cols; i++) {
            out.at<float>(j) = vhist.at<float>(i);
            j++;
        }
        for (int i = 0; i < hhist.cols; i++) {
            out.at<float>(j) = hhist.at<float>(i);
            j++;
        }
        
        return out;
    }
    void getHistogramFeatures(const Mat& image, Mat& features) {
        Mat grayImage;
        cvtColor(image, grayImage, CV_RGB2GRAY);
        
        //grayImage = histeq(grayImage);
        
        Mat img_threshold;
        threshold(grayImage, img_threshold, 0, 255, CV_THRESH_OTSU + CV_THRESH_BINARY);
        //Mat img_threshold = grayImage.clone();
        //spatial_ostu(img_threshold, 8, 2, getPlateType(image, false));
        
        features = getHistogram(img_threshold);
    }
    
    
    Mat charFeatures2(Mat in, int sizeData) {
        const int VERTICAL = 0;
        const int HORIZONTAL = 1;
        
        // cut the cetner, will afect 5% perices.
        Rect _rect = GetCenterRect(in);
        Mat tmpIn = CutTheRect(in, _rect);
        //Mat tmpIn = in.clone();
        
        // Low data feature
        Mat lowData;
        resize(tmpIn, lowData, Size(sizeData, sizeData));
        
        // Histogram features
        Mat vhist = ProjectedHistogram(lowData, VERTICAL);
        Mat hhist = ProjectedHistogram(lowData, HORIZONTAL);
        
        // Last 10 is the number of moments components
        int numCols = vhist.cols + hhist.cols + lowData.cols * lowData.cols;
        
        Mat out = Mat::zeros(1, numCols, CV_32F);
        
        int j = 0;
        for (int i = 0; i < vhist.cols; i++) {
            out.at<float>(j) = vhist.at<float>(i);
            j++;
        }
        for (int i = 0; i < hhist.cols; i++) {
            out.at<float>(j) = hhist.at<float>(i);
            j++;
        }
        for (int x = 0; x < lowData.cols; x++) {
            for (int y = 0; y < lowData.rows; y++) {
                out.at<float>(j) += (float)lowData.at <unsigned char>(x, y);
                j++;
            }
        }
        
        //std::cout << out << std::endl;
        
        return out;
    }
}
