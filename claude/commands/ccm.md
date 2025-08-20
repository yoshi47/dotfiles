meetsoneのコードベースから $ARGUMENTS を削除してください。
削除する前に使用されている箇所がないかを確認してください。
flagの場合、常にtrueとなるような実装にしてください。

手順
1. 変更を実施
2. yarn type-checkを実行して、$ARGUMENTS が使用されていないことを確認
3. 変更をコミット
4. origin/masterをfetch
5. origin/masterから新しいブランチを作成
6. ブランチ名は内容を簡単に表すものにしてください。既存のブランチと重複しないようにしてください。remoteは設定しないでください。
7. cherry-pick 作成したcommitを新しいブランチに適用
8. yoshiki/choreブランチに戻る
9. yoshiki/choreをmasterにrebaseする