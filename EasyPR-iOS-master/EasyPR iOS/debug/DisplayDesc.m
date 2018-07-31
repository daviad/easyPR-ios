//
//  DisplayDesc.m
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//

#import "DisplayDesc.h"

@implementation DisplayDesc
- (instancetype)init {
    if (self = [super init]) {
        self.layout = [[DisplayCellLayout alloc] init];
    }
    return self;
}
@end
