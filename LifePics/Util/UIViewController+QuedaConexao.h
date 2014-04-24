//
//  UIViewController+QuedaConexao.h
//  Prefeitura SP
//
//  Created by Gabriel Moraes on 24/03/14.
//  Copyright (c) 2014 Call. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConexaoView.h"

@interface UIViewController (QuedaConexao)

@property (nonatomic, retain) ConexaoView* barraAviso;

-(void)adicionaAviso:(NSString*)mensagem delay:(float)delay;
-(void)removeAviso;

@end
