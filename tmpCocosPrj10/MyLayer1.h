//
//  MyLayer1.h
//  tmpCocosPrj10
//
//  Created by Apple on 27.01.13.
//  Copyright (c) 2013 Smarty. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface MyLayer1 : CCLayer {
    CCSprite *background;
    CCSprite *background2;
    
    CCTexture2D *spriteTexture_;	// weak ref
    b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref

}

@end
