//
//  Foto.m
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "Foto.h"
#import <Parse/PFObject+Subclass.h>

@implementation Foto

@dynamic arquivo, usuario, moldura;

+(NSString *)parseClassName
{
    return NSStringFromClass([self class]);
}

@end
