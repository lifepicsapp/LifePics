//
//  PerfilView.m
//  LifePics
//
//  Created by Gabriel Moraes on 27/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "PerfilView.h"

@implementation PerfilView

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    self.lblNome.text = [NSString stringWithFormat:@"@%@", [_user valueForKey:@"login"]];
}

@end
