//
//  AppUtil.m
//  LifePics
//
//  Created by Gabriel Moraes on 15/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "AppUtil.h"
#import <Parse/Parse.h>

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

+ (void)adicionaLogo:(UIViewController*)context
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0,0,112,35)];
    view.backgroundColor = [UIColor clearColor];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,112,35)];
    iv.image = [UIImage imageNamed:@"logo-icon"];
    [view addSubview:iv];
    context.navigationItem.titleView = view;
}

+ (void)adicionaLoad:(UIViewController*)context
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    context.navigationItem.rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSData*) maskImage:(NSData *)imageData withMask:(UIImage *)maskImage {
    UIImage* image = [UIImage imageWithData:imageData];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [maskImage drawInRect:CGRectMake(image.size.width - maskImage.size.width, image.size.height - maskImage.size.height, maskImage.size.width, maskImage.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(result, 0.0f);
}

+ (void)logadoSucesso
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    [currentInstallation saveEventually];
}

+(NSString*)idiomaAtual
{
    for (NSString* language in [NSLocale preferredLanguages])
    {
        if ([@[@"pt", @"en", @"es"] containsObject:language])
        {
            return language;
        }
    }
    return nil;
}

@end
