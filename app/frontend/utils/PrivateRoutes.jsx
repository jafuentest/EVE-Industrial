import { Outlet, Navigate } from 'react-router-dom';

const PrivateRoutes = ({ session }) => {
  const isLoggedIn = !!session;
  return isLoggedIn ? <Outlet /> : <Navigate to='/login' replace />;
};

export default PrivateRoutes;
