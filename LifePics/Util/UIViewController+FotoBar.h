//
//  UIViewController+FotoBar.h
//  LifePics
//
//  Created by Gabriel Moraes on 22/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FotoView.h"
#import "Foto.h"
#import "Moldura.h"

@interface UIViewController (FotoBar)

@property (nonatomic, strong) FotoView* fotoBar;
@property (nonatomic, strong) NSMutableArray* options;

-(void)salva:(Foto*)foto compartilha:(NSData*)polaroid opcoes:(NSArray*)options legenda:(NSString*)legenda;

@end
