//
//  ann_train.cpp
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/22.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#include "ann_train.hpp"
#include "config.h"
#include "util.h"
#include "core_func.h"
#include "feature.hpp"

namespace easypr {
    AnnTrain::AnnTrain(const char* chars_folder, const char* xml)
    : chars_folder_(chars_folder), ann_xml_(xml) {
        ann_ = cv::ml::ANN_MLP::create();
        type = 0;
        kv_ = std::shared_ptr<Kv>(new Kv);
        kv_->load("/Users/dxw/Desktop/github/MLDemo/easyPR-ios/EasyPR-iOS-master/etc/province_mapping");
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
        
        cv::Ptr<cv::ml::TrainData> traindata = sdata(350);
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
            
            auto chars_files = Utils::getFiles(sub_folder);
//            size_t char_size = chars_files.size();
            
            std::vector<cv::Mat> matVec;
            matVec.reserve(number_for_count);
            for (auto file : chars_files) {
                auto img = cv::imread(file,0);
                matVec.push_back(img);
            }
            
            for (auto img : matVec) {
                auto fps = charFeatures2(img, kPredictSize);
                
                samples.push_back(fps);
                labels.push_back(i);
            }
        }
        
        cv::Mat samples_;
        samples.convertTo(samples_, CV_32F);
        cv::Mat train_classes = cv::Mat::zeros((int)labels.size(),classNumber, CV_32F);
        
        for (int i = 0; i < train_classes.rows; ++i) {
            train_classes.at<float>(i,labels[i]) = 1.f;
        }
        return cv::ml::TrainData::create(samples_, cv::ml::SampleTypes::ROW_SAMPLE,
                                         train_classes);;
    }
    
    void AnnTrain::test(std::string path){
        
        ann_ = ml::ANN_MLP::load<ml::ANN_MLP>(ann_xml_);
        
       int classNumber = 0;
       if (type == 0) classNumber = kCharsTotalNumber;
       if (type == 1) classNumber = kChineseNumber;
       
       auto img = cv::imread(path,0);
        identify(img);
    }
    std::pair<std::string, std::string> AnnTrain::identify(cv::Mat input) {
        cv::Mat feature = charFeatures2(input, kPredictSize);
        
        float maxVal = -2;
        int result = 0;
        
        cv::Mat output(1,kCharsTotalNumber, CV_32FC1);
        ann_->predict(feature.clone(), output);
        for (int j = 0; j < kCharsTotalNumber; j++) {
            float val = output.at<float>(j);
            if (val > maxVal) {
                maxVal = val;
                result = j;
            }
        }
        
        auto index = result;
        if (index < kCharactersNumber) {
            return std::make_pair(kChars[index], kChars[index]);
        } else {
            const char* key = kChars[index];
            std::string s = key;
//            std::cout << s << std::endl;
            std::string province = kv_->get(s);
            return std::make_pair(s, province);
        }
    }
    
    std::string AnnTrain::predict(cv::Mat img) {
        ann_ = ml::ANN_MLP::load<ml::ANN_MLP>(ann_xml_);
        int classNumber = 0;
        if (type == 0) classNumber = kCharsTotalNumber;
        if (type == 1) classNumber = kChineseNumber;
        
        std::pair<std::string, std::string> p =identify(img);
        return p.second;
    }
}
