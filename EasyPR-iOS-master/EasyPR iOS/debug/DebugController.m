//
//  DebugController.m
//  EasyPR iOS
//
//  Created by  dingxiuwei on 2018/7/31.
//  Copyright © 2018年 zhoushiwei. All rights reserved.
//

#import "DebugController.h"
#import "DisplayCell.h"

@interface DebugController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_displayTB;
    NSMutableArray *_dataArr;
}
@end

@implementation DebugController
#define  ReuseCell @"reusecell"
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _displayTB = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _displayTB.delegate = self;
    _displayTB.dataSource = self;
    [self.view addSubview:_displayTB];
    [_displayTB registerClass:[DisplayCell class] forCellReuseIdentifier:ReuseCell];
}

#pragma mark-- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseCell];
    return cell;
}

@end
