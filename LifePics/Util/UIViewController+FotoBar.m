//
//  UIViewController+FotoBar.m
//  LifePics
//
//  Created by Gabriel Moraes on 22/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "UIViewController+FotoBar.h"
#import "AlbumViewController.h"
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

-(void)salva:(Foto*)foto compartilha:(NSData*)imageData opcoes:(NSArray*)options legenda:(NSString*)legenda
{
    if (options)
    {
        self.options = [NSMutableArray arrayWithArray:options];
    
        if (!self.fotoBar)
        {
            self.fotoBar = [[[NSBundle mainBundle] loadNibNamed:@"FotoView" owner:self options:nil] lastObject];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
            {
                self.fotoBar.frame = CGRectMake(0, self.view.frame.size.height - 44, 320, 44);
            }
            else
            {
                self.fotoBar.frame = CGRectMake(0, self.view.frame.size.height - 93, 320, 44);
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"msg_erro", nil)
                                  message: NSLocalizedString(@"msg_processo", nil)
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [foto.arquivo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                self.fotoBar.imgFoto.image = [UIImage imageWithData:data];
                [self.fotoBar.aiCarregando startAnimating];
                [self.view addSubview:self.fotoBar];
                
                if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionUpload]])
                {
                    [self uploadImage:imageData foto:foto moldura:foto.moldura legenda:legenda];
                }
                else
                {
                    [self compartilha:imageData legenda:legenda];
                }
            }
            else
            {
                [self adicionaAviso:[NSString stringWithFormat:@"%@ '%@'",NSLocalizedString(@"msg_foto_moldura", nil), foto.moldura.titulo] delay:0.0];
            }
        }];
    }
}

-(void)compartilha:(NSData*)data legenda:(NSString*)legenda
{
    if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionLifePics]])
    {
        [self.options removeObject:[NSNumber numberWithInt:FotoBarOptionLifePics]];
        [self compartilhaLifePics:data legenda:legenda];
    }
    else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionFacebook]])
    {
        [self.options removeObject:[NSNumber numberWithInt:FotoBarOptionFacebook]];
        [self compartilhaFacebook:data legenda:legenda];
    }
    else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionTwitter]])
    {
        [self.options removeObject:[NSNumber numberWithInt:FotoBarOptionTwitter]];
        [self compartilhaTwitter:data legenda:legenda];
    }
    else if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionInstagram]])
    {}
    else
    {
        [self finalizaOk];
    }
}

-(void)uploadImage:(NSData*)imageData foto:(Foto*)foto moldura:(Moldura*)moldura legenda:(NSString*)legenda
{
    AlbumViewController* controller = ((AlbumViewController*)self);
    self.fotoBar.lblStatus.text = NSLocalizedString(@"msg_salvando", nil);
    self.fotoBar.pvUpload.hidden = NO;
    
    [foto.arquivo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            if (!foto.usuario)
            {
                foto.usuario = [PFUser currentUser];
                PFACL* ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [ACL setPublicReadAccess:YES];
                foto.ACL = ACL;
            }
            else
            {
                [controller.contextCache removeObjectForKey:foto.objectId];
            }
            
            [foto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    [self compartilha:imageData legenda:legenda];
                }
                else
                {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    [controller adicionaAviso:NSLocalizedString(@"msg_salvar", nil) delay:0.0];
                    [self removeBar:NO];
                }
            }];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [controller adicionaAviso:NSLocalizedString(@"msg_subir", nil) delay:0.0];
            [self removeBar:NO];
        }
    } progressBlock:^(int percentDone) {
        self.fotoBar.pvUpload.progress = (float)percentDone/100;
    }];
}


- (void)compartilhaLifePics:(NSData*)imageData legenda:(NSString*)legenda
{
    AlbumViewController* controller = ((AlbumViewController*)self);
    self.fotoBar.lblStatus.text = NSLocalizedString(@"msg_lifepics", nil);
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:legenda forKey:@"message"];
    [params setObject:imageData forKey:@"source"];
    
    [FBRequestConnection startWithGraphPath:@"/518721901572885/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            [self compartilha:imageData legenda:legenda];
        }
        else
        {
            [controller adicionaAviso:NSLocalizedString(@"msg_erro_lifepics", nil) delay:0.0];
            [self removeBar:NO];
        }
    }];
}

- (void)compartilhaFacebook:(NSData*)imageData legenda:(NSString*)legenda
{
    AlbumViewController* controller = ((AlbumViewController*)self);
    self.fotoBar.lblStatus.text = NSLocalizedString(@"msg_facebook", nil);
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:legenda forKey:@"message"];
    [params setObject:imageData forKey:@"source"];
    
    [FBRequestConnection startWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            [self compartilha:imageData legenda:legenda];
        }
        else
        {
            [controller adicionaAviso:NSLocalizedString(@"msg_erro_facebook", nil) delay:0.0];
            [self removeBar:NO];
        }
    }];
}

-(void)compartilhaTwitter:(NSData*)imageData legenda:(NSString*)legenda
{
    self.fotoBar.lblStatus.text = NSLocalizedString(@"msg_twitter", nil);
    
    AlbumViewController* controller = ((AlbumViewController*)self);
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
                            [controller adicionaAviso:NSLocalizedString(@"msg_erro_twitter", nil) delay:0.0];
                            [self removeBar:NO];
                        });
                    }
                }
                else {
                    NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [controller adicionaAviso:NSLocalizedString(@"msg_erro_twitter", nil) delay:0.0];
                        [self removeBar:NO];
                    });
                }
            }];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@", [error localizedDescription]);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [controller adicionaAviso:NSLocalizedString(@"msg_autorizar_twitter", nil) delay:0.0];
                [self removeBar:NO];
            });
        }
    }];
}

-(void)finalizaOk
{
    self.fotoBar.lblStatus.text = NSLocalizedString(@"msg_fim", nil);
    [self.fotoBar.aiCarregando stopAnimating];
    self.fotoBar.aiCarregando.hidden = YES;
    self.fotoBar.imgOK.hidden = NO;
    [self removeBar:YES];
    if ([self.options containsObject:[NSNumber numberWithInt:FotoBarOptionUpload]])
    {
        [((AlbumViewController*)self) carrega:1.5];
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
        {
            //on Sucess
        }
    }];
}

@end
