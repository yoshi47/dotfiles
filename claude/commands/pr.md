---
description: "Create a pull request for the current branch"
allowed-tools: ["Bash"]
---

現在のブランチからPull Requestを作成してください。

手順:
1. git statusで現在の状態を確認
2. 未コミットの変更がある場合は、コミットするか確認
3. 現在のブランチをリモートにプッシュ（まだプッシュされていない場合）
4. プロジェクトのPRテンプレートを確認:
   - .github/pull_request_template.md または .github/PULL_REQUEST_TEMPLATE.md を探す
   - .github/PULL_REQUEST_TEMPLATE/ ディレクトリ内のテンプレートも確認
5. テンプレートをコピーしてそこに追記する形でPRボディファイルを作成(/tmp/pr_body.md)
6. gh pr createコマンドを使用してPRを作成
   - bodyは--body-fileオプションを使用して作成したファイルを指定する
7. PRのURLを表示

注意事項:
- mainまたはmasterブランチからは直接PRを作成しない
- PRのタイトルは変更内容を簡潔に表現する
- PRのタイトルはブランチ名が"NONE-123"のようなチケット番号を含む場合は、チケット番号を[]で囲んだ[NONE-123]のようにするにして、その後ろに簡潔に変更内容を記載する
- チケット番号がない場合は[NO-TASK]とする
- プロジェクトのPRテンプレートがある場合は必ずそれを使用する
- PRの既存の内容は削除しないでください。
- PRのボディはテンプレートをコピーしてそこに追記する形で作成する
- draft PRを作成する
- tmp/pr_body.mdファイルは作成後に削除する

例：
- ブランチ名: yoshiki/NONE-123
- PRのタイトル: [NONE-123] 簡単な変更内容
