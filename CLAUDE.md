# CLAUDE.md

## プロジェクト概要

### アプリ名

**カチャリ / Kachari**

### コンセプト

3歳前後の子どもを対象とした、iPadネイティブの「お仕事ごっこ × タイピング」アプリ。

パパやママがパソコンで仕事をしている姿を見て、

**「自分もお仕事してみたい」**

と思う子どもが、キーボードを使って実際に仕事をしているような体験を楽しめることを目的とする。

一般的なタイピング練習アプリのように、最初から正確なキー入力や入力速度を求めない。

初期段階では、

**キーを押す
→ 画面が反応する
→ 仕事が進む
→ 完成する
→ 自分で最後の操作をする
→ 褒められる**

という体験を最重要とする。

---

# 1. プロダクトの最重要方針

以下の優先順位を守ること。

1. 3歳前後の子どもが直感的に使える
2. 「パパ・ママみたいに仕事をしている」という感覚を得られる
3. 子ども自身が「できた」と感じられる
4. 説明されなくても操作できる
5. 安全に利用できる
6. 保護者が安心して子どもに渡せる
7. 将来的に本当のタイピング学習へ自然につなげられる

初期段階では、

**教育効果よりも、楽しさ・仕事をしている感覚・達成感を優先する。**

---

# 2. 対象ユーザー

## メインユーザー

3歳前後の子ども。

UI・UX設計では以下を前提とする。

* 文字を読めない可能性が高い
* アルファベットを理解していない可能性が高い
* キーボード配列を理解していない
* 複雑な画面遷移を理解しにくい
* 長時間集中することが難しい
* 小さなボタンは操作しにくい
* 説明文を読むことを前提にしない
* 視覚・音・アニメーションによるフィードバックを重視する
* 正解・不正解より「操作すると何かが起きる」ことを重視する

---

## サブユーザー

子どもの保護者。

保護者は以下を担当する。

* 初期設定
* 子どもの名前設定
* メール送信先の設定
* 個人情報の管理
* 将来的なお仕事内容のカスタマイズ
* 課金機能を導入する場合の管理

子ども向け画面と保護者向け画面は明確に分離する。

---

# 3. 対応プラットフォーム

## 対象

* iPad
* iPadOS
* Swiftによるネイティブアプリ

iPhone対応は現時点では対象外とする。

コードを書く際も、不必要にiPhone向けUIへ一般化しない。

---

# 4. 技術スタック

原則として以下を使用する。

* Swift
* SwiftUI
* Observation
* Swift Concurrency
* Swift Testing
* Apple純正Framework

状態管理にはSwiftUIおよびObservationの標準的な仕組みを優先する。

非同期処理には、

* async / await
* Task
* actor
* Sendable

などSwift Concurrencyを優先する。

---

# 5. 外部ライブラリ方針

外部ライブラリは必要性が明確な場合のみ導入する。

「便利そう」
「将来使うかもしれない」
「一般的に使われている」

という理由だけでは追加しない。

特に理由なく、

* RxSwift
* Combineベースの独自状態管理
* TCA
* DI Framework
* Networking Framework
* 独自Navigation Framework

などを導入しない。

TCAなどの採用が適切と判断した場合は、実装前に理由・メリット・デメリットを提示すること。

---

# 6. アーキテクチャ方針

## 基本方針

**SwiftUI + Observationを中心に、Feature単位で構成する。**

特定のアーキテクチャパターンへコードを無理に当てはめない。

基本イメージ：

```text
Feature
├── View
├── Model / ViewModel
├── State
└── 必要に応じた補助ロジック
```

単純なFeatureでは、

```text
View
↓
@Observable Model
↓
Service
```

程度でよい。

---

# 7. MVVMについて

基本的にはMVVM寄りの設計を採用する。

ただし、

**「すべてのViewにViewModelを作る」ことをルールにしない。**

Viewが単純で、状態やロジックも少ない場合はSwiftUIの標準的な状態管理だけで実装してよい。

以下のような場合にModel / ViewModelへの分離を検討する。

* 状態遷移が複雑
* 非同期処理が存在する
* UI以外のロジックが増えている
* Unit Testを書きたいロジックがある
* Viewのbodyが状態管理ロジックで読みにくくなっている

---

# 8. Clean Architectureについて

Clean Architectureの考え方は採用するが、

**最初から全Featureを厳密なClean Architectureにしない。**

