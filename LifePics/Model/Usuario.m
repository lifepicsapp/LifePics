//
//  Usuario.m
//  LifePics
//
//  Created by Gabriel Moraes on 28/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "Usuario.h"

@implementation Usuario

+(instancetype)usuario:(PFUser*)user
{
    Usuario* usuario = [[Usuario alloc] init];
    usuario.user = user;
    return usuario;
}

+(instancetype)current
{
    Usuario* usuario = [[Usuario alloc] init];
    usuario.user = [PFUser currentUser];
    return usuario;
}

-(NSString *)login
{
    return [self.user objectForKey:@"login"];
}

-(void)setLogin:(NSString *)login
{
    [self.user setObject:login forKey:@"login"];
}

-(NSArray *)favoritos
{
    return [self.user objectForKey:@"favoritos"];
}

-(void)setFavoritos:(NSArray *)favoritos
{
    [self.user setObject:favoritos forKey:@"favoritos"];
}

-(NSArray *)fans
{
    return [self.user objectForKey:@"fans"];
}

-(void)setFans:(NSArray *)fans
{
    [self.user setObject:fans forKey:@"fans"];
}

@end
