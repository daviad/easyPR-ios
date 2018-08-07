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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 40, 50)];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tap {
    [self.navigationController pushViewController:[[ContourTestController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
