import { useLocation } from 'react-router-dom'

import { Bell, RefreshCw } from 'lucide-react'

import Button from '@/components/Button'
import ButtonIcon from '@/components/ButtonIcon'
import { useSession } from '@/contexts/AuthContext'
import formatIsk from '@/utils/formatIsk'

import styles from './TopBar.module.css'

interface TopBarProps {
  onSyncEsi: () => void
  walletBalance: number
}

const TITLES: Record<string, { title: string; subtitle: string }> = {
  '/login': { title: 'Login', subtitle: 'auth' },
  '/dashboard': { title: 'Dashboard', subtitle: 'overview' },
  '/industry': { title: 'Industry Jobs', subtitle: 'industry' },
  '/market': { title: 'Market Orders', subtitle: 'market'},
  '/colonies': { title: 'Planetary Colonies', subtitle: 'planetary interaction'},
  '/commodities': { title: 'Planetary Commodities', subtitle: 'planetary interaction'},
}

function TopBar({ walletBalance, onSyncEsi }: TopBarProps) {
  const { pathname } = useLocation()
  const title = TITLES[pathname]?.title || ''
  const subtitle = TITLES[pathname]?.subtitle || ''
  const session = useSession()

  return (
    <header className={styles.container}>
      <div className={styles.title}>
        <span className={styles.titleSubtitle}>{subtitle}</span>
        <h1 className={styles.titleHeading}>{title}</h1>
      </div>
      {session && (
        <div className={styles.rightSide}>
          <div className={styles.walletInfo}>
            <span className={styles.walletLabel}>wallet</span>
            <div className={styles.walletRow}>
              <span className={styles.amount}>{formatIsk(walletBalance)}</span>
              <span className={styles.currency}>ISK</span>
            </div>
          </div>
          <span className={styles.separator}></span>
          <div style={{ display: 'none' }}>
            <ButtonIcon aria-label="Notifications">
              <Bell width={17} height={17} />
            </ButtonIcon>
          </div>
          <Button onClick={onSyncEsi} size='sm' variant='primary'>
            <RefreshCw width={12} height={15} />
            Sync ESI
          </Button>
        </div>
      )}
    </header>
  )
}

export default TopBar
