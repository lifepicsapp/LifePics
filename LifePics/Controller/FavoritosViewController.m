//
//  FavoritosViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 26/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "FavoritosViewController.h"
#import "AppUtil.h"

@interface FavoritosViewController ()

@end

@implementation FavoritosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppUtil adicionaLogo:self];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [AppUtil removeTextoBotaoVoltar:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
