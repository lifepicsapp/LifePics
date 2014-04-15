//
//  HomeViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "Foto.h"
#import "MolduraView.h"
#import "CropViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[Moldura query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.arrMolduras = objects;
            [self.collectionView reloadData];
            
            PFQuery* query = [Foto query];
            [query whereKey:@"usuario" equalTo:[PFUser currentUser]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    self.arrFotos = objects;
                    [self.collectionView reloadData];
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos CollectionView Datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrMolduras.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MolduraView* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellMoldura" forIndexPath:indexPath];
    Moldura* moldura = [self.arrMolduras objectAtIndex:indexPath.item];
    
    if (self.arrFotos)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moldura.objectId == %@", moldura.objectId];
        NSArray *filteredArray = [self.arrFotos filteredArrayUsingPredicate:predicate];
        
        if ([filteredArray count] > 0)
        {
            Foto* foto = [filteredArray objectAtIndex:0];
            [foto.arquivo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    cell.imgFoto.image = [UIImage imageWithData:data];
                }
            }];
        }
    }
    
    cell.lblTitulo.text = moldura.titulo;
    
    return cell;
}

#pragma mark - Metodos CollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.moldura = [self.arrMolduras objectAtIndex:indexPath.item];
    
    MolduraView* cell = (MolduraView*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell.imgFoto.image)
    {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Escolher foto" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Biblioteca", @"Câmera", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - Metodos ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2)
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        
        if (buttonIndex == 0)
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if (buttonIndex == 1)
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.newMedia = YES;
        }
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        CropViewController *imageEditor = [[CropViewController alloc] initWithNibName:@"CropView" bundle:nil];
        imageEditor.sourceImage = image;
        imageEditor.checkBounds = YES;
        imageEditor.rotateEnabled = YES;
        
        imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled){
            
            if (!canceled)
            {
                NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.05f);
                [self uploadImage:imageData];
                
                if (self.newMedia)
                    UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
            }
            
            [picker dismissViewControllerAnimated:YES completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [picker setNavigationBarHidden:NO animated:YES];
        };
        
        [picker pushViewController:imageEditor animated:YES];
        [picker setNavigationBarHidden:YES animated:NO];
    }
}

-(void)uploadImage:(NSData*)imageData
{
    PFFile *imageFile = [PFFile fileWithName:[self.moldura.titulo stringByAppendingString:@".jpg"] data:imageData];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.HUD.delegate = self;
    self.HUD.mode = MBProgressHUDModeDeterminate;
    self.HUD.labelText = @"Carregando";
    
    [self.HUD show:YES];

    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [self.HUD hide:YES];
            
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.HUD];
            
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            
            self.HUD.delegate = self;

            Foto *foto = [Foto object];
            foto.arquivo = imageFile;
            
            PFUser *user = [PFUser currentUser];
            
            foto.ACL = [PFACL ACLWithUser:user];
            foto.usuario = user;
            NSIndexPath* indexPath = [self.collectionView indexPathsForSelectedItems][0];
            foto.moldura = [self.arrMolduras objectAtIndex:indexPath.item];
            
            [foto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    NSLog(@"Foto salva com sucesso!");
                }
                else
                {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else
        {
            [self.HUD hide:YES];
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        self.HUD.progress = (float)percentDone/100;
    }];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Erro"
                              message: @"Falha ao salvar imagem no albúm"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Metodos HUD Delegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
