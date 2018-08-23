//
//  feature.hpp
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/23.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#ifndef feature_hpp
#define feature_hpp

#include "opencv2/opencv.hpp"
namespace easypr {
    //! get character feature
    cv::Mat charFeatures(cv::Mat in, int sizeData);
    cv::Mat charFeatures2(cv::Mat in, int sizeData);
}
#endif /* feature_hpp */
