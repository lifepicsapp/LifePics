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
#import <Accounts/Accounts.h>
#import <Social/Social.h>
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
            [self.navigationController setToolbarHidden:YES];
            self.fotoBar = [[[NSBundle mainBundle] loadNibNamed:@"FotoView" owner:self options:nil] lastObject];
            self.fotoBar.frame = CGRectMake(0, self.view.frame.size.height - 44, 320, 44);
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
        NSString* legenda = [NSString stringWithFormat:URL_SHARE, moldura.legenda];
        
        if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionUpload]])
        {
            [self uploadImage:imageData foto:foto moldura:moldura];
        }
        else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionFacebook]])
        {
            [self compartilhaFacebook:imageData legenda:legenda];
        }
        else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionTwitter]])
        {
            [self compartilhaTwitter:imageData legenda:legenda];
        }
        else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionInstagram]]){}
    }
}

-(void)uploadImage:(NSData*)imageData foto:(Foto*)foto moldura:(Moldura*)moldura
{
    HomeViewController* controller = ((HomeViewController*)self);
    self.fotoBar.lblStatus.text = @"Salvando foto...";
    self.fotoBar.pvUpload.hidden = NO;
    
    PFFile *imageFile = [PFFile fileWithName:[[AppUtil escapeString:moldura.titulo] stringByAppendingString:@".jpg"] data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
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
                        [self compartilhaTwitter:imageData legenda:moldura.legenda];
                    }
                    else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionInstagram]]){}
                    else
                    {
                        [self finalizaOk];
                    }
                }
                else
                {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    [controller adicionaAviso:@"Erro ao salvar foto."];
                    [self removeBar:NO];
                }
            }];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [controller adicionaAviso:@"Erro ao subir foto."];
            [self removeBar:NO];
        }
    } progressBlock:^(int percentDone) {
        self.fotoBar.pvUpload.progress = (float)percentDone/100;
    }];
}

- (void)compartilhaFacebook:(NSData*)imageData legenda:(NSString*)legenda
{
    HomeViewController* controller = ((HomeViewController*)self);
    self.fotoBar.lblStatus.text = @"Compartilhando Facebook...";
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:legenda forKey:@"message"];
    [params setObject:imageData forKey:@"source"];
    
    [FBRequestConnection startWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionTwitter]])
            {
                [self compartilhaTwitter:imageData legenda:legenda];
            }
            else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionInstagram]]){}
            else
            {
                [self finalizaOk];
            }
        }
        else
        {
            [controller adicionaAviso:@"Erro ao compartilhar no Facebook."];
            [self removeBar:NO];
        }
    }];
}

-(void)compartilhaTwitter:(NSData*)imageData legenda:(NSString*)legenda
{
    self.fotoBar.lblStatus.text = @"Compartilhando Twitter...";
    
    HomeViewController* controller = ((HomeViewController*)self);
    ACAccountType *twitterType = [controller.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [controller.accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [controller.accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com" @"/1.1/statuses/update_with_media.json"];
            NSDictionary *params = @{@"status" : legenda};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:params];
            [request addMultipartData:imageData withName:@"media[]" type:@"image/jpeg" filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
            
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (responseData) {
                    NSInteger statusCode = urlResponse.statusCode;
                    if (statusCode >= 200 && statusCode < 300) {
                        NSDictionary *postResponseData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                        NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
                        
                        if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionInstagram]]){}
                        else
                        {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self finalizaOk];
                            });
                        }
                    }
                    else {
                        NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [controller adicionaAviso:@"Erro ao compartilhar no Twitter."];
                            [self removeBar:NO];
                        });
                    }
                }
                else {
                    NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [controller adicionaAviso:@"Erro ao compartilhar no Twitter."];
                        [self removeBar:NO];
                    });
                }
            }];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@", [error localizedDescription]);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [controller adicionaAviso:@"Erro ao autorizar Twitter."];
                [self removeBar:NO];
            });
        }
    }];
}

-(void)finalizaOk
{
    self.fotoBar.lblStatus.text = @"Finalizado!";
    [self.fotoBar.aiCarregando stopAnimating];
    self.fotoBar.aiCarregando.hidden = YES;
    self.fotoBar.imgOK.hidden = NO;
    [self removeBar:YES];
    if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionUpload]])
    {
        [((HomeViewController*)self) carrega];
    }
}

-(void)removeBar:(BOOL)success
{
    [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.fotoBar.alpha = 0;
    } completion:^(BOOL finished) {
        [self.fotoBar removeFromSuperview];
        self.fotoBar = nil;
        if (success)
            [self.navigationController setToolbarHidden:NO];
    }];
}

@end
