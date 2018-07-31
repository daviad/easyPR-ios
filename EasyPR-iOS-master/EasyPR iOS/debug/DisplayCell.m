//
//  ShowCell.m
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//

#import "DisplayCell.h"
#import "BaseConfigView.h"

@interface DisplayCell()
{
    BaseConfigView *_configView;
    UIImageView *_imgView;
    UILabel *_descLB;
    UIButton *_nextBtn;
}
@end

@implementation DisplayCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _descLB = [[UILabel alloc] init];
        [self.contentView addSubview:_descLB];
        _descLB.font = [UIFont systemFontOfSize:14];
        
        _imgView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imgView];
        
        _nextBtn = [[UIButton alloc] init];
        [self.contentView addSubview:_nextBtn];
        [_nextBtn setTitle:@"next" forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clearViews {
//    _descLB.frame = CGRectZero;
//    _imgView.frame = CGRectZero;
//    _configView.frame = CGRectZero;
//    _nextBtn.frame = CGRectZero;
}
- (void)loadData:(DisplayDesc*)data {
    if (data.desc.length > 1) {
        _descLB.text = data.desc;
        _descLB.frame = CGRectMake(5, 2, data.layout.descSize.width, data.layout.descSize.height);
    } else{
        _descLB.frame = CGRectMake(5, 2, data.layout.descSize.width, 0);
    }
    int nextY = _descLB.frame.size.height;
    
    if (data.img) {
        _imgView.image = data.img.img;
        _imgView.frame = CGRectMake(5, CGRectGetMaxY(_descLB.frame), data.layout.imgSize.width, data.layout.imgSize.height);
    } else {
        _imgView.frame = CGRectMake(5, CGRectGetMaxY(_descLB.frame), data.layout.imgSize.width, 0);
    }
    nextY += _imgView.frame.size.height;
   
    if (data.configView) {
        [_configView removeFromSuperview];
        _configView = data.configView;
        _configView.frame = CGRectMake(5, CGRectGetMaxY(_descLB.frame), data.layout.configViewSize.width, data.layout.configViewSize.height);
        nextY += _configView.frame.size.height;
    }
    
    if (data.hasNext) {
        _nextBtn.frame = CGRectMake(150, nextY, 70, 50);
    } else {
        _nextBtn.frame = CGRectZero;
    }
}

- (void)next {
    
}

+(CGFloat)calcultate:(DisplayDesc*)data withMaxWidth:(CGFloat)maxWidth{
    CGFloat h = 0.0;
    if (data.desc.length > 1) {
        data.layout.descSize = [data.desc boundingRectWithSize:CGSizeMake(maxWidth - 5*2, MAX_INPUT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
        h += data.layout.descSize.height;
    }
    
    if (data.img) {
        data.layout.imgSize = CGSizeMake(100, 100);
        h += data.layout.imgSize.height;
    }
    
    if (data.configView) {
        data.layout.configViewSize = CGSizeMake(100, 200);
        h += data.layout.configViewSize.height;
    }
    
    if (data.hasNext) {
        h += 50;
    }
    
    h += 50;
    return h;
}
@end
