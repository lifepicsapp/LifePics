//
//  LoginViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 13/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "HomeViewController.h"
#import "AppUtil.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos IBAction

- (IBAction)loginButtonTouchHandler:(id)sender  {
    self.btnFacebook.enabled = NO;
    [self.aiLogin startAnimating];
    [PFFacebookUtils logInWithPermissions:@[@"publish_actions"] block:^(PFUser *user, NSError *error) {
        [self.aiLogin stopAnimating];
        self.btnFacebook.enabled = YES;
        if (!user)
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Erro"
                                  message: @"Não foi possível efetuar o login."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            [AppUtil logadoSucesso];
            [self performSegueWithIdentifier:@"sgHome" sender:nil];
        }
    }];
}

@end
