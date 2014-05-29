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

@end
