/*!
 @file AKInterface.h
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理するクラスを定義する。
 */

#import "AKInterface.h"

// スライド入力の誤差許容範囲


/*!
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理する。
 */
@implementation AKInterface

@synthesize menuItems = menuItems_;

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // メンバの初期化を行う
    enableTag_ = 0;
    
    // メニュー項目格納用配列を生成する
    self.menuItems = [NSMutableArray array];

    return self;
}

/*!
 @brief 項目数を指定した初期化処理
 
 メニュー項目数を指定した初期化処理。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithCapacity:(NSInteger)capacity
{
    // スーパークラスの初期化処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // メンバの初期化を行う
    enableTag_ = 0;
    
    // メニュー項目格納用配列を生成する
    self.menuItems = [NSMutableArray arrayWithCapacity:capacity];
    
    return self;
}

/*!
 @brief 項目数を指定したコンビニエンスコンストラクタ
 
 メニュー項目を指定したコンビニエンスコンストラクタ。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)interfaceWithCapacity:(NSInteger)capacity
{
    return [[[[self class] alloc] initWithCapacity:capacity] autorelease];
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.menuItems = nil;
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief 有効タグの取得
 
 有効化するアイテムのタグを取得する。
 タグ1個だけを有効化しているときに使用する。
 @return 有効化するアイテムのタグ
 */
- (NSUInteger)enableTag
{
    return enableTag_;
}

/*!
 @brief 有効タグの設定
 
 有効化するアイテムのタグを設定する。
 有効化したアイテムのみを表示状態にする。
 @param enableItemTag 有効化するアイテムのタグ
 */
- (void)setEnableTag:(NSUInteger)enableTag
{
    // 有効化タグに値を設定する
    enableTag_ = enableTag;
    
    // メニュー項目の表示非表示に設定内容を反映する
    [self updateVisible];
}

/*!
 @brief レイヤー表示時処理
 
 レイヤーが表示された際の処理。タッチイベント処理を開始する。
 */
- (void)onEnter
{
    AKLog(1, @"onEnter start");
    
    // 親クラスの処理を呼び出す
    [super onEnter];

    // タッチイベント処理を開始する
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

    AKLog(1, @"onEnter end");
}

/*!
 @brief タッチ開始処理
 
 タッチが開始されたときの処理。
 @param touch タッチ情報
 @param event イベント情報
 @return タッチイベントを処理するかどうか
 */
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // メニュー項目が登録されていない場合は処理を終了する
    if (self.menuItems == nil) {
        AKLog(1, @"メニュー項目なし");
        return YES;
    }
    
    // 画面上のタッチ位置を取得する
    CGPoint locationInView = [touch locationInView:[touch view]];
    
    // cocos2dの座標系に変換する
    CGPoint location = [[CCDirector sharedDirector] convertToGL:locationInView];
    
    AKLog(0, @"location = (%f, %f)", location.x, location.y);
    
    // 各項目の選択処理を行う
    for (AKMenuItem *item in [self.menuItems objectEnumerator]) {
        
        // 有効な項目で選択されている場合は処理を行う
        if ((item.tag & self.enableTag || item.tag == 0) && [item isSelectPos:location]) {
            
            AKLog(0, @"tag = %d action = %@", item.tag, NSStringFromSelector(item.action));
            
            // スライド入力の場合
            if (item.type == kAKMenuTypeSlide) {
                
                // まだスライド開始していない場合は開始する
                if (item.touch == nil) {
                    item.touch = touch;
                    item.prevPoint = location;
                    [self.parent performSelector:item.action withObject:item];
                    return YES;
                }
                // すでにスライド開始している場合は処理しない
                else {
                    continue;
                }
            }
            
            // 選択されていれば親ノードにイベントを送信する
            [self.parent performSelector:item.action withObject:item];
            
            break;
        }
    }
    
    return YES;
}

/*!
 @brief タッチ中断処理
 
 タッチが中断された時の処理。
 @param touch タッチ情報
 @param event イベント情報
 */
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    AKLog(0, @"start");
    
    // キャンセルするメニュー項目を検索する
    for (AKMenuItem *item in [self.menuItems objectEnumerator]) {
        
        // メニュー項目のタッチイベントとキャンセルされたタッチイベントが一致した場合
        if (item.touch == touch) {
            
            // 最後のイベントを実行する
            [self.parent performSelector:item.action withObject:item];

            // タッチ情報をクリアする
            item.touch = nil;
            
            break;
        }
    }
    
    AKLog(0, @"end");
}

