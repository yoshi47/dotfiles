---
description: Create a new branch from latest master with the specified commit(s)
allowed-tools: ["Bash(git fetch:*)", "Bash(git checkout:*)", "Bash(git cherry-pick:*)", "Bash(git show:*)", "Bash(git log:*)", "Bash(git branch:*)", "Bash(git cat-file:*)", "Bash(ls:*)"]
---

指定されたcommit hash(es) ($ARGUMENTS) を最新のmasterブランチからcherry-pickして新しいブランチを作成してください。
複数のcommit hashをスペース区切りで指定できます。

手順:
1. commit hash(es) ($ARGUMENTS) が指定されているか確認
   - 指定されていない場合はエラーメッセージを表示して終了
   - $ARGUMENTSをスペース区切りで分割してcommit hashのリストを取得
2. origin/masterをfetch
3. 指定された全てのcommit hashが存在するか確認 (git cat-file -t または git show)
   - 存在しないcommitがある場合はエラーメッセージを表示して終了
4. git showで全てのcommit情報を表示して、内容を確認
5. ブランチ名を生成:
   - 最初のcommitメッセージから適切なブランチ名を生成
   - 複数commitの場合は全体を表すわかりやすい名前を生成
   - フォーマット: {user-name}/{commit-summary}
   - 既存のブランチと重複しないか確認 (git branch --list)
   - 重複する場合は数字を付加 (例: {user-name}/{commit-summary}-2)
6. origin/masterから新しいブランチを作成 (git checkout -b {branch-name} origin/master)
7. cherry-pickで指定された全てのcommitを順番に適用 (git cherry-pick {commit-hash1} {commit-hash2} ...)
   - 複数のcommitがある場合は一度に全てcherry-pickする
   - コンフリクトが発生した場合は状況を表示して中断
8. 適用されたcommitの数とブランチ名を表示

注意事項:
- commit hashは完全なハッシュまたは短縮形どちらでも可
- 複数のcommit hashはスペース区切りで指定
- ブランチ名はcommitメッセージから自動生成し、わかりやすい名前にする
- ブランチはリモートにpushしない（ローカルのみ）
- cherry-pickでコンフリクトが発生した場合は、ユーザーに解決方法を案内
- masterブランチまたはmainブランチの最新を基準にする
- 複数commitの場合、古い順にcherry-pickする

例:
1. 単一commit:
   コマンド: /branch-from-commit abc1234
   結果: {user-name}/fix-user-validation ブランチが作成され、abc1234がcherry-pickされる

2. 複数commits:
   コマンド: /branch-from-commit abc1234 def5678 ghi9012
   結果: {user-name}/update-authentication ブランチが作成され、3つのcommitがcherry-pickされる
