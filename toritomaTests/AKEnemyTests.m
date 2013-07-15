/*
 * Copyright (c) 2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "AKEnemyTests.h"
#import "ccMacros.h"

@implementation AKEnemyTests


- (void)setUp
{
    [super setUp];
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
	[director_ setDisplayStats:NO];
	[director_ setAnimationInterval:1.0/60];
	CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]
                                     pixelFormat:kEAGLColorFormatRGB565
                                     depthFormat:0 
                              preserveBackbuffer:NO
                                      sharegroup:nil
                                   multiSampling:NO
                                 numberOfSamples:0
                          ];
	[director_ setView:__glView];
	[director_ setDelegate:self];
	director_.wantsFullScreenLayout = YES;
	if( ! [director_ enableRetinaDisplay:NO] )
		CCLOG(@"Retina Display Not supported");
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	[window_ addSubview:navController_.view];
	[window_ makeKeyAndVisible];
}

- (void)tearDown
{
    CC_DIRECTOR_END();
    [super tearDown];
}

/*
 障害物がない場合に移動しないことを確認する。
 */
- (void)testCheckBlockPosition_1
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(50, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];

    STAssertEquals(newPoint.x, 50.0f, @"障害物がないのに移動した");
    STAssertEquals(newPoint.y, 50.0f, @"障害物がないのに移動した");
}

/*
 左側にしか障害物がない場合は左に移動することを確認する。
 */
- (void)testCheckBlockPosition_2
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:30.0f y:30.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(50, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 30.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 62.0f, @"正しい位置に移動していない");
}

/*
 右側にしか障害物がない場合は右に移動することを確認する。
 */
- (void)testCheckBlockPosition_3
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:60.0f y:30.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(50, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 60.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 62.0f, @"正しい位置に移動していない");
}

/*
 逆さま。左側にしか障害物がない場合は左に移動することを確認する。
 */
- (void)testCheckBlockPosition_4
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:30.0f y:232.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(50, 190) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 30.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 200.0f, @"正しい位置に移動していない");
}

/*
 逆さま。右側にしか障害物がない場合は右に移動することを確認する。
 */
- (void)testCheckBlockPosition_5
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:60.0f y:232.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(50, 190) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 60.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 200.0f, @"正しい位置に移動していない");
}

/*
 左側が1ブロック上、左方向への移動中に右に移動することを確認する。
 */
- (void)testCheckBlockPosition_6
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:48.0f];
    [data createBlock:1 x:48.0f y:16.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(47, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 48.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 48.0f, @"正しい位置に移動していない");
}

/*
 左側が1ブロック上、右方向への移動中に左に移動することを確認する。
 */
- (void)testCheckBlockPosition_7
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:48.0f];
    [data createBlock:1 x:48.0f y:16.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(17, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 16.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 80.0f, @"正しい位置に移動していない");
}

/*
 右側が1ブロック上、左方向への移動中に右に移動することを確認する。
 */
- (void)testCheckBlockPosition_8
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:16.0f];
    [data createBlock:1 x:48.0f y:48.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(47, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 48.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 80.0f, @"正しい位置に移動していない");
}

/*
 右側が1ブロック上、右方向への移動中に左に移動することを確認する。
 */
- (void)testCheckBlockPosition_9
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:16.0f];
    [data createBlock:1 x:48.0f y:48.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(16, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 16.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 48.0f, @"正しい位置に移動していない");
}

/*
 逆さま。左側が1ブロック上、左方向への移動中に右に移動することを確認する。
 */
- (void)testCheckBlockPosition_10
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:232.0f];
    [data createBlock:1 x:48.0f y:200.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(47, 180) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 48.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 168.0f, @"正しい位置に移動していない");
}

/*
 逆さま。左側が1ブロック上、右方向への移動中に左に移動することを確認する。
 */
- (void)testCheckBlockPosition_11
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:232.0f];
    [data createBlock:1 x:48.0f y:200.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(17, 180) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 16.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 200.0f, @"正しい位置に移動していない");
}

/*
 逆さま。右側が1ブロック上、左方向への移動中に右に移動することを確認する。
 */
- (void)testCheckBlockPosition_12
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:200.0f];
    [data createBlock:1 x:48.0f y:232.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(47, 50) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 48.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 200.0f, @"正しい位置に移動していない");
}

/*
 逆さま。右側が1ブロック上、右方向への移動中に左に移動することを確認する。
 */
- (void)testCheckBlockPosition_13
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:200.0f];
    [data createBlock:1 x:48.0f y:232.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(17, 50) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 16.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 168.0f, @"正しい位置に移動していない");
}

/*
 左側が1/2ブロック上、横方向は移動せず、高い方のブロックに縦方向は合わせることを確認する。
 */
- (void)testCheckBlockPosition_14
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:48.0f];
    [data createBlock:1 x:48.0f y:32.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(30, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 30.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 80.0f, @"正しい位置に移動していない");
}

/*
 右側が1/2ブロック上、横方向は移動せず、高い方のブロックに縦方向は合わせることを確認する。
 */
- (void)testCheckBlockPosition_15
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:32.0f];
    [data createBlock:1 x:48.0f y:48.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(30, 50) size:CGSizeMake(32, 32) isReverse:NO data:data];
    
    STAssertEquals(newPoint.x, 30.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 80.0f, @"正しい位置に移動していない");
}


/*
 逆さま。左側が1/2ブロック上、横方向は移動せず、低い方のブロックに縦方向は合わせることを確認する。
 */
