//
//  CropViewController.h
//  LifePics
//
//  Created by Gabriel Moraes on 13/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "HFImageEditorViewController+Private.h"
#import "CropViewController.h"

@interface CropViewController ()

@end

@implementation CropViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.cropRect = CGRectMake(0,0,320,320);
        self.minimumScale = 0.2;
        self.maximumScale = 10;
    }
    return self;
}

#pragma mark - Hooks

- (void)startTransformHook
{
    self.saveButton.tintColor = [UIColor colorWithRed:0 green:49/255.0f blue:98/255.0f alpha:1];
}

- (void)endTransformHook
{
    self.saveButton.tintColor = [UIColor colorWithRed:0 green:128/255.0f blue:1 alpha:1];
}

@end
