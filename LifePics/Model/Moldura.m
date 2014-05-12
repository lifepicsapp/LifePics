//
//  Moldura.m
//  LifePics
//
//  Created by Gabriel Moraes on 14/04/14.
//  Copyright (c) 2014 Gabriel Moraes. All rights reserved.
//

#import "Moldura.h"
#import <Parse/PFObject+Subclass.h>

@implementation Moldura

@dynamic titulo, legenda, tema, frase;

+(NSString *)parseClassName
{
    return NSStringFromClass([self class]);
}

-(NSString *)titulo
{
    return [self getLocalized:self.tema];
}

-(NSString *)legenda
{
    return [self getLocalized:self.frase];
}

- (NSString*)getLocalized:(PFObject*)object
{
    NSString* retorno;
    for (NSString* language in [NSLocale preferredLanguages])
    {
        retorno = [object valueForKey:language];
        if (retorno)
        {
            goto stopLoop;
        }
    }
    stopLoop:
    return retorno;
}

@end
