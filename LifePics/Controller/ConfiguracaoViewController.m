//
//  ConfiguracaoViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 28/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "ConfiguracaoViewController.h"
#import <Parse/Parse.h>

@interface ConfiguracaoViewController ()

@end

@implementation ConfiguracaoViewController

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

- (IBAction)desloga:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(@"msg_atencao", nil)
                          message: NSLocalizedString(@"msg_sair", nil)
                          delegate: self
                          cancelButtonTitle:NSLocalizedString(@"btn_cancelar", nil)
                          otherButtonTitles:NSLocalizedString(@"msg_sim", nil), nil];
    [alert show];
}

#pragma mark - AlertView

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        [PFUser logOut];
        if (!self.abriuLogado)
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self performSegueWithIdentifier:@"sgLogin" sender:nil];
        }
    }
}

@end
