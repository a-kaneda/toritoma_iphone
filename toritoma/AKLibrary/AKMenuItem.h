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
 @file AKMenuItem.h
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目クラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCommon.h"

/// メニューの種別
enum AKMenuType {
    kAKMenuTypeButton = 0,  ///< ボタン
    kAKMenuTypeMomentary,   ///< モーメンタリボタン
    kAKMenuTypeSlide        ///< スライド入力
};

// メニュー項目クラス
@interface AKMenuItem : NSObject {
    /// 種別
    enum AKMenuType type_;
    /// 位置
    CGRect pos_;
    /// 処理
    SEL action_;
    /// タグ
    NSUInteger tag_;
    /// 前回タッチ位置(スライド入力時に使用)
    CGPoint prevPoint_;
    /// タッチ情報(弱い参照)
    UITouch *touch_;
}

/// 種別
@property (nonatomic)enum AKMenuType type;
/// 処理
@property (nonatomic)SEL action;
/// タグ
@property (nonatomic)NSUInteger tag;
/// 前回タッチ位置(スライド入力時に使用)
@property (nonatomic)CGPoint prevPoint;
/// タッチ情報(弱い参照)
@property (nonatomic, assign)UITouch *touch;

// 矩形指定のメニュー項目生成
- (id)initWithRect:(CGRect)rect type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 座標指定のメニュー項目生成
- (id)initWithPoint:(CGPoint)point size:(NSInteger)size type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 矩形指定のメニュー項目生成のコンビニエンスコンストラクタ
+ (id)itemWithRect:(CGRect)rect type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 座標指定のメニュー項目生成のコンビニエンスコンストラクタ
+ (id)itemWithPoint:(CGPoint)point size:(NSInteger)size type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 項目選択判定
- (BOOL)isSelectPos:(CGPoint)pos;

@end
