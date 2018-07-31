//
//  DebugController.h
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import <UIKit/UIKit.h>

@interface DebugController : UIViewController
- (instancetype)initWith:(cv::Mat)sorceImage;
@end
