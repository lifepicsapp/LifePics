//
//  SocialView.m
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "SocialView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "CompartilhaViewController.h"

@implementation SocialView

-(void)setSocial:(Social *)social {
    _social = social;
    if ([_social.nome isEqualToString:@"instagram"])
        self.swtAtivo.enabled = NO;
        
    self.lblNome.text = [_social.nome capitalizedString];
    self.imgIcone.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_circle", _social.nome]];
}

- (IBAction)switchChange:(UISwitch *)sender {
    if ([self.social.nome isEqualToString:@"facebook"])
    {
        if (sender.on)
        {
            if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
            {
                sender.on = NO;
                [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceOnlyMe completionHandler:^(FBSession *session, NSError *error) {
                    if (!error && [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound)
                    {
                        sender.on = YES;
                        [[self controller] removeAviso];
                    }
                    else
                    {
                       [[self controller] adicionaAviso:@"Erro ao autorizar Facebook." delay:0.0];
                    }
                }];
            }
        }
    }
}

-(CompartilhaViewController*)controller
{
    return (CompartilhaViewController*)((UINavigationController*)((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController).visibleViewController;
}

@end
