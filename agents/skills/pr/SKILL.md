---
name: pr
description: Create a pull request for the current branch or specified branch
allowed-tools: Bash(git status:*), Bash(git checkout:*), Bash(gh pr create:*), Read, Write
---

指定されたブランチ（$ARGUMENTS）またはcurrentブランチからPull Requestを作成してください。
ブランチ名が指定されている場合は、そのブランチに切り替えてからPRを作成します。

手順:
1. $ARGUMENTSでブランチ名が指定されているか確認
   - 指定されている場合: そのブランチが存在するか確認 (git branch --list)
   - 存在する場合: git checkoutでそのブランチに切り替え
   - 存在しない場合: エラーメッセージを表示して終了
   - 指定されていない場合: 現在のブランチを使用
2. git statusで現在の状態を確認
3. 未コミットの変更がある場合は、コミットするか確認
4. 現在のブランチをリモートにプッシュ（まだプッシュされていない場合）
5. プロジェクトのPRテンプレートを確認:
   - .github/pull_request_template.md または .github/PULL_REQUEST_TEMPLATE.md を探す
   - .github/PULL_REQUEST_TEMPLATE/ ディレクトリ内のテンプレートも確認
6. テンプレートをコピーしてそこに追記する形でPRボディファイルを作成(/tmp/pr_body.md)
7. gh pr createコマンドを使用してPRを作成
   - bodyは--body-fileオプションを使用して作成したファイルを指定する
8. PRのURLを表示

注意事項:
- mainまたはmasterブランチからは直接PRを作成しない
- PRのタイトルは変更内容を簡潔に表現する
- PRのタイトルはブランチ名が"NONE-123"のようなチケット番号を含む場合は、チケット番号を[]で囲んだ[NONE-123]のようにするにして、その後ろに簡潔に変更内容を記載する
- チケット番号がない場合は[NO-TASK]とする
- プロジェクトのPRテンプレートがある場合は必ずそれを使用する
- PRの既存の内容は削除しないでください。
- PRのボディはテンプレートをコピーしてそこに追記する形で作成する
- チェックリストのチェックも忘れないでください
- draft PRを作成する
- tmp/pr_body.mdファイルは作成後に削除する

チェックリストのルール（必須）:
変更内容を分析して、以下のルールに従ってチェックリストをチェックしてください。

1. シンプルなPRの場合（以下のいずれかに該当）:
   - configファイルのみの変更
   - READMEやドキュメントのみの変更
   - 1-2ファイルの小さな修正
   - コメントやtypoの修正
   → `- [x] My pull request is simple, and does not need the quality checklist.` のみをチェック

2. それ以外のPRの場合:
   → 「My pull request is simple」はチェックせず、以下の全項目を `- [x]` でチェック:
   - Code has enough test coverage *for the amount of risk*.
   - Code has JSDoc.
   - Documentation is sufficient (can you understand it without context?).
   - No secrets, API keys, tokens, are hardcoded in the code.
   - Third party APIs integrations are configurable with environment variables.
   - New configuration/environment variables follow the guidelines.
   - Any added dependencies are up-to-date.
   - Endpoints are secured appropriately (e.g. with RBAC).
   - Shared resource performance (e.g. database) will not be negatively impacted.
   - Logging and observability is included, such that failures can be easily debugged.
   - LaunchDarkly flags are included for risky features so they can be enabled / disabled quickly.

例：
1. 現在のブランチからPR作成:
   コマンド: /pr
   結果: 現在のブランチからPRが作成される

2. 指定したブランチからPR作成:
   コマンド: /pr <ブランチ名>
   結果: <ブランチ名> ブランチに切り替えてPRが作成される
   PRのタイトル: [NONE-123] 簡単な変更内容
