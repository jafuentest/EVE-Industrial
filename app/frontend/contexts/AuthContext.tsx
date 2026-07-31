import { createContext, useContext } from 'react'

import type { Session } from '@/types'

interface AuthContextValue {
  session: Session | null
  logout: () => void
}

export const AuthContext = createContext<AuthContextValue | null>(null)

function useAuth(): AuthContextValue {
  const value = useContext(AuthContext)
  if (value === null)
    throw new Error('useAuth called outside AuthContext.Provider')

  return value
}

export function useLogout(): () => void {
  return useAuth().logout
}

export function useRequiredSession(): Session {
  const { session } = useAuth()
  if (!session)
    throw new Error('useRequiredSession called outside an authenticated route')

  return session
}

export function useSession(): Session | null {
  return useAuth().session
}
