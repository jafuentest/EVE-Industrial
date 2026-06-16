import React, { useEffect, useState } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import AppShell from './AppShell'
import PrivateRoutes from './utils/PrivateRoutes'
import type { Session } from './types'

// Pages
import Dashboard from './pages/Dashboard'
import Login from './pages/Login'

function App() {
  const [session, setSession] = useState<Session | null>(null)
  const [loginUrl, setLoginUrl] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/session', { credentials: 'same-origin' })
      .then(res => res.json().then(data => ({ ok: res.ok, data })))
      .then(({ ok, data }) => {
        if (ok) {
          setSession(data)
        } else {
          setLoginUrl(data.login_url)
        }
        setLoading(false)
      })
      .catch(() => setLoading(false))
  }, [])

  if (loading) return null

  return (
    <BrowserRouter>
      <AppShell session={session}>
        <Routes>
          <Route element={<PrivateRoutes session={session} />}>
            <Route path='/' element={<Dashboard session={session!} />} />
          </Route>
          <Route path='/login' element={<Login loginUrl={loginUrl} />} />
          <Route path='*' element={<Navigate to='/' replace />} />
        </Routes>
      </AppShell>
    </BrowserRouter>
  )
}

export default App
