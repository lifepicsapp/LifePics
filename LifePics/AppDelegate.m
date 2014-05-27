//
//  AppDelegate.m
//  LifePics
//
//  Created by Gabriel Moraes on 13/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "HomeViewController.h"
#import "Foto.h"
#import "Moldura.h"
#import "AppUtil.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [Foto registerSubclass];
    [Moldura registerSubclass];
    [Parse setApplicationId:@"Qtku8mihBi4W1RUrlpHfTgpT4tLXcWjQMoCSQctH"
                  clientKey:@"hCakOFPtlsE5Nuo3xd5eW1rKCkyYnKu9c8386VBb"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSString* login = [[PFUser currentUser] valueForKey:@"login"];
        if(!login || [login isEqualToString:@""])
        {
            self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Cadastro"];
        }
        else
        {
            UITabBarController* tabBar = [storyboard instantiateViewControllerWithIdentifier:@"Home"];
            HomeViewController* controller = ((UINavigationController*)tabBar.viewControllers[0]).viewControllers[0];
            controller.abriuLogado = YES;
            self.window.rootViewController = tabBar;
        }
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
}

#pragma mark - Metodos Facebook SDK

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark - Metodos Parse Framework

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setObject:[AppUtil idiomaAtual] forKey:@"idioma"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
