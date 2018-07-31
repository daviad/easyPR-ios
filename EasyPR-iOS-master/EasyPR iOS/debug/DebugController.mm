//
//  DebugController.m
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//

#import "DebugController.h"
#import "DisplayCell.h"
#import "DisplayDesc.h"

@interface DebugController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_displayTB;
    NSMutableArray *_dataArr;
    cv::Mat soreceImage;
}
@end

@implementation DebugController

- (instancetype)initWith:(cv::Mat)sorceImage2 {
    if (self = [super init]) {
        soreceImage = sorceImage2;
    }
    return self;
}

#define  ReuseCell @"reusecell"
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArr = [NSMutableArray array];
    
    DisplayDesc *desc = [[DisplayDesc alloc] init];
    desc.desc = @"点击 next 开启 Debug 之旅！";
    desc.hasNext = YES;
    [_dataArr addObject:desc];
    
    _displayTB = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _displayTB.delegate = self;
    _displayTB.dataSource = self;
    _displayTB.estimatedRowHeight = 0;
    [self.view addSubview:_displayTB];
    _displayTB.tableFooterView = [[UIView alloc] init];
//    [_displayTB registerClass:[DisplayCell class] forCellReuseIdentifier:ReuseCell];
    self.view.backgroundColor = [UIColor blackColor];
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 60, 40, 40)];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:closeBtn];
}

#pragma mark-- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseCell];
    if (!cell) {
        cell = [[DisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseCell];
    }
    [cell loadData:_dataArr[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DisplayCell calcultate:_dataArr[indexPath.row] withMaxWidth:tableView.frame.size.width-2 ];
}
- (void)closeAction {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
@end
