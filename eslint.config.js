import tsParser from '@typescript-eslint/parser'
import reactHooks from 'eslint-plugin-react-hooks'
import simpleImportSort from 'eslint-plugin-simple-import-sort'

export default [
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: { parser: tsParser },
    plugins: { 'simple-import-sort': simpleImportSort, 'react-hooks': reactHooks },
    rules: {
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'error',
      'simple-import-sort/imports': ['error', {
        groups: [
          ['^\\u0000'],          // side effects
          ['^react'],            // react related packages
          ['^@?\\w'],            // other packages
          ['^@/'],               // internal aliases
          ['^\\.'],              // relative
          ['\\.module\\.css$'],  // styles
        ],
      }],
      'simple-import-sort/exports': 'error',
      'no-restricted-imports': ['error', {
        patterns: [
          { group: ['../*'], message: 'Use the @/ alias instead of parent-relative paths.' },
          { group: ['./*/*'], message: 'Relative imports are for same-directory siblings only — use @/.' },
        ],
      }],
    },
  },
]
