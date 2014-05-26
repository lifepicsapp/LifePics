//
//  AppUtil.h
//  LifePics
//
//  Created by Gabriel Moraes on 15/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject

+(NSString*)escapeString:(NSString*)string;
+(void)removeTextoBotaoVoltar:(UIViewController*)context;
+(void)adicionaLoad:(UIViewController*)context;
+ (void)adicionaLogo:(UIViewController*)context;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithView:(UIView *)view;
+ (NSData*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (void)logadoSucesso;
+(NSString*)idiomaAtual;

@end

#define URL_SHARE @"%@ http://goo.gl/GgII7K"