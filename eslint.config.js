import tsParser from '@typescript-eslint/parser'
import simpleImportSort from 'eslint-plugin-simple-import-sort'

export default [
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: { parser: tsParser },
    plugins: { 'simple-import-sort': simpleImportSort },
    rules: {
      'simple-import-sort/imports': ['error', {
        groups: [
          ['^react$'],
          ['^@?\\w'],
          ['^@/'],
          ['^\\.'],
          ['^import type'],
          ['\\.module\\.css$'],
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
