//
//  MyLayer1.m
//  tmpCocosPrj10
//
//  Created by Apple on 27.01.13.
//  Copyright (c) 2013 Smarty. All rights reserved.
//


//see http://stackoverflow.com/questions/4578514/is-object-remain-fixed-when-scrolling-background-in-cocos2d

#import "MyLayer1.h"
#import "CCPhysicsSprite.h"

#define PTM_RATIO 32

enum {
	kTagParentNode = 1,
};

@interface MyLayer1()
-(void) initPhysics;
@end

@implementation MyLayer1

-(id) init
{
	if( (self=[super init])) {
		
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        // init physics
		[self initPhysics];

        
        //create both sprite to handle background
        background = [CCSprite spriteWithFile:@"Default.png"];
        background2 = [CCSprite spriteWithFile:@"Default2.png"];
        
        //one the screen and second just next to it
        background.position = ccp(size.width/2, size.height/2);
        //background2.position = ccp(size.width+160, size.height*2);
        background2.position = ccp(size.width/2, -size.height/2);
        
        
        //ofc add them to main layer
        [self addChild:background];
        [self addChild:background2];

        
        spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
		//[self addChild:parent z:0 tag:kTagParentNode];
        [background addChild:parent z:10 tag:kTagParentNode];
        
		[self addNewSpriteAtPosition:ccp(size.width/2, size.height/2)];

        
        //add schedule to move backgrounds
        [self schedule:@selector(scroll:)];

    

	}
	
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// bottom
	
	//groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
    groundBox.Set(b2Vec2(0,s.height/PTM_RATIO/4), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO/4));//lift bottom up to quarter of screen size
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();
	
	kmGLPopMatrix();
}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
    
	//CCNode *parent = [self getChildByTag:kTagParentNode];//sprite independant from bg
    CCNode *parent = [background getChildByTag:kTagParentNode];//move obj with bg

	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];//physical body
    //CCSprite *sprite = [CCSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];//image only
	[parent addChild:sprite];
	
	[sprite setPTMRatio:PTM_RATIO];//uncomment for physic body
	[sprite setBody:body]; //uncomment for physic body
	[sprite setPosition: ccp( p.x, p.y)];
    
}

- (void) scroll:(ccTime)dt {
//    //move them 100*dt pixels to left
//    background.position = ccp( background.position.x - 100*dt, background.position.y );
//    background2.position = ccp( background2.position.x - 100*dt, background.position.y );
//    
//    //reset position when they are off from view.
//    if (background.position.x < -160) {
//        background.position = ccp(480, 480/2);
//    }
//    else if (background2.position.x < -160) {
//        background2.position = ccp(480, 480/2);
//    }
    
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

    
    
    
    
    BOOL flg=FALSE;
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    
	//reset position when they are off from view.
    if (background.position.y - background.contentSize.height/2 >= winSize.height ) {
        background.position = ccp(winSize.width/2, -winSize.height/2);
		background2.position = ccp(winSize.width/2, winSize.height/2);
		flg =TRUE;
    }
    
	if (background2.position.y - background2.contentSize.height/2>= winSize.height) {
        background2.position = ccp(winSize.width/2, -winSize.height/2);
		background.position = ccp(winSize.width/2, winSize.height/2);
		flg =TRUE;
    }
    
	if (!flg) {
		//move them 100*dt pixels to left
		background.position = ccp( background.position.x , background.position.y + 40*dt);
		background2.position = ccp( background2.position.x , background2.position.y + 40*dt);
	}
}

@end
