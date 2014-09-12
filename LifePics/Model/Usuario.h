//
//  Usuario.h
//  LifePics
//
//  Created by Gabriel Moraes on 28/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFUser.h>

@interface Usuario : NSObject

@property (strong, nonatomic) PFUser* user;
@property (strong, nonatomic) NSString* login;
@property (strong, nonatomic) PFRelation* favoritos;
@property (strong, nonatomic) NSMutableArray* fans;

+(instancetype)usuario:(PFUser*)user;
+(instancetype)current;

@end
