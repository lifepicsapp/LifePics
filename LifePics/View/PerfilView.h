//
//  PerfilView.h
//  LifePics
//
//  Created by Gabriel Moraes on 27/05/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PerfilView : UICollectionReusableView

@property (strong, nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UILabel *lblNome;


@end
