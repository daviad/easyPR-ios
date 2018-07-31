//
//  DescImg.h
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DisplayImg : NSObject
@property(nonatomic,strong)UIImage *img;
@property(nonatomic,strong)NSString *desc;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@end
