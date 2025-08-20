# MCP (Model Context Protocol) 共通設定

この設定は以下のエディタ/IDEで共有されます：
- Claude Code
- Cursor
- Roo Code
- その他のMCP対応エディタ

## 設定ファイルの場所

各エディタは以下の場所でMCP設定を探します：
- Claude Code: `~/.claude.json`
- Cursor: `~/.cursor/mcp.json`
- Roo Code: `~/.roo/mcp.json`

install.shスクリプトがこれらすべてにシンボリックリンクを作成します。

## APIキーの設定

`config.json`内の以下のプレースホルダーを実際のAPIキーに置き換えてください：
- `NOTION_API_KEY`: Notion API Key
- `FIGMA_ACCESS_TOKEN`: Figma Personal Access Token
- `EXCEL_FILES_PATH`: Excelファイルのパス

## PostgreSQL設定

デフォルトでローカルのPostgreSQLに接続します：
```
postgresql://meetsone:meetsone@localhost:5432/meetsone
```

必要に応じて接続文字列を変更してください。