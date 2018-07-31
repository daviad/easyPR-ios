//
//  DisplayCell.h
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayDesc.h"

@interface DisplayCell : UITableViewCell

- (void)loadData:(DisplayDesc*)data;
+(CGFloat)calcultate:(DisplayDesc*)data withMaxWidth:(CGFloat)maxWidth;
@end
