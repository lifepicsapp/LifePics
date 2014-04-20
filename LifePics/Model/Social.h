//
//  Social.h
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Social : NSObject

@property (nonatomic, strong) NSString* nome;

+(instancetype)social:(NSString*)nome;

@end