- (void)testCheckBlockPosition_16
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:216.0f];
    [data createBlock:1 x:48.0f y:200.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(30, 180) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 30.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 168.0f, @"正しい位置に移動していない");
}

/*
 逆さま。右側が1/2ブロック上、横方向は移動せず、低い方のブロックに縦方向は合わせることを確認する。
 */
- (void)testCheckBlockPosition_17
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:5 x:16.0f y:240.0f];
    [data createBlock:4 x:48.0f y:272.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(47, 180) size:CGSizeMake(32, 32) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 47.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 224.0f, @"正しい位置に移動していない");
}

/*
 逆さま。右側が1/2ブロック上、横方向は移動せず、低い方のブロックに縦方向は合わせることを確認する。
 */
- (void)testCheckBlockPosition_18
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:4 x:303.0f y:240.0f];
    [data createBlock:5 x:335.0f y:240.0f];
    
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(304, 232) size:CGSizeMake(32, 16) isReverse:YES data:data];
    
    STAssertEquals(newPoint.x, 304.0f, @"正しい位置に移動していない");
    STAssertEquals(newPoint.y, 216.0f, @"正しい位置に移動していない");
}

/*
 障害物がひとつもない場合にnilが返されることを確認する。
 */
- (void)testGetBlockAtFeetAtX_1
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:16.0f from:64.0f isReverse:NO blocks:data.blocks];
    
    STAssertNil(blockAtFeet, @"障害物がない場合にnil以外が返された");
}

/*
 配置フラグが立っていない障害物は除外されることを確認する。
 */
- (void)testGetBlockAtFeetAtX_2
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:16.0f];
    
    for (AKCharacter *block in [data.blocks objectEnumerator]) {
        block.isStaged = NO;
    }

    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:16.0f from:64.0f isReverse:NO blocks:data.blocks];
    
    STAssertNil(blockAtFeet, @"配置フラグが立っていない障害物が検索対象になっている");
}

/*
 下方向の検索。同じ大きさの障害物の比較。1個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_3
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:48.0f];
    [data createBlock:1 x:48.0f y:16.0f];
    [data createBlock:1 x:16.0f y:240.0f];
    [data createBlock:1 x:48.0f y:200.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:NO blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 16.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 48.0f, @"正しい障害物が取得できていない");
}

/*
 下方向の検索。同じ大きさの障害物の比較。2個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_4
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:16.0f];
    [data createBlock:1 x:48.0f y:48.0f];
    [data createBlock:1 x:16.0f y:200.0f];
    [data createBlock:1 x:48.0f y:240.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:NO blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 48.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 48.0f, @"正しい障害物が取得できていない");
}

/*
 上方向の検索。同じ大きさの障害物の比較。1個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_5
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:48.0f];
    [data createBlock:1 x:48.0f y:16.0f];
    [data createBlock:1 x:16.0f y:200.0f];
    [data createBlock:1 x:48.0f y:240.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:YES blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 16.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 200.0f, @"正しい障害物が取得できていない");
}

/*
 上方向の検索。同じ大きさの障害物の比較。2個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_6
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:16.0f];
    [data createBlock:1 x:48.0f y:48.0f];
    [data createBlock:1 x:16.0f y:240.0f];
    [data createBlock:1 x:48.0f y:200.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:YES blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 48.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 200.0f, @"正しい障害物が取得できていない");
}

/*
 下方向の検索。違う大きさの障害物の比較。1個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_7
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:16.0f];
    [data createBlock:3 x:48.0f y:16.0f];
    [data createBlock:1 x:16.0f y:200.0f];
    [data createBlock:3 x:48.0f y:200.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:NO blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 16.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 16.0f, @"正しい障害物が取得できていない");
}

/*
 下方向の検索。違う大きさの障害物の比較。2個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_8
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:3 x:16.0f y:16.0f];
    [data createBlock:1 x:48.0f y:16.0f];
    [data createBlock:3 x:16.0f y:200.0f];
    [data createBlock:1 x:48.0f y:200.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:NO blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 48.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 16.0f, @"正しい障害物が取得できていない");
}

/*
 上方向の検索。違う大きさの障害物の比較。1個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_9
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:1 x:16.0f y:16.0f];
    [data createBlock:3 x:48.0f y:16.0f];
    [data createBlock:1 x:16.0f y:200.0f];
    [data createBlock:3 x:48.0f y:200.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:YES blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 16.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 200.0f, @"正しい障害物が取得できていない");
}

/*
 上方向の検索。違う大きさの障害物の比較。2個目が対象の場合。
 */
- (void)testGetBlockAtFeetAtX_10
{
    AKPlayData *data = [[[AKPlayData alloc] initWithScene:nil] autorelease];
    [data createBlock:3 x:16.0f y:24.0f];
    [data createBlock:1 x:48.0f y:16.0f];
    [data createBlock:3 x:16.0f y:208.0f];
    [data createBlock:1 x:48.0f y:200.0f];
    
    AKCharacter *blockAtFeet = [AKEnemy getBlockAtFeetAtX:32.0f from:70.0f isReverse:YES blocks:data.blocks];
    
    STAssertNotNil(blockAtFeet, @"障害物の取得ができていない");
    STAssertEquals(blockAtFeet.positionX, 48.0f, @"正しい障害物が取得できていない");
    STAssertEquals(blockAtFeet.positionY, 200.0f, @"正しい障害物が取得できていない");
}
@end
