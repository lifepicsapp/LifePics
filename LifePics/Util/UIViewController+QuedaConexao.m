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

-(void)adicionaAviso:(NSString*)mensagem
{
    if (!self.barraAviso)
    {
        [self.navigationController setToolbarHidden:YES];
        self.barraAviso = [[[NSBundle mainBundle] loadNibNamed:@"ConexaoView" owner:self options:nil] lastObject];
        self.barraAviso.alpha = 0.0;
        self.barraAviso.frame = CGRectMake(0, self.view.frame.size.height - 44, 320, 44);
        [self.view addSubview:self.barraAviso];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self.barraAviso addGestureRecognizer:tap];
        
        [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveLinear animations:^{
            self.barraAviso.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
    self.barraAviso.lblMensagem.text = mensagem;
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
            [self.navigationController setToolbarHidden:NO];
        }];
    }
}

-(void)onTap:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self removeAviso];
}

@end
