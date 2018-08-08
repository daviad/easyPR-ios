//
//  ViewController.m
//  EasyPR
//
//  Created by  dingxiuwei on 2018/7/30.
//  Copyright © 2018年  dingxiuwei. All rights reserved.
//



#import "ViewController.h"
#import "PlateRecognitionController.h"
#import "ContourTestController.h"
#import "ActionItem.h"

#import "MserLocateController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *ctrTB;
@property(nonatomic,strong)NSMutableArray<ActionItem*> *dataArr;
@end

@implementation ViewController

- (void)addActionBlk:(void (^)(void))blk withText:(NSString*)text{
    ActionItem *item = [[ActionItem alloc] initWithClickBlk:blk];
    item.text = text;
    [self.dataArr addObject:item];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"选择车牌定位的方式";
    _ctrTB = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_ctrTB];
    
    _ctrTB.delegate = self;
    _ctrTB.dataSource = self;
    [_ctrTB registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseCell"];
    
    _dataArr = [NSMutableArray array];
    
    __weak ViewController* weakSelf = self;
    [self addActionBlk:^{
          [weakSelf.navigationController pushViewController:[[MserLocateController alloc] init] animated:YES];
    } withText:@"mser"];
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell"];
    cell.textLabel.text = _dataArr[indexPath.row].text;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _dataArr[indexPath.row].action();
}


@end