/*!
 @brief タッチ終了処理
 
 タッチが終了された時の処理。
 @param touch タッチ情報
 @param event イベント情報
 */
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    AKLog(0, @"start");

    // 終了するメニュー項目を検索する
    for (AKMenuItem *item in [self.menuItems objectEnumerator]) {
        
        // メニュー項目のタッチイベントと終了されたタッチイベントが一致した場合
        if (item.touch == touch) {
            
            AKLog(0, @"タッチ入力終了");

            // 最後のイベントを実行する
            [self.parent performSelector:item.action withObject:item];
            
            // タッチ情報をクリアする
            item.touch = nil;
            
            break;
        }
    }

    AKLog(0, @"end");
}

/*!
 @brief タッチ移動処理
 
 タッチが移動された時の処理。
 @param touch タッチ情報
 @param event イベント情報
 */
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    AKLog(0, @"start");

    // 移動するメニュー項目を検索する
    for (AKMenuItem *item in [self.menuItems objectEnumerator]) {
        
        // メニュー項目のタッチイベントと移動されたタッチイベントが一致した場合
        if (item.touch == touch) {
            
            // イベントを実行する
            [self.parent performSelector:item.action withObject:item];
            
            // 画面上のタッチ位置を取得する
            CGPoint locationInView = [touch locationInView:[touch view]];
            
            // cocos2dの座標系に変換する
            CGPoint location = [[CCDirector sharedDirector] convertToGL:locationInView];

            // 前回タッチ位置を更新する
            item.prevPoint = location;
            
            return;
        }
    }
    
    AKLog(0, @"メニューに対応していないスライド");
    
    // 画面上のタッチ位置を取得する
    CGPoint locationInView = [touch locationInView:[touch view]];
    
    // cocos2dの座標系に変換する
    CGPoint location = [[CCDirector sharedDirector] convertToGL:locationInView];
    
    // 一致するメニュー項目がなかった場合に、まだタッチイベントが開始されていない項目がある場合は関連付ける
    for (AKMenuItem *item in [self.menuItems objectEnumerator]) {
        
        AKLog(0 && item.type == kAKMenuTypeSlide, @"touch=%@", item.touch);
        
        // スライド入力以外とすでにタッチイベントが開始されているものは除外する
        if (item.type != kAKMenuTypeSlide || item.touch != nil) {
            continue;
        }
        
        AKSetDebugFlg(0);
        AKLog(AKGetDebugFlg(), @"isSelectedPos=%d", [item isSelectPos:location]);
        AKSetDebugFlg(0);
        
        // 有効な項目で選択されている場合は処理を行う
        if ((item.tag & self.enableTag || item.tag == 0) && [item isSelectPos:location]) {
            
            AKLog(1, @"メニュー項目切り替え");
            
            item.touch = touch;
            item.prevPoint = location;
            [self.parent performSelector:item.action withObject:item];
            return;
        }
    }
    
    AKLog(0, @"end");
}

/*!
 @brief メニュー項目追加
 
 メニュー項目を追加する。
 スライド項目が後ろになるように配列に格納する。
 @param menu メニュー項目
 */
- (void)addMenuItem:(AKMenuItem *)menu
{
    // 追加する項目がスライド入力の場合は末尾に追加する
    if (menu.type == kAKMenuTypeSlide) {
        [self.menuItems addObject:menu];
    }
    // その他の場合は先頭に追加する
    else {
        [self.menuItems insertObject:menu atIndex:0];
    }
}

/*!
 @brief 画像ファイルからメニュー項目作成
 
 画像ファイルを読み込んでスプライトを作成し、同じ位置にメニュー項目を作成する。
 @param filename 画像ファイル名
 @param pos メニュー項目の位置
 @param action ボタンタップ時の処理
 @param z メニュー項目のz座標
 @param tag メニュー項目のタグ
 @return 作成したメニュー項目
 */