必要になった段階で、

```text
Presentation
↓
Domain
↓
Data
```

へ分離する。

例えば：

```text
MailJobView
↓
MailJobModel
↓
SendMailUseCase
↓
MailRepository
↓
MailAPIClient
```

ただし、以下を形式的に作成しない。

```text
UseCase
Repository
Protocol
Mapper
Entity
DTO
```

単純な処理に対してレイヤーを増やすことを禁止する。

---

# 9. アーキテクチャ判断の基準

以下の順番で判断する。

1. 読みやすいか
2. SwiftUIの自然なデータフローに沿っているか
3. テストしやすいか
4. 責務が明確か
5. 必要十分な分離になっているか
6. 将来変更しやすいか

以下を避ける。

* Architecture Astronaut的な過剰設計
* 将来予測による抽象化
* Protocolの乱用
* 1実装しか存在しない型の無意味なProtocol化
* レイヤーを作ること自体を目的にした設計

---

# 10. 推奨ディレクトリ構成

初期段階では以下を基本とする。

```text
Kachari
├── App
│   └── KachariApp.swift
│
├── Features
│   ├── MailJob
│   │   ├── MailJobView.swift
│   │   ├── MailJobModel.swift
│   │   └── MailJobState.swift
│   │
│   └── ParentSettings
│       ├── ParentSettingsView.swift
│       └── ParentSettingsModel.swift
│
├── Services
│   └── MailService.swift
│
├── Models
│
├── Components
│
├── Resources
│
└── Tests
```

必要になった場合のみ、

```text
Domain
Data
Repositories
UseCases
API
```

などを追加する。

---

# 11. Feature First

コードは技術レイヤー単位よりも、原則としてFeature単位でまとめる。

推奨：

```text
Features
├── MailJob
├── DocumentJob
├── ProgrammingJob
└── ParentSettings
```

避ける：

```text
Views
ViewModels
Models
Controllers
```

アプリが大きくなった場合も、Feature単位で関連コードを追いやすい構成を優先する。

---

# 12. 状態管理

互いに排他的な状態はenumで表現する。

推奨：

```swift
enum MailJobState {
    case ready
    case typing
    case completed
    case sending
    case sent
    case failed
}
```

避ける：

```swift
var isTyping: Bool
var isCompleted: Bool
var isSending: Bool
var isSent: Bool
var hasFailed: Bool
```

複数のBooleanによって不正な状態の組み合わせが発生する設計を避ける。

---

# 13. Observation

新規コードでは、原則としてObservationを利用する。

例：

```swift
@Observable
final class MailJobModel {
    var state: MailJobState = .ready
    var displayedText = ""
    var typingProgress = 0
}
```

SwiftUIの状態管理と相性のよい実装を優先する。

理由なくObservableObject / @Publishedを新規導入しない。

既存コードとの整合性が必要な場合は例外とする。

---

# 14. Swift Concurrency

非同期処理にはSwift Concurrencyを使用する。

推奨：

```swift
func sendMail() async throws {
    try await mailService.send(...)
}
```

理由なくCompletion Handlerを新規作成しない。

必要に応じて、

```swift
actor
Sendable
@MainActor
```

を適切に利用する。

Concurrency Warningを無視しない。

---

# 15. MainActor

UIに関連する状態を管理する型については、必要に応じて`@MainActor`を利用する。

例：

```swift
@MainActor
@Observable
final class MailJobModel {
    // ...
}
```

ただし、すべての型へ機械的に`@MainActor`を付けない。

---

# 16. Dependency Injection

依存関係は外部から注入できる構造を優先する。

例：

```swift
final class MailJobModel {
    private let mailService: MailService

    init(mailService: MailService) {
        self.mailService = mailService
    }
}
```

ただし、DI Frameworkは原則使用しない。

Initializer InjectionなどSwift標準のシンプルな方法を優先する。

---

# 17. Protocolの使用

Protocolは必要性がある場合のみ使用する。

利用を検討するケース：

* 複数実装が存在する
* テストで差し替える必要がある
* 外部依存との境界を作る意味が明確
* Domain層からData層を分離する必要がある

単純にMockを作る目的だけでProtocolを大量作成しない。

---

# 18. Repository

Repositoryはデータ取得元を抽象化する必要が出た場合に導入する。

例えば、

```text
MailRepository
├── Backend API
└── Local Cache
```

