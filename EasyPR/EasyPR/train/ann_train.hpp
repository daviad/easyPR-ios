//
//  ann_train.hpp
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/22.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#ifndef ann_train_hpp
#define ann_train_hpp
#include <opencv2/opencv.hpp>

#include <stdio.h>
#include "kv.h"
namespace easypr {
    class AnnTrain {
    public:
        AnnTrain(const char* chars_folder, const char* xml);
        void train();
        void test(std::string path);
        std::string predict(cv::Mat img);
        std::shared_ptr<Kv> kv_;

    private:
        cv::Ptr<cv::ml::ANN_MLP> ann_;
        const char* ann_xml_;
        const char* chars_folder_;
        int type;
        
        cv::Ptr<cv::ml::TrainData> sdata(size_t number_for_count);
        std::pair<std::string, std::string> identify(cv::Mat input);
    };
}
#endif /* ann_train_hpp */
