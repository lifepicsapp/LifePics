//
//  HomeViewController.m
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "Moldura.h"
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
    
    cell.lblTitulo.text = moldura.titulo;
    
    return cell;
}

#pragma mark - Metodos CollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Escolher foto" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Biblioteca", @"Câmera", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Metodos ActionSheet Delegat

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
            
            MolduraView* cell = (MolduraView*)[self.collectionView cellForItemAtIndexPath: [self.collectionView indexPathsForSelectedItems][0]];
            cell.imgFoto.image = editedImage;
            
            if (self.newMedia)
                UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
            
            [picker dismissViewControllerAnimated:YES completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [picker setNavigationBarHidden:NO animated:YES];
        };
        
        [picker pushViewController:imageEditor animated:YES];
        [picker setNavigationBarHidden:YES animated:NO];
    }
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

@end
