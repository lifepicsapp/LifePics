//
//  Social.m
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "Social.h"

@implementation Social

+(instancetype)socialNome:(NSString*)nome option:(FotoBarOptions)option
{
    Social* social = [[Social alloc] init];
    social.nome = nome;
    social.option = option;
    return social;
}

@end