など複数データソースが存在する場合は有効。

Backend APIを1回呼ぶだけのFeatureに、形式的にRepositoryを追加しない。

---

# 19. UseCase

UseCaseはビジネスルールが独立した意味を持つ場合に導入する。

例えば、

```text
SendMailUseCase
CreateJobMessageUseCase
CompleteJobUseCase
```

など。

単純なServiceメソッドを呼ぶだけの場合は、UseCaseを作成しなくてもよい。

---

# 20. MVP

最初のリリースでは、

**「メールのおしごと」**

1機能に集中する。

MVPはここでは、

**Minimum Viable Product**

の意味であり、Model-View-Presenterの意味ではない。

---

# 21. MVP基本フロー

```text
アプリ起動
↓
お仕事開始
↓
パパ / ママなど送信相手を選択
↓
メールを書く
↓
キーボードを入力
↓
文章が完成
↓
「おくる」
↓
実際にメール送信
↓
成功演出
↓
「おしごと かんりょう！」
```

---

# 22. メールのおしごと

3歳児に本当の文章をタイプさせない。

子どもがキーボードのどのキーを押しても、事前に用意された文章が順番に入力されていく。

例：

送信文章：

```text
パパへ

きょうも
おしごと がんばってね！
```

実際の入力：

```text
f j d k a l s
```

画面上：

```text
きょうも
おしごと がんばってね！
```

入力されたキーそのものは本文として使用しない。

---

# 23. タイピング進行

初期段階では、

**キー入力回数 = お仕事の進行**

として扱う。

例えば1キー入力ごとに、文章を1文字または一定単位進める。

目的は、

**キーボードを操作して文章を作っている感覚**

を与えることである。

---

# 24. メール送信

メールは疑似送信ではなく、保護者が登録したメールアドレスへ実際に送信する。

原則：

```text
iPad App
↓
Backend API
↓
Mail Delivery Service
↓
保護者
```

iPadからSMTPへ直接接続しない。

メールアドレスを子ども向け画面へ表示しない。

---

# 25. メール本文

MVPでは自由入力メールを提供しない。

メール本文はアプリ側で管理するテンプレートを使用する。

子どもが入力したキー文字列を、そのまま外部へ送信しない。

---

# 26. 保護者設定

保護者が以下を設定できる。

* 子どもの名前
* 送信先表示名
* 送信先メールアドレス

例：

```text
パパ
example@example.com
```

子ども側では、

```text
パパ
```

のみを表示する。

---

# 27. ペアレンタルゲート

保護者設定には、子どもが容易にアクセスできない仕組みを用意する。

例：

* 特定操作の長押し
* 複数ステップ操作
* 大人向け問題

具体的な方式は実装段階で検討する。

---

# 28. 子ども向けUI

## 原則

* 大きな操作対象
* 十分なタップ領域
* 文字を読まなくても操作できる
* アイコンを活用する
* 状態変化を視覚的に伝える
* 効果音を適切に利用する
* 複雑なNavigationを避ける

---

# 29. デザインの世界観

単なる幼児向けゲーム画面にはしない。

目指すのは、

**「子ども専用の本物っぽい仕事ツール」**

である。

以下をモチーフとして利用する。

* メール
* 書類
* コードエディタ
* 表計算
* カレンダー
* ビデオ会議

見た目は仕事ツールらしくしつつ、操作だけを3歳児向けに簡略化する。

---

# 30. お仕事の基本構造

1つのお仕事は30秒〜2分程度で完了できるようにする。

基本構造：

```text
開始
↓
操作
↓
仕事が進む
↓
完成
↓
最後の操作
↓
成功
```

最後の操作は必ず可能な限り子ども自身に行わせる。

例：

メール：

```text
📨 おくる
```

書類：

```text
🔴 ハンコ
```

プログラム：

```text
▶︎ うごかす
```

---

# 31. 成功演出

お仕事を完了した瞬間を最も強く演出する。

例：

* 紙飛行機が飛ぶ
* チェックマーク
* 拍手
* 星
* キャラクターのリアクション
* 音声
* 「おしごと かんりょう！」

毎キー入力で過剰な演出を行わない。

---

# 32. アニメーション

SwiftUI標準APIを優先する。

目的のないアニメーションを追加しない。

Reduce Motionを考慮する。

アニメーションは、

* 操作へのフィードバック
* 状態変化
* 完了演出

