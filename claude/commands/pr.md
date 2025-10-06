---
description: "Create a pull request for the current branch or specified branch"
allowed-tools: ["Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)", "Bash(git add:*)", "Bash(git commit:*)", "Bash(git push:*)", "Bash(gh pr create:*)", "Bash(ls:*)", "Bash(cat:*)", "Bash(rm /tmp/pr_body.md)", "Bash(git checkout:*)", "Bash(git branch:*)", "Bash(git branch --list:*)", "Bash(git rev-parse:*)", "Read", "Write(/tmp/pr_body.md)"]
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

例：
1. 現在のブランチからPR作成:
   コマンド: /pr
   結果: 現在のブランチからPRが作成される

2. 指定したブランチからPR作成:
   コマンド: /pr yoshiki/NONE-123
   結果: yoshiki/NONE-123 ブランチに切り替えてPRが作成される
   PRのタイトル: [NONE-123] 簡単な変更内容
