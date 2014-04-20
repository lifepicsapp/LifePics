//
//  UIViewController+QuedaConexao.h
//  Prefeitura SP
//
//  Created by Gabriel Moraes on 24/03/14.
//  Copyright (c) 2014 Call. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (QuedaConexao)

@property (nonatomic, retain) UIView* barraAviso;

-(void)adicionaAviso;
-(void)removeAviso;

@end
