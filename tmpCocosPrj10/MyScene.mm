//
//  MyScene.m
//  tmpCocosPrj10
//
//  Created by Apple on 27.01.13.
//  Copyright (c) 2013 Smarty. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)init {
    self = [super init];
    if (self != nil) {
        
        MyLayer1 *layer1 = [MyLayer1 node];
        [self addChild:layer1];
        
        MyLayer2 *layer2 = [MyLayer2 node];
        [self addChild:layer2];
        
    }
    return self;
}

@end
