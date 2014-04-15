//
//  Foto.h
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Moldura.h"

@interface Foto : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (retain) PFUser* usuario;
@property (retain) Moldura* moldura;

@end
