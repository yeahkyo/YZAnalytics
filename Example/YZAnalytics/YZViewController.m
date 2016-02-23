//
//  YZViewController.m
//  YZAnalytics
//
//  Created by Yeah on 02/14/2016.
//  Copyright (c) 2016 Yeah. All rights reserved.
//

#import "YZViewController.h"
#import <YZAnalytics/YZAnalytics.h>

@interface YZViewController ()

@property (nonatomic, strong) UIButton *btnOne;
@property (nonatomic, strong) UIButton *btnTwo;

@end

@implementation YZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.btnOne = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnOne.frame = CGRectMake(0, 0, 100, 50);
    self.btnOne.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    [self.btnOne setTitle:@"Button One" forState:UIControlStateNormal];
    [self.btnOne setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnOne addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];

    self.btnTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnTwo.frame = CGRectMake(0, 0, 100, 50);
    self.btnTwo.center = CGPointMake(self.view.center.x, self.view.center.y + 50);
    [self.btnTwo setTitle:@"Button Two" forState:UIControlStateNormal];
    [self.btnTwo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTwo addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.btnOne];
    [self.view addSubview:self.btnTwo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[YZAnalytics sharedInstance] collectCustomEvent:@"DemoViewShowed"];
}

- (void)btnClicked:(UIButton *)sender {
    [[YZAnalytics sharedInstance] collectCustomEvent:@"BtnClicked" count:1 parameters:@{@"ButtonName": sender.currentTitle}];
}

@end
