//
//  CustomNavigationController.m
//  Copa SP
//
//  Created by Gabriel Moraes on 12/12/13.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIColor* color = [UIColor colorWithRed:13/255.0 green:145/255.0 blue:133/255.0 alpha:0.1];
    UIColor* colorItems = [UIColor whiteColor];
    
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                              colorItems,NSForegroundColorAttributeName,
                                              colorItems,NSBackgroundColorAttributeName,nil];
    
    self.navigationBar.barTintColor = color;
    self.navigationBar.tintColor = colorItems;
    self.toolbar.barTintColor = color;
    self.toolbar.tintColor = colorItems;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
