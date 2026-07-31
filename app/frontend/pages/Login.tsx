import { useEffect, useState } from 'react'

import loginBtn from '@/assets/eve-sso-login-black-large.png'
import { fetchJsonWithStatus } from '@/utils/fetchJson'

import styles from './Login.module.css'

function Login() {
  const [loginUrl, setLoginUrl] = useState<string | null>(null)

  useEffect(() => {
    fetchJsonWithStatus<{ loginUrl: string }>('/api/session', { credentials: 'same-origin' })
      .then(({ status, data }) => {
        if (status === 200)
          window.location.href = '/dashboard'
        else
          setLoginUrl(data.loginUrl)
      })
      .catch((e) => { console.error('Error fetching session data', e) })
  }, [])

  return (
    <div className={styles.container}>
      <a href={loginUrl ?? '/login'}>
        <img src={loginBtn} alt="Log in with EVE Online" />
      </a>
    </div>
  )
}

export default Login
