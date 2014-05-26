//
//  CustomTabBarController.m
//  LifePics
//
//  Created by Gabriel Moraes on 26/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "CustomTabBarController.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* color = [UIColor colorWithRed:13/255.0 green:145/255.0 blue:133/255.0 alpha:1.0];
    UIColor* colorItems = [UIColor whiteColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
//        self.tabBar.tintColor = color;
        self.tabBar.backgroundColor = color;
    }
    else
    {
//        self.tabBar.barTintColor = color;
        self.tabBar.tintColor = color;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
