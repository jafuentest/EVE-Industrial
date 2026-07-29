import { useCallback, useEffect, useMemo, useState } from 'react'

import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'

import { AuthContext } from '@/contexts/AuthContext'
import AppShell from '@/layouts/AppShell'
import Dashboard from '@/pages/Dashboard'
import Login from '@/pages/Login'
import type { Session } from '@/types'
import csrfToken from '@/utils/csrfToken'
import { fetchJsonWithStatus } from '@/utils/fetchJson'
import PrivateRoutes from '@/utils/PrivateRoutes'

function App() {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  const handleLogout = useCallback(() => {
    fetchJsonWithStatus('/api/session', {
      method: 'DELETE',
      credentials: 'same-origin',
      headers: { 'X-CSRF-Token': csrfToken() },
    })
      .then(({ status }) => {
        if (status === 200)
          setSession(null)
        else
          throw new Error(`Failed to log out: ${status}`)
      })
      .catch(error => { console.error('Error logging out:', error) })
  }, [])

  const auth = useMemo(() => ({ session, logout: handleLogout }), [session, handleLogout])

  useEffect(() => {
    fetchJsonWithStatus<Session>('/api/session', { credentials: 'same-origin' })
      .then(({ status, data }) => {
        if (status === 200)
          setSession(data)

        setLoading(false)
      })
      .catch((e) => {
        setLoading(false)
        console.error('Error fetching session data', e)
      })
  }, [])

  if (loading) return null

  return (
    <BrowserRouter future={{
      v7_relativeSplatPath: true,
      v7_startTransition: true
    }}>
      <AuthContext.Provider value={auth}>
        <AppShell>
          <Routes>
            <Route element={<PrivateRoutes/>}>
              <Route path='/' element={<Navigate to='/dashboard' replace />} />
              <Route path='/dashboard' element={<Dashboard/>} />
            </Route>
            <Route path='/login' element={<Login/>} />
            <Route path='*' element={<Navigate to='/' replace />} />
          </Routes>
        </AppShell>
      </AuthContext.Provider>
    </BrowserRouter>
  )
}

export default App
