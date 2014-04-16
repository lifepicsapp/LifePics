//
//  AppUtil.m
//  LifePics
//
//  Created by Gabriel Moraes on 15/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "AppUtil.h"

@implementation AppUtil

+(NSString *)escapeString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+(void)removeTextoBotaoVoltar:(UIViewController*)context
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@""
                                   style:UIBarButtonItemStylePlain
                                   target:nil
                                   action:nil];
    context.navigationItem.backBarButtonItem=backButton;
}

+ (void)adicionaLoad:(UIViewController*)context
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    context.navigationItem.rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
}

@end
