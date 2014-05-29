//
//  PerfilView.m
//  LifePics
//
//  Created by Gabriel Moraes on 27/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "PerfilView.h"

@implementation PerfilView

-(id)init
{
    if (self = [super init])
    {
        [self.sgTipo setTintColor:[UIColor blackColor]];
    }
    return self;
}

-(void)setUsuario:(Usuario *)usuario
{
    _usuario = usuario;
    
    self.lblNome.text = [NSString stringWithFormat:@"@%@", _usuario.login];
}

@end
