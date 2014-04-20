//
//  UIViewController+QuedaConexao.m
//  Prefeitura SP
//
//  Created by Gabriel Moraes on 24/03/14.
//  Copyright (c) 2014 Call. All rights reserved.
//

#import "UIViewController+QuedaConexao.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation UIViewController (QuedaConexao)

static char const * const ObjectTagKey = "BarraAviso";

@dynamic barraAviso;

- (id)barraAviso {
    return objc_getAssociatedObject(self, ObjectTagKey);
}

- (void)setBarraAviso:(id)newObjectTag {
    objc_setAssociatedObject(self, ObjectTagKey, newObjectTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)adicionaAviso
{
    if (!self.barraAviso)
    {
        self.barraAviso = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 30)];
        self.barraAviso.alpha = 0.0;
        self.barraAviso.backgroundColor = [UIColor colorWithRed:255/255.f green:0/255.f blue:0/255.f alpha:0.7];
        [self.view addSubview:self.barraAviso];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self.barraAviso addGestureRecognizer:tap];
        
        UIImageView* imagem = [[UIImageView alloc] initWithFrame:CGRectMake(10, 2, 26, 26)];
        imagem.image = [UIImage imageNamed:@"alert"];
        [self.barraAviso addSubview:imagem];
        
        UILabel* mensagem = [[UILabel alloc] initWithFrame:CGRectMake(imagem.frame.size.width + 20, 0, self.view.frame.size.width - (imagem.frame.size.width + 30), self.barraAviso.frame.size.height)];
        mensagem.text = @"Verique sua conexão com a internet e tente novamente";
        mensagem.textColor = [UIColor whiteColor];
        mensagem.adjustsFontSizeToFitWidth = YES;
        mensagem.minimumScaleFactor = 9.0/[UIFont labelFontSize];
        mensagem.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        [self.barraAviso addSubview:mensagem];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.barraAviso.alpha = 1.0;
        }];
    }
}

-(void)removeAviso
{
    if (self.barraAviso)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.barraAviso.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.barraAviso removeFromSuperview];
            self.barraAviso = nil;
        }];
    }
}

-(void)onTap:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self removeAviso];
}

@end
