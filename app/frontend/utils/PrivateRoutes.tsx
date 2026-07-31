import { Navigate, Outlet } from 'react-router-dom'

import { useSession } from '@/contexts/AuthContext'

function PrivateRoutes() {
  const session = useSession()
  const isLoggedIn = !!session

  return isLoggedIn ? <Outlet /> : <Navigate to="/login" replace />
}

export default PrivateRoutes
