//
//  Social.h
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FotoView.h"

@interface Social : NSObject

@property (nonatomic, strong) NSString* nome;
@property (assign) FotoBarOptions option;

+(instancetype)socialNome:(NSString*)nome option:(FotoBarOptions)option;

@end
