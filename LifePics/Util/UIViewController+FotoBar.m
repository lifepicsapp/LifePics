//
//  UIViewController+FotoBar.m
//  LifePics
//
//  Created by Gabriel Moraes on 22/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "UIViewController+FotoBar.h"
#import "HomeViewController.h"
#import <objc/runtime.h>
#import "AppUtil.h"

@implementation UIViewController (FotoBar)

static char const * const ObjectTagKey = "FotoBar";
static char const * const OptionsTagKey = "Options";

@dynamic fotoBar, options;

- (id)fotoBar {
    return objc_getAssociatedObject(self, ObjectTagKey);
}

- (void)setFotoBar:(id)newObjectTag {
    objc_setAssociatedObject(self, ObjectTagKey, newObjectTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)options {
    return objc_getAssociatedObject(self, OptionsTagKey);
}

- (void)setOptions:(id)newObjectTag {
    objc_setAssociatedObject(self, OptionsTagKey, newObjectTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)salvaImagem:(UIImage*)image objeto:(Foto*)foto moldura:(Moldura*)moldura comOpcoes:(NSArray*)options
{
    if (options)
    {
        self.options = options;
    
        if (!self.fotoBar)
        {
            const int height = 44;
            self.fotoBar = [[[NSBundle mainBundle] loadNibNamed:@"FotoView" owner:self options:nil] lastObject];
            self.fotoBar.frame = CGRectMake(0, self.view.frame.size.height - self.navigationController.toolbar.frame.size.height - height, 320, height);
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Erro"
                                  message: @"Aguarde a conclusão do processo em andamento!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        self.fotoBar.imgFoto.image = image;
        [self.fotoBar.aiCarregando startAnimating];
        [self.view addSubview:self.fotoBar];
        
        NSData* imageData = UIImageJPEGRepresentation(image, 0.05f);
        if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionUpload]])
        {
            [self uploadImage:imageData foto:foto moldura:moldura];
        }
        else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionFacebook]])
        {
            [self compartilhaFacebook:imageData legenda:moldura.legenda];
        }
        else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionTwitter]])
        {
        }
        else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionInstagram]])
        {
        }
    }
}

-(void)uploadImage:(NSData*)imageData foto:(Foto*)foto moldura:(Moldura*)moldura
{
    self.fotoBar.lblStatus.text = @"Salvando foto...";
    self.fotoBar.pvUpload.hidden = NO;
    
    PFFile *imageFile = [PFFile fileWithName:[[AppUtil escapeString:moldura.titulo] stringByAppendingString:@".jpg"] data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            if (!foto.usuario)
            {
                foto.arquivo = imageFile;
                
                PFUser *user = [PFUser currentUser];
                
                foto.ACL = [PFACL ACLWithUser:user];
                foto.usuario = user;
                foto.moldura = moldura;
            }
            else
                [((HomeViewController*)self).cacheFotos removeObjectForKey:foto.objectId];
            
            foto.arquivo = imageFile;
            [foto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionFacebook]])
                    {
                        [self compartilhaFacebook:imageData legenda:moldura.legenda];
                    }
                    else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionTwitter]])
                    {
                    }
                    else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionInstagram]])
                    {
                    }
                    else
                    {
                        [self finalizaOk];
                    }
                }
                else
                {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self removeBar];
        }
    } progressBlock:^(int percentDone) {
        self.fotoBar.pvUpload.progress = (float)percentDone/100;
    }];
}

- (void)compartilhaFacebook:(NSData*)imageData legenda:(NSString*)legenda
{
    self.fotoBar.lblStatus.text = @"Compartilhando Facebook...";
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:URL_SHARE, legenda] forKey:@"message"];
    [params setObject:imageData forKey:@"source"];
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error)
                              {
                                  [self finalizaOk];
                              }
                              else
                              {
                                  [self removeBar];
                              }
                          }];
}

-(void)finalizaOk
{
    [self.fotoBar.aiCarregando stopAnimating];
    self.fotoBar.aiCarregando.hidden = YES;
    self.fotoBar.imgOK.hidden = NO;
    [self removeBar];
    if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionUpload]])
        [((HomeViewController*)self) carrega];
}

-(void)removeBar
{
    [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.fotoBar.alpha = 0;
    } completion:^(BOOL finished) {
        [self.fotoBar removeFromSuperview];
        self.fotoBar = nil;
    }];
}

@end
