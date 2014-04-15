//
//  Moldura.h
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface Moldura : PFObject <PFSubclassing>

@property (retain) NSString* titulo;
@property (retain) NSString* legenda;

+ (NSString *)parseClassName;

@end
