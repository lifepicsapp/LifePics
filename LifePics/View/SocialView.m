//
//  SocialView.m
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "SocialView.h"

@implementation SocialView

-(void)setSocial:(Social *)social {
    _social = social;
    
    self.lblNome.text = [_social.nome capitalizedString];
    self.imgIcone.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_circle", _social.nome]];
}

@end
