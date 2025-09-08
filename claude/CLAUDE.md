DBの値を確認する場合はMCPを利用してください
commandを実行する際はserver フォルダ or web フォルダに移動してから実行してください
tenantの情報が必要な場合はtenantKeyがmeetsmoreのテナントを利用してください
type-check
アロー関数を使ってください

# Hooks Files Removal Guideline

## Overview

This guideline outlines the initiative to remove separate 'hooks' files and integrate their functionality directly into component index files. This change aims to improve code quality, developer productivity, and overall codebase maintainability.

## Why Remove Hooks Files?

### 1. **TypeScript IntelliSense Performance**
- Hooks files significantly slow down TypeScript IntelliSense
- Type inference becomes complex when logic is separated across files
- This leads to decreased developer productivity

### 2. **Anti-Pattern**
- Separating component logic into hooks files is an established anti-pattern in React development
- It violates principles of component cohesion and clarity

### 3. **Hidden Issues**
- Hooks files can hide both development and performance issues
- Variables requiring API calls or heavy operations may be included in return objects but never used
- This creates unnecessary overhead and makes optimization difficult

### 4. **Code Organization**
- Hooks files artificially make components appear smaller than they actually are
- This disguises the true complexity of components
- Larger files should be broken into separate components rather than hiding complexity in hooks files

### 5. **Testability**
- Combined files are easier to test
- Component logic is more transparent and accessible for unit testing

### 6. **LLM Compatibility**
- Large Language Models are trained on well-structured, conventional code patterns
- Standard React patterns improve AI understanding and assistance

## Implementation Guidelines

### For New Components
- **Always** keep all component logic in the index file
- Do not create separate hooks files for new components

### For Existing Components

#### Small Components (≤ 300 lines)
- Combine hooks and index files immediately when working on them
- Move the `useHooks` function content directly into the component

#### Large Components (> 300 lines)
- Wait for dedicated tech-debt tasks
- These will be organized by module or feature owners
- This approach preserves git history for critical changes

### Migration Process

1. Identify the `useHooks` function (typically at the bottom of hooks files)
2. Copy the entire function body
3. Integrate it directly into the component's main function
4. Remove the hooks file import
5. Delete the hooks file

## Important Considerations

### Git History
- Large refactorings can make it difficult to track changes over time
- For files with 3+ years of history, careful consideration is needed
- Module/feature owners should handle these migrations

### Component Size
- If combining files results in overly large components, consider:
  - Breaking the component into smaller, focused components
  - Extracting reusable logic into utility functions (not hooks files)
  - Creating proper component composition patterns

## Example Migration

### Before
```typescript
// components/UserProfile/hooks.ts
export const useHooks = () => {
  const [user, setUser] = useState(null);
  const { data: userData } = useQuery('user');
  // ... more logic
  
  return { user, userData, setUser };
};

// components/UserProfile/index.tsx
import { useHooks } from './hooks';

export const UserProfile = () => {
  const { user, userData } = useHooks();
  
  return <div>{/* component JSX */}</div>;
};
```

### After
```typescript
// components/UserProfile/index.tsx
export const UserProfile = () => {
  const [user, setUser] = useState(null);
  const { data: userData } = useQuery('user');
  // ... more logic
  
  return <div>{/* component JSX */}</div>;
};
```

## Related Resources
- [SOLID for React Components](https://www.notion.so/meetsmore/SOLID-for-React-Components-21e1ff99692280818535c669d2dbebbf)