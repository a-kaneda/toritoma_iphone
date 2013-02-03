/*!
 @file AKPlayerShot.h
 @brief 自機弾クラス定義
 
 自機の発射する弾のクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKCharacter.h"

@interface AKPlayerShot : AKCharacter {
    
}

// 自機弾生成
- (void)createPlayerShotAtX:(NSInteger)x y:(NSInteger)y parent:(CCNode *)parent;

@end
