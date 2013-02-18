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
/*!
 @file AKFont.h
 @brief フォント管理クラス
 
 フォント情報を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCommon.h"

// フォントサイズ
extern const NSInteger kAKFontSize;

// フォント管理クラス
@interface AKFont : NSObject {
    /// 文字のテクスチャ内の位置情報
    NSDictionary *fontMap_;
    /// フォントテクスチャ
    CCTexture2D *fontTexture_;
}

/// 文字のテクスチャ内の位置情報
@property (nonatomic, retain)NSDictionary *fontMap;
/// フォントテクスチャ
@property (nonatomic, retain)CCTexture2D *fontTexture;

// シングルトンオブジェクトの取得
+ (AKFont *)sharedInstance;
// フォントサイズ取得
+ (NSInteger)fontSize;
// 文字のテクスチャ内の位置を取得する
- (CGRect)rectOfChar:(unichar)c;
// キーからテクスチャ内の位置を取得する
- (CGRect)rectByKey:(NSString *)key;
// 文字のスプライトフレームを取得する
- (CCSpriteFrame *)spriteFrameOfChar:(unichar)c isReverse:(BOOL)isReverse;
// キーからスプライトフレームを取得する
- (CCSpriteFrame *)spriteFrameWithKey:(NSString *)key isReverse:(BOOL)isReverse;
@end
