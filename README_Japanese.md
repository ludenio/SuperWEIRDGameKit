[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# SuperWEIRD Game Kit

こんにちは！[Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) では [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github)（ゲームは [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github) でご覧いただけます）を開発しています。これは、[Defold](https://defold.com) エンジンで制作された、レミングのようなロボットを使ってシステムの設計と自動化を行う協力プレイのゲームです。

開発初期にはビジュアルスタイルやゲームプレイについて多くの実験を行いました。これらが他の開発者の役に立つと考え、実験で作成したコード、テクスチャ、アニメーションをオープンな [CC0](LICENSE) ライセンスで公開することにしました。

このリポジトリには、6種類の異なるビジュアルスタイル（[video](https://youtu.be/RJwOEDY3MP4)）と、ショップ／生産シミュレーターのゲームプレイロジックが含まれています。プレイヤーは顧客の注文をこなし、生産を拡大していきます。[demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github) を遊ぶこともできます。

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

これらのプロトタイプで何を作るか、ぜひ [Discord](https://discord.gg/ludenio) に参加して教えてください。あるいは私たちの [YouTube channel](https://www.youtube.com/@ludenio) もご覧ください。[SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos) など、見どころがたくさんあります。

リンク:
- Discord（毎日います）: https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- 更新情報とテキスト版開発日記のニュースレター: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# パートナー

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD は [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun) の支援を受けて制作されています。Carina Initiatives は、多様なコミュニティの子どもたちに科学や技術へのアクセスを提供することを目指す慈善基金です。彼らは数学を将来のイノベーションの基盤と捉え、数学的才能を鼓舞し育成する団体に資金提供しています。ほかの教育プロジェクトに関心がある方は、Carina Initiatives のパートナーをご覧ください:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# クイックスタート

1. Defold Editor をインストール: https://defold.com
2. リポジトリをクローンまたはダウンロードします。
3. Defold Editor でプロジェクトフォルダを開きます。
4. プロジェクトをビルドして実行します。

注意: Spine アニメーションを編集するには Spine Editor が必要です。

# プロジェクト構成

1. ローディング
   - `loader` — ゲーム起動時に開始され、メモリに常駐し、Collection Proxy を通じてコレクションのロード／アンロードを管理します。起動時にスタートメニューを初期化します。
   - `menu` — ゲーム開始時に表示されるスタートメニュー。

2. コア
   - `main` — 共有ゲームコード。すべてのワールドで使用されるスクリプトやモジュールを含み、ゲームの全ロジックが入っています。
   - `assets` — ゲームアセット。テクスチャ、Spine モデル、タイルマップ、アトラス。各ワールドは固有のビジュアルを持つ `world_1`、`world_2` などのフォルダを持ちます。
   - `worlds` — ワールドのビジュアル設定。コレクションとゲームオブジェクト。各ワールドは `world_1`、`world_2` などの中の個別のコレクションです。

3. 追加
   - `SuperWEIRDGameKit_assets` — 本プロジェクトで使用されるグラフィックと Spine モデルの整理済みセット。

# ワールド管理のロジック

- ワールドの切り替えは `loader` を介して行われ、コレクションのロード／アンロードを担当します。
- ワールドのカスタマイズ: `worlds/world_X` でビジュアルのパラメータやゲームオブジェクトを更新し、`assets/world_X` でグラフィックを更新します。

## 新しいワールドの追加

1. フォルダ `assets/world_N` と `worlds/world_N` を作成します。
2. 既存のワールドからテンプレートをコピーします。
3. ローダー／メニューのコードに新しいワールドを登録します（`main` のロジックを参照）。
4. コレクションとアセットが正しくリンクされていることを確認します。
