//
//  CompartilhaViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 19/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+QuedaConexao.h"
#import "Foto.h"
#import "Moldura.h"

@interface CompartilhaViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *arrSocial;
@property (strong, nonatomic) NSMutableArray *arrOptions;
@property (strong, nonatomic) Foto *foto;
@property (assign) BOOL onlyShare;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imgFoto;
@property (weak, nonatomic) IBOutlet UILabel *lblLegenda;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnFinaliza;
@property (weak, nonatomic) IBOutlet UIView *vwCompartilha;

@end
