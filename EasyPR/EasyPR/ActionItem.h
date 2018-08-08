//
//  ActionItem.h
//  EasyPR
//
//  Created by 丁秀伟 on 2018/8/8.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionItem : NSObject
@property(nonatomic,copy) NSString* text;
@property(nonatomic,strong) Class cls;
@property(nonatomic,copy) void(^action)(void);
- (instancetype)initWithClickBlk:(void (^)(void))blk;
- (instancetype)initWithText:(NSString*)text withClass:(Class)cls;
@end
