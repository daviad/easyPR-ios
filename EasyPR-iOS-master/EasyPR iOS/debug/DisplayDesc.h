//
//  DisplayDesc.h
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayImg.h"
#import "DisplayConfig.h"
#import "DisplayCellLayout.h"
#import "BaseConfigView.h"

@interface DisplayDesc : NSObject

@property(nonatomic,copy)NSString *desc;
//@property(nonatomic,copy)NSArray<DisplayImg*> *imgs;
@property(nonatomic,copy)DisplayImg *img;
@property(nonatomic,strong)DisplayConfig *cfg;
@property(nonatomic,strong)DisplayCellLayout *layout;
@property(nonatomic,assign)BOOL hasNext;

@property(nonatomic,strong)BaseConfigView *configView;

@end
