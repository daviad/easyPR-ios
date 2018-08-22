//
//  ann_train.cpp
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/22.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#include "ann_train.hpp"
#include "config.h"

namespace easypr {
    AnnTrain::AnnTrain(const char* chars_folder, const char* xml)
    : chars_folder_(chars_folder), ann_xml_(xml) {
        ann_ = cv::ml::ANN_MLP::create();
    }
    
    void AnnTrain::train(){
        int classNumber = 0;
        cv::Mat layers;
        int input_number = 0;
        int hidden_number = 0;
        int output_number = 0;
        
//        cv::Mat layerSizess=(cv::Mat_<int>(1,3)<<x1,x2,x3);
        
        if (0 == type) {
            classNumber = kCharsTotalNumber;
            input_number = kAnnInput;
            hidden_number = kNeurons;
            output_number = classNumber;
        } else if (1 == type) {
            classNumber = kChineseNumber;
            input_number = kAnnInput;
            hidden_number = kNeurons;
            output_number = classNumber;
        }
        
        layers.create(1, 3, CV_32SC1);
        layers.at<int>(0) = input_number;
        layers.at<int>(1) = hidden_number;
        layers.at<int>(2) = output_number;
        
        ann_->setLayerSizes(layers);
        ann_->setActivationFunction(cv::ml::ANN_MLP::SIGMOID_SYM,1,1);
        ann_->setTrainMethod(cv::ml::ANN_MLP::TrainingMethods::BACKPROP);
        ann_->setTermCriteria(cvTermCriteria(CV_TERMCRIT_ITER, 30000, 0.0001));
        ann_->setBackpropWeightScale(0.1);
        ann_->setBackpropMomentumScale(0.1);
        
        cv::Ptr<cv::ml::TrainData> traindata;
        ann_->train(traindata);
        ann_->save(ann_xml_);
    }
    
    cv::Ptr<cv::ml::TrainData> AnnTrain::sdata(size_t number_for_count){
        assert(chars_folder_);
        
        cv::Mat samples;
        std::vector<int> labels;
        
        int classNumber = 0;
        if (type == 0) classNumber = kCharsTotalNumber;
        if (type == 1) classNumber = kChineseNumber;
        
        srand((unsigned)time(0));
        for (int i = 0; i < classNumber; ++i) {
            auto char_key = kChars[i + kCharsTotalNumber - classNumber];
            char sub_folder[512] = {0};
            sprintf(sub_folder, "%s/%s",chars_folder_,char_key);
            fprintf(stdout, ">> Testing characters %s in %s \n", char_key, sub_folder);
            
            
        }
        cv::Ptr<cv::ml::TrainData> aa;
        return aa;
    }
}
