//
//  ActionItem.m
//  EasyPR
//
//  Created by 丁秀伟 on 2018/8/8.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#import "ActionItem.h"

@implementation ActionItem
- (instancetype)initWithClickBlk:(void (^)(void))blk {
    if (self = [super init]) {
        self.action = blk;
    }
    return self;
}
- (instancetype)initWithText:(NSString*)text withClass:(Class)cls {
    if (self = [super init]) {
        self.text = text;
        self.cls = cls;
    }
    return self;
}
@end
