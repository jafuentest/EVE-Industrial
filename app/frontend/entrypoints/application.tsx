import React from 'react'
import { createRoot } from 'react-dom/client'
import App from '@/App'
import '@/styles/app.css'

const container = document.getElementById('app')
if (!container) throw new Error('Missing #app element')

const root = createRoot(container)
root.render(<App />)