など、意味がある箇所に利用する。

---

# 33. エラーハンドリング

技術的なエラー情報を子どもへそのまま表示しない。

避ける：

```text
HTTP 500
NetworkConnectionLost
DecodingError
```

子ども向け：

```text
うまく おくれなかったよ
もういちど やってみよう
```

技術的な詳細はログへ記録する。

---

# 34. プライバシー

幼児向けアプリであることを常に意識する。

以下を原則とする。

* 必要最小限の個人情報のみ扱う
* 子どもの個人情報を不必要に取得しない
* 位置情報を取得しない
* 広告トラッキングを導入しない
* 入力キーの内容を分析目的で保存しない
* メールアドレスを子ども画面へ表示しない
* 不要なAnalyticsを導入しない
* 外部URLへ自由にアクセスさせない

---

# 35. セキュリティ

秘密情報をコードへハードコードしない。

以下をGitへCommitしない。

* API Key
* Secret
* Token
* SMTP Credential
* Production Endpoint Credential

メール送信に必要な秘密情報はBackend側で管理する。

---

# 36. ローカルデータ

機密性が低い設定：

```text
UserDefaults
AppStorage
```

などを検討する。

機密性が高い情報：

```text
Keychain
Backend
```

を利用する。

ただし、保存方法はデータの性質を確認して判断する。

---

# 37. Networking

Backend通信はSwift Concurrencyベースで実装する。

原則として`URLSession`を利用する。

外部Networking Libraryは必要性が明確になるまで導入しない。

API処理とUI処理を直接結合しない。

---

# 38. API設計

iPadからBackendへ、必要最小限の情報のみ送信する。

例えば、

```json
{
  "recipientId": "parent_1",
  "messageId": "work_encouragement"
}
```

のようにし、可能な限りメールアドレスそのものを毎回クライアントから送信しない設計を検討する。

---

# 39. テスト方針

重要なロジックについてUnit Testを書く。

特に以下を優先する。

* タイピング進行
* メッセージ完成判定
* 状態遷移
* メール送信成功
* メール送信失敗
* Retry処理

UIからロジックを分離し、テスト可能な設計にする。

---

# 40. Swift Testing

新規Unit TestではSwift Testingを優先する。

例：

```swift
@Test
func keyPressAdvancesTypingProgress() {
    // ...
}
```

既存のXCTestを無理にすべて移行する必要はない。

---

# 41. UI Test

UI Testでは重要なユーザーフローを優先する。

例：

```text
メールのおしごと開始
↓
キー入力
↓
文章完成
↓
送信
↓
完了画面
```

すべての細かいUIをUI Testする必要はない。

---

# 42. Accessibility

可能な範囲で以下を考慮する。

* VoiceOver
* Reduce Motion
* 十分なコントラスト
* 色だけに依存しない
* 十分なタップ領域

ただし、3歳児向けUXとのバランスを考えて判断する。

---

# 43. 将来的なロードマップ

以下は将来構想であり、要求されない限り実装しない。

## Phase 1

メールのおしごと

* タイピング
* 実メール送信
* 完了演出

## Phase 2

達成要素

* お仕事カード
* 今日のお仕事
* 完了履歴

## Phase 3

書類のおしごと

```text
入力
↓
書類完成
↓
ハンコ
```

## Phase 4

プログラマーのおしごと

```text
入力
↓
コード完成
↓
実行
↓
キャラクターが動く
```

## Phase 5

本当のタイピング学習

```text
どのキーでもOK
↓
指定キーを探す
↓
単語入力
```

## Phase 6

保護者がお仕事を作る

## Phase 7

自分のオフィス

---

# 44. MVPで実装しないもの

要求されない限り以下を実装しない。

* ユーザーアカウント
* SNS
* 子ども同士の通信
* チャット
* 広告
* ランキング
* 課金
* オフィスカスタマイズ
* 複雑なAnalytics
* Cloud同期
* 自由入力メール
* AIチャット
* TCA
* 独自DI Framework
* 大規模Design System

---

# 45. コーディングルール

Swift標準の命名規則に従う。

型：

```swift
MailJobModel
MailService
SendMailRequest
```

変数・関数：

```swift
typingProgress
sendMail()
completeJob()
```

Boolean：

```swift
isCompleted
canSendMail
shouldShowSuccessAnimation
```

避ける：

```swift
flag
tmp
value1
check
data2
```

---

