//
//  CompartilhaViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Foto.h"
#import "Moldura.h"

@interface CompartilhaViewController : UIViewController <MBProgressHUDDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *arrSocial;
@property (strong, nonatomic) Foto *foto;
@property (strong, nonatomic) Moldura *moldura;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) UIImage *imagem;
@property (assign) BOOL onlyShare;
@property (assign) NSInteger countOperacao;
@property (assign) NSInteger countFim;
@property (assign) NSInteger countFalha;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imgFoto;
@property (weak, nonatomic) IBOutlet UILabel *lblLegenda;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnFinaliza;

@end
