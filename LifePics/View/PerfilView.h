//
//  PerfilView.h
//  LifePics
//
//  Created by Gabriel Moraes on 27/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Usuario.h"

@interface PerfilView : UICollectionReusableView

@property (strong, nonatomic) Usuario *usuario;

@property (weak, nonatomic) IBOutlet UILabel *lblNome;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgTipo;

@end
