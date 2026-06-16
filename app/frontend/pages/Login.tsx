interface LoginProps {
  loginUrl: string | null
}

function Login({ loginUrl }: LoginProps) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}>
      <a href={loginUrl ?? '/login'}>Log in with EVE Online</a>
    </div>
  )
}

export default Login
