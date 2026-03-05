---
name: bump-version
description: Bump VSCode extension version for release with changelog update
allowed-tools: Bash(git tag:*), Bash(git log:*), Read, Edit, Write
---

VSCode拡張機能のバージョンをアップデートし、CHANGELOG・READMEを更新してください。

手順:
1. package.jsonの存在と内容を確認
   - 存在しない場合はエラーメッセージを表示して終了
   - engines.vscodeがあることを確認（VSCode拡張機能かどうか）
   - 現在のバージョンを取得

2. 最後のバージョン変更を特定
   - まずgitタグを確認: `git tag --list 'v*' --sort=-version:refname | head -1`
   - タグがない場合、package.jsonの"version"を変更した最後のコミットを探す
   - `git log -1 --format="%H" -S'"version":' -- package.json`

3. 差分の確認
   - 最後のバージョン変更以降のコミット一覧を取得
   - `git log --oneline {基準点}..HEAD`
   - コミットメッセージと変更ファイルを分析
   - 変更内容をカテゴリ分け（feat, fix, docs, refactor等）

4. バージョン決定
   - $ARGUMENTSが指定されている場合:
     - "patch", "minor", "major" → 現在のバージョンから計算
     - "x.y.z"形式 → そのまま使用
   - 指定がない場合:
     - 変更内容から推奨バージョンを判定:
       - BREAKING CHANGEを含む → major推奨
       - feat:を含む → minor推奨
       - fix:のみ → patch推奨
     - ユーザーに確認（推奨を明示）

5. ファイル更新
   a. package.json
      - "version": "x.y.z" を新バージョンに更新

   b. CHANGELOG.md
      - 既存ファイルがあればフォーマットを検出
      - 新しいバージョンセクションを追加
      - コミットメッセージから変更内容を記載
      - Keep a Changelog形式の場合:
        - Added: 新機能（feat:）
        - Changed: 変更（refactor:, chore:）
        - Fixed: バグ修正（fix:）
        - Deprecated: 非推奨
        - Removed: 削除
        - Security: セキュリティ修正

   c. README.md（オプション）
      - バージョンバッジがある場合は更新
      - 新機能（feat:）が追加された場合:
        - 機能一覧セクションに追記
        - 使用例・サンプルコードの追加
      - 設定項目が変更された場合は設定セクションを更新
      - 破壊的変更（BREAKING CHANGE）がある場合:
        - 移行手順を追記
        - 注意事項を明記
      - 依存関係が変更された場合は要件セクションを更新

6. 結果表示
   - 更新したファイルの一覧
   - 変更内容のサマリー
   - 次のステップを案内:
     - git add .
     - git commit -m "chore: bump version to x.y.z"
     - git tag vx.y.z
     - git push && git push --tags

注意事項:
- VSCode拡張機能でない場合も警告を出しつつ続行可能
- CHANGELOGが存在しない場合はKeep a Changelog形式で新規作成
- コミット・タグ・プッシュは自動で行わない
- 変更がない場合（コミットがない場合）は警告を表示

例:
1. patchバージョンアップ:
   コマンド: /bump-version patch
   結果: 1.0.0 → 1.0.1

2. minorバージョンアップ:
   コマンド: /bump-version minor
   結果: 1.0.0 → 1.1.0

3. 具体的なバージョン指定:
   コマンド: /bump-version 2.0.0
   結果: 1.x.x → 2.0.0

4. 自動判定（対話形式）:
   コマンド: /bump-version
   結果: 変更内容を分析して推奨を表示、ユーザーに確認
