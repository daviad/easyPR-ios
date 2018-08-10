//
//  ShowController.m
//  EasyPR
//
//  Created by  dingxiuwei on 2018/8/7.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//

#import "ShowController.h"
#import <Foundation/Foundation.h>

@interface ShowController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_showTB;
    NSMutableArray<UIImage*> *_dataArr;
}
@end

@implementation ShowController
#define reUseCell  @"ReuseCell"
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _showTB = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
    _dataArr = [NSMutableArray array];
    _showTB = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _showTB.dataSource = self;
    _showTB.delegate = self;
    [self.view addSubview:_showTB];
    [_showTB registerClass:[UITableViewCell class] forCellReuseIdentifier:reUseCell];
}

- (UIImage *)scaleWithFixedWidth:(CGFloat)width srcImage:(UIImage*)srcImg
{
    float newHeight = srcImg.size.height * (width / srcImg.size.width);
    CGSize size = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), srcImg.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (void)loadImages:(NSMutableArray*)arr {
    [_dataArr removeAllObjects];
    for (UIImage *img in arr) {
        if (img.size.width > self.view.bounds.size.width) {
             [_dataArr addObject:[self scaleWithFixedWidth:self.view.bounds.size.width srcImage:img]];
        }else {
            [_dataArr addObject:img];
        }
       
    }
    [_showTB reloadData];
}
#pragma mark- UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUseCell];
    UIImage *image = _dataArr[indexPath.row];
//    cell.contentMode = UIViewContentModeCenter;
    cell.contentView.layer.contentsGravity = kCAGravityResizeAspect;
    cell.contentView.layer.contents = (__bridge id _Nullable)(image.CGImage);;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = _dataArr[indexPath.row];
    return image.size.height + 1;
}
@end
