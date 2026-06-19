import { Outlet, Navigate } from 'react-router-dom'
import type { Session } from '@/types'

interface PrivateRoutesProps {
  session: Session | null
}

const PrivateRoutes = ({ session }: PrivateRoutesProps) => {
  const isLoggedIn = !!session
  return isLoggedIn ? <Outlet /> : <Navigate to="/login" replace />
}

export default PrivateRoutes