- (CCSprite *)addMenuWithFile:(NSString *)filename atPos:(CGPoint)pos action:(SEL)action z:(NSInteger)z tag:(NSUInteger)tag
{
    // メニュー項目の位置と大きさ
    CGRect rect;
    // ボタンの画像
    CCSprite *item = nil;
    
    // ファイル名が指定されている場合は画像ファイルを読み込む
    if (filename != nil) {
        
        // ボタンの画像を読み込む
        item = [CCSprite spriteWithFile:filename];
        assert(item != nil);
        
        // ボタンの位置を設定する
        item.position = pos;
        
        // ボタンをレイヤーに配置する
        [self addChild:item z:z tag:tag];
        
        // メニュー項目の大きさにスプライトのサイズを設定する
        rect.size = item.contentSize;
        
        // メニュー項目の位置をスプライトの左上の端を設定する
        rect.origin = ccp(item.position.x - item.contentSize.width / 2,
                          item.position.y - item.contentSize.height / 2);
        
    }
    // ファイル名が指定されていない場合、メニュー項目の位置と大きさは画面全体とする
    else {
        rect = CGRectMake(0, 0, [AKScreenSize screenSize].width, [AKScreenSize screenSize].height);
    }
    
    // メニュー項目を追加する
    [self addMenuItem:[AKMenuItem itemWithRect:rect
                                          type:kAKMenuTypeButton
                                        action:action
                                           tag:tag]];
    
    // 作成したメニュー項目を返す
    return item;
}

/*!
 @brief メニュー項目の追加
 
 メニュー項目のラベルを作成し、インターフェースに項目を追加する。
 @param menuString メニューのキャプション
 @param pos メニューの位置
 @param action メニュー選択時の処理
 @param z メニュー項目のz座標
 @param tag メニュー項目のタグ
 @param withFrame 枠を付けるかどうか
 @return 作成したメニュー項目
 */
- (AKLabel *)addMenuWithString:(NSString *)menuString
                         atPos:(CGPoint)pos
                        action:(SEL)action
                             z:(NSInteger)z
                           tag:(NSUInteger)tag
                     withFrame:(BOOL)withFrame
{
    // ラベルを作成する
    AKLabel *label = [AKLabel labelWithString:menuString
                                    maxLength:menuString.length
                                      maxLine:1
                                        frame:(withFrame ? kAKLabelFrameButton : kAKLabelFrameNone)];
    
    // ラベルの位置を設定する
    label.position = pos;
        
    // ラベルを画面に配置する
    [self addChild:label z:z tag:tag];
    
    AKLog(0, @"rect=(%f, %f, %f, %f)", label.rect.origin.x, label.rect.origin.y, label.rect.size.width, label.rect.size.height);
    
    // メニュー項目をインターフェースに追加する
    [self addMenuItem:[AKMenuItem itemWithRect:label.rect type:kAKMenuTypeButton action:action tag:tag]];
    
    // 作成したメニュー項目を返す
    return label;
}

// スライド入力作成
/*!
 @brief スライド入力作成
 
 スライド入力を作成する。
 @param rect 位置と大きさ
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 */
- (void)addSlideMenuWithRect:(CGRect)rect
                      action:(SEL)action
                         tag:(NSUInteger)tag
{
    [self addMenuItem:[AKMenuItem itemWithRect:rect type:kAKMenuTypeSlide action:action tag:tag]];
}

/*!
 @brief メニュー項目表示非表示設定
 
 メニュー項目の表示非表示を有効化タグ範囲をもとに設定する。
 有効化タグ範囲内の項目は表示、範囲外の項目は非表示とする。
 */
- (void)updateVisible
{
    // レイヤー上のすべてのノードに対して処理を行う
    CCNode *item = nil;
    CCARRAY_FOREACH(self.children, item) {
        
        // 有効タグならば表示する、タグが0の場合は無条件に表示する
        if ((item.tag == 0) || (item.tag & self.enableTag)) {
            item.visible = YES;
        }
        // 範囲外ならば非表示にする
        else {
            item.visible = NO;
        }
        
        // 個別に表示非表示を設定
        [self updateVisibleItem:item];
    }
}

/*!
 @brief メニュー項目個別表示設定
 
 メニュー項目の表示非表示を有効タグとは別に設定したい場合に個別に設定を行う。
 派生クラスで使用する。
 @param item 設定するメニュー項目
 */
- (void)updateVisibleItem:(CCNode *)item
{
    // 派生クラスで処理を追加する
}

@end
