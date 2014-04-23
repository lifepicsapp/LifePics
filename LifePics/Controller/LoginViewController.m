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
    NSArray *permissionsArray = @[@"user_about_me", @"user_birthday", @"publish_actions"];
    self.btnFacebook.enabled = NO;
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        self.btnFacebook.enabled = YES;
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Erro"
                                  message: @"Não foi possível efetuar o login."
                                  delegate: nil
                                  cancelButtonTitle:@"Cancelar"
                                  otherButtonTitles: nil];
            [alert show];
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self performSegueWithIdentifier:@"sgHome" sender:nil];
        } else {
            NSLog(@"User with facebook logged in!");
            [self performSegueWithIdentifier:@"sgHome" sender:nil];
        }
    }];
}

@end
