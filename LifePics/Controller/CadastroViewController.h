//
//  CadastroViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 27/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CadastroViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnVerificar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiVerificar;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnContinuar;

@end
