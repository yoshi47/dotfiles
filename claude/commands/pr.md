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
5. gh pr createコマンドを使用してPRを作成:
   - PRテンプレートが存在する場合は、そのテンプレートを使用してPRボディを作成
   - テンプレートがない場合は、ブランチのコミット内容から適切に作成
6. PRのURLを表示

注意事項:
- mainまたはmasterブランチからは直接PRを作成しない
- PRのタイトルは変更内容を簡潔に表現する
- プロジェクトのPRテンプレートがある場合は必ずそれを使用する
- PRのボディには変更内容の詳細を記載する