//
//  FotoViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 15/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foto.h"
#import "Moldura.h"

@import MobileCoreServices;

@interface FotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) Foto *foto;
@property (strong, nonatomic) Moldura *moldura;
@property (strong, nonatomic) UIImage *imagem;
@property (assign) BOOL newMedia;
@property (assign) BOOL onlyShare;

@property (weak, nonatomic) IBOutlet UIImageView *imgFoto;
@property (weak, nonatomic) IBOutlet UILabel *lblLegenda;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRemover;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCompartilhar;

@end
