//
//  CadastroViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 27/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "CadastroViewController.h"
#import <Parse/Parse.h>

@interface CadastroViewController ()

@end

@implementation CadastroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos IBAction

- (IBAction)verifica:(UIButton *)sender {
    self.btnVerificar.enabled = NO;
    [self.aiVerificar startAnimating];
    PFQuery* query = [PFUser query];
    [query whereKey:@"login" equalTo:self.txtLogin.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self.aiVerificar stopAnimating];
        if (!object)
        {
            self.lblStatus.text = @"Nome de usuário válido!";
            self.txtLogin.enabled = NO;
            self.btnContinuar.enabled = YES;
        }
        else
        {
            self.btnVerificar.enabled = YES;
            self.lblStatus.text = @"Nome de usuário já existe!";
        }
    }];
}

- (IBAction)continua:(UIButton *)sender {
    PFUser* user = [PFUser currentUser];
    [user setValue:self.txtLogin.text forKey:@"login"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self performSegueWithIdentifier:@"sgLoginCadastro" sender:nil];
    }];
}

@end