# 46. SwiftUI View

Viewの`body`が巨大にならないようにする。

例：

```swift
struct MailJobView: View {
    var body: some View {
        VStack {
            header
            messageArea
            sendButton
        }
    }
}
```

ただし数行しかないViewを過剰にファイル分割しない。

意味単位で分割する。

---

# 47. Viewへ書いてよい処理

以下のようなUI固有処理はView内でもよい。

* 表示条件
* Animation
* Transition
* Layout
* Focus
* Accessibility modifier

ビジネスルールやAPI通信処理はViewへ直接書かない。

---

# 48. コメント

コードから明確に読み取れることをコメントしない。

避ける：

```swift
// メールを送信する
sendMail()
```

以下の場合にコメントする。

* なぜこの実装なのか
* Apple API特有の制約
* 一見不要に見える処理
* 子ども向けUX特有の理由

---

# 49. Claude Codeへの作業指示

コードを変更する前に、必ず関連する既存実装を確認する。

確認対象：

1. 関連ファイル
2. 現在の状態管理
3. 既存の命名
4. 関連テスト
5. 依存関係
6. 呼び出し元

---

# 50. 最小変更原則

要求された目的を満たすための最小限の変更を優先する。

以下を同時に行わない。

* 関係ないリファクタリング
* 大量Rename
* Architecture変更
* Folder再構成
* Formattingの全面変更

必要な場合は理由を説明する。

---

# 51. 実装後の確認

変更後は可能な限り以下を確認する。

* Buildが成功する
* Compiler Errorがない
* Warningを増やしていない
* Swift Concurrency Warningがない
* 関連テストが成功する
* 既存機能を壊していない

---

# 52. 勝手に機能を追加しない

要求されていない機能を推測して追加しない。

特に、

「将来必要になりそう」

という理由で先行実装しない。

良いアイデアがある場合は、実装せず提案として提示する。

---

# 53. Claude Codeが判断に迷った場合

以下の順番で判断する。

1. 3歳児に理解できるか
2. 子どもが操作しやすいか
3. 「お仕事している感」があるか
4. 達成感があるか
5. 安全か
6. SwiftUIとして自然か
7. テストしやすいか
8. 実装が単純か
9. 将来変更しやすいか

---

# 54. 技術選定の判断

新しい技術・Framework・Architectureを導入するときは、

**「このプロジェクトのどの問題を解決するのか」**

を説明できること。

以下は理由にならない。

* 流行っている
* モダンだから
* 有名だから
* 大規模アプリで使われている
* 将来役立つかもしれない

---

# 55. ポートフォリオとしての品質

このアプリは実際のユーザー体験を最優先する。

同時に、iOS開発者として以下の技術を適切に実践できるコードベースを目指す。

* SwiftUI
* Observation
* Swift Concurrency
* async / await
* actor
* Sendable
* Dependency Injection
* API通信
* 状態管理
* Unit Test
* Swift Testing
* セキュリティ
* プライバシー設計
* 必要に応じたClean Architecture

ただし、

**ポートフォリオのためにアーキテクチャを複雑にしない。**

適切な技術選択と、その理由を説明できることを重視する。

---

# 56. 設計の基本思想

このプロジェクトでは、

**Simple first, separate when needed.**

を基本思想とする。

最初はSwiftUIとObservationを使ってシンプルに実装する。

複雑性が実際に発生してから、

* ViewModel
* UseCase
* Repository
* Protocol
* Domain層

などへ分離する。

将来の複雑性を想像して、現在のコードを複雑にしない。

---

# 57. MVPで最も重要な検証

MVPでは技術的な完成度以上に、子どもが以下の行動をするかを確認する。

* 自分からキーボードを触る
* キー入力に反応する画面を楽しむ
* お仕事を最後まで進める
* 「おくる」ボタンを理解する
* メール送信時に達成感を感じる
* パパ・ママへ本当に届くことを喜ぶ
* もう一度やりたがる

---

# 58. プロダクト判断の最終基準

新しい機能を追加するときは、

**「これはカチャリだからこそ面白いのか？」**

を考える。

一般的な知育アプリやタイピングアプリに存在するという理由だけで追加しない。

カチャリの中心は、

**小さな子どもが、憧れているパパやママの仕事を真似し、自分も本当に仕事をしたと感じられること。**

すべての機能・UI・技術判断は、このコンセプトを支えるために存在する。

