//
//  ann_train.hpp
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/22.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#ifndef ann_train_hpp
#define ann_train_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>
namespace easypr {
    class AnnTrain {
    public:
        AnnTrain(const char* chars_folder, const char* xml);
        void train();
        void test();
        
    private:
        cv::Ptr<cv::ml::ANN_MLP> ann_;
        const char* ann_xml_;
        const char* chars_folder_;
        int type;
        
        cv::Ptr<cv::ml::TrainData> sdata(size_t number_for_count);
    };
}
#endif /* ann_train_hpp */
