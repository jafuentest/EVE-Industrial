import React, { useEffect, useState } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'

function App() {
  const [session, setSession] = useState(null)
  const [loginUrl, setLoginUrl] = useState(null)
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

  if (!session) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}>
        <a href={loginUrl ?? '/login'}>Log in with EVE Online</a>
      </div>
    )
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<div>EVE Industrial — logged in as {session.user?.character_name}</div>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
